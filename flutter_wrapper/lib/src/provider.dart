import 'package:flutter/widgets.dart';
import 'package:telebirr_sdk_core/telebirr_sdk_core.dart';

/// An [InheritedWidget] that provides a [Telebirr] instance to the widget tree.
///
/// Place this widget near the top of your app (typically wrapping [MaterialApp])
/// so that descendant widgets can access the Telebirr SDK via
/// [TelebirrProvider.of] or the [TelebirrContextExtension] extension.
///
/// ```dart
/// TelebirrProvider(
///   telebirr: telebirr,
///   child: MaterialApp(home: MyApp()),
/// )
/// ```
class TelebirrProvider extends InheritedWidget {
  /// The [Telebirr] SDK instance made available to descendants.
  final Telebirr telebirr;

  /// Creates a [TelebirrProvider].
  ///
  /// The [telebirr] parameter is the initialized SDK instance.
  /// The [child] parameter is the subtree that will have access to the SDK.
  const TelebirrProvider({
    super.key,
    required this.telebirr,
    required super.child,
  });

  /// Returns the [Telebirr] instance from the nearest [TelebirrProvider] ancestor.
  ///
  /// Throws an [AssertionError] if no [TelebirrProvider] is found in the
  /// widget tree above [context].
  static Telebirr of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<TelebirrProvider>();
    assert(provider != null, 'No TelebirrProvider found in context');
    return provider!.telebirr;
  }

  @override
  bool updateShouldNotify(TelebirrProvider oldWidget) =>
      telebirr != oldWidget.telebirr;
}

/// Extension on [BuildContext] for convenient access to the [Telebirr] instance.
///
/// Usage:
/// ```dart
/// final telebirr = context.telebirr;
/// ```
extension TelebirrContextExtension on BuildContext {
  /// The [Telebirr] instance from the nearest [TelebirrProvider] ancestor.
  Telebirr get telebirr => TelebirrProvider.of(this);
}
