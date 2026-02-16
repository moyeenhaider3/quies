import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quies/core/updater/update_checker_wrapper.dart';

void main() {
  group('UpdateCheckerWrapper', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UpdateCheckerWrapper(child: Scaffold(body: Text('Test Child'))),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('gracefully handles network failure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: UpdateCheckerWrapper(
            child: Scaffold(body: Text('Still Works')),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Still Works'), findsOneWidget);
    });
  });
}
