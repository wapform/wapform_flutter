// example/test/widget_test.dart
//
// A smoke test only — it deliberately does NOT wait for the gateway
// ping to resolve (pumpAndSettle would hang/flake here since there's
// no server.js running in a test environment), just checks the first
// frame renders without throwing and shows the loading state.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wapform_flutter_example/main.dart';

void main() {
  testWidgets('home page renders and starts checking the gateway',
      (tester) async {
    await tester.pumpWidget(const WapformExampleApp());
    // Single pump: the async WapDb.ping() call in initState hasn't
    // resolved yet, so this only asserts the initial "checking" frame.
    await tester.pump();

    expect(find.text('wapform_flutter example'), findsOneWidget);
    expect(find.textContaining('Checking http://localhost:3000'),
        findsOneWidget);
    // The button is disabled until the gateway check succeeds.
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });
}
