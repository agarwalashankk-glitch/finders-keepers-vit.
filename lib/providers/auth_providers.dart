import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateChangesProvider = StreamProvider<UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  final asyncUser = ref.watch(authStateChangesProvider);
  return asyncUser.value ?? ref.watch(authRepositoryProvider).currentUser;
});

final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAdmin ?? false;
});
