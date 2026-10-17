import 'package:finders_keepers/core/utils/input_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputValidators Form Validation', () {
    test('Email validator enforces valid format', () {
      expect(InputValidators.validateEmail(''), isNotNull);
      expect(InputValidators.validateEmail('notanemail'), isNotNull);
      expect(InputValidators.validateEmail('student@vitstudent.ac.in'), isNull);
    });

    test('Password validator requires at least 6 characters', () {
      expect(InputValidators.validatePassword('123'), isNotNull);
      expect(InputValidators.validatePassword('secret123'), isNull);
    });

    test('Claim evidence validator enforces minimum length for fraud prevention', () {
      expect(InputValidators.validateClaimEvidence('mine'), isNotNull);
      expect(
        InputValidators.validateClaimEvidence(
          'This has distinctive blue sticker on back and crack on top corner',
        ),
        isNull,
      );
    });
  });
}
