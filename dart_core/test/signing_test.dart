import 'package:telebirr_sdk_core/src/signing.dart';
import 'package:test/test.dart';

void main() {
  group('buildSignString', () {
    test('excludes sign, sign_type, header, refund_info, openType, raw_request, biz_content', () {
      final request = <String, dynamic>{
        'method': 'payment.preorder',
        'version': '1.0',
        'nonce_str': 'ABC123',
        'timestamp': '1234567890',
        'sign_type': 'SHA256WithRSA',
        'sign': 'skipsign',
        'header': 'skipheader',
        'refund_info': 'skiprefund',
        'openType': 'skipopen',
        'raw_request': 'skipraw',
        'biz_content': {
          'appid': '123',
          'merch_code': 'MC001',
        },
      };

      final result = buildSignString(request);

      expect(result, contains('appid=123'));
      expect(result, contains('merch_code=MC001'));
      expect(result, contains('method=payment.preorder'));
      expect(result, contains('nonce_str=ABC123'));
      expect(result, contains('timestamp=1234567890'));
      expect(result, contains('version=1.0'));

      expect(result, isNot(contains('sign=')));
      expect(result, isNot(contains('sign_type=')));
      expect(result, isNot(contains('header=')));
      expect(result, isNot(contains('refund_info=')));
      expect(result, isNot(contains('openType=')));
      expect(result, isNot(contains('raw_request=')));
      expect(result, isNot(contains('biz_content=')));
    });

    test('flattens biz_content inner fields', () {
      final request = <String, dynamic>{
        'method': 'payment.preorder',
        'biz_content': {
          'appid': '123',
          'merch_code': 'MC001',
          'total_amount': '100',
        },
      };

      final result = buildSignString(request);

      expect(result, contains('appid=123'));
      expect(result, contains('merch_code=MC001'));
      expect(result, contains('total_amount=100'));
      expect(result, contains('method=payment.preorder'));
    });

    test('sorts keys ASCII lexicographically', () {
      final request = <String, dynamic>{
        'zebra': 'z',
        'alpha': 'a',
        'middle': 'm',
      };

      final result = buildSignString(request);

      expect(result, 'alpha=a&middle=m&zebra=z');
    });

    test('sorts flattened biz_content keys together with top-level keys', () {
      final request = <String, dynamic>{
        'method': 'payment.preorder',
        'version': '1.0',
        'biz_content': {
          'appid': '123',
          'merch_code': 'MC001',
        },
      };

      final result = buildSignString(request);

      final parts = result.split('&');
      final keys = parts.map((p) => p.split('=')[0]).toList();
      final sortedKeys = List<String>.from(keys)..sort();
      expect(keys, sortedKeys);
    });

    test('handles empty biz_content', () {
      final request = <String, dynamic>{
        'method': 'payment.preorder',
        'version': '1.0',
        'biz_content': <String, dynamic>{},
      };

      final result = buildSignString(request);

      expect(result, 'method=payment.preorder&version=1.0');
    });

    test('handles missing biz_content', () {
      final request = <String, dynamic>{
        'method': 'payment.preorder',
        'version': '1.0',
      };

      final result = buildSignString(request);

      expect(result, 'method=payment.preorder&version=1.0');
    });

    test('converts values to strings', () {
      final request = <String, dynamic>{
        'count': 42,
        'active': true,
        'ratio': 3.14,
      };

      final result = buildSignString(request);

      expect(result, contains('active=true'));
      expect(result, contains('count=42'));
      expect(result, contains('ratio=3.14'));
    });

    test('produces correct format from full example', () {
      final request = <String, dynamic>{
        'nonce_str': 'ABC123',
        'method': 'payment.preorder',
        'timestamp': '1234567890',
        'version': '1.0',
        'sign_type': 'SHA256WithRSA',
        'biz_content': {
          'notify_url': 'https://example.com/hook',
          'business_type': 'BuyGoods',
          'trade_type': 'InApp',
          'appid': '98765',
          'merch_code': 'MC001',
          'merch_order_id': 'ORD001',
          'title': 'Test Order',
          'total_amount': '100',
          'trans_currency': 'ETB',
          'timeout_express': '120m',
          'payee_identifier': '220311',
          'payee_identifier_type': '04',
          'payee_type': '5000',
        },
      };

      final result = buildSignString(request);

      // Should contain all flattened fields
      expect(result, contains('appid=98765'));
      expect(result, contains('business_type=BuyGoods'));
      expect(result, contains('merch_code=MC001'));
      expect(result, contains('merch_order_id=ORD001'));
      expect(result, contains('method=payment.preorder'));
      expect(result, contains('nonce_str=ABC123'));
      expect(result, contains('notify_url=https://example.com/hook'));
      expect(result, contains('payee_identifier=220311'));
      expect(result, contains('payee_identifier_type=04'));
      expect(result, contains('payee_type=5000'));
      expect(result, contains('timeout_express=120m'));
      expect(result, contains('title=Test Order'));
      expect(result, contains('timestamp=1234567890'));
      expect(result, contains('total_amount=100'));
      expect(result, contains('trade_type=InApp'));
      expect(result, contains('trans_currency=ETB'));
      expect(result, contains('version=1.0'));

      // Should NOT contain excluded fields
      expect(result, isNot(contains('sign=')));
      expect(result, isNot(contains('sign_type=')));
      expect(result, isNot(contains('biz_content=')));
    });
  });
}
