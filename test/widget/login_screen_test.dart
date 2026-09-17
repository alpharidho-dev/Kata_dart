import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kata/screens/login_screen.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('Login screen renders with email and password fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Masuk'), findsWidgets);
    });

    testWidgets('Email validation shows error for empty input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Email wajib diisi'), findsOneWidget);
    });

    testWidgets('Password field toggles visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      final visibilityButton = find.byIcon(Icons.visibility_off_outlined);
      expect(visibilityButton, findsOneWidget);

      await tester.tap(visibilityButton);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('Navigate to register screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
          routes: {
            '/register': (context) => const Scaffold(
              body: Text('Register Screen'),
            ),
          },
        ),
      );

      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();

      expect(find.text('Register Screen'), findsOneWidget);
    });

    testWidgets('Form shows error for invalid email format',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Format email salah'), findsOneWidget);
    });

    testWidgets('Form shows error for short password',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(emailField, 'test@email.com');
      await tester.enterText(passwordField, '123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Password minimal 6 karakter'), findsOneWidget);
    });
  });
}
