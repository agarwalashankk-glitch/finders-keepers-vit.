import 'package:finders_keepers/models/item_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ItemStateMachine Lifecycle Transitions', () {
    test('Permits valid LOST transitions', () {
      expect(ItemStateMachine.canTransition(ItemStatus.lost, ItemStatus.found), isTrue);
      expect(ItemStateMachine.canTransition(ItemStatus.lost, ItemStatus.claimed), isTrue);
      expect(ItemStateMachine.canTransition(ItemStatus.lost, ItemStatus.returned), isTrue);
      expect(ItemStateMachine.canTransition(ItemStatus.lost, ItemStatus.closed), isTrue);
    });

    test('Permits valid FOUND transitions', () {
      expect(ItemStateMachine.canTransition(ItemStatus.found, ItemStatus.claimed), isTrue);
      expect(ItemStateMachine.canTransition(ItemStatus.found, ItemStatus.closed), isTrue);
      // Cannot transition directly from found to returned without verification
      expect(ItemStateMachine.canTransition(ItemStatus.found, ItemStatus.returned), isFalse);
    });

    test('Enforces verification before handover', () {
      expect(ItemStateMachine.canTransition(ItemStatus.claimed, ItemStatus.verified), isTrue);
      expect(ItemStateMachine.canTransition(ItemStatus.claimed, ItemStatus.returned), isFalse);
      expect(ItemStateMachine.canTransition(ItemStatus.verified, ItemStatus.returned), isTrue);
    });

    test('Terminal states cannot transition anywhere', () {
      expect(ItemStateMachine.canTransition(ItemStatus.returned, ItemStatus.lost), isFalse);
      expect(ItemStateMachine.canTransition(ItemStatus.returned, ItemStatus.found), isFalse);
      expect(ItemStateMachine.canTransition(ItemStatus.closed, ItemStatus.claimed), isFalse);
    });
  });
}
