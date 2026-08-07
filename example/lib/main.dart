// example/lib/main.dart
//
// Minimal shell app: checks the WapDb gateway is reachable, then opens
// the "系統參數建檔" (system parameters master file) screen — the
// single-table CRUD pattern every other WML-generated screen builds on.
//
// Before running this, start the backend (see example/server/README.md
// or the top-level example/README.md):
//   cd example/server && npm install && node server.js
import 'package:flutter/material.dart';
import 'package:wapform_flutter/wapform_flutter.dart';

import 'pages/agp001.dart';

void main() => runApp(const WapformExampleApp());

class WapformExampleApp extends StatelessWidget {
  const WapformExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wapform_flutter example',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF1A6FB5)),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();
  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  // null = checking, true = reachable, false = unreachable
  bool? _serverOk;

  @override
  void initState() {
    super.initState();
    _checkServer();
  }

  Future<void> _checkServer() async {
    // WapDb.ping() hits GET /ping on the gateway (server.js) — the same
    // http://localhost:3000 every TWapSQLConnection in this app talks to.
    final ok = await WapDb.ping();
    if (mounted) setState(() => _serverOk = ok);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('wapform_flutter example')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusBanner(),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.article_outlined),
              label: const Text('系統參數建檔'),
              onPressed: _serverOk == true
                  ? () => showAgp001(context)
                  : null,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _checkServer,
              child: const Text('Re-check server'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBanner() {
    if (_serverOk == null) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 8),
          Text('Checking http://localhost:3000 ...'),
        ],
      );
    }
    if (_serverOk == false) {
      return Column(
        children: [
          const Icon(Icons.cloud_off, color: Colors.red, size: 32),
          const SizedBox(height: 8),
          const Text(
            'Cannot reach the WapDb gateway at http://localhost:3000.',
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Start it with: cd example/server && npm install && node server.js',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_done, color: Colors.green),
        SizedBox(width: 8),
        Text('Connected to the WapDb gateway'),
      ],
    );
  }
}
