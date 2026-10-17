import 'package:finders_keepers/core/utils/fuzzy_location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FuzzyLocation Privacy Obfuscator', () {
    const lat = 12.9708;
    const lng = 79.1594;

    test('Generates approximate coordinate within requested privacy radius', () {
      final fuzzed = FuzzyLocation.applyPrivacyOffset(
        latitude: lat,
        longitude: lng,
        approxRadiusMeters: 65.0,
      );

      final distance = FuzzyLocation.distanceBetweenMeters(lat, lng, fuzzed.lat, fuzzed.lng);
      expect(distance, lessThanOrEqualTo(70.0));
      expect(distance, greaterThan(10.0));
      // Coordinates must not match exact raw input
      expect(fuzzed.lat != lat || fuzzed.lng != lng, isTrue);
    });
  });
}
