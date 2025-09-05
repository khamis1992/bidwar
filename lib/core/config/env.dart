/// Environment Configuration for BidWar App
///
/// يقرأ متغيرات البيئة من String.fromEnvironment
/// يدعم SUPABASE_URL و SUPABASE_ANON_KEY
///
/// Usage:
/// ```dart
/// final url = EnvConfig.supabaseUrl;
/// final key = EnvConfig.supabaseAnonKey;
/// ```
class EnvConfig {
  EnvConfig._(); // Private constructor to prevent instantiation

  /// Supabase Project URL
  /// يتم قراءته من --dart-define SUPABASE_URL=...
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase Anonymous Key
  /// يتم قراءته من --dart-define SUPABASE_ANON_KEY=...
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// تحقق من صحة متغيرات Supabase المطلوبة
  static bool get hasValidSupabaseConfig {
    return supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty &&
        supabaseUrl.startsWith('https://') &&
        supabaseUrl.contains('.supabase.co');
  }

  /// تحقق من وجود متغير معين
  static bool hasEnvironmentVariable(String key) {
    const availableVars = {
      'SUPABASE_URL': supabaseUrl,
      'SUPABASE_ANON_KEY': supabaseAnonKey,
    };

    return availableVars[key]?.isNotEmpty ?? false;
  }

  /// الحصول على معلومات التكوين للتشخيص
  static Map<String, dynamic> getConfigStatus() {
    return {
      'supabase_url_configured': supabaseUrl.isNotEmpty,
      'supabase_key_configured': supabaseAnonKey.isNotEmpty,
      'supabase_url_valid':
          supabaseUrl.startsWith('https://') &&
          supabaseUrl.contains('.supabase.co'),
      'has_valid_config': hasValidSupabaseConfig,
      'environment_source': 'String.fromEnvironment (dart-define)',
    };
  }

  /// طباعة حالة التكوين (للتشخيص في وضع التطوير فقط)
  static void printConfigStatus() {
    final status = getConfigStatus();
    print('🔧 Environment Configuration Status:');
    print(
      '   - Supabase URL configured: ${status['supabase_url_configured'] ? "✅" : "❌"}',
    );
    print(
      '   - Supabase Key configured: ${status['supabase_key_configured'] ? "✅" : "❌"}',
    );
    print(
      '   - Supabase URL format valid: ${status['supabase_url_valid'] ? "✅" : "❌"}',
    );
    print(
      '   - Overall config valid: ${status['has_valid_config'] ? "✅" : "❌"}',
    );

    if (!hasValidSupabaseConfig) {
      print('⚠️ Missing or invalid Supabase configuration!');
      print(
        '   Make sure to run: flutter run --dart-define-from-file=env.json',
      );
    }
  }
}
