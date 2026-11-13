import 'package:accessibility_packages/accessibility_packages.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Home()));

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<AccessibilityApp>> _apps;

  @override
  void initState() {
    super.initState();
    _apps = AccessibilityPackages.getEnabledApps();
  }

  void _refresh() =>
      setState(() => _apps = AccessibilityPackages.getEnabledApps());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apps using Accessibility'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh)],
      ),
      body: FutureBuilder<List<AccessibilityApp>>(
        future: _apps,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('${snap.error}'));
          final apps = snap.data!;
          if (apps.isEmpty) return const Center(child: Text('None enabled'));
          return ListView.separated(
            itemCount: apps.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final a = apps[i];
              return ListTile(
                title: Text(a.appName),
                subtitle: Text('${a.packageName}\n${a.capabilities.join(", ")}'),
                isThreeLine: true,
                trailing: a.isSystemApp ? const Chip(label: Text('system')) : null,
              );
            },
          );
        },
      ),
    );
  }
}
