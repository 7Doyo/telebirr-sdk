# Telebirr Dart/Flutter Example

A Flutter app demonstrating `telebirr_sdk_core` and `telebirr_flutter_elements`.

## Setup

```bash
flutter pub get
flutter run
```

## Structure

- `lib/main.dart` — Flutter app with `TelebirrProvider`, `PaymentButton`, and `TestModeBadge`

## Configuration

Edit the `TelebirrConfig` in `lib/main.dart` with your developer credentials. In a production app, load these from environment variables or a secure config service.

## Notes

- The `TestModeBadge` widget displays a yellow "Test Mode" badge when the environment is `sandbox`.
- The `PaymentButton` handles loading state automatically via `PaymentNotifier`.
- All signing and token management is handled internally by the SDK.
