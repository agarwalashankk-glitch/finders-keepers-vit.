import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_wrapper.dart';
import 'routing/app_routes.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initializes Firebase or gracefully activates demo mode if config is pending
  await FirebaseService.initialize();

  runApp(
    const ProviderScope(
      child: FindersKeepersApp(),
    ),
  );
}

class FindersKeepersApp extends StatelessWidget {
  const FindersKeepersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finders Keepers?',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: const AuthWrapper(),
    );
  }
}
