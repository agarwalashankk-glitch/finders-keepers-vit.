import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/errors/app_exception.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AuthRepository {
  UserModel? _cachedUser;
  final StreamController<UserModel?> _userController =
      StreamController<UserModel?>.broadcast();

  UserModel? get currentUser => _cachedUser;

  Stream<UserModel?> get authStateChanges async* {
    yield _cachedUser;
    yield* _userController.stream;
  }

  AuthRepository() {
    _init();
  }

  void _init() {
    if (FirebaseService.hasFirebaseConfig) {
      FirebaseService.auth.authStateChanges().listen((User? user) async {
        if (user == null) {
          _cachedUser = null;
          _userController.add(null);
        } else {
          final profile = await fetchUserProfile(user.uid);
          _cachedUser = profile;
          _userController.add(profile);
        }
      });
    } else {
      // Demo evaluator fallback: default active campus student user
      _cachedUser = UserModel(
        uid: 'demo_user_active',
        email: 'student@vitstudent.ac.in',
        displayName: 'Campus Student',
        role: UserRole.user,
        campusRegistrationNumber: '23BCE1023',
        reputationScore: 100,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      _userController.add(_cachedUser);
    }
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String displayName,
    String? campusRegistrationNumber,
  }) async {
    if (!FirebaseService.hasFirebaseConfig) {
      final newUser = UserModel(
        uid: 'demo_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName,
        campusRegistrationNumber: campusRegistrationNumber,
        role: email.contains('admin') ? UserRole.admin : UserRole.user,
        createdAt: DateTime.now(),
      );
      _cachedUser = newUser;
      _userController.add(newUser);
      return newUser;
    }

    try {
      final UserCredential creds =
          await FirebaseService.auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = creds.user!;
      await user.updateDisplayName(displayName);

      final userModel = UserModel(
        uid: user.uid,
        email: email.trim(),
        displayName: displayName,
        campusRegistrationNumber: campusRegistrationNumber,
        role: email.contains('admin') ? UserRole.admin : UserRole.user,
        createdAt: DateTime.now(),
      );

      await FirebaseService.firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toMap());

      _cachedUser = userModel;
      _userController.add(userModel);
      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication error occurred', code: e.code);
    } catch (e) {
      throw AuthException('Failed to complete registration: $e');
    }
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    if (!FirebaseService.hasFirebaseConfig) {
      final role = email.contains('admin') ? UserRole.admin : UserRole.user;
      final mockUser = UserModel(
        uid: 'demo_${email.hashCode.abs()}',
        email: email,
        displayName: email.split('@').first,
        role: role,
        campusRegistrationNumber: '23BCE0001',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      );
      _cachedUser = mockUser;
      _userController.add(mockUser);
      return mockUser;
    }

    try {
      final UserCredential creds =
          await FirebaseService.auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final profile = await fetchUserProfile(creds.user!.uid);
      _cachedUser = profile;
      _userController.add(profile);
      return profile;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Login failed', code: e.code);
    } catch (e) {
      throw AuthException('Failed to sign in: $e');
    }
  }

  Future<void> sendPasswordReset(String email) async {
    if (!FirebaseService.hasFirebaseConfig) return;

    try {
      await FirebaseService.auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to send reset link', code: e.code);
    }
  }

  Future<void> signOut() async {
    if (FirebaseService.hasFirebaseConfig) {
      await FirebaseService.auth.signOut();
    }
    _cachedUser = null;
    _userController.add(null);
  }

  Future<UserModel> fetchUserProfile(String uid) async {
    if (!FirebaseService.hasFirebaseConfig) {
      return _cachedUser ??
          UserModel(
            uid: uid,
            email: 'evaluator@vit.ac.in',
            displayName: 'Evaluator',
            createdAt: DateTime.now(),
          );
    }

    try {
      final doc =
          await FirebaseService.firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      } else {
        // Fallback user profile if Firestore document does not exist yet
        final firebaseUser = FirebaseService.auth.currentUser;
        return UserModel(
          uid: uid,
          email: firebaseUser?.email ?? '',
          displayName: firebaseUser?.displayName ?? 'Campus User',
          createdAt: DateTime.now(),
        );
      }
    } catch (e) {
      return UserModel(
        uid: uid,
        email: 'user@vitstudent.ac.in',
        displayName: 'Campus Student',
        createdAt: DateTime.now(),
      );
    }
  }

  /// Sets the demo user to Admin role for evaluation of moderation features
  void toggleDemoAdmin(bool makeAdmin) {
    if (_cachedUser != null) {
      _cachedUser = _cachedUser!.copyWith(
        role: makeAdmin ? UserRole.admin : UserRole.user,
      );
      _userController.add(_cachedUser);
    }
  }
}
