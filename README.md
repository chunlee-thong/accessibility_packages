# accessibility_packages

Android-only Flutter plugin that reports which apps have an **accessibility service** enabled (or merely installed). Useful for security checks (detecting overlay/keylogger-style abuse), kiosk apps, banking apps, etc.

## Usage

```yaml
dependencies:
  accessibility_packages:
    path: ../accessibility_packages
```

```dart
import 'package:accessibility_packages/accessibility_packages.dart';

final enabled = await AccessibilityPackages.getEnabledApps();
for (final app in enabled) {
  print('${app.appName} (${app.packageName}) system=${app.isSystemApp}');
}

final names = await AccessibilityPackages.getEnabledPackageNames();
final installed = await AccessibilityPackages.getInstalledApps(); // check .isEnabled
```

## Notes
- No special permissions needed; it uses `AccessibilityManager`, which also avoids `QUERY_ALL_PACKAGES`.
- Returns an empty list on non-Android platforms.
- Can't see *which* apps are actively reading the screen, only which services are enabled.
- `capabilities` shows what each service can do (e.g. `retrieveWindowContent`, `performGestures`).

## Try the example
```
cd example && flutter create . --platforms=android && flutter run
```
