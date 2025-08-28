import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './services/supabase_service.dart';
import 'core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool supabaseInitialized = false;
  try {
    // Initialize Supabase with better error handling
    supabaseInitialized = await SupabaseService.initialize();
    if (supabaseInitialized) {
      print('✅ Supabase initialized successfully');
    } else {
      print('⚠️ Supabase initialization failed - running in offline mode');
    }
  } catch (e) {
    // Handle initialization error gracefully
    print('❌ Supabase initialization error: $e');
    supabaseInitialized = false;
  }

  runApp(MyApp(supabaseInitialized: supabaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool supabaseInitialized;

  const MyApp({super.key, required this.supabaseInitialized});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: MaterialApp(
            title: 'BidWar',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
          ),
        );
      },
    );
  }
}