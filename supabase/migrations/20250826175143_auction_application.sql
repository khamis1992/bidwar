-- Location: supabase/migrations/20250826175143_auction_application.sql
-- Schema Analysis: Fresh auction application project
-- Integration Type: Complete auction system implementation
-- Dependencies: None (fresh project)

-- 1. EXTENSIONS & TYPES
CREATE TYPE public.user_role AS ENUM ('admin', 'seller', 'bidder');
CREATE TYPE public.auction_status AS ENUM ('upcoming', 'live', 'ended', 'cancelled');
CREATE TYPE public.bid_status AS ENUM ('active', 'outbid', 'winning');
CREATE TYPE public.payment_status AS ENUM ('pending', 'completed', 'failed', 'refunded');
CREATE TYPE public.transaction_type AS ENUM ('credit_purchase', 'bid_placed', 'auction_won', 'refund');

-- 2. CORE TABLES (no foreign keys)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'bidder'::public.user_role,
    phone TEXT,
    address JSONB,
    credit_balance INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT false,
    profile_picture_url TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. DEPENDENT TABLES (with foreign keys)
CREATE TABLE public.auction_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    starting_price INTEGER NOT NULL CHECK (starting_price > 0),
    reserve_price INTEGER,
    current_highest_bid INTEGER DEFAULT 0,
    bid_increment INTEGER DEFAULT 1,
    condition TEXT,
    brand TEXT,
    model TEXT,
    specifications JSONB,
    images JSONB DEFAULT '[]'::jsonb,
    status public.auction_status DEFAULT 'upcoming'::public.auction_status,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    featured BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    winner_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT valid_auction_times CHECK (end_time > start_time),
    CONSTRAINT valid_reserve_price CHECK (reserve_price IS NULL OR reserve_price >= starting_price)
);

CREATE TABLE public.bids (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auction_item_id UUID REFERENCES public.auction_items(id) ON DELETE CASCADE,
    bidder_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    bid_amount INTEGER NOT NULL CHECK (bid_amount > 0),
    status public.bid_status DEFAULT 'active'::public.bid_status,
    is_auto_bid BOOLEAN DEFAULT false,
    max_auto_bid INTEGER,
    placed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(auction_item_id, bidder_id, placed_at)
);

CREATE TABLE public.credit_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    transaction_type public.transaction_type NOT NULL,
    amount INTEGER NOT NULL,
    description TEXT,
    related_auction_id UUID REFERENCES public.auction_items(id) ON DELETE SET NULL,
    related_bid_id UUID REFERENCES public.bids(id) ON DELETE SET NULL,
    payment_status public.payment_status DEFAULT 'completed'::public.payment_status,
    payment_reference TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.watchlist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    auction_item_id UUID REFERENCES public.auction_items(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, auction_item_id)
);

CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL,
    related_auction_id UUID REFERENCES public.auction_items(id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. ESSENTIAL INDEXES
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_categories_active ON public.categories(is_active);
CREATE INDEX idx_auction_items_seller_id ON public.auction_items(seller_id);
CREATE INDEX idx_auction_items_category_id ON public.auction_items(category_id);
CREATE INDEX idx_auction_items_status ON public.auction_items(status);
CREATE INDEX idx_auction_items_start_time ON public.auction_items(start_time);
CREATE INDEX idx_auction_items_end_time ON public.auction_items(end_time);
CREATE INDEX idx_auction_items_featured ON public.auction_items(featured);
CREATE INDEX idx_bids_auction_item_id ON public.bids(auction_item_id);
CREATE INDEX idx_bids_bidder_id ON public.bids(bidder_id);
CREATE INDEX idx_bids_placed_at ON public.bids(placed_at);
CREATE INDEX idx_credit_transactions_user_id ON public.credit_transactions(user_id);
CREATE INDEX idx_watchlist_user_id ON public.watchlist(user_id);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_unread ON public.notifications(user_id, is_read);

-- 5. FUNCTIONS (before RLS policies)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'bidder'::public.user_role)
  );  
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.update_auction_status()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Update upcoming auctions to live
  UPDATE public.auction_items
  SET status = 'live'::public.auction_status
  WHERE status = 'upcoming'::public.auction_status
    AND start_time <= CURRENT_TIMESTAMP;
  
  -- Update live auctions to ended
  UPDATE public.auction_items
  SET status = 'ended'::public.auction_status
  WHERE status = 'live'::public.auction_status
    AND end_time <= CURRENT_TIMESTAMP;
END;
$$;

CREATE OR REPLACE FUNCTION public.process_bid(
  p_auction_item_id UUID,
  p_bidder_id UUID,
  p_bid_amount INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_bid INTEGER;
  v_min_bid INTEGER;
  v_user_credits INTEGER;
  v_auction_status public.auction_status;
  v_bid_id UUID;
BEGIN
  -- Get current auction info
  SELECT current_highest_bid, starting_price + bid_increment, status
  INTO v_current_bid, v_min_bid, v_auction_status
  FROM public.auction_items
  WHERE id = p_auction_item_id;
  
  -- Check if auction is live
  IF v_auction_status != 'live' THEN
    RETURN jsonb_build_object('success', false, 'message', 'Auction is not live');
  END IF;
  
  -- Calculate minimum bid
  IF v_current_bid = 0 THEN
    v_min_bid := (SELECT starting_price FROM public.auction_items WHERE id = p_auction_item_id);
  ELSE
    v_min_bid := v_current_bid + (SELECT bid_increment FROM public.auction_items WHERE id = p_auction_item_id);
  END IF;
  
  -- Validate bid amount
  IF p_bid_amount < v_min_bid THEN
    RETURN jsonb_build_object('success', false, 'message', 'Bid amount too low');
  END IF;
  
  -- Check user credits
  SELECT credit_balance INTO v_user_credits
  FROM public.user_profiles
  WHERE id = p_bidder_id;
  
  IF v_user_credits < p_bid_amount THEN
    RETURN jsonb_build_object('success', false, 'message', 'Insufficient credits');
  END IF;
  
  -- Insert bid
  INSERT INTO public.bids (auction_item_id, bidder_id, bid_amount)
  VALUES (p_auction_item_id, p_bidder_id, p_bid_amount)
  RETURNING id INTO v_bid_id;
  
  -- Update auction current highest bid
  UPDATE public.auction_items
  SET current_highest_bid = p_bid_amount,
      updated_at = CURRENT_TIMESTAMP
  WHERE id = p_auction_item_id;
  
  -- Mark previous bids as outbid
  UPDATE public.bids
  SET status = 'outbid'::public.bid_status
  WHERE auction_item_id = p_auction_item_id
    AND id != v_bid_id;
  
  RETURN jsonb_build_object('success', true, 'bid_id', v_bid_id);
END;
$$;

-- 6. ENABLE RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.auction_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bids ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.credit_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.watchlist ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 7. RLS POLICIES

-- Pattern 1: Core user table (user_profiles) - Simple only, no functions
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 4: Public read, private write for categories
CREATE POLICY "public_can_read_categories"
ON public.categories
FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "admins_manage_categories"
ON public.categories
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'
  )
);

-- Pattern 4: Public read, private write for auction items
CREATE POLICY "public_can_read_auction_items"
ON public.auction_items
FOR SELECT
TO public
USING (true);

CREATE POLICY "sellers_manage_own_auction_items"
ON public.auction_items
FOR ALL
TO authenticated
USING (seller_id = auth.uid())
WITH CHECK (seller_id = auth.uid());

-- Pattern 2: Simple user ownership for bids
CREATE POLICY "users_manage_own_bids"
ON public.bids
FOR ALL
TO authenticated
USING (bidder_id = auth.uid())
WITH CHECK (bidder_id = auth.uid());

-- Allow reading all bids for auction transparency
CREATE POLICY "public_can_read_bids"
ON public.bids
FOR SELECT
TO public
USING (true);

-- Pattern 2: Simple user ownership for credit transactions
CREATE POLICY "users_manage_own_credit_transactions"
ON public.credit_transactions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for watchlist
CREATE POLICY "users_manage_own_watchlist"
ON public.watchlist
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 2: Simple user ownership for notifications
CREATE POLICY "users_manage_own_notifications"
ON public.notifications
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- 8. TRIGGERS
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 9. COMPLETE MOCK DATA
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    seller_uuid UUID := gen_random_uuid();
    bidder1_uuid UUID := gen_random_uuid();
    bidder2_uuid UUID := gen_random_uuid();
    category1_uuid UUID := gen_random_uuid();
    category2_uuid UUID := gen_random_uuid();
    category3_uuid UUID := gen_random_uuid();
    auction1_uuid UUID := gen_random_uuid();
    auction2_uuid UUID := gen_random_uuid();
    auction3_uuid UUID := gen_random_uuid();
BEGIN
    -- Create complete auth users with required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@bidwar.com', crypt('admin123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (seller_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'seller@bidwar.com', crypt('seller123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Seller", "role": "seller"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (bidder1_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'bidder1@bidwar.com', crypt('bidder123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Alice Bidder", "role": "bidder"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (bidder2_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'bidder2@bidwar.com', crypt('bidder456', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Bob Collector", "role": "bidder"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Update user profiles with additional data
    UPDATE public.user_profiles 
    SET credit_balance = 10000, is_verified = true, phone = '+1234567890'
    WHERE id = bidder1_uuid;
    
    UPDATE public.user_profiles 
    SET credit_balance = 15000, is_verified = true, phone = '+1234567891'
    WHERE id = bidder2_uuid;
    
    UPDATE public.user_profiles 
    SET credit_balance = 5000, is_verified = true
    WHERE id = seller_uuid;

    -- Insert categories
    INSERT INTO public.categories (id, name, description, image_url) VALUES
        (category1_uuid, 'Electronics', 'Phones, computers, gadgets and electronic devices', 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400'),
        (category2_uuid, 'Collectibles', 'Rare items, antiques, memorabilia and collectible pieces', 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400'),
        (category3_uuid, 'Art & Design', 'Paintings, sculptures, digital art and design pieces', 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400');

    -- Insert auction items
    INSERT INTO public.auction_items (
        id, seller_id, category_id, title, description, starting_price, reserve_price,
        current_highest_bid, bid_increment, condition, brand, model, 
        images, status, start_time, end_time, featured
    ) VALUES
        (auction1_uuid, seller_uuid, category1_uuid, 
         'iPhone 15 Pro Max - 256GB Space Black', 
         'Brand new iPhone 15 Pro Max in Space Black color with 256GB storage. Includes original box, charger, and documentation. Never used, still sealed.',
         800, 1000, 850, 25, 'New', 'Apple', 'iPhone 15 Pro Max',
         '["https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=400", "https://images.unsplash.com/photo-1601784551446-20c9e07cdbdb?w=400"]'::jsonb,
         'live'::public.auction_status, 
         CURRENT_TIMESTAMP - INTERVAL '2 hours', 
         CURRENT_TIMESTAMP + INTERVAL '6 hours', 
         true),
        (auction2_uuid, seller_uuid, category2_uuid,
         'Vintage Rolex Submariner 1970s',
         'Authentic vintage Rolex Submariner from the 1970s. Excellent condition with original bracelet. Service history available. A true collectors piece.',
         2500, 3500, 2750, 100, 'Excellent', 'Rolex', 'Submariner',
         '["https://images.unsplash.com/photo-1547996160-81dfa63595aa?w=400", "https://images.unsplash.com/photo-1609587312208-3de5e2ddb713?w=400"]'::jsonb,
         'live'::public.auction_status,
         CURRENT_TIMESTAMP - INTERVAL '1 hour',
         CURRENT_TIMESTAMP + INTERVAL '12 hours',
         true),
        (auction3_uuid, seller_uuid, category3_uuid,
         'Original Oil Painting - Mountain Landscape',
         'Beautiful original oil painting depicting a serene mountain landscape. Painted by emerging artist Sarah Johnson. Framed and ready to hang.',
         200, 400, 0, 25, 'Excellent', 'Original', 'Oil on Canvas',
         '["https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400"]'::jsonb,
         'upcoming'::public.auction_status,
         CURRENT_TIMESTAMP + INTERVAL '2 hours',
         CURRENT_TIMESTAMP + INTERVAL '24 hours',
         false);

    -- Insert sample bids
    INSERT INTO public.bids (auction_item_id, bidder_id, bid_amount, status) VALUES
        (auction1_uuid, bidder1_uuid, 800, 'outbid'::public.bid_status),
        (auction1_uuid, bidder2_uuid, 825, 'outbid'::public.bid_status),
        (auction1_uuid, bidder1_uuid, 850, 'active'::public.bid_status),
        (auction2_uuid, bidder2_uuid, 2500, 'outbid'::public.bid_status),
        (auction2_uuid, bidder1_uuid, 2650, 'outbid'::public.bid_status),
        (auction2_uuid, bidder2_uuid, 2750, 'active'::public.bid_status);

    -- Insert watchlist items
    INSERT INTO public.watchlist (user_id, auction_item_id) VALUES
        (bidder1_uuid, auction2_uuid),
        (bidder1_uuid, auction3_uuid),
        (bidder2_uuid, auction1_uuid),
        (bidder2_uuid, auction3_uuid);

    -- Insert sample credit transactions
    INSERT INTO public.credit_transactions (user_id, transaction_type, amount, description, payment_reference) VALUES
        (bidder1_uuid, 'credit_purchase'::public.transaction_type, 10000, 'Initial credit purchase', 'PAY_123456'),
        (bidder2_uuid, 'credit_purchase'::public.transaction_type, 15000, 'Credit package purchase', 'PAY_123457'),
        (bidder1_uuid, 'bid_placed'::public.transaction_type, -850, 'Bid on iPhone 15 Pro Max', null),
        (bidder2_uuid, 'bid_placed'::public.transaction_type, -2750, 'Bid on Vintage Rolex', null);

    -- Insert sample notifications
    INSERT INTO public.notifications (user_id, title, message, type, related_auction_id) VALUES
        (bidder1_uuid, 'Bid Outbid', 'Your bid on iPhone 15 Pro Max has been outbid', 'bid_outbid', auction1_uuid),
        (bidder2_uuid, 'Auction Ending', 'Vintage Rolex auction ends in 1 hour', 'auction_ending', auction2_uuid),
        (seller_uuid, 'New Bid', 'New bid received on your iPhone 15 Pro Max', 'new_bid', auction1_uuid);

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;