-- Location: supabase/migrations/20250826212000_live_streaming_module.sql
-- Schema Analysis: Existing auction system with user_profiles, auction_items, bids
-- Integration Type: Addition - New live streaming module
-- Dependencies: user_profiles, auction_items (existing)

-- 1. Create enum types for live streaming
CREATE TYPE public.stream_status AS ENUM ('upcoming', 'live', 'ended', 'cancelled');
CREATE TYPE public.chat_message_type AS ENUM ('text', 'emoji', 'system');

-- 2. Create live_streams table
CREATE TABLE public.live_streams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    streamer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    auction_item_id UUID REFERENCES public.auction_items(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    agora_channel_id TEXT NOT NULL UNIQUE,
    agora_token TEXT,
    status public.stream_status DEFAULT 'upcoming'::public.stream_status,
    scheduled_start TIMESTAMPTZ NOT NULL,
    actual_start TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    viewer_count INTEGER DEFAULT 0,
    max_viewers INTEGER DEFAULT 0,
    stream_settings JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Create stream_viewers table (junction for many-to-many)
CREATE TABLE public.stream_viewers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stream_id UUID REFERENCES public.live_streams(id) ON DELETE CASCADE,
    viewer_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    left_at TIMESTAMPTZ,
    watch_duration INTEGER DEFAULT 0, -- in seconds
    UNIQUE(stream_id, viewer_id)
);

-- 4. Create stream_chat_messages table
CREATE TABLE public.stream_chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stream_id UUID REFERENCES public.live_streams(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    message_type public.chat_message_type DEFAULT 'text'::public.chat_message_type,
    content TEXT NOT NULL,
    emoji_data JSONB,
    is_pinned BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Create indexes for performance
CREATE INDEX idx_live_streams_streamer_id ON public.live_streams(streamer_id);
CREATE INDEX idx_live_streams_auction_item_id ON public.live_streams(auction_item_id);
CREATE INDEX idx_live_streams_status ON public.live_streams(status);
CREATE INDEX idx_live_streams_scheduled_start ON public.live_streams(scheduled_start);
CREATE INDEX idx_stream_viewers_stream_id ON public.stream_viewers(stream_id);
CREATE INDEX idx_stream_viewers_viewer_id ON public.stream_viewers(viewer_id);
CREATE INDEX idx_stream_chat_messages_stream_id ON public.stream_chat_messages(stream_id);
CREATE INDEX idx_stream_chat_messages_created_at ON public.stream_chat_messages(created_at);

-- 6. Create helper functions BEFORE RLS policies
CREATE OR REPLACE FUNCTION public.is_stream_participant(stream_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.live_streams ls
    WHERE ls.id = stream_uuid
    AND (ls.streamer_id = auth.uid() OR EXISTS (
        SELECT 1 FROM public.stream_viewers sv
        WHERE sv.stream_id = stream_uuid AND sv.viewer_id = auth.uid()
    ))
)
$$;

-- 7. Enable RLS on all tables
ALTER TABLE public.live_streams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stream_viewers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stream_chat_messages ENABLE ROW LEVEL SECURITY;

-- 8. Create RLS policies following proper patterns
-- Pattern 2: Simple user ownership for live_streams
CREATE POLICY "streamers_manage_own_live_streams"
ON public.live_streams
FOR ALL
TO authenticated
USING (streamer_id = auth.uid())
WITH CHECK (streamer_id = auth.uid());

-- Pattern 4: Public read for live streams, private write
CREATE POLICY "public_can_read_active_live_streams"
ON public.live_streams
FOR SELECT
TO public
USING (status = 'live'::public.stream_status);

-- Pattern 2: Simple user ownership for stream_viewers
CREATE POLICY "users_manage_own_stream_viewers"
ON public.stream_viewers
FOR ALL
TO authenticated
USING (viewer_id = auth.uid())
WITH CHECK (viewer_id = auth.uid());

-- Pattern 2: Simple user ownership for chat messages
CREATE POLICY "users_manage_own_stream_chat_messages"
ON public.stream_chat_messages
FOR ALL
TO authenticated
USING (sender_id = auth.uid())
WITH CHECK (sender_id = auth.uid());

-- Pattern 7: Complex access for chat viewing (participants can read)
CREATE POLICY "participants_can_read_stream_chat_messages"
ON public.stream_chat_messages
FOR SELECT
TO authenticated
USING (public.is_stream_participant(stream_id));

-- 9. Create triggers for updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_live_streams_updated_at
    BEFORE UPDATE ON public.live_streams
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- 10. Mock data for live streaming
DO $$
DECLARE
    existing_seller_id UUID;
    existing_auction_id UUID;
    stream_id UUID := gen_random_uuid();
    viewer_id UUID;
BEGIN
    -- Get existing seller and auction from current data
    SELECT id INTO existing_seller_id FROM public.user_profiles WHERE role = 'admin' LIMIT 1;
    SELECT id INTO existing_auction_id FROM public.auction_items WHERE status = 'live' LIMIT 1;
    
    IF existing_seller_id IS NOT NULL AND existing_auction_id IS NOT NULL THEN
        -- Create sample live stream
        INSERT INTO public.live_streams (
            id, streamer_id, auction_item_id, title, description, 
            agora_channel_id, status, scheduled_start, actual_start,
            viewer_count, max_viewers
        ) VALUES (
            stream_id, existing_seller_id, existing_auction_id,
            'Live iPhone 15 Pro Max Auction', 
            'Don''t miss this amazing opportunity to bid on the latest iPhone!',
            'channel_' || extract(epoch from now())::text,
            'live'::public.stream_status,
            now() - interval '1 hour',
            now() - interval '30 minutes',
            45, 67
        );
        
        -- Get another user as viewer
        SELECT id INTO viewer_id FROM public.user_profiles 
        WHERE id != existing_seller_id LIMIT 1;
        
        IF viewer_id IS NOT NULL THEN
            -- Add viewer
            INSERT INTO public.stream_viewers (stream_id, viewer_id, joined_at, watch_duration)
            VALUES (stream_id, viewer_id, now() - interval '20 minutes', 1200);
            
            -- Add sample chat messages
            INSERT INTO public.stream_chat_messages (stream_id, sender_id, message_type, content) VALUES
                (stream_id, viewer_id, 'text'::public.chat_message_type, 'This iPhone looks amazing! 😍'),
                (stream_id, existing_seller_id, 'text'::public.chat_message_type, 'Thank you! Still in perfect condition with all original accessories'),
                (stream_id, viewer_id, 'text'::public.chat_message_type, 'What''s the current bid?'),
                (stream_id, existing_seller_id, 'system'::public.chat_message_type, 'Current highest bid: $520');
        END IF;
    ELSE
        RAISE NOTICE 'Existing user or auction not found. Create users and auctions first.';
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;