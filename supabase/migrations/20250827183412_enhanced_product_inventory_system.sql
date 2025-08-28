-- Location: supabase/migrations/20250827183412_enhanced_product_inventory_system.sql
-- Schema Analysis: Extending existing auction system with system-owned inventory
-- Integration Type: Enhancement - adding new tables for product management
-- Dependencies: auction_items, user_profiles, categories, credit_transactions

-- Step 1: Create new types
CREATE TYPE public.product_tier AS ENUM ('bronze', 'silver', 'gold', 'platinum');
CREATE TYPE public.commission_status AS ENUM ('pending', 'processing', 'paid', 'cancelled');

-- Step 2: System products inventory table (admin-managed products)
CREATE TABLE public.system_products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    brand TEXT,
    model TEXT,
    condition TEXT DEFAULT 'new',
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    images JSONB DEFAULT '[]'::jsonb,
    specifications JSONB,
    retail_value INTEGER NOT NULL, -- in cents
    starting_price INTEGER NOT NULL, -- in cents
    reserve_price INTEGER,
    tier_requirement public.product_tier NOT NULL DEFAULT 'bronze'::public.product_tier,
    min_credit_balance INTEGER NOT NULL DEFAULT 0,
    is_available BOOLEAN DEFAULT true,
    featured BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Step 3: Product tier mapping table
CREATE TABLE public.product_tier_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tier public.product_tier NOT NULL UNIQUE,
    min_credit_balance INTEGER NOT NULL,
    max_credit_balance INTEGER,
    commission_rate DECIMAL(5,2) DEFAULT 10.00, -- 10% default
    description TEXT,
    benefits JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Step 4: Commission tracking table
CREATE TABLE public.creator_commissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    creator_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    auction_item_id UUID REFERENCES public.auction_items(id) ON DELETE CASCADE,
    system_product_id UUID REFERENCES public.system_products(id) ON DELETE SET NULL,
    commission_rate DECIMAL(5,2) NOT NULL,
    sale_amount INTEGER, -- final sale amount in cents
    commission_amount INTEGER, -- calculated commission in cents
    status public.commission_status DEFAULT 'pending'::public.commission_status,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMPTZ,
    paid_at TIMESTAMPTZ,
    payment_reference TEXT
);

-- Step 5: Stream product selection tracking
CREATE TABLE public.stream_product_selections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stream_id UUID REFERENCES public.live_streams(id) ON DELETE CASCADE,
    system_product_id UUID REFERENCES public.system_products(id) ON DELETE CASCADE,
    creator_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    selected_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(stream_id, system_product_id)
);

-- Step 6: Create indexes for better performance
CREATE INDEX idx_system_products_category_id ON public.system_products(category_id);
CREATE INDEX idx_system_products_tier ON public.system_products(tier_requirement);
CREATE INDEX idx_system_products_available ON public.system_products(is_available);
CREATE INDEX idx_system_products_featured ON public.system_products(featured);
CREATE INDEX idx_system_products_credit_balance ON public.system_products(min_credit_balance);

CREATE INDEX idx_creator_commissions_creator_id ON public.creator_commissions(creator_id);
CREATE INDEX idx_creator_commissions_auction_id ON public.creator_commissions(auction_item_id);
CREATE INDEX idx_creator_commissions_status ON public.creator_commissions(status);

CREATE INDEX idx_stream_selections_stream_id ON public.stream_product_selections(stream_id);
CREATE INDEX idx_stream_selections_creator_id ON public.stream_product_selections(creator_id);

-- Step 7: Functions for tier calculation
CREATE OR REPLACE FUNCTION public.get_user_tier(user_credit_balance INTEGER)
RETURNS public.product_tier
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT tier 
FROM public.product_tier_config 
WHERE user_credit_balance >= min_credit_balance 
  AND (max_credit_balance IS NULL OR user_credit_balance <= max_credit_balance)
ORDER BY min_credit_balance DESC 
LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.calculate_commission(sale_amount INTEGER, commission_rate DECIMAL)
RETURNS INTEGER
LANGUAGE sql
STABLE
AS $$
SELECT FLOOR(sale_amount * commission_rate / 100)::INTEGER;
$$;

-- Step 8: Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_system_products_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_system_products_updated_at
    BEFORE UPDATE ON public.system_products
    FOR EACH ROW
    EXECUTE FUNCTION public.update_system_products_updated_at();

-- Step 9: Enable RLS
ALTER TABLE public.system_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_tier_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.creator_commissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stream_product_selections ENABLE ROW LEVEL SECURITY;

-- Step 10: RLS Policies
-- System products - public read, admin manage
CREATE POLICY "public_can_read_system_products"
ON public.system_products
FOR SELECT
TO public
USING (is_available = true);

CREATE POLICY "admin_manage_system_products"
ON public.system_products
FOR ALL
TO authenticated
USING (has_admin_role())
WITH CHECK (has_admin_role());

-- Product tier config - public read, admin manage
CREATE POLICY "public_can_read_tier_config"
ON public.product_tier_config
FOR SELECT
TO public
USING (true);

CREATE POLICY "admin_manage_tier_config"
ON public.product_tier_config
FOR ALL
TO authenticated
USING (has_admin_role())
WITH CHECK (has_admin_role());

-- Creator commissions - users see own, admin see all
CREATE POLICY "users_manage_own_creator_commissions"
ON public.creator_commissions
FOR ALL
TO authenticated
USING (creator_id = auth.uid())
WITH CHECK (creator_id = auth.uid());

CREATE POLICY "admin_full_access_creator_commissions"
ON public.creator_commissions
FOR ALL
TO authenticated
USING (has_admin_role())
WITH CHECK (has_admin_role());

-- Stream product selections - users manage own
CREATE POLICY "users_manage_own_stream_selections"
ON public.stream_product_selections
FOR ALL
TO authenticated
USING (creator_id = auth.uid())
WITH CHECK (creator_id = auth.uid());

-- Step 11: Insert default tier configuration
INSERT INTO public.product_tier_config (tier, min_credit_balance, max_credit_balance, commission_rate, description, benefits) VALUES
('bronze', 0, 999, 10.00, 'Bronze Tier - Entry Level', '{"products": "Basic products", "support": "Standard support"}'),
('silver', 1000, 4999, 10.00, 'Silver Tier - Intermediate Level', '{"products": "Premium products", "support": "Priority support", "early_access": true}'),
('gold', 5000, 19999, 12.00, 'Gold Tier - Advanced Level', '{"products": "Luxury products", "support": "Premium support", "early_access": true, "exclusive_items": true}'),
('platinum', 20000, NULL, 15.00, 'Platinum Tier - Elite Level', '{"products": "Exclusive premium products", "support": "VIP support", "early_access": true, "exclusive_items": true, "custom_requests": true}');

-- Step 12: Sample system products for different tiers
DO $$
DECLARE
    electronics_cat UUID;
    fashion_cat UUID;
    product1_id UUID := gen_random_uuid();
    product2_id UUID := gen_random_uuid();
    product3_id UUID := gen_random_uuid();
    product4_id UUID := gen_random_uuid();
BEGIN
    -- Get category IDs
    SELECT id INTO electronics_cat FROM public.categories WHERE name ILIKE '%electronics%' LIMIT 1;
    SELECT id INTO fashion_cat FROM public.categories WHERE name ILIKE '%fashion%' LIMIT 1;
    
    -- If categories don't exist, create them
    IF electronics_cat IS NULL THEN
        INSERT INTO public.categories (name, description, is_active)
        VALUES ('Electronics', 'Electronic devices and gadgets', true)
        RETURNING id INTO electronics_cat;
    END IF;
    
    IF fashion_cat IS NULL THEN
        INSERT INTO public.categories (name, description, is_active)
        VALUES ('Fashion', 'Fashion items and accessories', true)
        RETURNING id INTO fashion_cat;
    END IF;

    -- Insert sample products
    INSERT INTO public.system_products (
        id, title, description, brand, model, category_id, 
        retail_value, starting_price, reserve_price, 
        tier_requirement, min_credit_balance, images
    ) VALUES
    (product1_id, 'Wireless Bluetooth Headphones', 'Premium quality wireless headphones with noise cancellation', 'TechBrand', 'TB-WH100', electronics_cat, 
     15000, 5000, 8000, 'bronze'::public.product_tier, 0, 
     '["https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500"]'::jsonb),
    
    (product2_id, 'Smart Fitness Watch', 'Advanced fitness tracking with heart rate monitor', 'FitTech', 'FT-SW200', electronics_cat,
     25000, 8000, 12000, 'silver'::public.product_tier, 1000,
     '["https://images.unsplash.com/photo-1544117519-31a4b719223d?w=500"]'::jsonb),
     
    (product3_id, 'Designer Leather Handbag', 'Luxury Italian leather handbag', 'LuxFashion', 'LF-BAG300', fashion_cat,
     50000, 15000, 25000, 'gold'::public.product_tier, 5000,
     '["https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=500"]'::jsonb),
     
    (product4_id, 'Limited Edition Smartwatch', 'Exclusive platinum edition smartwatch', 'EliteTech', 'ET-PW400', electronics_cat,
     100000, 30000, 50000, 'platinum'::public.product_tier, 20000,
     '["https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500"]'::jsonb);

    RAISE NOTICE 'Sample system products created successfully';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating sample products: %', SQLERRM;
END $$;