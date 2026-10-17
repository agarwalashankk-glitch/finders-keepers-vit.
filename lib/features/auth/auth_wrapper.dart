import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_providers.dart';
import '../home/main_navigation_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final currentUser = ref.watch(currentUserProvider);

    // If a user profile is present in repository cache, immediately load home!
    if (currentUser != null) {
      return const MainNavigationScreen();
    }

    return authState.when(
      data: (user) {
        if (user != null) {
          return const MainNavigationScreen();
        }
        return const LoginScreen();
      },
      loading: () {
        if (currentUser != null) {
          return const MainNavigationScreen();
        }
        return const LoginScreen();
      },
      error: (err, stack) => const LoginScreen(),
    );
  }
}
