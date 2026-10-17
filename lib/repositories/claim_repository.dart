import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../core/errors/app_exception.dart';
import '../models/claim_model.dart';
import '../models/item_status.dart';
import '../services/firebase_service.dart';
import 'item_repository.dart';

class ClaimRepository {
  final ItemRepository _itemRepository;
  final List<ClaimModel> _localClaimsCache = [];

  ClaimRepository({required ItemRepository itemRepository})
      : _itemRepository = itemRepository {
    // Add demo seed claim for demo item 3
    final now = DateTime.now();
    _localClaimsCache.add(
      ClaimModel(
        id: 'demo_claim_1',
        itemId: 'demo_item_3',
        itemTitle: 'Black Tommy Hilfiger Leather Bifold Wallet',
        itemCategory: 'Wallets & Purses',
        itemReporterId: 'demo_finder_user_2',
        claimantId: 'demo_user_active',
        claimantName: 'Campus Student',
        claimantEmail: 'student@vitstudent.ac.in',
        status: ClaimStatus.pending,
        distinguishingFeatures:
            'There is a faint scratch near the bottom right metal emblem. Inside right pocket has my expired metro card and a folded receipt from SJT coffee shop.',
        hiddenContents:
            'SBI Global debit card ending in 4108, student library card with photo, exactly 3x 100 rupee notes.',
        serialOrIdentifier: 'SBI-4108',
        lossCircumstance:
            'Slipped out of my back pocket when taking the stairs from SJT 2nd floor to ground floor after my 11 AM class.',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
    );
  }

  /// Submits an ownership claim with mandatory private verification evidence
  Future<ClaimModel> submitClaim({
    required String itemId,
    required String itemTitle,
    required String itemCategory,
    required String itemReporterId,
    required String claimantId,
    required String claimantName,
    required String claimantEmail,
    required String distinguishingFeatures,
    required String hiddenContents,
    String serialOrIdentifier = '',
    required String lossCircumstance,
    List<String> proofImageUrls = const [],
  }) async {
    // Guard: Prevent finder from claiming their own item
    if (claimantId == itemReporterId) {
      throw const ValidationException(
        'You cannot submit an ownership claim on an item that you reported finding.',
      );
    }

    final currentItem = await _itemRepository.getItemById(itemId);
    if (currentItem == null) {
      throw const AppException('Item not found');
    }

    if (!currentItem.canBeClaimed) {
      throw const AppException('This item is currently not accepting ownership claims.');
    }

    final claimId = 'claim_${const Uuid().v4()}';
    final now = DateTime.now();

    final claim = ClaimModel(
      id: claimId,
      itemId: itemId,
      itemTitle: itemTitle,
      itemCategory: itemCategory,
      itemReporterId: itemReporterId,
      claimantId: claimantId,
      claimantName: claimantName,
      claimantEmail: claimantEmail,
      status: ClaimStatus.pending,
      distinguishingFeatures: distinguishingFeatures.trim(),
      hiddenContents: hiddenContents.trim(),
      serialOrIdentifier: serialOrIdentifier.trim(),
      lossCircumstance: lossCircumstance.trim(),
      proofImageUrls: proofImageUrls,
      createdAt: now,
    );

    if (FirebaseService.hasFirebaseConfig) {
      final claimRef =
          FirebaseService.firestore.collection('claims').doc(claimId);
      final itemRef =
          FirebaseService.firestore.collection('items').doc(itemId);

      await FirebaseService.firestore.runTransaction((transaction) async {
        final itemSnap = await transaction.get(itemRef);
        if (!itemSnap.exists) {
          throw const AppException('Item no longer exists');
        }

        final currentClaims =
            (itemSnap.data()?['activeClaimCount'] as num?)?.toInt() ?? 0;

        transaction.set(claimRef, claim.toMap());
        transaction.update(itemRef, {
          'activeClaimCount': currentClaims + 1,
          'status': ItemStatus.claimed.name,
          'updatedAt': now.toIso8601String(),
        });
      });
    }

    _localClaimsCache.insert(0, claim);

    // Update local item status to claimed
    await _itemRepository.updateItemStatus(
      itemId: itemId,
      newStatus: ItemStatus.claimed,
      userId: claimantId,
      userName: claimantName,
      reasonNote: 'Ownership claim submitted by $claimantName for verification review.',
    );

    return claim;
  }

  /// Streams claims submitted for a specific found item (Private to Finder or Admin)
  Stream<List<ClaimModel>> watchClaimsForItem({
    required String itemId,
    required String currentUserId,
    required bool isAdmin,
  }) {
    if (FirebaseService.hasFirebaseConfig) {
      return FirebaseService.firestore
          .collection('claims')
          .where('itemId', isEqualTo: itemId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) {
        return snap.docs.map((doc) => ClaimModel.fromMap(doc.data(), doc.id)).toList();
      });
    }

    Stream<List<ClaimModel>> fallbackStream() async* {
      yield _localClaimsCache.where((c) => c.itemId == itemId).toList();
      yield* Stream.periodic(const Duration(milliseconds: 500), (_) {
        return _localClaimsCache.where((c) => c.itemId == itemId).toList();
      });
    }

    return fallbackStream();
  }

  /// Streams claims submitted by the current user across all items
  Stream<List<ClaimModel>> watchUserClaims(String userId) {
    if (FirebaseService.hasFirebaseConfig) {
      return FirebaseService.firestore
          .collection('claims')
          .where('claimantId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) {
        return snap.docs.map((doc) => ClaimModel.fromMap(doc.data(), doc.id)).toList();
      });
    }

    Stream<List<ClaimModel>> fallbackStream() async* {
      yield _localClaimsCache.where((c) => c.claimantId == userId).toList();
      yield* Stream.periodic(const Duration(milliseconds: 500), (_) {
        return _localClaimsCache.where((c) => c.claimantId == userId).toList();
      });
    }

    return fallbackStream();
  }

  /// Finder reviews and APPROVES a claim after comparing hidden proof with actual item
  Future<void> approveClaim({
    required String claimId,
    required String reviewerId,
    required String reviewerName,
    required String reviewerNotes,
  }) async {
    final claimIndex = _localClaimsCache.indexWhere((c) => c.id == claimId);
    ClaimModel? targetClaim = claimIndex != -1 ? _localClaimsCache[claimIndex] : null;

    if (FirebaseService.hasFirebaseConfig) {
      final doc = await FirebaseService.firestore.collection('claims').doc(claimId).get();
      if (doc.exists && doc.data() != null) {
        targetClaim = ClaimModel.fromMap(doc.data()!, doc.id);
      }
    }

    if (targetClaim == null) {
      throw const AppException('Claim not found');
    }

    // Check if another claim on this item was already verified
    final currentItem = await _itemRepository.getItemById(targetClaim.itemId);
    if (currentItem?.verifiedClaimId != null &&
        currentItem!.verifiedClaimId != claimId) {
      throw const AppException(
        'Another claim has already been verified for this item. Only one verified owner is permitted.',
      );
    }

    // Generate secure 6-digit handover verification code
    final randomCode = (100000 + Random().nextInt(900000)).toString();
    final now = DateTime.now();

    final verifiedClaim = targetClaim.copyWith(
      status: ClaimStatus.verified,
      reviewedAt: now,
      reviewerNotes: reviewerNotes,
      handoverVerificationCode: randomCode,
    );

    if (FirebaseService.hasFirebaseConfig) {
      final batch = FirebaseService.firestore.batch();
      final claimRef = FirebaseService.firestore.collection('claims').doc(claimId);
      final itemRef = FirebaseService.firestore.collection('items').doc(targetClaim.itemId);

      batch.update(claimRef, verifiedClaim.toMap());
      batch.update(itemRef, {
        'status': ItemStatus.verified.name,
        'verifiedClaimId': claimId,
        'updatedAt': now.toIso8601String(),
      });
      await batch.commit();
    }

    if (claimIndex != -1) {
      _localClaimsCache[claimIndex] = verifiedClaim;
    }

    // Update item status in repository
    await _itemRepository.updateItemStatus(
      itemId: targetClaim.itemId,
      newStatus: ItemStatus.verified,
      userId: reviewerId,
      userName: reviewerName,
      reasonNote: 'Ownership claim verified by finder ($reviewerName). Handover code generated.',
      verifiedClaimId: claimId,
    );
  }

  /// Finder rejects a claim if evidence does not match actual item
  Future<void> rejectClaim({
    required String claimId,
    required String reviewerId,
    required String reviewerName,
    required String rejectionReason,
  }) async {
    final claimIndex = _localClaimsCache.indexWhere((c) => c.id == claimId);
    ClaimModel? targetClaim = claimIndex != -1 ? _localClaimsCache[claimIndex] : null;

    if (FirebaseService.hasFirebaseConfig) {
      final doc = await FirebaseService.firestore.collection('claims').doc(claimId).get();
      if (doc.exists && doc.data() != null) {
        targetClaim = ClaimModel.fromMap(doc.data()!, doc.id);
      }
    }

    if (targetClaim == null) {
      throw const AppException('Claim not found');
    }

    final now = DateTime.now();
    final rejectedClaim = targetClaim.copyWith(
      status: ClaimStatus.rejected,
      reviewedAt: now,
      reviewerNotes: rejectionReason,
    );

    if (FirebaseService.hasFirebaseConfig) {
      await FirebaseService.firestore.collection('claims').doc(claimId).update({
        'status': ClaimStatus.rejected.name,
        'reviewedAt': now.toIso8601String(),
        'reviewerNotes': rejectionReason,
      });
    }

    if (claimIndex != -1) {
      _localClaimsCache[claimIndex] = rejectedClaim;
    }

    // Check remaining pending claims for this item
    final itemClaims = _localClaimsCache
        .where((c) => c.itemId == targetClaim!.itemId && c.status == ClaimStatus.pending)
        .toList();

    // If no more active pending claims remain, revert item status back to 'found'
    if (itemClaims.isEmpty) {
      await _itemRepository.updateItemStatus(
        itemId: targetClaim.itemId,
        newStatus: ItemStatus.found,
        userId: reviewerId,
        userName: reviewerName,
        reasonNote: 'Claim rejected. Item restored to public Found pool for legitimate claims.',
      );
    }
  }

  /// Physical handover verification: Claimant provides 6-digit code to Finder
  Future<bool> verifyHandoverCodeAndComplete({
    required String claimId,
    required String enteredCode,
    required String finderUserId,
    required String finderUserName,
  }) async {
    final claimIndex = _localClaimsCache.indexWhere((c) => c.id == claimId);
    ClaimModel? targetClaim = claimIndex != -1 ? _localClaimsCache[claimIndex] : null;

    if (FirebaseService.hasFirebaseConfig) {
      final doc = await FirebaseService.firestore.collection('claims').doc(claimId).get();
      if (doc.exists && doc.data() != null) {
        targetClaim = ClaimModel.fromMap(doc.data()!, doc.id);
      }
    }

    if (targetClaim == null) {
      throw const AppException('Claim not found');
    }

    if (targetClaim.handoverVerificationCode != enteredCode.trim()) {
      return false; // Code mismatch
    }

    // Code matches: complete handover and transition to RETURNED terminal state
    await _itemRepository.updateItemStatus(
      itemId: targetClaim.itemId,
      newStatus: ItemStatus.returned,
      userId: finderUserId,
      userName: finderUserName,
      reasonNote: 'Handover code successfully confirmed in person. Item safely returned to owner.',
      verifiedClaimId: claimId,
    );

    return true;
  }
}
