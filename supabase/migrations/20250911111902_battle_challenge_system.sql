-- Schema Analysis: Existing auction system with user_profiles, auction_items, live_streams, product_inventory
-- Integration Type: Extension - Adding battle system while preserving existing infrastructure
-- Dependencies: user_profiles, product_inventory, categories, live_streams

-- 1. ENUMS FOR BATTLE SYSTEM
CREATE TYPE public.battle_status AS ENUM ('pending', 'active', 'ended', 'cancelled');
CREATE TYPE public.battle_invitation_status AS ENUM ('pending', 'accepted', 'declined', 'expired');
CREATE TYPE public.support_type AS ENUM ('coins', 'hearts', 'energy', 'gifts');

-- 2. BATTLE ROOMS TABLE
CREATE TABLE public.battle_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    creator_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    competitor_a_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    competitor_b_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    product_a_id UUID REFERENCES public.product_inventory(id) ON DELETE SET NULL,
    product_b_id UUID REFERENCES public.product_inventory(id) ON DELETE SET NULL,
    status public.battle_status DEFAULT 'pending'::public.battle_status,
    battle_duration_minutes INTEGER DEFAULT 30,
    min_support_threshold INTEGER DEFAULT 100,
    total_support_a INTEGER DEFAULT 0,
    total_support_b INTEGER DEFAULT 0,
    viewer_count INTEGER DEFAULT 0,
    max_viewers INTEGER DEFAULT 0,
    scheduled_start TIMESTAMPTZ,
    actual_start TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    winner_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    stream_settings JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. BATTLE INVITATIONS TABLE
CREATE TABLE public.battle_invitations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    battle_room_id UUID REFERENCES public.battle_rooms(id) ON DELETE CASCADE,
    inviter_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    invitee_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.product_inventory(id) ON DELETE SET NULL,
    status public.battle_invitation_status DEFAULT 'pending'::public.battle_invitation_status,
    message TEXT,
    expires_at TIMESTAMPTZ,
    responded_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. BATTLE SUPPORT TABLE
CREATE TABLE public.battle_support (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    battle_room_id UUID REFERENCES public.battle_rooms(id) ON DELETE CASCADE,
    supporter_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    competitor_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    support_type public.support_type DEFAULT 'coins'::public.support_type,
    amount INTEGER NOT NULL CHECK (amount > 0),
    cost_in_credits INTEGER NOT NULL CHECK (cost_in_credits > 0),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. BATTLE PARTICIPANTS VIEW
CREATE TABLE public.battle_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    battle_room_id UUID REFERENCES public.battle_rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMPTZ,
    watch_duration INTEGER DEFAULT 0,
    UNIQUE(battle_room_id, user_id)
);

-- 6. INDEXES
CREATE INDEX idx_battle_rooms_status ON public.battle_rooms(status);
CREATE INDEX idx_battle_rooms_creator_id ON public.battle_rooms(creator_id);
CREATE INDEX idx_battle_rooms_scheduled_start ON public.battle_rooms(scheduled_start);
CREATE INDEX idx_battle_rooms_category_id ON public.battle_rooms(category_id);
CREATE INDEX idx_battle_invitations_invitee_id ON public.battle_invitations(invitee_id);
CREATE INDEX idx_battle_invitations_status ON public.battle_invitations(status);
CREATE INDEX idx_battle_support_battle_room_id ON public.battle_support(battle_room_id);
CREATE INDEX idx_battle_support_competitor_id ON public.battle_support(competitor_id);
CREATE INDEX idx_battle_participants_battle_room_id ON public.battle_participants(battle_room_id);

-- 7. FUNCTIONS
CREATE OR REPLACE FUNCTION public.update_battle_support_totals()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    -- Update totals for the battle room based on which competitor received support
    UPDATE public.battle_rooms
    SET 
        total_support_a = CASE 
            WHEN NEW.competitor_id = competitor_a_id THEN total_support_a + NEW.amount
            ELSE total_support_a
        END,
        total_support_b = CASE 
            WHEN NEW.competitor_id = competitor_b_id THEN total_support_b + NEW.amount
            ELSE total_support_b
        END,
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.battle_room_id;
    
    RETURN NEW;
END;
$func$;

CREATE OR REPLACE FUNCTION public.update_battle_viewer_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
BEGIN
    -- Update current viewer count and max viewers for battle room
    IF TG_OP = 'INSERT' THEN
        UPDATE public.battle_rooms
        SET 
            viewer_count = viewer_count + 1,
            max_viewers = GREATEST(max_viewers, viewer_count + 1),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.battle_room_id;
    ELSIF TG_OP = 'UPDATE' AND OLD.left_at IS NULL AND NEW.left_at IS NOT NULL THEN
        UPDATE public.battle_rooms
        SET 
            viewer_count = GREATEST(0, viewer_count - 1),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.battle_room_id;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$func$;

-- 8. ENABLE RLS
ALTER TABLE public.battle_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.battle_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.battle_support ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.battle_participants ENABLE ROW LEVEL SECURITY;

-- 9. RLS POLICIES
-- Battle Rooms - Public read, creator/participants manage
CREATE POLICY "public_can_read_battle_rooms"
ON public.battle_rooms
FOR SELECT
TO public
USING (true);

CREATE POLICY "creators_manage_own_battle_rooms"
ON public.battle_rooms
FOR ALL
TO authenticated
USING (creator_id = auth.uid())
WITH CHECK (creator_id = auth.uid());

-- Battle Invitations - Users manage their own invitations
CREATE POLICY "users_manage_own_battle_invitations"
ON public.battle_invitations
FOR ALL
TO authenticated
USING (inviter_id = auth.uid() OR invitee_id = auth.uid())
WITH CHECK (inviter_id = auth.uid());

-- Battle Support - Users manage their own support
CREATE POLICY "users_manage_own_battle_support"
ON public.battle_support
FOR ALL
TO authenticated
USING (supporter_id = auth.uid())
WITH CHECK (supporter_id = auth.uid());

-- Battle Participants - Users manage their own participation
CREATE POLICY "users_manage_own_battle_participants"
ON public.battle_participants
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Admin access for all battle tables
CREATE POLICY "admin_full_access_battle_rooms"
ON public.battle_rooms
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

CREATE POLICY "admin_full_access_battle_invitations"
ON public.battle_invitations
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

CREATE POLICY "admin_full_access_battle_support"
ON public.battle_support
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- 10. TRIGGERS
CREATE TRIGGER update_battle_support_totals_trigger
    AFTER INSERT ON public.battle_support
    FOR EACH ROW EXECUTE FUNCTION public.update_battle_support_totals();

CREATE TRIGGER update_battle_participants_updated_at
    BEFORE UPDATE ON public.battle_rooms
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_battle_viewer_count_trigger
    AFTER INSERT OR UPDATE ON public.battle_participants
    FOR EACH ROW EXECUTE FUNCTION public.update_battle_viewer_count();

-- 11. MOCK DATA FOR BATTLE SYSTEM
DO $$
DECLARE
    existing_user_id UUID;
    existing_user_id_2 UUID;
    existing_product_id_1 UUID;
    existing_product_id_2 UUID;
    existing_category_id UUID;
    battle_room_id UUID := gen_random_uuid();
    invitation_id UUID := gen_random_uuid();
BEGIN
    -- Get existing users and products
    SELECT id INTO existing_user_id FROM public.user_profiles LIMIT 1;
    SELECT id INTO existing_user_id_2 FROM public.user_profiles OFFSET 1 LIMIT 1;
    SELECT id INTO existing_product_id_1 FROM public.product_inventory LIMIT 1;
    SELECT id INTO existing_product_id_2 FROM public.product_inventory OFFSET 1 LIMIT 1;
    SELECT id INTO existing_category_id FROM public.categories LIMIT 1;
    
    -- Create battle rooms if users exist
    IF existing_user_id IS NOT NULL THEN
        INSERT INTO public.battle_rooms (
            id, title, description, category_id, creator_id, competitor_a_id, 
            product_a_id, status, battle_duration_minutes, scheduled_start
        ) VALUES
            (battle_room_id, 'Epic iPhone vs MacBook Battle', 'Two tech giants clash in the ultimate showdown! Support your favorite and help them win!', 
             existing_category_id, existing_user_id, existing_user_id, existing_product_id_1,
             'pending'::public.battle_status, 30, CURRENT_TIMESTAMP + INTERVAL '2 hours'),
            (gen_random_uuid(), 'Fashion Face-Off Challenge', 'Style meets substance in this heated fashion battle. Which look will reign supreme?',
             existing_category_id, existing_user_id, existing_user_id, existing_product_id_2,
             'active'::public.battle_status, 45, CURRENT_TIMESTAMP - INTERVAL '10 minutes');

        -- Create battle invitation
        IF existing_user_id_2 IS NOT NULL THEN
            INSERT INTO public.battle_invitations (
                id, battle_room_id, inviter_id, invitee_id, product_id, 
                message, expires_at
            ) VALUES
                (invitation_id, battle_room_id, existing_user_id, existing_user_id_2, existing_product_id_2,
                 'Ready to battle? I challenge you to an epic showdown!', 
                 CURRENT_TIMESTAMP + INTERVAL '24 hours');
        END IF;

        -- Create battle support
        INSERT INTO public.battle_support (
            battle_room_id, supporter_id, competitor_id, support_type, amount, cost_in_credits
        ) VALUES
            (battle_room_id, existing_user_id, existing_user_id, 'coins'::public.support_type, 50, 25),
            (battle_room_id, existing_user_id, existing_user_id, 'hearts'::public.support_type, 100, 10);

        -- Create battle participants
        INSERT INTO public.battle_participants (
            battle_room_id, user_id
        ) VALUES
            (battle_room_id, existing_user_id);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Battle system mock data creation failed: %', SQLERRM;
END $$;