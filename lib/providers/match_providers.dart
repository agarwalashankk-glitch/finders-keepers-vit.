import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item_model.dart';
import '../models/match_result_model.dart';
import '../services/matching_service.dart';
import 'item_providers.dart';

/// Calculates potential matches for a target item from among all active reports
final potentialMatchesProvider =
    Provider.family<List<MatchResultModel>, ItemModel>((ref, targetItem) {
  final allItemsAsync = ref.watch(filteredItemsProvider);

  return allItemsAsync.maybeWhen(
    data: (items) {
      return MatchingService.findPotentialMatches(
        target: targetItem,
        candidates: items,
      );
    },
    orElse: () => [],
  );
});
