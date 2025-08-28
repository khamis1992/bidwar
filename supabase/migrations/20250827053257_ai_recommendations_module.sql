-- Location: supabase/migrations/20250827053257_ai_recommendations_module.sql
-- Schema Analysis: Existing auction platform with live_streams, auction_items, user_profiles, bids, watchlist
-- Integration Type: Addition - AI recommendation system for stream suggestions
-- Dependencies: user_profiles, auction_items, live_streams, categories, bids, stream_viewers

-- 1. ENUMS AND TYPES
CREATE TYPE public.recommendation_type AS ENUM (
    'similar_to_watched',
    'trending_now', 
    'ending_soon',
    'new_sellers',
    'category_based',
    'price_based',
    'collaborative_filtering'
);

CREATE TYPE public.preference_level AS ENUM ('low', 'medium', 'high', 'critical');

-- 2. USER PREFERENCES TABLE
CREATE TABLE public.user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    category_preferences JSONB DEFAULT '{}'::JSONB,
    price_range_min INTEGER DEFAULT 0,
    price_range_max INTEGER DEFAULT 1000000,
    preferred_times JSONB DEFAULT '[]'::JSONB,
    seller_preferences JSONB DEFAULT '{}'::JSONB,
    notification_settings JSONB DEFAULT '{}'::JSONB,
    recommendation_frequency public.preference_level DEFAULT 'medium'::public.preference_level,
    discovery_mode_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. USER INTERACTION TRACKING
CREATE TABLE public.user_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    auction_item_id UUID REFERENCES public.auction_items(id) ON DELETE CASCADE,
    stream_id UUID REFERENCES public.live_streams(id) ON DELETE SET NULL,
    interaction_type TEXT NOT NULL, -- 'view', 'click', 'bid', 'watchlist_add', 'share'
    duration_seconds INTEGER DEFAULT 0,
    interaction_context JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. RECOMMENDATION HISTORY
CREATE TABLE public.recommendation_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    auction_item_id UUID REFERENCES public.auction_items(id) ON DELETE CASCADE,
    recommendation_type public.recommendation_type NOT NULL,
    confidence_score DECIMAL(3,2) DEFAULT 0.0, -- 0.00 to 1.00
    reasoning JSONB DEFAULT '{}'::JSONB,
    is_clicked BOOLEAN DEFAULT false,
    is_successful BOOLEAN DEFAULT false, -- user ended up bidding/buying
    generated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    clicked_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ
);

-- 5. AI MODEL SCORES (for ML algorithm results)
CREATE TABLE public.ai_model_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    auction_item_id UUID REFERENCES public.auction_items(id) ON DELETE CASCADE,
    similarity_score DECIMAL(5,4) DEFAULT 0.0000,
    category_match_score DECIMAL(5,4) DEFAULT 0.0000,
    price_preference_score DECIMAL(5,4) DEFAULT 0.0000,
    seller_reputation_score DECIMAL(5,4) DEFAULT 0.0000,
    trending_score DECIMAL(5,4) DEFAULT 0.0000,
    urgency_score DECIMAL(5,4) DEFAULT 0.0000,
    final_recommendation_score DECIMAL(5,4) DEFAULT 0.0000,
    model_version TEXT DEFAULT 'v1.0',
    computed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. RECOMMENDATION FEEDBACK
CREATE TABLE public.recommendation_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    recommendation_id UUID REFERENCES public.recommendation_history(id) ON DELETE CASCADE,
    feedback_type TEXT NOT NULL, -- 'like', 'dislike', 'not_interested', 'report'
    feedback_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 7. INDEXES FOR PERFORMANCE
CREATE INDEX idx_user_preferences_user_id ON public.user_preferences(user_id);
CREATE INDEX idx_user_interactions_user_id ON public.user_interactions(user_id);
CREATE INDEX idx_user_interactions_auction_item_id ON public.user_interactions(auction_item_id);
CREATE INDEX idx_user_interactions_created_at ON public.user_interactions(created_at);
CREATE INDEX idx_recommendation_history_user_id ON public.recommendation_history(user_id);
CREATE INDEX idx_recommendation_history_generated_at ON public.recommendation_history(generated_at);
CREATE INDEX idx_ai_model_scores_user_id ON public.ai_model_scores(user_id);
CREATE INDEX idx_ai_model_scores_final_score ON public.ai_model_scores(final_recommendation_score DESC);
CREATE INDEX idx_recommendation_feedback_recommendation_id ON public.recommendation_feedback(recommendation_id);

-- 8. FUNCTIONS FOR AI RECOMMENDATIONS
CREATE OR REPLACE FUNCTION public.calculate_user_similarity(user_a UUID, user_b UUID)
RETURNS DECIMAL(3,2)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT COALESCE(
    (SELECT 
        COUNT(CASE WHEN ui1.auction_item_id = ui2.auction_item_id THEN 1 END) * 1.0 /
        NULLIF(COUNT(DISTINCT ui1.auction_item_id) + COUNT(DISTINCT ui2.auction_item_id), 0)
     FROM public.user_interactions ui1
     JOIN public.user_interactions ui2 ON ui1.user_id = user_a AND ui2.user_id = user_b
     WHERE ui1.interaction_type IN ('view', 'bid', 'watchlist_add')
       AND ui2.interaction_type IN ('view', 'bid', 'watchlist_add')
    ), 0.0
)::DECIMAL(3,2);
$$;

CREATE OR REPLACE FUNCTION public.update_recommendation_success()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- When user makes a bid, mark related recommendations as successful
    UPDATE public.recommendation_history 
    SET is_successful = true, completed_at = CURRENT_TIMESTAMP
    WHERE user_id = NEW.bidder_id 
      AND auction_item_id = NEW.auction_item_id
      AND is_clicked = true
      AND is_successful = false;
    
    RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.get_trending_auctions(time_window_hours INTEGER DEFAULT 24)
RETURNS TABLE(
    auction_item_id UUID,
    trending_score DECIMAL(5,4),
    view_count BIGINT,
    bid_count BIGINT
)
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT 
    ai.id as auction_item_id,
    (COALESCE(interaction_counts.view_count, 0) * 0.3 + 
     COALESCE(interaction_counts.bid_count, 0) * 0.7)::DECIMAL(5,4) as trending_score,
    COALESCE(interaction_counts.view_count, 0) as view_count,
    COALESCE(interaction_counts.bid_count, 0) as bid_count
FROM public.auction_items ai
LEFT JOIN (
    SELECT 
        ui.auction_item_id,
        COUNT(CASE WHEN ui.interaction_type = 'view' THEN 1 END) as view_count,
        COUNT(CASE WHEN ui.interaction_type = 'bid' THEN 1 END) as bid_count
    FROM public.user_interactions ui
    WHERE ui.created_at >= NOW() - INTERVAL '1 hour' * time_window_hours
    GROUP BY ui.auction_item_id
) interaction_counts ON ai.id = interaction_counts.auction_item_id
WHERE ai.status = 'live'::auction_status
ORDER BY trending_score DESC;
$$;

-- 9. ENABLE RLS
ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_model_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recommendation_feedback ENABLE ROW LEVEL SECURITY;

-- 10. RLS POLICIES
CREATE POLICY "users_manage_own_user_preferences"
ON public.user_preferences
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_user_interactions"
ON public.user_interactions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_recommendation_history"
ON public.recommendation_history
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_ai_model_scores"
ON public.ai_model_scores
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "users_manage_own_recommendation_feedback"
ON public.recommendation_feedback
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "admin_full_access_user_preferences"
ON public.user_preferences
FOR ALL
TO authenticated
USING (has_admin_role())
WITH CHECK (has_admin_role());

CREATE POLICY "admin_full_access_user_interactions"
ON public.user_interactions
FOR ALL
TO authenticated
USING (has_admin_role())
WITH CHECK (has_admin_role());

-- 11. TRIGGERS
CREATE TRIGGER update_user_preferences_updated_at
    BEFORE UPDATE ON public.user_preferences
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_recommendation_success_on_bid
    AFTER INSERT ON public.bids
    FOR EACH ROW EXECUTE FUNCTION public.update_recommendation_success();

-- 12. MOCK DATA
DO $$
DECLARE
    existing_user_id UUID;
    existing_user_id_2 UUID;
    auction_item_1 UUID;
    auction_item_2 UUID;
    electronics_cat_id UUID;
    art_cat_id UUID;
    rec_history_id UUID;
BEGIN
    -- Get existing user IDs
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    SELECT id INTO existing_user_id_2 FROM public.user_profiles OFFSET 1 LIMIT 1;
    
    -- Get existing auction items
    SELECT id INTO auction_item_1 FROM public.auction_items LIMIT 1;
    SELECT id INTO auction_item_2 FROM public.auction_items OFFSET 1 LIMIT 1;
    
    -- Get category IDs
    SELECT id INTO electronics_cat_id FROM public.categories WHERE name = 'Electronics';
    SELECT id INTO art_cat_id FROM public.categories WHERE name = 'Art & Collectibles';
    
    -- Insert user preferences
    INSERT INTO public.user_preferences (user_id, category_preferences, price_range_min, price_range_max, preferred_times, recommendation_frequency)
    VALUES 
        (existing_user_id, 
         JSON_BUILD_OBJECT('electronics', 'high', 'art', 'medium', 'automotive', 'low')::JSONB,
         1000, 500000,
         '["morning", "evening"]'::JSONB,
         'high'::public.preference_level),
        (existing_user_id_2,
         JSON_BUILD_OBJECT('art', 'high', 'collectibles', 'high', 'electronics', 'low')::JSONB,
         5000, 100000,
         '["afternoon", "night"]'::JSONB,
         'medium'::public.preference_level);
    
    -- Insert user interactions
    INSERT INTO public.user_interactions (user_id, auction_item_id, interaction_type, duration_seconds, interaction_context)
    VALUES 
        (existing_user_id, auction_item_1, 'view', 45, '{"source": "homepage", "device": "mobile"}'::JSONB),
        (existing_user_id, auction_item_1, 'watchlist_add', 5, '{"from_recommendation": true}'::JSONB),
        (existing_user_id_2, auction_item_2, 'view', 120, '{"source": "category_browse", "device": "desktop"}'::JSONB),
        (existing_user_id_2, auction_item_2, 'bid', 10, '{"bid_amount": 8500}'::JSONB);
    
    -- Insert recommendation history
    INSERT INTO public.recommendation_history (id, user_id, auction_item_id, recommendation_type, confidence_score, reasoning, is_clicked)
    VALUES 
        (gen_random_uuid(), existing_user_id, auction_item_1, 'category_based'::public.recommendation_type, 0.85, 
         '{"matched_categories": ["electronics"], "price_fit": 0.9, "user_activity": "high"}'::JSONB, true),
        (gen_random_uuid(), existing_user_id_2, auction_item_2, 'similar_to_watched'::public.recommendation_type, 0.92,
         '{"similar_items_viewed": 3, "category_match": "art", "seller_reputation": 4.5}'::JSONB, true)
    RETURNING id INTO rec_history_id;
    
    -- Insert AI model scores
    INSERT INTO public.ai_model_scores (user_id, auction_item_id, similarity_score, category_match_score, price_preference_score, final_recommendation_score)
    VALUES 
        (existing_user_id, auction_item_1, 0.7500, 0.9200, 0.8100, 0.8267),
        (existing_user_id_2, auction_item_2, 0.8900, 0.9500, 0.7800, 0.8733);
    
    -- Insert recommendation feedback
    INSERT INTO public.recommendation_feedback (user_id, recommendation_id, feedback_type, feedback_reason)
    VALUES 
        (existing_user_id, rec_history_id, 'like', 'Great recommendation, exactly what I was looking for!');

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data insertion failed: %', SQLERRM;
END $$;