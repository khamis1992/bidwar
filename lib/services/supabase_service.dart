import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './environment_service.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance =>
      _instance ??= SupabaseService._internal();

  SupabaseService._internal();

  SupabaseClient? _client;
  bool _isInitialized = false;

  // Safe client access with null check
  SupabaseClient? get safeClient => _client;

  // Get client with validation
  SupabaseClient get client {
    if (_client == null) {
      throw Exception(
          'Supabase client is not initialized. Call initialize() first.');
    }
    return _client!;
  }

  // Check if service is initialized
  static bool get isInitialized => _instance?._isInitialized ?? false;

  // Check if we have valid credentials
  static bool get hasValidCredentials =>
      EnvironmentService.hasValidSupabaseCredentials();

  // Initialize Supabase with enhanced error handling and validation
  static Future<bool> initialize() async {
    try {
      print('🔧 SupabaseService: Starting initialization...');

      // Validate environment configuration first
      if (!EnvironmentService.hasValidSupabaseCredentials()) {
        print('❌ Supabase credentials not available or invalid');
        print(
            '   - URL configured: ${EnvironmentService.get('SUPABASE_URL')?.isNotEmpty ?? false}');
        print(
            '   - Key configured: ${EnvironmentService.get('SUPABASE_ANON_KEY')?.isNotEmpty ?? false}');
        return false;
      }

      final String? supabaseUrl = EnvironmentService.get('SUPABASE_URL');
      final String? supabaseAnonKey =
          EnvironmentService.get('SUPABASE_ANON_KEY');

      if (supabaseUrl == null || supabaseAnonKey == null) {
        print('❌ Supabase credentials are null');
        return false;
      }

      print(
          '🔧 Initializing Supabase with URL: ${supabaseUrl.length > 20 ? '${supabaseUrl.substring(0, 20)}...' : supabaseUrl}');

      // Initialize Supabase Flutter
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );

      // Set up instance
      _instance ??= SupabaseService._internal();
      _instance!._client = Supabase.instance.client;
      _instance!._isInitialized = true;

      // Test the connection to make sure everything works
      final connectionTest = await _instance!.checkConnection();
      if (!connectionTest) {
        print('⚠️ Supabase initialized but connection test failed');
        // Still return true since initialization succeeded
      }

      print('✅ Supabase initialized successfully');
      return true;
    } catch (e, stackTrace) {
      print('❌ SupabaseService initialization failed: $e');
      if (kDebugMode) {
        print('Stack trace: $stackTrace');
      }

      // Reset instance on failure
      _instance?._isInitialized = false;
      _instance?._client = null;
      return false;
    }
  }

  // Test connection to Supabase with timeout and error categorization
  Future<bool> checkConnection({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (_client == null) {
      print('❌ Cannot check connection: Supabase client is null');
      return false;
    }

    try {
      print('🔧 Testing Supabase connection...');

      // Simple query with timeout to test connection
      final response = await _client!
          .from('categories')
          .select('id')
          .limit(1)
          .timeout(timeout);

      print('✅ Supabase connection test successful');
      return true;
    } catch (e) {
      final errorMessage = e.toString();
      print('⚠️ Supabase connection test failed: $errorMessage');

      // Categorize errors for better debugging
      if (errorMessage.contains('timeout')) {
        print('   → Error type: Connection timeout');
      } else if (errorMessage.contains('network')) {
        print('   → Error type: Network error');
      } else if (errorMessage.contains('permission')) {
        print('   → Error type: Permission/RLS error');
      } else if (errorMessage.contains('relation') ||
          errorMessage.contains('table')) {
        print('   → Error type: Database schema issue (missing table)');
      } else {
        print('   → Error type: Unknown');
      }

      return false;
    }
  }

  // Get current session with safe access
  Session? get currentSession {
    try {
      return _client?.auth.currentSession;
    } catch (e) {
      print('⚠️ Error getting current session: $e');
      return null;
    }
  }

  // Get current user with safe access
  User? get currentUser {
    try {
      return _client?.auth.currentUser;
    } catch (e) {
      print('⚠️ Error getting current user: $e');
      return null;
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated {
    try {
      return currentSession != null;
    } catch (e) {
      print('⚠️ Error checking authentication status: $e');
      return false;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    if (_client == null) {
      throw Exception('Supabase client is not initialized');
    }

    try {
      print('🔐 Signing in user with email: $email');
      final response = await _client!.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        print('✅ User signed in successfully');
      } else {
        print('⚠️ Sign in successful but no session created');
      }

      return response;
    } catch (e) {
      print('❌ Sign in failed: $e');
      rethrow;
    }
  }

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    if (_client == null) {
      throw Exception('Supabase client is not initialized');
    }

    try {
      print('📝 Registering new user with email: $email');
      final response = await _client!.auth.signUp(
        email: email,
        password: password,
        data: data,
      );

      if (response.user != null) {
        print('✅ User registered successfully');
      } else {
        print('⚠️ Registration completed but user is null');
      }

      return response;
    } catch (e) {
      print('❌ Registration failed: $e');
      rethrow;
    }
  }

  // Sign out user
  Future<void> signOut() async {
    if (_client == null) {
      throw Exception('Supabase client is not initialized');
    }

    try {
      print('🔐 Signing out user...');
      await _client!.auth.signOut();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Sign out failed: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    if (_client == null) {
      throw Exception('Supabase client is not initialized');
    }

    try {
      print('🔒 Sending password reset email to: $email');
      await _client!.auth.resetPasswordForEmail(email);
      print('✅ Password reset email sent successfully');
    } catch (e) {
      print('❌ Password reset failed: $e');
      rethrow;
    }
  }

  // Listen to auth changes
  Stream<AuthState> get authStateChanges {
    if (_client == null) {
      throw Exception('Supabase client is not initialized');
    }
    return _client!.auth.onAuthStateChange;
  }

  // Get status information for debugging
  Map<String, dynamic> getStatus() {
    return {
      'is_initialized': _isInitialized,
      'has_client': _client != null,
      'has_credentials': hasValidCredentials,
      'is_authenticated': isAuthenticated,
      'current_user_id': currentUser?.id,
      'session_expires_at': currentSession?.expiresAt,
    };
  }

  // Dispose resources
  void dispose() {
    print('🔧 Disposing SupabaseService...');
    // Note: We don't dispose the Supabase client itself as it's managed by the Supabase package
    _isInitialized = false;
    print('✅ SupabaseService disposed');
  }
}
