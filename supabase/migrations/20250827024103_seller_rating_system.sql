-- Location: supabase/migrations/20250827024103_seller_rating_system.sql
-- Schema Analysis: Existing auction application with live streaming functionality
-- Integration Type: NEW_MODULE - Adding seller rating and review system
-- Dependencies: user_profiles, auction_items tables (existing)

-- Step 1: Create rating level enum
CREATE TYPE public.rating_level AS ENUM ('1', '2', '3', '4', '5');

-- Step 2: Create seller ratings table
CREATE TABLE public.seller_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    buyer_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    auction_item_id UUID REFERENCES public.auction_items(id) ON DELETE SET NULL,
    overall_rating public.rating_level NOT NULL,
    product_quality_rating public.rating_level,
    shipping_speed_rating public.rating_level,
    communication_rating public.rating_level,
    stream_entertainment_rating public.rating_level,
    review_text TEXT,
    review_images JSONB DEFAULT '[]'::jsonb,
    is_verified BOOLEAN DEFAULT false,
    seller_response TEXT,
    seller_response_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Step 3: Create seller rating statistics table for performance
CREATE TABLE public.seller_rating_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    total_reviews INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.0,
    average_product_quality DECIMAL(3,2) DEFAULT 0.0,
    average_shipping_speed DECIMAL(3,2) DEFAULT 0.0,
    average_communication DECIMAL(3,2) DEFAULT 0.0,
    average_stream_entertainment DECIMAL(3,2) DEFAULT 0.0,
    five_star_count INTEGER DEFAULT 0,
    four_star_count INTEGER DEFAULT 0,
    three_star_count INTEGER DEFAULT 0,
    two_star_count INTEGER DEFAULT 0,
    one_star_count INTEGER DEFAULT 0,
    response_rate DECIMAL(5,2) DEFAULT 0.0,
    total_transactions INTEGER DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(seller_id)
);

-- Step 4: Essential indexes
CREATE INDEX idx_seller_ratings_seller_id ON public.seller_ratings(seller_id);
CREATE INDEX idx_seller_ratings_buyer_id ON public.seller_ratings(buyer_id);
CREATE INDEX idx_seller_ratings_auction_item_id ON public.seller_ratings(auction_item_id);
CREATE INDEX idx_seller_ratings_overall_rating ON public.seller_ratings(overall_rating);
CREATE INDEX idx_seller_ratings_created_at ON public.seller_ratings(created_at);
CREATE INDEX idx_seller_ratings_is_verified ON public.seller_ratings(is_verified);
CREATE INDEX idx_seller_rating_stats_seller_id ON public.seller_rating_stats(seller_id);

-- Step 5: Functions (before RLS policies)
CREATE OR REPLACE FUNCTION public.update_seller_rating_stats()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    seller_uuid UUID;
    stats_record RECORD;
BEGIN
    -- Get seller_id from new or old record
    seller_uuid := COALESCE(NEW.seller_id, OLD.seller_id);
    
    -- Calculate new statistics
    SELECT 
        COUNT(*) as total,
        ROUND(AVG(CASE WHEN overall_rating = '5' THEN 5
                      WHEN overall_rating = '4' THEN 4  
                      WHEN overall_rating = '3' THEN 3
                      WHEN overall_rating = '2' THEN 2
                      WHEN overall_rating = '1' THEN 1 END), 2) as avg_rating,
        ROUND(AVG(CASE WHEN product_quality_rating = '5' THEN 5
                      WHEN product_quality_rating = '4' THEN 4
                      WHEN product_quality_rating = '3' THEN 3  
                      WHEN product_quality_rating = '2' THEN 2
                      WHEN product_quality_rating = '1' THEN 1 END), 2) as avg_quality,
        ROUND(AVG(CASE WHEN shipping_speed_rating = '5' THEN 5
                      WHEN shipping_speed_rating = '4' THEN 4
                      WHEN shipping_speed_rating = '3' THEN 3
                      WHEN shipping_speed_rating = '2' THEN 2  
                      WHEN shipping_speed_rating = '1' THEN 1 END), 2) as avg_shipping,
        ROUND(AVG(CASE WHEN communication_rating = '5' THEN 5
                      WHEN communication_rating = '4' THEN 4
                      WHEN communication_rating = '3' THEN 3
                      WHEN communication_rating = '2' THEN 2
                      WHEN communication_rating = '1' THEN 1 END), 2) as avg_comm,
        ROUND(AVG(CASE WHEN stream_entertainment_rating = '5' THEN 5
                      WHEN stream_entertainment_rating = '4' THEN 4
                      WHEN stream_entertainment_rating = '3' THEN 3
                      WHEN stream_entertainment_rating = '2' THEN 2
                      WHEN stream_entertainment_rating = '1' THEN 1 END), 2) as avg_stream,
        COUNT(*) FILTER (WHERE overall_rating = '5') as five_stars,
        COUNT(*) FILTER (WHERE overall_rating = '4') as four_stars,
        COUNT(*) FILTER (WHERE overall_rating = '3') as three_stars,
        COUNT(*) FILTER (WHERE overall_rating = '2') as two_stars,
        COUNT(*) FILTER (WHERE overall_rating = '1') as one_stars,
        ROUND((COUNT(*) FILTER (WHERE seller_response IS NOT NULL) * 100.0 / NULLIF(COUNT(*), 0)), 2) as response_rate
    INTO stats_record
    FROM public.seller_ratings
    WHERE seller_id = seller_uuid;
    
    -- Upsert statistics
    INSERT INTO public.seller_rating_stats (
        seller_id, total_reviews, average_rating, average_product_quality,
        average_shipping_speed, average_communication, average_stream_entertainment,
        five_star_count, four_star_count, three_star_count, two_star_count, one_star_count,
        response_rate, updated_at
    ) VALUES (
        seller_uuid, stats_record.total, stats_record.avg_rating, stats_record.avg_quality,
        stats_record.avg_shipping, stats_record.avg_comm, stats_record.avg_stream,
        stats_record.five_stars, stats_record.four_stars, stats_record.three_stars,
        stats_record.two_stars, stats_record.one_stars, stats_record.response_rate, CURRENT_TIMESTAMP
    ) ON CONFLICT (seller_id) DO UPDATE SET
        total_reviews = EXCLUDED.total_reviews,
        average_rating = EXCLUDED.average_rating,
        average_product_quality = EXCLUDED.average_product_quality,
        average_shipping_speed = EXCLUDED.average_shipping_speed,
        average_communication = EXCLUDED.average_communication,
        average_stream_entertainment = EXCLUDED.average_stream_entertainment,
        five_star_count = EXCLUDED.five_star_count,
        four_star_count = EXCLUDED.four_star_count,
        three_star_count = EXCLUDED.three_star_count,
        two_star_count = EXCLUDED.two_star_count,
        one_star_count = EXCLUDED.one_star_count,
        response_rate = EXCLUDED.response_rate,
        updated_at = EXCLUDED.updated_at;
        
    RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE OR REPLACE FUNCTION public.update_updated_at_seller_ratings()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- Step 6: Enable RLS
ALTER TABLE public.seller_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.seller_rating_stats ENABLE ROW LEVEL SECURITY;

-- Step 7: RLS Policies

-- Pattern 4: Public read, private write for seller_ratings
CREATE POLICY "public_can_read_seller_ratings"
ON public.seller_ratings
FOR SELECT
TO public
USING (true);

CREATE POLICY "buyers_can_create_ratings"
ON public.seller_ratings
FOR INSERT
TO authenticated
WITH CHECK (buyer_id = auth.uid());

CREATE POLICY "buyers_can_update_own_ratings"
ON public.seller_ratings
FOR UPDATE
TO authenticated
USING (buyer_id = auth.uid())
WITH CHECK (buyer_id = auth.uid());

CREATE POLICY "sellers_can_respond_to_ratings"
ON public.seller_ratings
FOR UPDATE
TO authenticated
USING (seller_id = auth.uid() AND seller_response IS NULL)
WITH CHECK (seller_id = auth.uid());

-- Pattern 2: Simple ownership for stats (seller access)
CREATE POLICY "sellers_manage_own_rating_stats"
ON public.seller_rating_stats
FOR ALL
TO authenticated
USING (seller_id = auth.uid())
WITH CHECK (seller_id = auth.uid());

-- Public read for rating stats
CREATE POLICY "public_can_read_seller_rating_stats"
ON public.seller_rating_stats
FOR SELECT
TO public
USING (true);

-- Step 8: Triggers
CREATE TRIGGER update_seller_rating_stats_trigger
    AFTER INSERT OR UPDATE OR DELETE
    ON public.seller_ratings
    FOR EACH ROW
    EXECUTE FUNCTION public.update_seller_rating_stats();

CREATE TRIGGER update_seller_ratings_updated_at
    BEFORE UPDATE
    ON public.seller_ratings
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_seller_ratings();

-- Step 9: Mock data for testing
DO $$
DECLARE
    existing_seller_id UUID;
    existing_buyer_id UUID;
    existing_auction_id UUID;
    rating_id_1 UUID := gen_random_uuid();
    rating_id_2 UUID := gen_random_uuid();
    rating_id_3 UUID := gen_random_uuid();
BEGIN
    -- Get existing users and auction items
    SELECT id INTO existing_seller_id FROM public.user_profiles WHERE role = 'seller' LIMIT 1;
    SELECT id INTO existing_buyer_id FROM public.user_profiles WHERE role != 'seller' LIMIT 1;
    SELECT id INTO existing_auction_id FROM public.auction_items LIMIT 1;
    
    -- If no seller found, get any user
    IF existing_seller_id IS NULL THEN
        SELECT id INTO existing_seller_id FROM public.user_profiles LIMIT 1;
    END IF;
    
    -- If no buyer found, get any other user
    IF existing_buyer_id IS NULL OR existing_buyer_id = existing_seller_id THEN
        SELECT id INTO existing_buyer_id FROM public.user_profiles WHERE id != existing_seller_id LIMIT 1;
    END IF;
    
    -- Create sample ratings only if we have users
    IF existing_seller_id IS NOT NULL AND existing_buyer_id IS NOT NULL THEN
        INSERT INTO public.seller_ratings (
            id, seller_id, buyer_id, auction_item_id, overall_rating,
            product_quality_rating, shipping_speed_rating, communication_rating,
            stream_entertainment_rating, review_text, is_verified
        ) VALUES
            (rating_id_1, existing_seller_id, existing_buyer_id, existing_auction_id, '5',
             '5', '4', '5', '4', 'Excellent seller! Great live stream presentation and fast shipping.', true),
            (rating_id_2, existing_seller_id, existing_buyer_id, existing_auction_id, '4',
             '4', '5', '4', '5', 'Good experience overall. The live auction was entertaining!', true),
            (rating_id_3, existing_seller_id, existing_buyer_id, existing_auction_id, '3',
             '3', '3', '4', '3', 'Average experience. Product was as described but shipping could be faster.', false);
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data generation failed: %', SQLERRM;
END $$;