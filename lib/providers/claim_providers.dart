import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/claim_model.dart';
import '../repositories/claim_repository.dart';
import 'auth_providers.dart';
import 'item_providers.dart';

final claimRepositoryProvider = Provider<ClaimRepository>((ref) {
  final itemRepo = ref.watch(itemRepositoryProvider);
  return ClaimRepository(itemRepository: itemRepo);
});

/// Streams claims submitted for a specific item (for finder/reporter to review)
final itemClaimsProvider =
    StreamProvider.family<List<ClaimModel>, String>((ref, itemId) {
  final claimRepo = ref.watch(claimRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final isAdmin = ref.watch(isAdminProvider);

  if (user == null) return Stream.value([]);

  return claimRepo.watchClaimsForItem(
    itemId: itemId,
    currentUserId: user.uid,
    isAdmin: isAdmin,
  );
});

/// Streams claims submitted by the current user
final myClaimsProvider = StreamProvider<List<ClaimModel>>((ref) {
  final claimRepo = ref.watch(claimRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return Stream.value([]);
  return claimRepo.watchUserClaims(user.uid);
});
