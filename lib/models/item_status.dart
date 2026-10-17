enum ItemReportType {
  lost,
  found;

  String get displayName {
    switch (this) {
      case ItemReportType.lost:
        return 'Lost Item';
      case ItemReportType.found:
        return 'Found Item';
    }
  }

  static ItemReportType fromString(String val) {
    return ItemReportType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => ItemReportType.lost,
    );
  }
}

enum ItemStatus {
  lost,
  found,
  claimed,
  verified,
  returned,
  closed;

  String get displayName {
    switch (this) {
      case ItemStatus.lost:
        return 'Lost';
      case ItemStatus.found:
        return 'Found';
      case ItemStatus.claimed:
        return 'Under Claim';
      case ItemStatus.verified:
        return 'Claim Verified';
      case ItemStatus.returned:
        return 'Returned';
      case ItemStatus.closed:
        return 'Closed';
    }
  }

  static ItemStatus fromString(String val) {
    return ItemStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => ItemStatus.lost,
    );
  }
}

/// State Machine Validator enforcing valid lifecycle transitions for campus items
class ItemStateMachine {
  static const Map<ItemStatus, List<ItemStatus>> _validTransitions = {
    ItemStatus.lost: [
      ItemStatus.claimed,
      ItemStatus.found,
      ItemStatus.returned,
      ItemStatus.closed,
    ],
    ItemStatus.found: [
      ItemStatus.claimed,
      ItemStatus.closed,
    ],
    ItemStatus.claimed: [
      ItemStatus.found, // If all active claims are rejected, reverts to found
      ItemStatus.lost,  // If claim on lost item rejected
      ItemStatus.verified, // Ownership verified by finder
      ItemStatus.closed,
    ],
    ItemStatus.verified: [
      ItemStatus.claimed, // Retracted or disputed
      ItemStatus.returned, // Physical handover complete
      ItemStatus.closed,
    ],
    ItemStatus.returned: [], // Terminal state
    ItemStatus.closed: [],   // Terminal state
  };

  /// Returns true if transition from [from] to [to] is permitted
  static bool canTransition(ItemStatus from, ItemStatus to) {
    if (from == to) return true;
    final allowed = _validTransitions[from] ?? [];
    return allowed.contains(to);
  }

  /// Returns human-readable explanation of why a transition failed
  static String transitionErrorMessage(ItemStatus from, ItemStatus to) {
    return 'Invalid status transition: Cannot change item from ${from.displayName} to ${to.displayName}.';
  }
}
