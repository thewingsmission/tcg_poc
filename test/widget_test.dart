// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:tcg_poc/main.dart';

void main() {
  testWidgets('home screen shows all poc buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Flutter PoC Gallery'), findsOneWidget);
    expect(find.text('PoC 1: 3D Card'), findsOneWidget);
    expect(find.text('PoC 2: Crack Glow'), findsOneWidget);
    expect(find.text('PoC 3: Foil Frame'), findsOneWidget);
    expect(find.text('PoC 4: Immersive 3D Card'), findsOneWidget);
  });
}
