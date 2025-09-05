-- Location: supabase/migrations/20250126000001_add_view_count_function.sql
-- Description: Add view count increment function for auction details
-- Integration: Supports auction details page view tracking

-- Function to increment view count for auctions
CREATE OR REPLACE FUNCTION public.increment_view_count(auction_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Update view count for the auction
  UPDATE public.auction_items
  SET view_count = COALESCE(view_count, 0) + 1,
      updated_at = CURRENT_TIMESTAMP
  WHERE id = auction_id;
  
  -- Log the view (optional - for analytics)
  -- INSERT INTO public.auction_views (auction_id, viewed_at, viewer_ip)
  -- VALUES (auction_id, CURRENT_TIMESTAMP, inet_client_addr());
  
EXCEPTION
  WHEN OTHERS THEN
    -- Silently ignore errors to not break the main flow
    RAISE NOTICE 'Failed to increment view count for auction %: %', auction_id, SQLERRM;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.increment_view_count(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION public.increment_view_count(UUID) TO anon;
