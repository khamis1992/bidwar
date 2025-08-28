import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

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

  // Initialize Supabase - call this in main()
  static Future<bool> initialize() async {
    try {
      // Try to load from env.json first
      await _loadEnvironmentVariables();

      // Fallback to --dart-define if env.json loading fails
      if (!hasValidCredentials) {
        _supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
        _supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');
      }

      if (!hasValidCredentials) {
        print(
          'Warning: Supabase credentials not found. Running in offline mode.',
        );
        return false;
      }

      await Supabase.initialize(url: _supabaseUrl!, anonKey: _supabaseAnonKey!);

      _isInitialized = true;
      print('Supabase initialized successfully');
      return true;
    } catch (e) {
      print('Supabase initialization failed: $e');
      _isInitialized = false;
      return false;
    }
  }

  // Load environment variables from env.json
  static Future<void> _loadEnvironmentVariables() async {
    try {
      final String envString = await rootBundle.loadString('env.json');
      final Map<String, dynamic> env = json.decode(envString);

      _supabaseUrl = env['SUPABASE_URL']?.toString();
      _supabaseAnonKey = env['SUPABASE_ANON_KEY']?.toString();

      // Clean up masked values
      if (_supabaseUrl?.contains('Real value exists') == true) {
        _supabaseUrl = null;
      }
      if (_supabaseAnonKey?.contains('Real value exists') == true) {
        _supabaseAnonKey = null;
      }
    } catch (e) {
      print('Failed to load env.json: $e');
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
      return null;
    }
  }

  // Check if Supabase connection is healthy
  static Future<bool> checkConnection({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (!_isInitialized) return false;

    try {
      final client = instance.client;
      await client.from('categories').select('id').limit(1).timeout(timeout);
      return true;
    } catch (e) {
      print('Supabase connection check failed: $e');
      return false;
    }
  }
}
