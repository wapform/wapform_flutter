// example/test/widget_test.dart
//
// A smoke test only: the first frame of the example app builds without
// throwing. It does not wait for the login / gateway round trips
// (there is no server.js running in a test environment).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wapform_flutter_example/main.dart';

void main() {
  testWidgets('example app builds its first frame', (tester) async {
    await tester.pumpWidget(const WapApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
