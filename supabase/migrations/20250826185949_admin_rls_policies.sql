-- Location: supabase/migrations/20250826185949_admin_rls_policies.sql
-- Schema Analysis: Complete auction application schema exists with user management
-- Integration Type: Enhancement - Add admin RLS policies for comprehensive user management
-- Dependencies: user_profiles, auction_items, bids, credit_transactions, notifications

-- Add admin RLS policies to allow admin users full access to all tables for management console

-- Function to check if user is admin (using auth.users metadata - safest approach)
CREATE OR REPLACE FUNCTION public.is_admin_from_auth()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM auth.users au
    WHERE au.id = auth.uid() 
    AND (au.raw_user_meta_data->>'role' = 'admin' 
         OR au.raw_app_meta_data->>'role' = 'admin')
)
$$;

-- Function to check if user has admin role from user_profiles (for non-user tables)
CREATE OR REPLACE FUNCTION public.has_admin_role()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
SELECT EXISTS (
    SELECT 1 FROM public.user_profiles up
    WHERE up.id = auth.uid() AND up.role = 'admin'::public.user_role
)
$$;

-- Admin access policy for user_profiles table (using auth metadata to avoid circular dependency)
CREATE POLICY "admin_full_access_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (public.is_admin_from_auth())
WITH CHECK (public.is_admin_from_auth());

-- Admin access policies for other tables (safe to use user_profiles function)
CREATE POLICY "admin_full_access_auction_items"
ON public.auction_items
FOR ALL
TO authenticated
USING (public.has_admin_role())
WITH CHECK (public.has_admin_role());

CREATE POLICY "admin_full_access_bids"
ON public.bids
FOR ALL
TO authenticated
USING (public.has_admin_role())
WITH CHECK (public.has_admin_role());

CREATE POLICY "admin_full_access_credit_transactions"
ON public.credit_transactions
FOR ALL
TO authenticated
USING (public.has_admin_role())
WITH CHECK (public.has_admin_role());

CREATE POLICY "admin_full_access_notifications"
ON public.notifications
FOR ALL
TO authenticated
USING (public.has_admin_role())
WITH CHECK (public.has_admin_role());

-- Mock data: Create admin user for testing
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
BEGIN
    -- Create admin auth user
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@bidwar.com', crypt('Admin123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Admin User", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"], "role": "admin"}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Update existing user to admin for testing if exists
    UPDATE public.user_profiles 
    SET role = 'admin'::public.user_role 
    WHERE email = 'admin@bidwar.com' OR id = admin_uuid;

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Admin user already exists, skipping creation';
    WHEN OTHERS THEN
        RAISE NOTICE 'Error creating admin user: %', SQLERRM;
END $$;