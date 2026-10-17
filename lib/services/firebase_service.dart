import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static bool _initialized = false;
  static bool _hasFirebaseConfig = false;

  static bool get isInitialized => _initialized;
  static bool get hasFirebaseConfig => _hasFirebaseConfig;

  /// Safely initializes Firebase and enables Firestore offline persistence
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      _hasFirebaseConfig = true;

      // Enable offline persistence caching for Firestore
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      _initialized = true;
      if (kDebugMode) {
        print('Firebase successfully initialized with offline persistence.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization notice: $e');
        print('Running in fallback/demo-ready mode until google-services.json is configured.');
      }
      _initialized = true;
      _hasFirebaseConfig = false;
    }
  }

  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;
}
