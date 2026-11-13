import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// Describes one accessibility service and the app (package) that owns it.
class AccessibilityApp {
  const AccessibilityApp({
    required this.packageName,
    required this.appName,
    required this.serviceName,
    required this.serviceId,
    required this.isEnabled,
    required this.isSystemApp,
    required this.capabilities,
    this.description,
  });

  final String packageName;
  final String appName;
  final String serviceName;
  final String serviceId;
  final bool isEnabled;
  final bool isSystemApp;
  final List<String> capabilities;
  final String? description;

  factory AccessibilityApp.fromMap(Map<dynamic, dynamic> map) {
    return AccessibilityApp(
      packageName: map['packageName'] as String,
      appName: map['appName'] as String? ?? '',
      serviceName: map['serviceName'] as String? ?? '',
      serviceId: map['serviceId'] as String? ?? '',
      isEnabled: map['isEnabled'] as bool? ?? false,
      isSystemApp: map['isSystemApp'] as bool? ?? false,
      capabilities: (map['capabilities'] as List?)?.cast<String>() ?? const <String>[],
      description: map['description'] as String?,
    );
  }

  @override
  String toString() => 'AccessibilityApp($packageName, enabled: $isEnabled, system: $isSystemApp)';
}

/// Query which apps use Android's accessibility services.
class AccessibilityPackages {
  AccessibilityPackages._();

  static const MethodChannel _channel = MethodChannel('com.lynical.accessibility_packages');

  /// Apps whose accessibility service is currently turned ON.
  static Future<List<AccessibilityApp>> getEnabledApps() async {
    return _fetch('getEnabledServices');
  }

  /// All installed apps that declare an accessibility service
  /// (each has [AccessibilityApp.isEnabled] set accordingly).
  static Future<List<AccessibilityApp>> getInstalledApps() async {
    return _fetch('getInstalledServices');
  }

  /// Just the unique package names of enabled accessibility apps.
  static Future<List<String>> getEnabledPackageNames() async {
    final apps = await getEnabledApps();
    return apps.map((a) => a.packageName).toSet().toList();
  }

  static Future<List<AccessibilityApp>> _fetch(String method) async {
    if (!Platform.isAndroid) return const [];
    final result = await _channel.invokeListMethod<Map>(method);
    return (result ?? const <Map>[]).map((m) => AccessibilityApp.fromMap(m)).toList();
  }
}
