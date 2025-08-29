import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import './environment_service.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  static String? _supabaseUrl;
  static String? _supabaseAnonKey;
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;
  static bool get hasValidCredentials =>
      _supabaseUrl?.isNotEmpty == true && _supabaseAnonKey?.isNotEmpty == true;

  // Initialize Supabase with enhanced error handling and environment service
  static Future<bool> initialize() async {
    try {
      print('🔧 Supabase Service: Starting initialization...');

      // First ensure environment service is initialized
      final envInitialized = await EnvironmentService.initialize();
      if (!envInitialized) {
        print('⚠️ Environment Service initialization failed');
      }

      // Load credentials from environment service
      await _loadCredentialsFromEnvironment();

      // If no credentials found, try legacy loading methods
      if (!hasValidCredentials) {
        print(
            '⚠️ No credentials from Environment Service, trying legacy methods...');
        await _loadEnvironmentVariablesLegacy();
      }

      // Final validation
      if (!hasValidCredentials) {
        print('❌ Supabase credentials not found or invalid');
        print(
            '   - SUPABASE_URL: ${_supabaseUrl?.isNotEmpty == true ? "✅" : "❌"}');
        print(
            '   - SUPABASE_ANON_KEY: ${_supabaseAnonKey?.isNotEmpty == true ? "✅" : "❌"}');
        return false;
      }

      // Initialize Supabase
      await Supabase.initialize(
        url: _supabaseUrl!,
        anonKey: _supabaseAnonKey!,
        debug: kDebugMode,
      );

      _isInitialized = true;
      print('✅ Supabase initialized successfully');
      print('   - URL: ${_supabaseUrl}');
      print('   - App Mode: ${kDebugMode ? "Debug" : "Release"}');

      return true;
    } catch (e) {
      print('❌ Supabase initialization failed: $e');
      _isInitialized = false;
      return false;
    }
  }

  // Load credentials from the new environment service
  static Future<void> _loadCredentialsFromEnvironment() async {
    try {
      _supabaseUrl = EnvironmentService.get('SUPABASE_URL');
      _supabaseAnonKey = EnvironmentService.get('SUPABASE_ANON_KEY');

      print('🔧 Loaded credentials from Environment Service:');
      print('   - URL: ${_supabaseUrl != null ? "Found" : "Not found"}');
      print('   - Key: ${_supabaseAnonKey != null ? "Found" : "Not found"}');
    } catch (e) {
      print('❌ Error loading from Environment Service: $e');
    }
  }

  // Legacy loading method for fallback compatibility
  static Future<void> _loadEnvironmentVariablesLegacy() async {
    try {
      // Fallback to --dart-define if env service failed
      if (_supabaseUrl?.isEmpty != false) {
        _supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
      }
      if (_supabaseAnonKey?.isEmpty != false) {
        _supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
      }

      print('🔧 Legacy credential loading:');
      print(
          '   - URL from dart-define: ${_supabaseUrl?.isNotEmpty == true ? "Found" : "Not found"}');
      print(
          '   - Key from dart-define: ${_supabaseAnonKey?.isNotEmpty == true ? "Found" : "Not found"}');

      // Clean up any masked/placeholder values
      if (_supabaseUrl?.contains('Real value exists') == true) {
        _supabaseUrl = null;
      }
      if (_supabaseAnonKey?.contains('Real value exists') == true) {
        _supabaseAnonKey = null;
      }
    } catch (e) {
      print('❌ Failed to load legacy environment variables: $e');
    }
  }

  // Get Supabase client with safety check
  SupabaseClient get client {
    if (!_isInitialized) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return Supabase.instance.client;
  }

  // Safe client getter that doesn't throw
  SupabaseClient? get safeClient {
    try {
      return _isInitialized ? Supabase.instance.client : null;
    } catch (e) {
      print('⚠️ Error accessing Supabase client: $e');
      return null;
    }
  }

  // Check if Supabase connection is healthy with enhanced error handling
  static Future<bool> checkConnection({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (!_isInitialized) {
      print('⚠️ Supabase not initialized for connection check');
      return false;
    }

    try {
      final client = instance.safeClient;
      if (client == null) {
        print('⚠️ Supabase client not available');
        return false;
      }

      // Test with a simple query to check database connectivity
      await client.from('categories').select('id').limit(1).timeout(timeout);

      print('✅ Supabase connection check successful');
      return true;
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('timeout')) {
        print('⏰ Supabase connection timeout');
      } else if (errorMessage.contains('network')) {
        print('🌐 Network error during Supabase connection check');
      } else if (errorMessage.contains('unauthorized') ||
          errorMessage.contains('403')) {
        print('🔐 Supabase authentication error');
      } else {
        print('❌ Supabase connection check failed: $errorMessage');
      }
      return false;
    }
  }

  // Get initialization status for debugging
  static Map<String, dynamic> getStatus() {
    return {
      'initialized': _isInitialized,
      'has_valid_credentials': hasValidCredentials,
      'url_available': _supabaseUrl?.isNotEmpty == true,
      'key_available': _supabaseAnonKey?.isNotEmpty == true,
      'environment_status': EnvironmentService.getStatus(),
    };
  }
}
