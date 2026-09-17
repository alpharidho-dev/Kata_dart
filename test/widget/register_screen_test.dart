import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kata/screens/register_screen.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
    await tester.pumpAndSettle();
  }

  group('RegisterScreen', () {
    testWidgets('menampilkan form username, email, dan password',
        (tester) async {
      await pumpScreen(tester);

      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.text('Buat akun KATA'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Daftar'), findsWidgets);
    });

    testWidgets('submit kosong memunculkan semua error wajib isi',
        (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Username wajib diisi'), findsOneWidget);
      expect(find.text('Email wajib diisi'), findsOneWidget);
      expect(find.text('Password wajib diisi'), findsOneWidget);
    });

    testWidgets('username kurang dari 3 karakter ditolak', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Username'),
        'ab',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Username minimal 3 karakter'), findsOneWidget);
    });

    testWidgets('email tanpa @ ditolak', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'bukan-email',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Format email salah'), findsOneWidget);
    });

    testWidgets('password di bawah 8 karakter ditolak', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'Ab1',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Password minimal 8 karakter'), findsOneWidget);
    });

    testWidgets('password tanpa angka ditolak', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'abcd efgh',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Password harus memuat angka'), findsOneWidget);
    });

    testWidgets('password tanpa huruf ditolak', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '12345678',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Password harus memuat huruf'), findsOneWidget);
    });

    testWidgets('tombol visibilitas password berfungsi', (tester) async {
      await pumpScreen(tester);

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('tombol Masuk kembali ke halaman sebelumnya', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
              child: const Text('Buka daftar'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Buka daftar'));
      await tester.pumpAndSettle();
      expect(find.byType(RegisterScreen), findsOneWidget);

      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(find.byType(RegisterScreen), findsNothing);
      expect(find.text('Buka daftar'), findsOneWidget);
    });
  });
}
