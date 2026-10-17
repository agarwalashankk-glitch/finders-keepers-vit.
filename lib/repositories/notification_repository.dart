import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import '../services/firebase_service.dart';

class NotificationRepository {
  final List<NotificationModel> _localNotifications = [];

  NotificationRepository() {
    // Add realistic seed notifications
    final now = DateTime.now();
    _localNotifications.addAll([
      NotificationModel(
        id: 'notif_1',
        userId: 'demo_user_active',
        title: 'New Ownership Claim Received',
        body: 'A student has submitted an ownership claim for your found wallet. Review the private evidence in My Reports.',
        type: NotificationType.claimSubmitted,
        relatedItemId: 'demo_item_3',
        relatedClaimId: 'demo_claim_1',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'notif_2',
        userId: 'demo_user_active',
        title: 'Potential Match Detected!',
        body: 'A found Casio calculator in SMV Block matches your lost item description with 78% confidence.',
        type: NotificationType.potentialMatch,
        relatedItemId: 'demo_item_5',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }

  Stream<List<NotificationModel>> watchUserNotifications(String userId) {
    if (FirebaseService.hasFirebaseConfig) {
      return FirebaseService.firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) {
        return snap.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList();
      });
    }

    return Stream.periodic(const Duration(milliseconds: 300), (_) {
      return _localNotifications.where((n) => n.userId == userId).toList();
    });
  }

  Future<void> sendNotification({
    required String targetUserId,
    required String title,
    required String body,
    required NotificationType type,
    String? relatedItemId,
    String? relatedClaimId,
  }) async {
    final notif = NotificationModel(
      id: 'notif_${const Uuid().v4()}',
      userId: targetUserId,
      title: title,
      body: body,
      type: type,
      relatedItemId: relatedItemId,
      relatedClaimId: relatedClaimId,
      createdAt: DateTime.now(),
    );

    if (FirebaseService.hasFirebaseConfig) {
      await FirebaseService.firestore
          .collection('notifications')
          .doc(notif.id)
          .set(notif.toMap());
    }

    _localNotifications.insert(0, notif);
  }

  Future<void> markAsRead(String notificationId) async {
    if (FirebaseService.hasFirebaseConfig) {
      await FirebaseService.firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    }

    final index = _localNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _localNotifications[index] = _localNotifications[index].copyWith(isRead: true);
    }
  }

  Future<void> markAllAsRead(String userId) async {
    for (int i = 0; i < _localNotifications.length; i++) {
      if (_localNotifications[i].userId == userId) {
        _localNotifications[i] = _localNotifications[i].copyWith(isRead: true);
      }
    }
  }
}
