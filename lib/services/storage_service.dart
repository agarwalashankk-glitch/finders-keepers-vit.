import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../core/errors/app_exception.dart';
import 'firebase_service.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();

  /// Picks an image from the camera or gallery with automatic compression constraints
  Future<File?> pickImage({required ImageSource source}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80, // Compresses image to ~200-400KB instead of 5MB
      );

      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      throw StorageUploadException('Failed to select image: $e');
    }
  }

  /// Uploads an item image to Firebase Storage with progress tracking
  Future<String> uploadItemImage({
    required File file,
    required String itemId,
    void Function(double progress)? onProgress,
  }) async {
    if (!FirebaseService.hasFirebaseConfig) {
      // Offline fallback: Return a simulated local or placeholder URL
      onProgress?.call(1.0);
      return 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=600&q=80';
    }

    try {
      final fileExtension = file.path.split('.').last.toLowerCase();
      final String filename = '${const Uuid().v4()}.$fileExtension';
      final Reference ref = FirebaseService.storage
          .ref()
          .child('items')
          .child(itemId)
          .child(filename);

      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/$fileExtension',
          customMetadata: {'itemId': itemId},
        ),
      );

      // Listen for progress updates
      final StreamSubscription<TaskSnapshot> sub = uploadTask.snapshotEvents.listen(
        (TaskSnapshot snapshot) {
          if (snapshot.totalBytes > 0) {
            final double progress = snapshot.bytesTransferred / snapshot.totalBytes;
            onProgress?.call(progress);
          }
        },
      );

      final TaskSnapshot snapshot = await uploadTask;
      await sub.cancel();

      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      throw StorageUploadException('Storage upload failed: ${e.message}', code: e.code);
    } catch (e) {
      throw StorageUploadException('Image upload error: $e');
    }
  }

  /// Uploads a private claim evidence document/image
  Future<String> uploadClaimProofImage({
    required File file,
    required String claimId,
    void Function(double progress)? onProgress,
  }) async {
    if (!FirebaseService.hasFirebaseConfig) {
      onProgress?.call(1.0);
      return 'https://images.unsplash.com/photo-1584438784894-089d6a62b8fa?auto=format&fit=crop&w=600&q=80';
    }

    try {
      final fileExtension = file.path.split('.').last.toLowerCase();
      final String filename = 'proof_${const Uuid().v4()}.$fileExtension';
      final Reference ref = FirebaseService.storage
          .ref()
          .child('claims')
          .child(claimId)
          .child(filename);

      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/$fileExtension'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw StorageUploadException('Claim proof upload failed: $e');
    }
  }
}
