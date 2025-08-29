import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Enhanced Environment Service with multiple fallback strategies
class EnvironmentService {
  static EnvironmentService? _instance;
  static EnvironmentService get instance =>
      _instance ??= EnvironmentService._();

  EnvironmentService._();

  static Map<String, String> _environmentVariables = {};
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;
  static Map<String, String> get variables =>
      Map.unmodifiable(_environmentVariables);

  /// Initialize environment variables with multiple fallback strategies
  static Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      print('🔧 Environment Service: Starting initialization...');

      // Strategy 1: Try to load from .env file (flutter_dotenv)
      bool dotEnvLoaded = await _loadFromDotEnv();

      // Strategy 2: Try to load from env.json file with validation
      bool jsonLoaded = await _loadFromEnvJson();

      // Strategy 3: Load from dart-define variables
      bool defineLoaded = await _loadFromDartDefine();

      // Strategy 4: Load from platform environment variables (not for web)
      bool platformLoaded = await _loadFromPlatformEnvironment();

      _isInitialized = true;

      print('🔧 Environment Service: Initialization complete');
      print('   - .env file: ${dotEnvLoaded ? "✅" : "❌"}');
      print('   - env.json: ${jsonLoaded ? "✅" : "❌"}');
      print('   - dart-define: ${defineLoaded ? "✅" : "❌"}');
      print('   - platform env: ${platformLoaded ? "✅" : "❌"}');
      print('   - Total variables loaded: ${_environmentVariables.length}');

      return _environmentVariables.isNotEmpty;
    } catch (e) {
      print('❌ Environment Service initialization failed: $e');
      _isInitialized = true; // Mark as initialized even if failed
      return false;
    }
  }

  /// Strategy 1: Load from .env file using flutter_dotenv
  static Future<bool> _loadFromDotEnv() async {
    try {
      await dotenv.load(fileName: ".env");

      for (String key in dotenv.env.keys) {
        _environmentVariables[key] = dotenv.env[key] ?? '';
      }

      if (dotenv.env.isNotEmpty) {
        print('✅ Loaded ${dotenv.env.length} variables from .env file');
        return true;
      }
    } catch (e) {
      print('⚠️ Could not load .env file: $e');
    }
    return false;
  }

  /// Strategy 2: Load from env.json with enhanced validation and error handling
  static Future<bool> _loadFromEnvJson() async {
    try {
      final String envString = await rootBundle.loadString('env.json');

      // Validate JSON content - check for HTML response
      if (envString.trim().toLowerCase().startsWith('<!doctype') ||
          envString.trim().toLowerCase().startsWith('<html')) {
        print('❌ env.json contains HTML content instead of JSON');
        return false;
      }

      // Validate JSON format
      if (!envString.trim().startsWith('{') ||
          !envString.trim().endsWith('}')) {
        print('❌ env.json does not contain valid JSON structure');
        return false;
      }

      final Map<String, dynamic> env = json.decode(envString);
      int validVariables = 0;

      for (String key in env.keys) {
        String? value = env[key]?.toString();

        // Skip masked values and placeholders
        if (value != null &&
            !value.contains('Real value exists') &&
            !value.contains('your-') &&
            !value.contains('-here') &&
            value.trim().isNotEmpty) {
          _environmentVariables[key] = value;
          validVariables++;
        }
      }

      if (validVariables > 0) {
        print('✅ Loaded $validVariables valid variables from env.json');
        return true;
      } else {
        print('⚠️ env.json found but no valid variables extracted');
      }
    } catch (e) {
      if (e is FormatException) {
        print('❌ env.json parsing failed - Invalid JSON format: $e');
      } else {
        print('⚠️ Could not load env.json: $e');
      }
    }
    return false;
  }

  /// Strategy 3: Load from --dart-define variables
  static Future<bool> _loadFromDartDefine() async {
    try {
      final keys = [
        'SUPABASE_URL',
        'SUPABASE_ANON_KEY',
        'OPENAI_API_KEY',
        'GEMINI_API_KEY',
        'ANTHROPIC_API_KEY',
        'PERPLEXITY_API_KEY',
      ];

      int loadedCount = 0;
      for (String key in keys) {
        final String value = String.fromEnvironment(key);
        if (value.isNotEmpty) {
          _environmentVariables[key] = value;
          loadedCount++;
        }
      }

      if (loadedCount > 0) {
        print('✅ Loaded $loadedCount variables from dart-define');
        return true;
      }
    } catch (e) {
      print('⚠️ Error loading dart-define variables: $e');
    }
    return false;
  }

  /// Strategy 4: Load from platform environment variables (not for web)
  static Future<bool> _loadFromPlatformEnvironment() async {
    if (kIsWeb) return false; // Skip on web platform

    try {
      final keys = [
        'SUPABASE_URL',
        'SUPABASE_ANON_KEY',
        'OPENAI_API_KEY',
        'GEMINI_API_KEY',
        'ANTHROPIC_API_KEY',
        'PERPLEXITY_API_KEY',
      ];

      int loadedCount = 0;
      for (String key in keys) {
        final value = Platform.environment[key];
        if (value != null && value.isNotEmpty) {
          _environmentVariables[key] = value;
          loadedCount++;
        }
      }

      if (loadedCount > 0) {
        print('✅ Loaded $loadedCount variables from platform environment');
        return true;
      }
    } catch (e) {
      print('⚠️ Error loading platform environment variables: $e');
    }
    return false;
  }

  /// Get environment variable with fallback
  static String? get(String key, {String? fallback}) {
    return _environmentVariables[key] ?? fallback;
  }

  /// Check if variable exists
  static bool has(String key) {
    return _environmentVariables.containsKey(key);
  }

  /// Get all variables (useful for debugging)
  static Map<String, String> getAll() {
    return Map.unmodifiable(_environmentVariables);
  }

  /// Validate critical Supabase variables
  static bool hasValidSupabaseCredentials() {
    final url = get('SUPABASE_URL');
    final key = get('SUPABASE_ANON_KEY');

    return url != null &&
        key != null &&
        url.isNotEmpty &&
        key.isNotEmpty &&
        url.startsWith('https://');
  }

  /// Get detailed status for debugging
  static Map<String, dynamic> getStatus() {
    return {
      'initialized': _isInitialized,
      'total_variables': _environmentVariables.length,
      'has_supabase_url': has('SUPABASE_URL'),
      'has_supabase_key': has('SUPABASE_ANON_KEY'),
      'supabase_credentials_valid': hasValidSupabaseCredentials(),
      'available_keys': _environmentVariables.keys.toList(),
    };
  }
}
