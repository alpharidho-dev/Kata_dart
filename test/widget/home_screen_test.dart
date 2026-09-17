import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kata/screens/home_screen.dart';
import 'package:kata/widgets/bottom_nav_bar.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('HomeScreen renders with bottom navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
    });

    testWidgets('AppBar displays title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.text('KATA'), findsOneWidget);
    });

    testWidgets('Search and refresh buttons present in AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsWidgets);
    });
  });
}
