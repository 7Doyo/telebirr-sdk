import 'dart:io';

import 'package:telebirr_sdk_core/telebirr_sdk_core.dart';

void main() async {
  final environment = Platform.environment['TELEBIRR_ENVIRONMENT'] ?? 'SANDBOX';

  final config = TelebirrConfig(
    environment: environment == 'PRODUCTION'
        ? Environment.production
        : Environment.sandbox,
    fabricAppId: Platform.environment['TELEBIRR_FABRIC_APP_ID'] ?? '',
    merchantAppId: Platform.environment['TELEBIRR_MERCHANT_APP_ID'] ?? '',
    merchantCode: Platform.environment['TELEBIRR_MERCHANT_CODE'] ?? '',
    appSecret: Platform.environment['TELEBIRR_API_KEY'] ?? '',
    privateKeyPem: Platform.environment['TELEBIRR_PRIVATE_KEY'] ?? '',
    shortCode: Platform.environment['TELEBIRR_SHORT_CODE'] ?? '220311',
    timeout: Platform.environment['TELEBIRR_TIMEOUT'] ?? '120m',
    notifyUrl: Platform.environment['TELEBIRR_NOTIFY_URL'] ?? '',
  );

  final telebirr = Telebirr(config);

  stdout.writeln('Telebirr SDK - Pure Dart CLI Example');
  stdout.writeln('Environment: ${config.environment.name}');
  stdout.writeln();

  stdout.write('Enter amount (ETB): ');
  final amount = stdin.readLineSync() ?? '100';

  stdout.write('Enter title: ');
  final title = stdin.readLineSync() ?? 'Test Payment';

  stdout.writeln();
  stdout.writeln('Creating order...');

  try {
    final result = await telebirr.payments.charge(
      CreateOrderParams(
        amount: amount,
        title: title,
      ),
    );

    stdout.writeln('Order created successfully!');
    stdout.writeln('  Prepay ID:   ${result.prepayId}');
    stdout.writeln('  Receive Code: ${result.receiveCode}');
    stdout.writeln('  Message:     ${result.message}');

    final receiveCode = telebirr.payments.buildReceiveCodeForPrepayId(result.prepayId);
    stdout.writeln();
    stdout.writeln('  Built Receive Code: $receiveCode');
  } catch (e) {
    stdout.writeln('Error: $e');
    exit(1);
  }
}
