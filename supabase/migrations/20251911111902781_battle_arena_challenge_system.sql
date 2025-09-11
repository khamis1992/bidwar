-- Location: supabase/migrations/20251911111902781_battle_arena_challenge_system.sql
-- Schema Analysis: Extending existing auction/streaming system with TikTok-style battle functionality
-- Integration Type: PARTIAL_EXISTS - Adding battle rooms that reference existing live_streams and user_profiles
-- Dependencies: user_profiles, live_streams, auction_items, stream_chat_messages (all existing)

-- 1. New Types for Battle System
CREATE TYPE public.battle_status AS ENUM ('upcoming', 'live', 'ended', 'cancelled');
CREATE TYPE public.support_type AS ENUM ('heart', 'coin', 'boost', 'gift');

-- 2. Battle Rooms Table (Two-competitor battles)
CREATE TABLE public.battle_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    competitor_1_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    competitor_2_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    product_1_id UUID REFERENCES public.auction_items(id) ON DELETE CASCADE,
    product_2_id UUID REFERENCES public.auction_items(id) ON DELETE CASCADE,
    stream_id UUID REFERENCES public.live_streams(id) ON DELETE SET NULL,
    status public.battle_status DEFAULT 'upcoming'::public.battle_status,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    duration_minutes INTEGER DEFAULT 10,
    competitor_1_support INTEGER DEFAULT 0,
    competitor_2_support INTEGER DEFAULT 0,
    total_viewers INTEGER DEFAULT 0,
    max_viewers INTEGER DEFAULT 0,
    winner_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Battle Support Actions (Hearts, coins, boosts from viewers)
CREATE TABLE public.battle_support_actions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    battle_room_id UUID REFERENCES public.battle_rooms(id) ON DELETE CASCADE,
    supporter_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    competitor_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    support_type public.support_type NOT NULL,
    amount INTEGER DEFAULT 1,
    cost_credits INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Battle Invitations System
CREATE TABLE public.battle_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    battle_room_id UUID REFERENCES public.battle_rooms(id) ON DELETE CASCADE,
    inviter_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    invitee_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending',
    message TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMPTZ,
    CONSTRAINT battle_invitations_status_check CHECK (status IN ('pending', 'accepted', 'declined', 'expired'))
);

-- 5. Battle Metrics for Real-time Updates
CREATE TABLE public.battle_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    battle_room_id UUID REFERENCES public.battle_rooms(id) ON DELETE CASCADE,
    competitor_1_hearts INTEGER DEFAULT 0,
    competitor_1_coins INTEGER DEFAULT 0,
    competitor_1_boosts INTEGER DEFAULT 0,
    competitor_2_hearts INTEGER DEFAULT 0,
    competitor_2_coins INTEGER DEFAULT 0,
    competitor_2_boosts INTEGER DEFAULT 0,
    current_viewers INTEGER DEFAULT 0,
    engagement_score INTEGER DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 6. Battle Spectators (Track viewers)
CREATE TABLE public.battle_spectators (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    battle_room_id UUID REFERENCES public.battle_rooms(id) ON DELETE CASCADE,
    spectator_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMPTZ,
    total_support_given INTEGER DEFAULT 0,
    favorite_competitor_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    UNIQUE(battle_room_id, spectator_id)
);

-- 7. Essential Indexes
CREATE INDEX idx_battle_rooms_status ON public.battle_rooms(status);
CREATE INDEX idx_battle_rooms_start_time ON public.battle_rooms(start_time);
CREATE INDEX idx_battle_rooms_competitor_1 ON public.battle_rooms(competitor_1_id);
CREATE INDEX idx_battle_rooms_competitor_2 ON public.battle_rooms(competitor_2_id);
CREATE INDEX idx_battle_rooms_stream_id ON public.battle_rooms(stream_id);
CREATE INDEX idx_battle_support_actions_battle_room ON public.battle_support_actions(battle_room_id);
CREATE INDEX idx_battle_support_actions_supporter ON public.battle_support_actions(supporter_id);
CREATE INDEX idx_battle_support_actions_competitor ON public.battle_support_actions(competitor_id);
CREATE INDEX idx_battle_invitations_invitee ON public.battle_invitations(invitee_id);
CREATE INDEX idx_battle_spectators_battle_room ON public.battle_spectators(battle_room_id);
CREATE INDEX idx_battle_spectators_spectator ON public.battle_spectators(spectator_id);

-- 8. Functions for Battle Management
CREATE OR REPLACE FUNCTION public.update_battle_support(battle_uuid UUID, competitor_uuid UUID, support_amount INTEGER)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    UPDATE public.battle_rooms
    SET competitor_1_support = CASE 
            WHEN competitor_1_id = competitor_uuid 
            THEN competitor_1_support + support_amount
            ELSE competitor_1_support
        END,
        competitor_2_support = CASE 
            WHEN competitor_2_id = competitor_uuid 
            THEN competitor_2_support + support_amount
            ELSE competitor_2_support
        END,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = battle_uuid;
END;
$func$;

CREATE OR REPLACE FUNCTION public.end_battle_and_declare_winner(battle_uuid UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    winner_uuid UUID;
    competitor1_support INTEGER;
    competitor2_support INTEGER;
    competitor1_id UUID;
    competitor2_id UUID;
BEGIN
    SELECT 
        competitor_1_id, competitor_2_id, 
        competitor_1_support, competitor_2_support
    INTO competitor1_id, competitor2_id, competitor1_support, competitor2_support
    FROM public.battle_rooms
    WHERE id = battle_uuid;

    -- Determine winner based on support
    IF competitor1_support > competitor2_support THEN
        winner_uuid := competitor1_id;
    ELSIF competitor2_support > competitor1_support THEN
        winner_uuid := competitor2_id;
    ELSE
        winner_uuid := NULL; -- Tie
    END IF;

    -- Update battle room with winner
    UPDATE public.battle_rooms
    SET winner_id = winner_uuid,
        status = 'ended'::public.battle_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = battle_uuid;

    RETURN winner_uuid;
END;
$func$;

CREATE OR REPLACE FUNCTION public.get_active_battles()
RETURNS TABLE(
    battle_id UUID,
    title TEXT,
    competitor_1_name TEXT,
    competitor_2_name TEXT,
    competitor_1_support INTEGER,
    competitor_2_support INTEGER,
    current_viewers INTEGER,
    time_remaining INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    RETURN QUERY
    SELECT 
        br.id,
        br.title,
        up1.full_name,
        up2.full_name,
        br.competitor_1_support,
        br.competitor_2_support,
        br.total_viewers,
        EXTRACT(EPOCH FROM (br.end_time - CURRENT_TIMESTAMP))::INTEGER
    FROM public.battle_rooms br
    JOIN public.user_profiles up1 ON br.competitor_1_id = up1.id
    JOIN public.user_profiles up2 ON br.competitor_2_id = up2.id
    WHERE br.status = 'live'::public.battle_status
    AND br.end_time > CURRENT_TIMESTAMP
    ORDER BY br.start_time DESC;
END;
$func$;

-- 9. Enable RLS on all new tables
ALTER TABLE public.battle_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.battle_support_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.battle_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.battle_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.battle_spectators ENABLE ROW LEVEL SECURITY;

-- 10. RLS Policies using correct patterns
-- Pattern 4: Public Read, Private Write for battle rooms (viewers can see all battles)
CREATE POLICY "public_can_read_battle_rooms"
ON public.battle_rooms
FOR SELECT
TO public
USING (true);

CREATE POLICY "competitors_manage_own_battles"
ON public.battle_rooms
FOR ALL
TO authenticated
USING (competitor_1_id = auth.uid() OR competitor_2_id = auth.uid())
WITH CHECK (competitor_1_id = auth.uid() OR competitor_2_id = auth.uid());

-- Pattern 2: Simple user ownership for support actions
CREATE POLICY "users_manage_own_support_actions"
ON public.battle_support_actions
FOR ALL
TO authenticated
USING (supporter_id = auth.uid())
WITH CHECK (supporter_id = auth.uid());

-- Pattern 2: Simple user ownership for invitations
CREATE POLICY "users_manage_own_invitations"
ON public.battle_invitations
FOR ALL
TO authenticated
USING (inviter_id = auth.uid() OR invitee_id = auth.uid())
WITH CHECK (inviter_id = auth.uid());

-- Pattern 4: Public read for metrics (viewers need to see real-time stats)
CREATE POLICY "public_can_read_battle_metrics"
ON public.battle_metrics
FOR SELECT
TO public
USING (true);

CREATE POLICY "competitors_can_update_metrics"
ON public.battle_metrics
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.battle_rooms br
        WHERE br.id = battle_room_id
        AND (br.competitor_1_id = auth.uid() OR br.competitor_2_id = auth.uid())
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.battle_rooms br
        WHERE br.id = battle_room_id
        AND (br.competitor_1_id = auth.uid() OR br.competitor_2_id = auth.uid())
    )
);

-- Pattern 2: Simple user ownership for spectators
CREATE POLICY "users_manage_own_spectator_records"
ON public.battle_spectators
FOR ALL
TO authenticated
USING (spectator_id = auth.uid())
WITH CHECK (spectator_id = auth.uid());

-- 11. Triggers for automatic updates
CREATE OR REPLACE FUNCTION public.update_battle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$func$;

CREATE TRIGGER update_battle_rooms_updated_at
    BEFORE UPDATE ON public.battle_rooms
    FOR EACH ROW EXECUTE FUNCTION public.update_battle_updated_at();

CREATE TRIGGER update_battle_metrics_updated_at
    BEFORE UPDATE ON public.battle_metrics
    FOR EACH ROW EXECUTE FUNCTION public.update_battle_updated_at();

-- 12. Mock Data for Testing
DO $$
DECLARE
    user1_id UUID;
    user2_id UUID;
    user3_id UUID;
    product1_id UUID;
    product2_id UUID;
    stream1_id UUID;
    battle1_id UUID := gen_random_uuid();
    battle2_id UUID := gen_random_uuid();
BEGIN
    -- Get existing user IDs
    SELECT id INTO user1_id FROM public.user_profiles LIMIT 1 OFFSET 0;
    SELECT id INTO user2_id FROM public.user_profiles LIMIT 1 OFFSET 1;
    
    -- Create additional user for testing if needed
    INSERT INTO public.user_profiles (id, email, full_name, role)
    VALUES (gen_random_uuid(), 'competitor@battle.com', 'Battle Competitor', 'seller'::public.user_role)
    ON CONFLICT (email) DO NOTHING
    RETURNING id INTO user3_id;
    
    -- Use user3_id or fallback to user2_id
    user3_id := COALESCE(user3_id, user2_id);

    -- Get existing product and stream IDs
    SELECT id INTO product1_id FROM public.auction_items LIMIT 1 OFFSET 0;
    SELECT id INTO product2_id FROM public.auction_items LIMIT 1 OFFSET 1;
    SELECT id INTO stream1_id FROM public.live_streams LIMIT 1 OFFSET 0;

    -- Create sample battle rooms if we have the required data
    IF user1_id IS NOT NULL AND user3_id IS NOT NULL THEN
        INSERT INTO public.battle_rooms (
            id, title, description, 
            competitor_1_id, competitor_2_id,
            product_1_id, product_2_id,
            stream_id, status,
            start_time, end_time,
            competitor_1_support, competitor_2_support,
            total_viewers
        ) VALUES
        (battle1_id, 'iPhone vs Samsung Battle', 'Epic battle between the latest smartphone models',
         user1_id, user3_id,
         product1_id, product2_id,
         stream1_id, 'live'::public.battle_status,
         CURRENT_TIMESTAMP - INTERVAL '5 minutes',
         CURRENT_TIMESTAMP + INTERVAL '15 minutes',
         247, 189, 156),
        (battle2_id, 'Gaming Setup Showdown', 'Ultimate gaming setup battle for tech enthusiasts',
         user1_id, user3_id,
         product1_id, product2_id,
         NULL, 'upcoming'::public.battle_status,
         CURRENT_TIMESTAMP + INTERVAL '1 hour',
         CURRENT_TIMESTAMP + INTERVAL '1 hour 20 minutes',
         0, 0, 0);

        -- Create sample support actions
        INSERT INTO public.battle_support_actions (
            battle_room_id, supporter_id, competitor_id, support_type, amount, cost_credits
        ) VALUES
        (battle1_id, user1_id, user1_id, 'heart'::public.support_type, 5, 0),
        (battle1_id, user1_id, user1_id, 'coin'::public.support_type, 10, 50),
        (battle1_id, user3_id, user3_id, 'boost'::public.support_type, 1, 100);

        -- Create battle metrics
        INSERT INTO public.battle_metrics (
            battle_room_id, competitor_1_hearts, competitor_1_coins, competitor_1_boosts,
            competitor_2_hearts, competitor_2_coins, competitor_2_boosts,
            current_viewers, engagement_score
        ) VALUES
        (battle1_id, 127, 85, 35, 95, 72, 22, 156, 750),
        (battle2_id, 0, 0, 0, 0, 0, 0, 0, 0);

        -- Create sample spectators
        INSERT INTO public.battle_spectators (
            battle_room_id, spectator_id, total_support_given, favorite_competitor_id
        ) VALUES
        (battle1_id, user1_id, 15, user1_id),
        (battle1_id, user3_id, 8, user3_id);

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Mock data creation failed: %', SQLERRM;
END $$;