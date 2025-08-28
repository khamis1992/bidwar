import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import './supabase_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  SupabaseClient? get _client => SupabaseService.instance.safeClient;

  // Get current user
  User? get currentUser => _client?.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  // Get current session
  Session? get currentSession => _client?.auth.currentSession;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = 'bidder',
  }) async {
    if (_client == null) {
      throw Exception(
          'Supabase not initialized. Please check your connection.');
    }

    try {
      final response = await _client!.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'role': role},
      );
      return response;
    } catch (error) {
      throw Exception('Sign up failed: $error');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (_client == null) {
      throw Exception(
          'Supabase not initialized. Please check your connection.');
    }

    try {
      final response = await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      // More specific error handling for admin login
      String errorMessage = error.toString();
      if (errorMessage.contains('Invalid login credentials') &&
          email == 'admin@bidwar.com') {
        throw Exception(
          'Admin credentials invalid. Please ensure the admin account is properly set up in the database.',
        );
      }
      throw Exception('Sign in failed: $error');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign out failed: $error');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  // Check if current user is admin
  Future<bool> isAdmin() async {
    try {
      if (!isLoggedIn) return false;

      // Check user metadata for admin role
      final user = currentUser!;
      final userRole = user.userMetadata?['role'] as String?;
      final appRole = user.appMetadata['role'] as String?;

      return userRole == 'admin' || appRole == 'admin';
    } catch (error) {
      return false;
    }
  }

  // Update user profile
  Future<UserResponse> updateProfile({
    String? fullName,
    String? phone,
    Map<String, dynamic>? address,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;

      return await _client.auth.updateUser(UserAttributes(data: updates));
    } catch (error) {
      throw Exception('Profile update failed: $error');
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Get user profile data from database
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (!isLoggedIn) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  // Update user profile in database
  Future<void> updateUserProfile({
    String? fullName,
    String? phone,
    Map<String, dynamic>? address,
    String? profilePictureUrl,
  }) async {
    try {
      if (!isLoggedIn) throw Exception('User not logged in');

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (fullName != null) updates['full_name'] = fullName;
      if (phone != null) updates['phone'] = phone;
      if (address != null) updates['address'] = address;
      if (profilePictureUrl != null)
        updates['profile_picture_url'] = profilePictureUrl;

      await _client
          .from('user_profiles')
          .update(updates)
          .eq('id', currentUser!.id);
    } catch (error) {
      throw Exception('Failed to update profile: $error');
    }
  }

  // Get user credit balance
  Future<int> getCreditBalance() async {
    try {
      if (!isLoggedIn) return 0;

      final response = await _client
          .from('user_profiles')
          .select('credit_balance')
          .eq('id', currentUser!.id)
          .single();

      return response['credit_balance'] ?? 0;
    } catch (error) {
      throw Exception('Failed to get credit balance: $error');
    }
  }

  // Get current user profile with UserProfile model
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      if (!isLoggedIn) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return UserProfile.fromMap(response);
    } catch (error) {
      throw Exception('Failed to get current user profile: $error');
    }
  }
}
