import 'package:finders_keepers/models/approximate_location_model.dart';
import 'package:finders_keepers/models/item_model.dart';
import 'package:finders_keepers/models/item_status.dart';
import 'package:finders_keepers/services/matching_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MatchingService Rule-Based Heuristic', () {
    final now = DateTime.now();

    final lostAirpods = ItemModel(
      id: 'lost_1',
      reportType: ItemReportType.lost,
      status: ItemStatus.lost,
      title: 'Lost Apple AirPods Pro with white case',
      category: 'Earphones & Audio',
      description: 'Lost my airpods in TT computer lab with astronaut sticker',
      approximateLocation: const ApproximateLocationModel(
        zoneId: 'tt',
        zoneName: 'Technology Tower (TT)',
        approxLatitude: 12.9708,
        approxLongitude: 79.1594,
      ),
      incidentDateTime: now,
      reporterId: 'user_a',
      reporterName: 'Student A',
      submissionId: 'sub_1',
      createdAt: now,
      updatedAt: now,
    );

    final foundAirpods = ItemModel(
      id: 'found_1',
      reportType: ItemReportType.found,
      status: ItemStatus.found,
      title: 'Found AirPods Pro White Case',
      category: 'Earphones & Audio',
      description: 'Found white apple airpods in TT building',
      approximateLocation: const ApproximateLocationModel(
        zoneId: 'tt',
        zoneName: 'Technology Tower (TT)',
        approxLatitude: 12.9708,
        approxLongitude: 79.1594,
      ),
      incidentDateTime: now.subtract(const Duration(hours: 3)),
      reporterId: 'user_b',
      reporterName: 'Student B',
      submissionId: 'sub_2',
      createdAt: now,
      updatedAt: now,
    );

    test('Computes strong match score for complementary items with shared keywords and zone', () {
      final match = MatchingService.scoreMatch(lostAirpods, foundAirpods);
      expect(match.score, greaterThan(65.0));
      expect(match.categoryScore, equals(40.0));
      expect(match.locationScore, equals(20.0));
      expect(match.timeScore, equals(10.0));
      expect(match.matchReasons, isNotEmpty);
    });
  });
}
