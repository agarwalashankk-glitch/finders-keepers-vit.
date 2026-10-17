import '../core/constants/app_constants.dart';
import '../core/utils/fuzzy_location.dart';
import '../models/item_model.dart';
import '../models/item_status.dart';
import '../models/match_result_model.dart';

class MatchingService {
  static const Set<String> _stopWords = {
    'a', 'an', 'the', 'and', 'or', 'in', 'on', 'at', 'to', 'for', 'of', 'with',
    'by', 'my', 'is', 'it', 'was', 'lost', 'found', 'near', 'beside', 'around',
    'please', 'help', 'vit', 'campus', 'item', 'belonging', 'colour', 'color',
  };

  /// Computes rule-based potential matches between [target] and a list of [candidates].
  /// If target is LOST, searches among FOUND items (and vice versa).
  static List<MatchResultModel> findPotentialMatches({
    required ItemModel target,
    required List<ItemModel> candidates,
    double threshold = AppConstants.matchScoreThreshold,
  }) {
    final List<MatchResultModel> results = [];

    // Filter to complementary report types (Lost <-> Found)
    final complementaryType = target.isLost ? ItemReportType.found : ItemReportType.lost;

    for (final candidate in candidates) {
      if (candidate.id == target.id) continue;
      if (candidate.reportType != complementaryType) continue;
      // Do not match closed or already returned items
      if (candidate.status == ItemStatus.returned || candidate.status == ItemStatus.closed) {
        continue;
      }

      final matchResult = scoreMatch(target, candidate);
      if (matchResult.score >= threshold) {
        results.add(matchResult);
      }
    }

    // Sort by descending match score
    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }

  /// Evaluates two items using four transparent, explainable heuristic dimensions:
  /// 1. Category (40%)
  /// 2. Keywords (30%)
  /// 3. Location Proximity (20%)
  /// 4. Time Proximity (10%)
  static MatchResultModel scoreMatch(ItemModel target, ItemModel candidate) {
    double categoryScore = 0.0;
    double keywordScore = 0.0;
    double locationScore = 0.0;
    double timeScore = 0.0;
    final List<String> reasons = [];

    // 1. Category Heuristic (Max 40 pts)
    if (target.category.toLowerCase() == candidate.category.toLowerCase()) {
      categoryScore = 40.0;
      reasons.add('Identical category: ${target.category}');
    }

    // 2. Keyword Overlap Heuristic (Max 30 pts)
    final targetTokens = _extractTokens('${target.title} ${target.description}');
    final candidateTokens = _extractTokens('${candidate.title} ${candidate.description}');

    final commonTokens = targetTokens.intersection(candidateTokens);
    if (commonTokens.isNotEmpty) {
      final double overlapRatio = (commonTokens.length * 2.0) /
          (targetTokens.length + candidateTokens.length).clamp(1, 100);
      keywordScore = (overlapRatio * 30.0).clamp(0.0, 30.0);
      if (keywordScore > 5.0) {
        final sampleWords = commonTokens.take(3).join(', ');
        reasons.add('Matching keywords: "$sampleWords"');
      }
    }

    // 3. Approximate Location Proximity Heuristic (Max 20 pts)
    if (target.approximateLocation.zoneId == candidate.approximateLocation.zoneId) {
      locationScore = 20.0;
      reasons.add('Same campus zone: ${target.approximateLocation.zoneName}');
    } else {
      final distance = FuzzyLocation.distanceBetweenMeters(
        target.approximateLocation.approxLatitude,
        target.approximateLocation.approxLongitude,
        candidate.approximateLocation.approxLatitude,
        candidate.approximateLocation.approxLongitude,
      );
      if (distance <= 250.0) {
        locationScore = 14.0;
        reasons.add('Adjacent zone (<250m away)');
      } else if (distance <= 500.0) {
        locationScore = 8.0;
        reasons.add('Nearby campus area (<500m away)');
      }
    }

    // 4. Temporal Proximity Heuristic (Max 10 pts)
    final timeDiff = target.incidentDateTime
        .difference(candidate.incidentDateTime)
        .abs();
    final daysDiff = timeDiff.inDays;

    if (daysDiff <= 1) {
      timeScore = 10.0;
      reasons.add('Reported within 24 hours of each other');
    } else if (daysDiff <= 3) {
      timeScore = 8.0;
      reasons.add('Reported within 3 days');
    } else if (daysDiff <= 7) {
      timeScore = 5.0;
      reasons.add('Reported within 1 week');
    } else if (daysDiff <= 14) {
      timeScore = 2.0;
    }

    final double totalScore = (categoryScore + keywordScore + locationScore + timeScore)
        .clamp(0.0, 100.0);

    return MatchResultModel(
      targetItem: target,
      candidateItem: candidate,
      score: totalScore,
      categoryScore: categoryScore,
      keywordScore: keywordScore,
      locationScore: locationScore,
      timeScore: timeScore,
      matchReasons: reasons,
    );
  }

  static Set<String> _extractTokens(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((token) => token.length >= 3 && !_stopWords.contains(token))
        .toSet();
  }
}
