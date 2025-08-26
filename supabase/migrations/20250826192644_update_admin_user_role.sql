-- Location: supabase/migrations/20250826192644_update_admin_user_role.sql
-- Schema Analysis: Complete auction application with authentication and role system exists
-- Integration Type: Modification - Update specific user's role to admin
-- Dependencies: Uses existing user_profiles table and user_role enum

-- Update the admin@admin.com user role from 'bidder' to 'admin'
-- This user already exists in the database and just needs role elevation
UPDATE public.user_profiles 
SET 
    role = 'admin'::public.user_role,
    updated_at = CURRENT_TIMESTAMP
WHERE email = 'admin@admin.com';

-- Verify the update was successful
DO $$
DECLARE
    updated_count INTEGER;
BEGIN
    -- Check if the update was successful
    SELECT COUNT(*) INTO updated_count
    FROM public.user_profiles
    WHERE email = 'admin@admin.com' AND role = 'admin';
    
    IF updated_count = 1 THEN
        RAISE NOTICE 'Successfully updated admin@admin.com to admin role';
    ELSE
        RAISE NOTICE 'Warning: admin@admin.com user not found or update failed';
    END IF;
END $$;