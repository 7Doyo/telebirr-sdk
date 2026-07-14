import 'package:telebirr_sdk_core/src/receive_code.dart';
import 'package:test/test.dart';

void main() {
  group('buildReceiveCode', () {
    test('builds correct format from example values', () {
      final result = buildReceiveCode('220311', '100', 'PREPAY123', '120m');

      expect(result, 'TELEBIRR\$BUYGOODS220311100PREPAY123%120m');
    });

    test('builds correct format with empty values', () {
      final result = buildReceiveCode('', '', '', '');

      expect(result, 'TELEBIRR\$BUYGOODS%');
    });

    test('preserves exact order of parameters', () {
      final result = buildReceiveCode(
        'shortCode',
        'amount',
        'prepayId',
        'timeout',
      );

      expect(result, 'TELEBIRR\$BUYGOODSshortCodeamountprepayId%timeout');
    });

    test('starts with TELEBIRR prefix', () {
      final result = buildReceiveCode('123', '456', 'P789', '30m');

      expect(result, startsWith('TELEBIRR'));
    });

    test('contains BUYGOODS delimiter', () {
      final result = buildReceiveCode('123', '456', 'P789', '30m');

      expect(result, contains('BUYGOODS'));
    });

    test('contains % separator before timeout', () {
      final result = buildReceiveCode('123', '456', 'P789', '30m');

      expect(result, contains('%30m'));
    });

    test('handles numeric-looking strings', () {
      final result = buildReceiveCode('220311', '100', '12345', '120m');

      expect(result, 'TELEBIRR\$BUYGOODS22031110012345%120m');
    });
  });
}
