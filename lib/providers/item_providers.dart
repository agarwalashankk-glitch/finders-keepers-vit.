import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item_event_model.dart';
import '../models/item_model.dart';
import '../models/item_status.dart';
import '../repositories/item_repository.dart';
import 'auth_providers.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository();
});

class ItemFilterState {
  final ItemReportType? reportType;
  final String? category;
  final ItemStatus? status;
  final String? zoneId;
  final String? searchQuery;

  const ItemFilterState({
    this.reportType,
    this.category,
    this.status,
    this.zoneId,
    this.searchQuery,
  });

  ItemFilterState copyWith({
    ItemReportType? reportType,
    bool clearReportType = false,
    String? category,
    bool clearCategory = false,
    ItemStatus? status,
    bool clearStatus = false,
    String? zoneId,
    bool clearZone = false,
    String? searchQuery,
    bool clearSearch = false,
  }) {
    return ItemFilterState(
      reportType: clearReportType ? null : (reportType ?? this.reportType),
      category: clearCategory ? null : (category ?? this.category),
      status: clearStatus ? null : (status ?? this.status),
      zoneId: clearZone ? null : (zoneId ?? this.zoneId),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
    );
  }
}

class ItemFilterNotifier extends StateNotifier<ItemFilterState> {
  ItemFilterNotifier() : super(const ItemFilterState());

  void setReportType(ItemReportType? type) {
    state = state.copyWith(reportType: type, clearReportType: type == null);
  }

  void setCategory(String? category) {
    state = state.copyWith(category: category, clearCategory: category == null || category == 'All');
  }

  void setStatus(ItemStatus? status) {
    state = state.copyWith(status: status, clearStatus: status == null);
  }

  void setZone(String? zoneId) {
    state = state.copyWith(zoneId: zoneId, clearZone: zoneId == null || zoneId == 'all');
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, clearSearch: query.trim().isEmpty);
  }

  void resetFilters() {
    state = const ItemFilterState();
  }
}

final itemFilterProvider =
    StateNotifierProvider<ItemFilterNotifier, ItemFilterState>((ref) {
  return ItemFilterNotifier();
});

/// Streams items based on currently selected filters and search term
final filteredItemsProvider = StreamProvider<List<ItemModel>>((ref) {
  final repo = ref.watch(itemRepositoryProvider);
  final filter = ref.watch(itemFilterProvider);

  return repo.watchItems(
    reportType: filter.reportType,
    category: filter.category,
    status: filter.status,
    zoneId: filter.zoneId,
    searchQuery: filter.searchQuery,
  );
});

/// Recent items for home screen (unfiltered, top 5)
final recentItemsProvider = StreamProvider<List<ItemModel>>((ref) {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.watchItems().map((list) => list.take(6).toList());
});

/// Streams items reported by current logged-in user
final myReportsProvider = StreamProvider<List<ItemModel>>((ref) {
  final repo = ref.watch(itemRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);

  return repo.watchItems().map((list) {
    return list.where((item) => item.reporterId == user.uid).toList();
  });
});

/// Fetches a single item by id
final singleItemProvider =
    FutureProvider.family<ItemModel?, String>((ref, itemId) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getItemById(itemId);
});

/// Fetches audit event history for an item
final itemEventsProvider =
    FutureProvider.family<List<ItemEventModel>, String>((ref, itemId) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getItemEvents(itemId);
});
