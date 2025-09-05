import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

/// Supabase Client Provider for BidWar App
///
/// يوفر عميل Supabase كـ singleton مع Realtime support
/// يستخدم نمط Service Locator للوصول العام
///
/// Usage:
/// ```dart
/// // Initialize once in main.dart
/// await SupabaseClientProvider.initialize();
///
/// // Use anywhere in the app
/// final client = SupabaseClientProvider.instance.client;
/// ```
class SupabaseClientProvider {
  static SupabaseClientProvider? _instance;
  static SupabaseClientProvider get instance {
    if (_instance == null) {
      throw Exception(
        'SupabaseClientProvider not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  SupabaseClient? _client;
  bool _isInitialized = false;

  SupabaseClientProvider._();

  /// تهيئة عميل Supabase مع Realtime
  static Future<bool> initialize() async {
    try {
      print('🔧 Initializing Supabase Client Provider...');

      // التحقق من صحة التكوين
      if (!EnvConfig.hasValidSupabaseConfig) {
        print('❌ Invalid Supabase configuration');
        EnvConfig.printConfigStatus();
        return false;
      }

      // إنشاء المثيل
      _instance = SupabaseClientProvider._();

      // تهيئة Supabase
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
        debug: kDebugMode,
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
          eventsPerSecond: 10, // تحديد معدل الأحداث لتحسين الأداء
        ),
      );

      _instance!._client = Supabase.instance.client;
      _instance!._isInitialized = true;

      print('✅ Supabase Client Provider initialized successfully');
      print('   - URL: ${EnvConfig.supabaseUrl}');
      print('   - Realtime enabled: ✅');
      print('   - Debug mode: ${kDebugMode ? "✅" : "❌"}');

      return true;
    } catch (e) {
      print('❌ Failed to initialize Supabase Client Provider: $e');
      _instance = null;
      return false;
    }
  }

  /// الحصول على عميل Supabase
  SupabaseClient get client {
    if (!_isInitialized || _client == null) {
      throw Exception('Supabase client not initialized');
    }
    return _client!;
  }

  /// الحصول على عميل Supabase بأمان (لا يرمي استثناء)
  SupabaseClient? get safeClient {
    return _isInitialized ? _client : null;
  }

  /// التحقق من حالة التهيئة
  bool get isInitialized => _isInitialized;

  /// التحقق من صحة الاتصال
  static Future<bool> checkConnection({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      if (_instance?._client == null) {
        print('⚠️ Supabase client not available for connection check');
        return false;
      }

      // اختبار الاتصال بقاعدة البيانات
      await _instance!._client!
          .from('users') // جدول افتراضي للاختبار
          .select('id')
          .limit(1)
          .timeout(timeout);

      print('✅ Supabase connection check successful');
      return true;
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('timeout')) {
        print('⏰ Supabase connection timeout');
      } else if (errorMessage.contains('network')) {
        print('🌐 Network error during connection check');
      } else if (errorMessage.contains('unauthorized') ||
          errorMessage.contains('403')) {
        print('🔐 Authentication error - check your Supabase keys');
      } else if (errorMessage.contains('relation') ||
          errorMessage.contains('does not exist')) {
        print('✅ Connection successful (table not found is expected)');
        return true; // الاتصال سليم حتى لو الجدول غير موجود
      } else {
        print('❌ Connection check failed: $e');
      }
      return false;
    }
  }

  /// الحصول على معلومات الحالة للتشخيص
  static Map<String, dynamic> getStatus() {
    return {
      'provider_initialized': _instance != null,
      'client_initialized': _instance?._isInitialized ?? false,
      'client_available': _instance?._client != null,
      'config_status': EnvConfig.getConfigStatus(),
    };
  }

  /// طباعة حالة المزود
  static void printStatus() {
    final status = getStatus();
    print('🔧 Supabase Client Provider Status:');
    print(
      '   - Provider initialized: ${status['provider_initialized'] ? "✅" : "❌"}',
    );
    print(
      '   - Client initialized: ${status['client_initialized'] ? "✅" : "❌"}',
    );
    print('   - Client available: ${status['client_available'] ? "✅" : "❌"}');
  }

  /// إعادة تعيين المزود (للاختبارات أو إعادة التهيئة)
  static void reset() {
    _instance?._client = null;
    _instance?._isInitialized = false;
    _instance = null;
    print('🔄 Supabase Client Provider reset');
  }
}

/// Service Locator للوصول المبسط لعميل Supabase
class SupabaseClientService {
  /// الحصول على عميل Supabase
  static SupabaseClient get client => SupabaseClientProvider.instance.client;

  /// الحصول على عميل Supabase بأمان
  static SupabaseClient? get safeClient =>
      SupabaseClientProvider.instance.safeClient;

  /// التحقق من حالة التهيئة
  static bool get isInitialized =>
      SupabaseClientProvider.instance.isInitialized;

  /// التحقق من صحة الاتصال
  static Future<bool> checkConnection() =>
      SupabaseClientProvider.checkConnection();
}
