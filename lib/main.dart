import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './services/environment_service.dart';
import './services/supabase_service.dart';
import './services/local_notification_service.dart';
import './core/config/env.dart';
import './core/network/supabase_client_provider.dart';
import 'core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 BidWar App Starting...');
  print('   - Platform: ${defaultTargetPlatform}');
  print(
    '   - Debug Mode: ${bool.fromEnvironment('dart.vm.product') ? 'Release' : 'Debug'}',
  );
  print('   - Environment source: --dart-define-from-file=env.json');

  bool supabaseInitialized = false;
  bool environmentInitialized = false;

  try {
    // Step 1: Check Environment Configuration
    print('🔧 Checking Environment Configuration...');
    EnvConfig.printConfigStatus();
    environmentInitialized = EnvConfig.hasValidSupabaseConfig;

    // Step 2: Initialize new Supabase Client Provider
    print('🔧 Initializing Supabase Client Provider...');
    supabaseInitialized = await SupabaseClientProvider.initialize();

    // Step 3: Fallback to legacy services if needed
    if (!supabaseInitialized) {
      print('🔄 Falling back to legacy services...');

      // Initialize legacy Environment Service
      print('🔧 Initializing Legacy Environment Service...');
      environmentInitialized = await EnvironmentService.initialize();

      if (environmentInitialized) {
        print('✅ Legacy Environment Service initialized successfully');
        final status = EnvironmentService.getStatus();
        print('   - Variables loaded: ${status['total_variables']}');
        print(
          '   - Supabase credentials: ${status['supabase_credentials_valid'] ? "Valid" : "Invalid"}',
        );
      }

      // Initialize legacy Supabase Service
      print('🔧 Initializing Legacy Supabase Service...');
      supabaseInitialized = await SupabaseService.initialize();

      if (supabaseInitialized) {
        print('✅ Legacy Supabase initialized successfully');
      } else {
        print(
          '⚠️ All Supabase initialization methods failed - running in offline mode',
        );
      }
    }

    // Test connection if initialized
    if (supabaseInitialized) {
      print('🔍 Testing Supabase connection...');
      final connectionOk = await SupabaseClientProvider.checkConnection();
      if (!connectionOk) {
        print('⚠️ Supabase connection test failed - but continuing anyway');
      }
    }

    // Initialize Local Notifications
    print('🔔 Initializing Local Notifications...');
    final notificationsInitialized =
        await LocalNotificationService.instance.initialize();
    if (notificationsInitialized) {
      print('✅ Local Notifications initialized successfully');
    } else {
      print('⚠️ Local Notifications initialization failed - continuing anyway');
    }
  } catch (e) {
    print('❌ Initialization error: $e');
    supabaseInitialized = false;
    environmentInitialized = false;
  }

  print('🎯 App initialization complete');
  print('   - Environment: ${environmentInitialized ? "✅" : "❌"}');
  print('   - Supabase: ${supabaseInitialized ? "✅" : "❌"}');
  print('   - Mode: ${supabaseInitialized ? "Full Featured" : "Demo Mode"}');

  runApp(
    MyApp(
      supabaseInitialized: supabaseInitialized,
      environmentInitialized: environmentInitialized,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool supabaseInitialized;
  final bool environmentInitialized;

  const MyApp({
    super.key,
    required this.supabaseInitialized,
    required this.environmentInitialized,
  });

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: MaterialApp(
            title: 'BidWar',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
            builder: (context, child) {
              // Add global error boundary
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return Material(
                  child: Container(
                    color: Colors.red.shade50,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'The app encountered an error and will restart shortly.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Restart app
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.splash,
                              (route) => false,
                            );
                          },
                          child: const Text('Restart App'),
                        ),
                      ],
                    ),
                  ),
                );
              };

              return child!;
            },
          ),
        );
      },
    );
  }
}
