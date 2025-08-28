-- Location: supabase/migrations/20250827183412_product_selection_commission_system.sql
-- Schema Analysis: Existing auction platform with auction_items, user_profiles, categories, credit_transactions
-- Integration Type: Addition - Product inventory system for content creators with credit tiers and commission tracking
-- Dependencies: user_profiles, auction_items, categories, credit_transactions

-- 1. ENUMS AND TYPES
CREATE TYPE public.creator_tier AS ENUM ('bronze', 'silver', 'gold', 'platinum');
CREATE TYPE public.product_availability AS ENUM ('available', 'reserved', 'unavailable', 'featured');
CREATE TYPE public.commission_status AS ENUM ('pending', 'processing', 'paid', 'cancelled');

-- 2. CREATOR TIERS TABLE
CREATE TABLE public.creator_tiers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tier_name public.creator_tier UNIQUE NOT NULL,
    min_credit_requirement INTEGER NOT NULL DEFAULT 0,
    max_credit_requirement INTEGER,
    commission_rate DECIMAL(3,2) NOT NULL DEFAULT 0.10, -- 10% default
    tier_benefits JSONB DEFAULT '{}'::JSONB,
    tier_color TEXT DEFAULT '#CCCCCC',
    tier_description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. PRODUCT INVENTORY TABLE
CREATE TABLE public.product_inventory (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    starting_price INTEGER NOT NULL,
    reserve_price INTEGER,
    retail_value INTEGER NOT NULL,
    min_credit_requirement INTEGER DEFAULT 0,
    required_tier public.creator_tier DEFAULT 'bronze'::public.creator_tier,
    images JSONB DEFAULT '[]'::JSONB,
    specifications JSONB DEFAULT '{}'::JSONB,
    brand TEXT,
    model TEXT,
    condition TEXT DEFAULT 'New',
    availability_status public.product_availability DEFAULT 'available'::public.product_availability,
    estimated_duration_hours INTEGER DEFAULT 24,
    historical_performance JSONB DEFAULT '{}'::JSONB,
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    is_featured BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. PRODUCT SELECTIONS TABLE (tracks what creators selected)
CREATE TABLE public.product_selections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    product_inventory_id UUID REFERENCES public.product_inventory(id) ON DELETE CASCADE,
    auction_item_id UUID REFERENCES public.auction_items(id) ON DELETE SET NULL,
    selected_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    scheduled_start_time TIMESTAMPTZ,
    estimated_end_time TIMESTAMPTZ,
    selection_notes TEXT,
    creator_tier_at_selection public.creator_tier,
    credit_balance_at_selection INTEGER DEFAULT 0,
    commission_rate DECIMAL(3,2) NOT NULL DEFAULT 0.10,
    status TEXT DEFAULT 'selected', -- 'selected', 'live', 'completed', 'cancelled'
    UNIQUE(product_inventory_id, creator_id, selected_at)
);

-- 5. COMMISSION TRACKING TABLE (enhanced credit_transactions)
CREATE TABLE public.commission_earnings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    auction_item_id UUID REFERENCES public.auction_items(id) ON DELETE CASCADE,
    product_selection_id UUID REFERENCES public.product_selections(id) ON DELETE SET NULL,
    final_sale_price INTEGER NOT NULL,
    commission_rate DECIMAL(3,2) NOT NULL DEFAULT 0.10,
    commission_amount INTEGER NOT NULL,
    commission_status public.commission_status DEFAULT 'pending'::public.commission_status,
    payment_reference TEXT,
    earned_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMPTZ,
    paid_at TIMESTAMPTZ,
    notes TEXT
);

-- 6. TIER QUALIFICATION TRACKING
CREATE TABLE public.creator_tier_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    previous_tier public.creator_tier,
    new_tier public.creator_tier NOT NULL,
    credit_balance_at_change INTEGER,
    change_reason TEXT,
    changed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. INDEXES FOR PERFORMANCE
CREATE INDEX idx_creator_tiers_tier_name ON public.creator_tiers(tier_name);
CREATE INDEX idx_product_inventory_category_id ON public.product_inventory(category_id);
CREATE INDEX idx_product_inventory_min_credit ON public.product_inventory(min_credit_requirement);
CREATE INDEX idx_product_inventory_required_tier ON public.product_inventory(required_tier);
CREATE INDEX idx_product_inventory_availability ON public.product_inventory(availability_status);
CREATE INDEX idx_product_selections_creator_id ON public.product_selections(creator_id);
CREATE INDEX idx_product_selections_product_inventory_id ON public.product_selections(product_inventory_id);
CREATE INDEX idx_commission_earnings_creator_id ON public.commission_earnings(creator_id);
CREATE INDEX idx_commission_earnings_status ON public.commission_earnings(commission_status);
CREATE INDEX idx_creator_tier_history_creator_id ON public.creator_tier_history(creator_id);

-- 8. FUNCTIONS FOR TIER MANAGEMENT AND COMMISSION CALCULATION
CREATE OR REPLACE FUNCTION public.calculate_creator_tier(credit_balance INTEGER)
RETURNS public.creator_tier
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT tier_name
FROM public.creator_tiers
WHERE credit_balance >= min_credit_requirement
  AND (max_credit_requirement IS NULL OR credit_balance <= max_credit_requirement)
  AND is_active = true
ORDER BY min_credit_requirement DESC
LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.get_available_products_for_creator(creator_user_id UUID)
RETURNS TABLE(
    id UUID,
    title TEXT,
    starting_price INTEGER,
    retail_value INTEGER,
    commission_potential INTEGER,
    category_name TEXT,
    required_tier public.creator_tier,
    is_accessible BOOLEAN
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
WITH creator_info AS (
    SELECT 
        up.credit_balance,
        public.calculate_creator_tier(up.credit_balance) as current_tier
    FROM public.user_profiles up
    WHERE up.id = creator_user_id
)
SELECT 
    pi.id,
    pi.title,
    pi.starting_price,
    pi.retail_value,
    (pi.retail_value * 0.10)::INTEGER as commission_potential,
    c.name as category_name,
    pi.required_tier,
    CASE 
        WHEN ci.credit_balance >= pi.min_credit_requirement 
        AND ci.current_tier >= pi.required_tier THEN true
        ELSE false
    END as is_accessible
FROM public.product_inventory pi
LEFT JOIN public.categories c ON pi.category_id = c.id
CROSS JOIN creator_info ci
WHERE pi.is_active = true 
  AND pi.availability_status = 'available'::public.product_availability
ORDER BY pi.is_featured DESC, pi.retail_value DESC;
$$;

CREATE OR REPLACE FUNCTION public.calculate_commission(sale_price INTEGER, commission_rate DECIMAL DEFAULT 0.10)
RETURNS INTEGER
LANGUAGE sql
IMMUTABLE
SECURITY DEFINER
AS $$
SELECT (sale_price * commission_rate)::INTEGER;
$$;

CREATE OR REPLACE FUNCTION public.update_creator_tier()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    current_tier public.creator_tier;
    new_tier public.creator_tier;
BEGIN
    -- Get current tier from user profile or calculate from credit balance
    current_tier := public.calculate_creator_tier(OLD.credit_balance);
    new_tier := public.calculate_creator_tier(NEW.credit_balance);
    
    -- If tier changed, log the change
    IF current_tier != new_tier THEN
        INSERT INTO public.creator_tier_history (
            creator_id, 
            previous_tier, 
            new_tier, 
            credit_balance_at_change, 
            change_reason
        )
        VALUES (
            NEW.id, 
            current_tier, 
            new_tier, 
            NEW.credit_balance, 
            'Credit balance change'
        );
    END IF;
    
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.process_auction_commission()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    selection_record RECORD;
    commission_amt INTEGER;
BEGIN
    -- Find the product selection for this auction
    SELECT ps.*, pi.retail_value 
    INTO selection_record
    FROM public.product_selections ps
    JOIN public.product_inventory pi ON ps.product_inventory_id = pi.id
    WHERE ps.auction_item_id = NEW.id;
    
    -- If this auction was created from product selection and has a winner
    IF selection_record IS NOT NULL AND NEW.winner_id IS NOT NULL THEN
        commission_amt := public.calculate_commission(
            COALESCE(NEW.current_highest_bid, NEW.starting_price), 
            selection_record.commission_rate
        );
        
        -- Create commission earning record
        INSERT INTO public.commission_earnings (
            creator_id,
            auction_item_id,
            product_selection_id,
            final_sale_price,
            commission_rate,
            commission_amount,
            commission_status
        ) VALUES (
            selection_record.creator_id,
            NEW.id,
            selection_record.id,
            COALESCE(NEW.current_highest_bid, NEW.starting_price),
            selection_record.commission_rate,
            commission_amt,
            'pending'::public.commission_status
        );
        
        -- Add commission to creator's credit balance
        UPDATE public.user_profiles 
        SET credit_balance = credit_balance + commission_amt
        WHERE id = selection_record.creator_id;
        
        -- Log the transaction
        INSERT INTO public.credit_transactions (
            user_id,
            amount,
            transaction_type,
            related_auction_id,
            description,
            payment_status
        ) VALUES (
            selection_record.creator_id,
            commission_amt,
            'auction_won'::public.transaction_type,
            NEW.id,
            'Commission earned from auction: ' || NEW.title,
            'completed'::public.payment_status
        );
    END IF;
    
    RETURN NEW;
END;
$$;

-- 9. ENABLE RLS
ALTER TABLE public.creator_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_selections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commission_earnings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.creator_tier_history ENABLE ROW LEVEL SECURITY;

-- 10. RLS POLICIES
CREATE POLICY "public_can_read_creator_tiers"
ON public.creator_tiers
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "admin_manage_creator_tiers"
ON public.creator_tiers
FOR ALL
TO authenticated
USING (has_admin_role())
WITH CHECK (has_admin_role());

CREATE POLICY "public_can_read_product_inventory"
ON public.product_inventory
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "admin_manage_product_inventory"
ON public.product_inventory
FOR ALL
TO authenticated
USING (has_admin_role())
WITH CHECK (has_admin_role());

CREATE POLICY "creators_manage_own_product_selections"
ON public.product_selections
FOR ALL
TO authenticated
USING (creator_id = auth.uid())
WITH CHECK (creator_id = auth.uid());

CREATE POLICY "admin_full_access_product_selections"
ON public.product_selections
FOR ALL
TO authenticated
USING (has_admin_role())
WITH CHECK (has_admin_role());

CREATE POLICY "creators_manage_own_commission_earnings"
ON public.commission_earnings
FOR ALL
TO authenticated
USING (creator_id = auth.uid())
WITH CHECK (creator_id = auth.uid());

CREATE POLICY "admin_full_access_commission_earnings"
ON public.commission_earnings
FOR ALL
TO authenticated
USING (has_admin_role())
WITH CHECK (has_admin_role());

CREATE POLICY "users_view_own_tier_history"
ON public.creator_tier_history
FOR SELECT
TO authenticated
USING (creator_id = auth.uid());

CREATE POLICY "admin_full_access_tier_history"
ON public.creator_tier_history
FOR ALL
TO authenticated
USING (has_admin_role())
WITH CHECK (has_admin_role());

-- 11. TRIGGERS
CREATE TRIGGER update_creator_tiers_updated_at
    BEFORE UPDATE ON public.creator_tiers
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_product_inventory_updated_at
    BEFORE UPDATE ON public.product_inventory
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_creator_tier_on_credit_change
    AFTER UPDATE ON public.user_profiles
    FOR EACH ROW 
    WHEN (OLD.credit_balance != NEW.credit_balance)
    EXECUTE FUNCTION public.update_creator_tier();

CREATE TRIGGER process_commission_on_auction_end
    AFTER UPDATE ON public.auction_items
    FOR EACH ROW 
    WHEN (OLD.status != 'ended'::auction_status AND NEW.status = 'ended'::auction_status)
    EXECUTE FUNCTION public.process_auction_commission();

-- 12. INSERT INITIAL TIER DATA
INSERT INTO public.creator_tiers (tier_name, min_credit_requirement, max_credit_requirement, commission_rate, tier_benefits, tier_color, tier_description) VALUES
    ('bronze'::public.creator_tier, 0, 9999, 0.08, 
     '{"max_products": 5, "features": ["basic_analytics", "standard_support"]}'::JSONB, 
     '#CD7F32', 'Entry level for new content creators'),
    ('silver'::public.creator_tier, 10000, 49999, 0.10, 
     '{"max_products": 15, "features": ["advanced_analytics", "priority_support", "featured_placement"]}'::JSONB, 
     '#C0C0C0', 'Intermediate tier with enhanced features'),
    ('gold'::public.creator_tier, 50000, 199999, 0.12, 
     '{"max_products": 50, "features": ["premium_analytics", "dedicated_support", "premium_products", "early_access"]}'::JSONB, 
     '#FFD700', 'High-tier creators with premium access'),
    ('platinum'::public.creator_tier, 200000, NULL, 0.15, 
     '{"max_products": null, "features": ["full_analytics", "vip_support", "exclusive_products", "custom_campaigns", "revenue_sharing"]}'::JSONB, 
     '#E5E4E2', 'Elite tier for top-performing creators');

-- 13. MOCK PRODUCT INVENTORY DATA
DO $$
DECLARE
    electronics_cat_id UUID;
    fashion_cat_id UUID;
    admin_user_id UUID;
BEGIN
    -- Get category IDs
    SELECT id INTO electronics_cat_id FROM public.categories WHERE name ILIKE '%electron%' LIMIT 1;
    SELECT id INTO fashion_cat_id FROM public.categories WHERE name ILIKE '%fashion%' OR name ILIKE '%cloth%' LIMIT 1;
    SELECT id INTO admin_user_id FROM public.user_profiles WHERE role = 'admin'::public.user_role LIMIT 1;
    
    -- Insert sample products for different tiers
    INSERT INTO public.product_inventory (
        title, description, category_id, starting_price, reserve_price, retail_value, 
        min_credit_requirement, required_tier, images, specifications, brand, model, 
        condition, availability_status, is_featured, created_by
    ) VALUES 
        ('iPhone 15 Pro Max - 256GB', 
         'Latest flagship smartphone with professional camera system and titanium build',
         electronics_cat_id, 80000, 90000, 120000,
         0, 'bronze'::public.creator_tier,
         '["https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=800", "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800"]'::JSONB,
         '{"storage": "256GB", "color": "Natural Titanium", "warranty": "1 Year Apple Warranty"}'::JSONB,
         'Apple', 'iPhone 15 Pro Max', 'New', 'available'::public.product_availability, true, admin_user_id),
         
        ('MacBook Pro 16" M3', 
         'Powerful laptop for content creation with M3 chip and stunning Retina display',
         electronics_cat_id, 180000, 200000, 280000,
         25000, 'silver'::public.creator_tier,
         '["https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800", "https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=800"]'::JSONB,
         '{"processor": "M3 Pro", "ram": "18GB", "storage": "512GB SSD", "display": "16.2-inch Retina"}'::JSONB,
         'Apple', 'MacBook Pro', 'New', 'available'::public.product_availability, true, admin_user_id),
         
        ('Rolex Submariner Watch', 
         'Luxury Swiss watch, iconic diving watch with exceptional craftsmanship',
         fashion_cat_id, 500000, 600000, 800000,
         100000, 'gold'::public.creator_tier,
         '["https://images.unsplash.com/photo-1609081219090-a6d81d3085bf?w=800", "https://images.unsplash.com/photo-1434056886845-dac89ffe9b56?w=800"]'::JSONB,
         '{"case_material": "Stainless Steel", "movement": "Automatic", "water_resistance": "300m", "warranty": "5 Years"}'::JSONB,
         'Rolex', 'Submariner', 'Excellent', 'available'::public.product_availability, true, admin_user_id),
         
        ('Limited Edition Ferrari Model Collection', 
         'Exclusive collector series featuring rare Ferrari models with certificates of authenticity',
         NULL, 1000000, 1200000, 1500000,
         200000, 'platinum'::public.creator_tier,
         '["https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=800", "https://images.unsplash.com/photo-1614200179396-2bdb77ebf81b?w=800"]'::JSONB,
         '{"edition": "Limited Edition", "pieces": 3, "certificates": true, "display_case": "Premium Glass Case"}'::JSONB,
         'Ferrari', 'Collector Series', 'Mint', 'available'::public.product_availability, true, admin_user_id),
         
        ('Samsung Galaxy S24 Ultra', 
         'Premium Android smartphone with S Pen and professional camera capabilities',
         electronics_cat_id, 60000, 70000, 95000,
         5000, 'bronze'::public.creator_tier,
         '["https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?w=800", "https://images.unsplash.com/photo-1598300042247-d088f8ab3a91?w=800"]'::JSONB,
         '{"storage": "256GB", "ram": "12GB", "display": "6.8-inch Dynamic AMOLED", "s_pen": true}'::JSONB,
         'Samsung', 'Galaxy S24 Ultra', 'New', 'available'::product_availability, false, admin_user_id),
         
        ('Canon EOS R5 Camera Kit', 
         'Professional mirrorless camera with lens kit for content creators',
         electronics_cat_id, 220000, 250000, 350000,
         40000, 'silver'::public.creator_tier,
         '["https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800", "https://images.unsplash.com/photo-1618172193622-ae2d025f4032?w=800"]'::JSONB,
         '{"resolution": "45MP", "video": "8K RAW", "lens": "24-105mm f/4L", "accessories": "Battery Grip, Extra Batteries"}'::JSONB,
         'Canon', 'EOS R5', 'New', 'available'::product_availability, true, admin_user_id);

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock product inventory insertion failed: %', SQLERRM;
END $$;