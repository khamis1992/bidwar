-- Location: supabase/migrations/20250126000002_create_auctions_storage_bucket.sql
-- Description: Create storage bucket for auction images
-- Integration: Supports image upload in CreateAuctionScreen

-- Create storage bucket for auction images
INSERT INTO storage.buckets (id, name, public)
VALUES ('auctions', 'auctions', true);

-- Set up RLS policies for the auctions bucket
CREATE POLICY "Allow authenticated users to upload auction images"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'auctions');

CREATE POLICY "Allow public read access to auction images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'auctions');

CREATE POLICY "Allow users to update their own auction images"
ON storage.objects
FOR UPDATE
TO authenticated
USING (bucket_id = 'auctions' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Allow users to delete their own auction images"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'auctions' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Create function to clean up unused auction images
CREATE OR REPLACE FUNCTION public.cleanup_unused_auction_images()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Delete storage objects that are not referenced in auction_items
  DELETE FROM storage.objects
  WHERE bucket_id = 'auctions'
    AND name NOT IN (
      SELECT DISTINCT jsonb_array_elements_text(images)
      FROM public.auction_items
      WHERE images IS NOT NULL
    )
    -- Only delete files older than 1 hour to avoid race conditions
    AND created_at < CURRENT_TIMESTAMP - INTERVAL '1 hour';
    
  RAISE NOTICE 'Cleanup completed for unused auction images';
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.cleanup_unused_auction_images() TO authenticated;
