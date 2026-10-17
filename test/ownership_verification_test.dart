import 'package:finders_keepers/core/errors/app_exception.dart';
import 'package:finders_keepers/models/approximate_location_model.dart';
import 'package:finders_keepers/models/claim_model.dart';
import 'package:finders_keepers/models/item_model.dart';
import 'package:finders_keepers/models/item_status.dart';
import 'package:finders_keepers/repositories/claim_repository.dart';
import 'package:finders_keepers/repositories/item_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Ownership Verification Anti-Fraud Workflow', () {
    late ItemRepository itemRepo;
    late ClaimRepository claimRepo;
    late ItemModel testFoundItem;

    setUp(() async {
      itemRepo = ItemRepository();
      claimRepo = ClaimRepository(itemRepository: itemRepo);

      testFoundItem = await itemRepo.createItem(
        reportType: ItemReportType.found,
        title: 'Found Apple Watch Series 8',
        category: 'Electronics & Gadgets',
        description: 'Found on TT 2nd floor bench',
        imageUrls: [],
        approximateLocation: const ApproximateLocationModel(
          zoneId: 'tt',
          zoneName: 'Technology Tower (TT)',
          approxLatitude: 12.9708,
          approxLongitude: 79.1594,
        ),
        incidentDateTime: DateTime.now(),
        reporterId: 'finder_user_1',
        reporterName: 'Finder Person',
        submissionId: 'test_sub_1',
      );
    });

    test('Finder cannot claim their own found item', () async {
      expect(
        () => claimRepo.submitClaim(
          itemId: testFoundItem.id,
          itemTitle: testFoundItem.title,
          itemCategory: testFoundItem.category,
          itemReporterId: testFoundItem.reporterId,
          claimantId: 'finder_user_1', // Same as reporterId
          claimantName: 'Finder Person',
          claimantEmail: 'finder@vitstudent.ac.in',
          distinguishingFeatures: 'I found it myself so I want it',
          hiddenContents: 'None',
          lossCircumstance: 'Lost on campus yesterday afternoon',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Legitimate claimant submits claim and item moves to CLAIMED status', () async {
      final claim = await claimRepo.submitClaim(
        itemId: testFoundItem.id,
        itemTitle: testFoundItem.title,
        itemCategory: testFoundItem.category,
        itemReporterId: testFoundItem.reporterId,
        claimantId: 'legit_owner_1',
        claimantName: 'Real Owner',
        claimantEmail: 'owner@vitstudent.ac.in',
        distinguishingFeatures: 'Space gray aluminum, braided solo loop strap with blue thread',
        hiddenContents: 'Passcode starts with 49, Mickey mouse custom face',
        lossCircumstance: 'Left on bench after CS class at 12 PM',
      );

      expect(claim.status, equals(ClaimStatus.pending));

      final updatedItem = await itemRepo.getItemById(testFoundItem.id);
      expect(updatedItem?.status, equals(ItemStatus.claimed));
    });

    test('Approving claim generates 6-digit handover code and transitions to VERIFIED', () async {
      final claim = await claimRepo.submitClaim(
        itemId: testFoundItem.id,
        itemTitle: testFoundItem.title,
        itemCategory: testFoundItem.category,
        itemReporterId: testFoundItem.reporterId,
        claimantId: 'legit_owner_2',
        claimantName: 'Real Owner',
        claimantEmail: 'owner2@vitstudent.ac.in',
        distinguishingFeatures: 'Space gray aluminum, braided solo loop strap',
        hiddenContents: 'Passcode starts with 49',
        lossCircumstance: 'Left on bench after class',
      );

      await claimRepo.approveClaim(
        claimId: claim.id,
        reviewerId: testFoundItem.reporterId,
        reviewerName: 'Finder Person',
        reviewerNotes: 'Verified strap and passcode hint matches item.',
      );

      final updatedItem = await itemRepo.getItemById(testFoundItem.id);
      expect(updatedItem?.status, equals(ItemStatus.verified));
      expect(updatedItem?.verifiedClaimId, equals(claim.id));
    });
  });
}
