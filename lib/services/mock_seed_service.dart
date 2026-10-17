import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/campus_locations.dart';
import '../models/approximate_location_model.dart';
import '../models/item_model.dart';
import '../models/item_status.dart';
import 'firebase_service.dart';

class MockSeedService {
  static List<ItemModel> getDemoItems() {
    final now = DateTime.now();

    return [
      ItemModel(
        id: 'demo_item_1',
        reportType: ItemReportType.found,
        status: ItemStatus.found,
        title: 'Apple AirPods Pro (2nd Gen) with White Case',
        category: 'Earphones & Audio',
        description: 'Found on a desk in TT 4th floor computer lab 412. Case has a small cartoon astronaut sticker on the back.',
        imageUrls: [
          'https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?auto=format&fit=crop&w=600&q=80',
        ],
        approximateLocation: const ApproximateLocationModel(
          zoneId: 'tt',
          zoneName: 'Technology Tower (TT)',
          approxLatitude: 12.9708,
          approxLongitude: 79.1594,
          areaDetail: '4th Floor Computer Lab 412 Area',
        ),
        incidentDateTime: now.subtract(const Duration(hours: 4)),
        reporterId: 'demo_finder_user_1',
        reporterName: 'Aarav Sharma',
        activeClaimCount: 0,
        submissionId: 'sub_demo_1',
        createdAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
      ItemModel(
        id: 'demo_item_2',
        reportType: ItemReportType.lost,
        status: ItemStatus.lost,
        title: 'Lost Student ID Card (Reg No: 23BCE1042)',
        category: 'Student ID & Cards',
        description: 'Lost my VIT ID card with blue lanyard somewhere between Main Library and Foodys during lunch hour.',
        imageUrls: [
          'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=600&q=80',
        ],
        approximateLocation: const ApproximateLocationModel(
          zoneId: 'foodys',
          zoneName: 'Foodys & Gazebo Courtyard',
          approxLatitude: 12.9704,
          approxLongitude: 79.1601,
          areaDetail: 'Outdoor Gazebo Seating',
        ),
        incidentDateTime: now.subtract(const Duration(hours: 8)),
        reporterId: 'demo_owner_user_1',
        reporterName: 'Sneha Patel',
        activeClaimCount: 0,
        submissionId: 'sub_demo_2',
        createdAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now.subtract(const Duration(hours: 8)),
      ),
      ItemModel(
        id: 'demo_item_3',
        reportType: ItemReportType.found,
        status: ItemStatus.claimed,
        title: 'Black Tommy Hilfiger Leather Bifold Wallet',
        category: 'Wallets & Purses',
        description: 'Found near the SJT Ground Floor stairs. Contains multiple cards and cash. Safe with finder - submit claim with card names and currency breakdown to verify.',
        imageUrls: [
          'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&w=600&q=80',
        ],
        approximateLocation: const ApproximateLocationModel(
          zoneId: 'sjt',
          zoneName: 'Silver Jubilee Tower (SJT)',
          approxLatitude: 12.9719,
          approxLongitude: 79.1636,
          areaDetail: 'Ground Floor Staircase Area',
        ),
        incidentDateTime: now.subtract(const Duration(days: 1, hours: 2)),
        reporterId: 'demo_finder_user_2',
        reporterName: 'Vikramaditya',
        activeClaimCount: 1,
        submissionId: 'sub_demo_3',
        createdAt: now.subtract(const Duration(days: 1, hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      ItemModel(
        id: 'demo_item_4',
        reportType: ItemReportType.found,
        status: ItemStatus.found,
        title: 'Hero Sprint Bicycle Key with Blue Marvel Lanyard',
        category: 'Keys & Keychains',
        description: 'Single brass key attached to a Captain America shield metallic keychain. Left on bench outside Periyar Central Library.',
        imageUrls: [
          'https://images.unsplash.com/photo-1582139329536-e7284fece509?auto=format&fit=crop&w=600&q=80',
        ],
        approximateLocation: const ApproximateLocationModel(
          zoneId: 'library',
          zoneName: 'Central Library (Periyar EVR)',
          approxLatitude: 12.9698,
          approxLongitude: 79.1578,
          areaDetail: 'North Garden Benches',
        ),
        incidentDateTime: now.subtract(const Duration(days: 2)),
        reporterId: 'demo_finder_user_3',
        reporterName: 'Priya Sundaram',
        activeClaimCount: 0,
        submissionId: 'sub_demo_4',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      ItemModel(
        id: 'demo_item_5',
        reportType: ItemReportType.lost,
        status: ItemStatus.lost,
        title: 'Casio fx-991EX Classwiz Scientific Calculator',
        category: 'Electronics & Gadgets',
        description: 'Black calculator with silver trim. Has initials "R.K." engraved in small letters on the battery compartment cover.',
        imageUrls: [
          'https://images.unsplash.com/photo-1594980596870-8aa52a78d8cd?auto=format&fit=crop&w=600&q=80',
        ],
        approximateLocation: const ApproximateLocationModel(
          zoneId: 'smv',
          zoneName: 'SMV Block (Mech / Civil)',
          approxLatitude: 12.9695,
          approxLongitude: 79.1610,
          areaDetail: 'Mechanics Lab 2nd Floor',
        ),
        incidentDateTime: now.subtract(const Duration(days: 3)),
        reporterId: 'demo_owner_user_2',
        reporterName: 'Rohan Kulkarni',
        activeClaimCount: 0,
        submissionId: 'sub_demo_5',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      ItemModel(
        id: 'demo_item_6',
        reportType: ItemReportType.found,
        status: ItemStatus.returned,
        title: 'Stainless Steel Milton Water Bottle (1L, Blue)',
        category: 'Bottles & Lunchboxes',
        description: 'Found at SJT 7th floor reading room. Successfully verified and returned to rightful owner.',
        imageUrls: [
          'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=600&q=80',
        ],
        approximateLocation: const ApproximateLocationModel(
          zoneId: 'sjt',
          zoneName: 'Silver Jubilee Tower (SJT)',
          approxLatitude: 12.9719,
          approxLongitude: 79.1636,
          areaDetail: '7th Floor Reading Room',
        ),
        incidentDateTime: now.subtract(const Duration(days: 5)),
        reporterId: 'demo_finder_user_1',
        reporterName: 'Aarav Sharma',
        activeClaimCount: 1,
        verifiedClaimId: 'demo_claim_returned',
        submissionId: 'sub_demo_6',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  /// Seeds demo data into Firestore if Firestore is configured and connected
  static Future<int> seedToFirestore() async {
    if (!FirebaseService.hasFirebaseConfig) return 0;

    final batch = FirebaseService.firestore.batch();
    final items = getDemoItems();

    for (final item in items) {
      final docRef = FirebaseService.firestore.collection('items').doc(item.id);
      batch.set(docRef, item.toMap());
    }

    await batch.commit();
    return items.length;
  }
}
