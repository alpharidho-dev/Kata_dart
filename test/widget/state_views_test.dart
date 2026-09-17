import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kata/widgets/state_views.dart';

void main() {
  group('EmptyStateView', () {
    testWidgets('menampilkan ikon, judul, dan subjudul', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.photo_library_outlined,
              title: 'Belum ada postingan',
              subtitle: 'Tap tombol + untuk mulai menulis.',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
      expect(find.text('Belum ada postingan'), findsOneWidget);
      expect(find.text('Tap tombol + untuk mulai menulis.'), findsOneWidget);
    });
  });

  group('ErrorStateView', () {
    testWidgets('menampilkan pesan error tanpa tombol bila onRetry null',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ErrorStateView(message: 'Gagal memuat data'),
          ),
        ),
      );

      expect(find.text('Gagal memuat data'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('menampilkan tombol Coba Lagi dan memanggil onRetry',
        (tester) async {
      var retryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateView(
              message: 'Gagal memuat data',
              onRetry: () => retryCount++,
            ),
          ),
        ),
      );

      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();

      expect(retryCount, 1);
    });
  });
}
