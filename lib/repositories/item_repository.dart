import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../core/errors/app_exception.dart';
import '../models/approximate_location_model.dart';
import '../models/item_event_model.dart';
import '../models/item_model.dart';
import '../models/item_status.dart';
import '../services/firebase_service.dart';
import '../services/mock_seed_service.dart';

class ItemRepository {
  List<ItemModel> _localCache = [];

  ItemRepository() {
    // Populate local cache with realistic demo items as baseline
    _localCache = MockSeedService.getDemoItems();
  }

  /// Creates a new Lost or Found item report with audit event and idempotency protection
  Future<ItemModel> createItem({
    required ItemReportType reportType,
    required String title,
    required String category,
    required String description,
    required List<String> imageUrls,
    required ApproximateLocationModel approximateLocation,
    required DateTime incidentDateTime,
    required String reporterId,
    required String reporterName,
    required String submissionId,
  }) async {
    final now = DateTime.now();
    final initialStatus =
        reportType == ItemReportType.lost ? ItemStatus.lost : ItemStatus.found;

    final String itemId = 'item_${const Uuid().v4()}';
    final newItem = ItemModel(
      id: itemId,
      reportType: reportType,
      status: initialStatus,
      title: title.trim(),
      category: category,
      description: description.trim(),
      imageUrls: imageUrls,
      approximateLocation: approximateLocation,
      incidentDateTime: incidentDateTime,
      reporterId: reporterId,
      reporterName: reporterName,
      activeClaimCount: 0,
      submissionId: submissionId,
      createdAt: now,
      updatedAt: now,
    );

    if (FirebaseService.hasFirebaseConfig) {
      try {
        // Idempotency check: Ensure same submissionId wasn't already posted
        final existing = await FirebaseService.firestore
            .collection('items')
            .where('submissionId', isEqualTo: submissionId)
            .limit(1)
            .get();

        if (existing.docs.isNotEmpty) {
          return ItemModel.fromMap(
              existing.docs.first.data(), existing.docs.first.id);
        }

        final docRef = FirebaseService.firestore.collection('items').doc(itemId);
        final eventRef = docRef.collection('events').doc();

        final initialEvent = ItemEventModel(
          id: eventRef.id,
          itemId: itemId,
          eventType: 'reported',
          previousStatus: initialStatus,
          newStatus: initialStatus,
          triggeredByUserId: reporterId,
          triggeredByUserName: reporterName,
          notes: 'Report created as ${reportType.displayName}',
          timestamp: now,
        );

        // Atomic batch write for item document + initial event log
        final batch = FirebaseService.firestore.batch();
        batch.set(docRef, newItem.toMap());
        batch.set(eventRef, initialEvent.toMap());
        await batch.commit();
      } catch (e) {
        throw AppException('Failed to publish report to campus board: $e');
      }
    }

    _localCache.insert(0, newItem);
    return newItem;
  }

  /// Streams items matching active filters and search criteria
  Stream<List<ItemModel>> watchItems({
    ItemReportType? reportType,
    String? category,
    ItemStatus? status,
    String? zoneId,
    String? searchQuery,
  }) {
    if (FirebaseService.hasFirebaseConfig) {
      Query<Map<String, dynamic>> query = FirebaseService.firestore
          .collection('items')
          .orderBy('createdAt', descending: true);

      if (reportType != null) {
        query = query.where('reportType', isEqualTo: reportType.name);
      }
      if (category != null && category.isNotEmpty && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      if (zoneId != null && zoneId.isNotEmpty && zoneId != 'all') {
        query = query.where('approximateLocation.zoneId', isEqualTo: zoneId);
      }

      return query.snapshots().map((snapshot) {
        final items = snapshot.docs.map((doc) {
          return ItemModel.fromMap(doc.data(), doc.id);
        }).toList();

        // Perform in-memory keyword search on title + description
        if (searchQuery != null && searchQuery.trim().isNotEmpty) {
          final queryTerms = searchQuery.trim().toLowerCase().split(' ');
          return items.where((item) {
            final text = '${item.title} ${item.description}'.toLowerCase();
            return queryTerms.every((term) => text.contains(term));
          }).toList();
        }

        return items;
      });
    }

    // In-memory fallback stream for demo/offline evaluation: emit immediately!
    Stream<List<ItemModel>> fallbackStream() async* {
      yield _filterLocalCache(
        reportType: reportType,
        category: category,
        status: status,
        zoneId: zoneId,
        searchQuery: searchQuery,
      );
      yield* Stream.periodic(const Duration(milliseconds: 500), (_) {
        return _filterLocalCache(
          reportType: reportType,
          category: category,
          status: status,
          zoneId: zoneId,
          searchQuery: searchQuery,
        );
      });
    }

    return fallbackStream();
  }

  List<ItemModel> _filterLocalCache({
    ItemReportType? reportType,
    String? category,
    ItemStatus? status,
    String? zoneId,
    String? searchQuery,
  }) {
    List<ItemModel> list = List.from(_localCache);

    if (reportType != null) {
      list = list.where((i) => i.reportType == reportType).toList();
    }
    if (category != null && category.isNotEmpty && category != 'All') {
      list = list.where((i) => i.category == category).toList();
    }
    if (status != null) {
      list = list.where((i) => i.status == status).toList();
    }
    if (zoneId != null && zoneId.isNotEmpty && zoneId != 'all') {
      list = list.where((i) => i.approximateLocation.zoneId == zoneId).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final queryTerms = searchQuery.trim().toLowerCase().split(' ');
      list = list.where((item) {
        final text = '${item.title} ${item.description}'.toLowerCase();
        return queryTerms.every((term) => text.contains(term));
      }).toList();
    }

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Fetches a single item by its ID
  Future<ItemModel?> getItemById(String itemId) async {
    if (FirebaseService.hasFirebaseConfig) {
      try {
        final doc =
            await FirebaseService.firestore.collection('items').doc(itemId).get();
        if (doc.exists && doc.data() != null) {
          return ItemModel.fromMap(doc.data()!, doc.id);
        }
      } catch (_) {}
    }

    try {
      return _localCache.firstWhere((i) => i.id == itemId);
    } catch (_) {
      return null;
    }
  }

  /// Updates item status enforcing state machine rules and writing to audit history
  Future<void> updateItemStatus({
    required String itemId,
    required ItemStatus newStatus,
    required String userId,
    required String userName,
    required String reasonNote,
    String? verifiedClaimId,
  }) async {
    final currentItem = await getItemById(itemId);
    if (currentItem == null) {
      throw const AppException('Item not found');
    }

    // Strict State Machine Verification
    if (!ItemStateMachine.canTransition(currentItem.status, newStatus)) {
      throw StateTransitionException(
        ItemStateMachine.transitionErrorMessage(currentItem.status, newStatus),
      );
    }

    final now = DateTime.now();
    final updatedItem = currentItem.copyWith(
      status: newStatus,
      verifiedClaimId: verifiedClaimId ?? currentItem.verifiedClaimId,
      updatedAt: now,
    );

    if (FirebaseService.hasFirebaseConfig) {
      final itemRef =
          FirebaseService.firestore.collection('items').doc(itemId);
      final eventRef = itemRef.collection('events').doc();

      final event = ItemEventModel(
        id: eventRef.id,
        itemId: itemId,
        eventType: 'status_transition',
        previousStatus: currentItem.status,
        newStatus: newStatus,
        triggeredByUserId: userId,
        triggeredByUserName: userName,
        notes: reasonNote,
        timestamp: now,
      );

      final batch = FirebaseService.firestore.batch();
      batch.update(itemRef, {
        'status': newStatus.name,
        if (verifiedClaimId != null) 'verifiedClaimId': verifiedClaimId,
        'updatedAt': now.toIso8601String(),
      });
      batch.set(eventRef, event.toMap());
      await batch.commit();
    }

    final index = _localCache.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _localCache[index] = updatedItem;
    }
  }

  /// Fetches event history / audit trail for an item
  Future<List<ItemEventModel>> getItemEvents(String itemId) async {
    if (FirebaseService.hasFirebaseConfig) {
      try {
        final query = await FirebaseService.firestore
            .collection('items')
            .doc(itemId)
            .collection('events')
            .orderBy('timestamp', descending: true)
            .get();

        return query.docs.map((doc) {
          return ItemEventModel.fromMap(doc.data(), doc.id);
        }).toList();
      } catch (_) {}
    }

    // Fallback audit trail for demo item
    return [
      ItemEventModel(
        id: 'event_init',
        itemId: itemId,
        eventType: 'reported',
        previousStatus: ItemStatus.found,
        newStatus: ItemStatus.found,
        triggeredByUserId: 'user_finder',
        triggeredByUserName: 'Finder',
        notes: 'Item reported and published to campus lost-and-found board.',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    ];
  }

  /// Flags an item as suspicious or inappropriate (Moderation)
  Future<void> flagItem({
    required String itemId,
    required String reason,
    required String reportingUserId,
  }) async {
    if (FirebaseService.hasFirebaseConfig) {
      await FirebaseService.firestore.collection('items').doc(itemId).update({
        'isFlagged': true,
        'flagReason': reason,
      });
    }

    final index = _localCache.indexWhere((i) => i.id == itemId);
    if (index != -1) {
      _localCache[index] = _localCache[index].copyWith(
        isFlagged: true,
        flagReason: reason,
      );
    }
  }

  /// Admin moderation action to remove or close inappropriate listing
  Future<void> moderateDeleteItem(String itemId) async {
    if (FirebaseService.hasFirebaseConfig) {
      await FirebaseService.firestore.collection('items').doc(itemId).delete();
    }
    _localCache.removeWhere((i) => i.id == itemId);
  }
}
