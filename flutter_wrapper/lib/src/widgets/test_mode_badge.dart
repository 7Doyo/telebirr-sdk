import 'package:flutter/widgets.dart';
import 'package:telebirr_sdk_core/telebirr_sdk_core.dart';

import '../l10n/telebirr_localizations.dart';

/// A yellow "Test Mode" badge that is visible only in sandbox environments.
///
/// Renders nothing (zero-size [SizedBox]) when [environment] is not
/// [Environment.sandbox]. When in sandbox mode, displays a rounded yellow
/// chip with the localized test-mode label.
///
/// ```dart
/// TestModeBadge(environment: Environment.sandbox)
/// ```
class TestModeBadge extends StatelessWidget {
  /// The current SDK environment.
  final Environment environment;

  /// Creates a [TestModeBadge] for the given [environment].
  const TestModeBadge({super.key, required this.environment});

  @override
  Widget build(BuildContext context) {
    if (environment != Environment.sandbox) return const SizedBox.shrink();

    final l10n = TelebirrLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        l10n.testMode,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF856404),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
