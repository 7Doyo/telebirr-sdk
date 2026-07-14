import 'package:flutter/material.dart';
import 'package:telebirr_flutter_elements/telebirr_flutter_elements.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telebirr Flutter Example',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00A850),
        useMaterial3: true,
      ),
      home: const PaymentScreen(),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final Telebirr _telebirr;
  late final PaymentNotifier _notifier;

  final _amountController = TextEditingController(text: '100');
  final _titleController = TextEditingController(text: 'Test Payment');
  String? _resultMessage;

  @override
  void initState() {
    super.initState();

    _telebirr = Telebirr(
      const TelebirrConfig(
        environment: Environment.sandbox,
        fabricAppId: '5f0b1a2c-3d4e-5f6a-7b8c-9d0e1f2a3b4c',
        merchantAppId: '100001',
        merchantCode: 'TEST_MERCHANT',
        appSecret: 'sk_test_your_app_secret_here',
        privateKeyPem: '-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBg...\n-----END PRIVATE KEY-----',
        shortCode: '220311',
        timeout: '120m',
        notifyUrl: 'https://your-domain.com/webhook',
      ),
    );

    _notifier = PaymentNotifier(_telebirr);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _handleCharge() async {
    setState(() => _resultMessage = null);

    try {
      await _notifier.charge(
        CreateOrderParams(
          amount: _amountController.text,
          title: _titleController.text,
        ),
      );

      final response = _notifier.response;
      setState(() {
        _resultMessage = 'Order created!\nPrepay ID: ${response?.prepayId}\nReceive code: ${response?.receiveCode}';
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TelebirrProvider(
      telebirr: _telebirr,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Telebirr Payment'),
          actions: const [
            TestModeBadge(environment: Environment.sandbox),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (ETB)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              PaymentButton(
                notifier: _notifier,
                onPressed: _handleCharge,
              ),
              if (_resultMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_resultMessage!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
