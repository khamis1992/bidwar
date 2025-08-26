-- Location: supabase/migrations/20250826191926_fix_admin_auth.sql
-- Schema Analysis: Existing auction application schema with user_profiles table containing admin user
-- Integration Type: Authentication fix - Adding missing auth.users record for admin login
-- Dependencies: Existing user_profiles table with admin@bidwar.com record

-- Fix admin authentication by creating the missing auth.users record
-- The admin user exists in user_profiles but not in auth.users, causing login failures

DO $$
DECLARE
    admin_profile_id UUID;
    admin_email TEXT := 'admin@bidwar.com';
    admin_password TEXT := 'admin123';
BEGIN
    -- Get the existing admin profile ID
    SELECT id INTO admin_profile_id 
    FROM public.user_profiles 
    WHERE email = admin_email AND role = 'admin'::public.user_role;
    
    IF admin_profile_id IS NOT NULL THEN
        -- Create the missing auth.users record with all required fields
        -- This will enable login for the existing admin user
        INSERT INTO auth.users (
            id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
            created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
            is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
            recovery_token, recovery_sent_at, email_change_token_new, email_change,
            email_change_sent_at, email_change_token_current, email_change_confirm_status,
            reauthentication_token, reauthentication_sent_at, phone, phone_change,
            phone_change_token, phone_change_sent_at
        ) VALUES (
            admin_profile_id, -- Use existing profile ID for consistency
            '00000000-0000-0000-0000-000000000000', 
            'authenticated', 
            'authenticated',
            admin_email,
            crypt(admin_password, gen_salt('bf', 10)), -- Hash the password
            now(), -- Confirm email immediately for admin
            now(), 
            now(),
            '{"full_name": "Admin User", "role": "admin"}'::jsonb, -- Set admin role in metadata
            '{"provider": "email", "providers": ["email"], "role": "admin"}'::jsonb,
            false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null
        )
        ON CONFLICT (id) DO UPDATE SET
            raw_user_meta_data = '{"full_name": "Admin User", "role": "admin"}'::jsonb,
            raw_app_meta_data = '{"provider": "email", "providers": ["email"], "role": "admin"}'::jsonb,
            email_confirmed_at = now(),
            updated_at = now();
            
        RAISE NOTICE 'Admin auth record created/updated successfully for %', admin_email;
    ELSE
        RAISE NOTICE 'Admin profile not found in user_profiles table';
    END IF;
    
EXCEPTION
    WHEN unique_violation THEN
        -- If auth.users record already exists, update the metadata to ensure admin role
        UPDATE auth.users SET
            raw_user_meta_data = '{"full_name": "Admin User", "role": "admin"}'::jsonb,
            raw_app_meta_data = '{"provider": "email", "providers": ["email"], "role": "admin"}'::jsonb,
            email_confirmed_at = now(),
            updated_at = now()
        WHERE email = admin_email;
        
        RAISE NOTICE 'Admin auth record updated with admin role metadata';
        
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating admin auth record: %', SQLERRM;
END $$;

-- Verify the fix by checking that is_admin_from_auth() will work
-- This function checks auth.users metadata for admin role
DO $$
BEGIN
    -- Test query to verify admin role detection
    IF EXISTS (
        SELECT 1 FROM auth.users au
        WHERE au.email = 'admin@bidwar.com'
        AND (au.raw_user_meta_data->>'role' = 'admin' 
             OR au.raw_app_meta_data->>'role' = 'admin')
    ) THEN
        RAISE NOTICE 'SUCCESS: Admin role properly detected in auth metadata';
    ELSE
        RAISE NOTICE 'WARNING: Admin role not found in auth metadata';
    END IF;
END $$;