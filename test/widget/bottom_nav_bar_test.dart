import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kata/widgets/bottom_nav_bar.dart';
import 'package:kata/widgets/loading_indicator.dart';

void main() {
  group('AppBottomNavBar', () {
    testWidgets('menampilkan label dua tab dan tombol compose',
        (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              selectedIndex: 0,
              onItemSelected: (_) {},
              onComposePressed: () {},
            ),
          ),
        ),
      );

      // Label tab dirender lewat Semantics, bukan widget Text.
      expect(find.bySemanticsLabel('Beranda'), findsOneWidget);
      expect(find.bySemanticsLabel('Profil'), findsOneWidget);
      expect(find.bySemanticsLabel('Buat postingan'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      semantics.dispose();
    });

    testWidgets('tab Profil memanggil onItemSelected(1)', (tester) async {
      var selected = -1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              selectedIndex: 0,
              onItemSelected: (i) => selected = i,
              onComposePressed: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.person_outline_rounded));
      await tester.pumpAndSettle();

      expect(selected, 1);
    });

    testWidgets('tombol compose memanggil onComposePressed', (tester) async {
      var composePressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              selectedIndex: 0,
              onItemSelected: (_) {},
              onComposePressed: () => composePressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(composePressed, isTrue);
    });

    testWidgets('tab aktif memakai ikon versi solid', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              selectedIndex: 1,
              onItemSelected: (_) {},
              onComposePressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(find.byIcon(Icons.home_rounded), findsNothing);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });
  });

  group('LoadingIndicator', () {
    testWidgets('menampilkan pesan bawaan "Memuat..."', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: LoadingIndicator())),
      );

      expect(find.text('Memuat...'), findsOneWidget);
    });

    testWidgets('menampilkan pesan kustom', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LoadingIndicator(message: 'Memuat postingan...')),
        ),
      );

      expect(find.text('Memuat postingan...'), findsOneWidget);
    });
  });
}
