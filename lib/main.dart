import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './services/environment_service.dart';
import './services/supabase_service.dart';
import 'core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 BidWar App Starting...');
  print('   - Platform: ${defaultTargetPlatform}');
  print(
    '   - Debug Mode: ${bool.fromEnvironment('dart.vm.product') ? 'Release' : 'Debug'}',
  );

  bool supabaseInitialized = false;
  bool environmentInitialized = false;

  try {
    // Step 1: Initialize Environment Service
    print('🔧 Initializing Environment Service...');
    environmentInitialized = await EnvironmentService.initialize();

    if (environmentInitialized) {
      print('✅ Environment Service initialized successfully');
      final status = EnvironmentService.getStatus();
      print('   - Variables loaded: ${status['total_variables']}');
      print(
        '   - Supabase credentials: ${status['supabase_credentials_valid'] ? "Valid" : "Invalid"}',
      );
    } else {
      print('⚠️ Environment Service initialization failed');
    }

    // Step 2: Initialize Supabase Service
    print('🔧 Initializing Supabase Service...');
    supabaseInitialized = await SupabaseService.initialize();

    if (supabaseInitialized) {
      print('✅ Supabase initialized successfully');
    } else {
      print('⚠️ Supabase initialization failed - running in offline mode');
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
        return MaterialApp(
          title: 'BidWar',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
