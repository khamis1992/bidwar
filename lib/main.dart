import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './services/supabase_service.dart';
import 'core/app_export.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    await SupabaseService.initialize();
  } catch (e) {
    // Handle initialization error gracefully
    print('Supabase initialization error: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(1.0),
        ),
        child: MaterialApp(
          title: 'BidWar',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
        ),
      );
    });
  }
}