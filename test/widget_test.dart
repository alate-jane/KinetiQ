import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinetiq/main.dart';

void main() {
  testWidgets('KinetiQ app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: KinetiQApp()),
    );
    // App should render without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
