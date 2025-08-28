-- Location: supabase/migrations/20250826211000_populate_sample_data.sql
-- Schema Analysis: Complete auction system exists with all tables
-- Integration Type: addition - adding sample data only
-- Dependencies: auction_items, user_profiles, categories, bids, credit_transactions

-- Populate sample data for existing auction application
DO $$
DECLARE
    category1_id UUID := gen_random_uuid();
    category2_id UUID := gen_random_uuid();
    category3_id UUID := gen_random_uuid();
    auction1_id UUID := gen_random_uuid();
    auction2_id UUID := gen_random_uuid();
    auction3_id UUID := gen_random_uuid();
    auction4_id UUID := gen_random_uuid();
    auction5_id UUID := gen_random_uuid();
    user1_id UUID;
    user2_id UUID;
BEGIN
    -- Get existing user IDs
    SELECT id INTO user1_id FROM public.user_profiles LIMIT 1;
    
    -- If no users exist, skip auction creation
    IF user1_id IS NULL THEN
        RAISE NOTICE 'No users found. Creating sample categories only.';
        
        -- Create categories
        INSERT INTO public.categories (id, name, description, image_url, is_active) VALUES
            (category1_id, 'Electronics', 'Electronic devices and gadgets', 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400', true),
            (category2_id, 'Art & Collectibles', 'Artwork and collectible items', 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400', true),
            (category3_id, 'Automotive', 'Cars, motorcycles and automotive parts', 'https://images.unsplash.com/photo-1494976688531-05c0c29e21e7?w=400', true);
        
        RETURN;
    END IF;

    -- Get a second user if available
    SELECT id INTO user2_id FROM public.user_profiles WHERE id != user1_id LIMIT 1;
    IF user2_id IS NULL THEN
        user2_id := user1_id;
    END IF;

    -- Create categories
    INSERT INTO public.categories (id, name, description, image_url, is_active) VALUES
        (category1_id, 'Electronics', 'Electronic devices and gadgets', 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400', true),
        (category2_id, 'Art & Collectibles', 'Artwork and collectible items', 'https://images.unsplash.com/photo-1541961017774-22349e4a1262?w=400', true),
        (category3_id, 'Automotive', 'Cars, motorcycles and automotive parts', 'https://images.unsplash.com/photo-1494976688531-05c0c29e21e7?w=400', true)
    ON CONFLICT (name) DO NOTHING;

    -- Create sample auction items
    INSERT INTO public.auction_items (
        id, seller_id, category_id, title, description, starting_price, reserve_price,
        current_highest_bid, bid_increment, condition, brand, model, specifications,
        images, status, start_time, end_time, featured, view_count
    ) VALUES
        -- Live Electronics Auction
        (auction1_id, user1_id, category1_id, 
         'iPhone 15 Pro Max - 256GB', 
         'Brand new iPhone 15 Pro Max in Natural Titanium. Complete with original box and accessories.',
         50000, 75000, 52000, 500, 'New', 'Apple', 'iPhone 15 Pro Max',
         '{"storage": "256GB", "color": "Natural Titanium", "network": "5G", "warranty": "1 year"}'::jsonb,
         '["https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=400", "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400"]'::jsonb,
         'live'::auction_status, 
         NOW() - INTERVAL '2 hours', NOW() + INTERVAL '22 hours',
         true, 147),

        -- Upcoming Art Auction
        (auction2_id, user2_id, category2_id,
         'Original Abstract Painting',
         'Beautiful original abstract painting by emerging artist. Oil on canvas, 60x80cm.',
         15000, 25000, 0, 250, 'Excellent', 'Independent Artist', 'Untitled #3',
         '{"medium": "Oil on Canvas", "dimensions": "60x80cm", "year": "2024", "style": "Abstract"}'::jsonb,
         '["https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400", "https://images.unsplash.com/photo-1571115764595-644a1f56a55c?w=400"]'::jsonb,
         'upcoming'::auction_status,
         NOW() + INTERVAL '6 hours', NOW() + INTERVAL '30 hours',
         false, 23),

        -- Live Featured Automotive Auction
        (auction3_id, user1_id, category3_id,
         'BMW M3 Competition 2022',
         'Stunning BMW M3 Competition with low mileage. Perfect condition, full service history.',
         450000, 520000, 465000, 5000, 'Excellent', 'BMW', 'M3 Competition',
         '{"year": "2022", "mileage": "12000 km", "engine": "3.0L Twin Turbo", "transmission": "Automatic", "color": "Alpine White"}'::jsonb,
         '["https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400", "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400"]'::jsonb,
         'live'::auction_status,
         NOW() - INTERVAL '4 hours', NOW() + INTERVAL '20 hours',
         true, 892),

        -- Ended Electronics Auction
        (auction4_id, user2_id, category1_id,
         'MacBook Pro 16-inch M3',
         'High-performance MacBook Pro with M3 chip. Ideal for professionals and creators.',
         180000, 220000, 195000, 1000, 'Like New', 'Apple', 'MacBook Pro 16-inch',
         '{"processor": "M3 Max", "ram": "32GB", "storage": "1TB SSD", "color": "Space Black"}'::jsonb,
         '["https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400", "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400"]'::jsonb,
         'ended'::auction_status,
         NOW() - INTERVAL '3 days', NOW() - INTERVAL '1 day',
         false, 234),

        -- Live Art Auction
        (auction5_id, user1_id, category2_id,
         'Vintage Photography Collection',
         'Rare collection of vintage photographs from the 1960s. Black and white prints in excellent condition.',
         8000, 12000, 8500, 100, 'Very Good', 'Various Artists', 'Vintage Collection',
         '{"era": "1960s", "type": "Black & White Prints", "quantity": "25 pieces", "condition": "Archival Quality"}'::jsonb,
         '["https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=400", "https://images.unsplash.com/photo-1581833971358-2c8b550f87b3?w=400"]'::jsonb,
         'live'::auction_status,
         NOW() - INTERVAL '1 hour', NOW() + INTERVAL '23 hours',
         false, 67);

    -- Create sample bids for live auctions
    INSERT INTO public.bids (auction_item_id, bidder_id, bid_amount, status, is_auto_bid, placed_at) VALUES
        -- Bids for iPhone auction
        (auction1_id, user2_id, 50000, 'outbid'::bid_status, false, NOW() - INTERVAL '90 minutes'),
        (auction1_id, user1_id, 51000, 'outbid'::bid_status, false, NOW() - INTERVAL '75 minutes'),
        (auction1_id, user2_id, 52000, 'winning'::bid_status, false, NOW() - INTERVAL '60 minutes'),
        
        -- Bids for BMW auction
        (auction3_id, user2_id, 450000, 'outbid'::bid_status, false, NOW() - INTERVAL '3 hours'),
        (auction3_id, user1_id, 460000, 'outbid'::bid_status, false, NOW() - INTERVAL '2 hours'),
        (auction3_id, user2_id, 465000, 'winning'::bid_status, false, NOW() - INTERVAL '90 minutes'),
        
        -- Bids for Photography collection
        (auction5_id, user2_id, 8000, 'outbid'::bid_status, false, NOW() - INTERVAL '45 minutes'),
        (auction5_id, user1_id, 8500, 'winning'::bid_status, false, NOW() - INTERVAL '30 minutes');

    -- Create sample credit transactions
    INSERT INTO public.credit_transactions (
        user_id, transaction_type, amount, description, payment_status, 
        related_auction_id, created_at
    ) VALUES
        -- Credit purchases
        (user1_id, 'credit_purchase'::transaction_type, 10000, 'Credit purchase - Premium Pack', 'completed'::payment_status, NULL, NOW() - INTERVAL '1 week'),
        (user2_id, 'credit_purchase'::transaction_type, 5000, 'Credit purchase - Standard Pack', 'completed'::payment_status, NULL, NOW() - INTERVAL '5 days'),
        
        -- Bid transactions
        (user1_id, 'bid_placed'::transaction_type, -10, 'Bid placed on iPhone 15 Pro Max', 'completed'::payment_status, auction1_id, NOW() - INTERVAL '75 minutes'),
        (user2_id, 'bid_placed'::transaction_type, -15, 'Bid placed on BMW M3 Competition', 'completed'::payment_status, auction3_id, NOW() - INTERVAL '90 minutes'),
        (user1_id, 'bid_placed'::transaction_type, -5, 'Bid placed on Vintage Photography Collection', 'completed'::payment_status, auction5_id, NOW() - INTERVAL '30 minutes');

    -- Create sample notifications
    INSERT INTO public.notifications (
        user_id, title, message, type, is_read, related_auction_id, created_at
    ) VALUES
        (user1_id, 'Bid Placed Successfully', 'Your bid of ₹51,000 has been placed on iPhone 15 Pro Max', 'bid_placed', false, auction1_id, NOW() - INTERVAL '75 minutes'),
        (user2_id, 'Outbid Notification', 'You have been outbid on iPhone 15 Pro Max. Current highest bid: ₹52,000', 'outbid', false, auction1_id, NOW() - INTERVAL '60 minutes'),
        (user1_id, 'Auction Ending Soon', 'BMW M3 Competition auction ends in 20 hours', 'auction_ending', false, auction3_id, NOW() - INTERVAL '2 hours'),
        (user2_id, 'New Auction Available', 'New auction started: Vintage Photography Collection', 'new_auction', true, auction5_id, NOW() - INTERVAL '1 hour');

    RAISE NOTICE 'Sample data populated successfully with % auctions created', 5;

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key constraint error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Error populating sample data: %', SQLERRM;
END $$;