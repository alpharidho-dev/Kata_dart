import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kata/widgets/user_avatar.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('UserAvatar', () {
    testWidgets('tanpa imageUrl menampilkan inisial username', (tester) async {
      await tester.pumpWidget(
        wrap(const UserAvatar(imageUrl: null, username: 'budi')),
      );

      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('imageUrl kosong juga menampilkan inisial', (tester) async {
      await tester.pumpWidget(
        wrap(const UserAvatar(imageUrl: '', username: 'sinta')),
      );

      expect(find.text('S'), findsOneWidget);
    });

    testWidgets('username kosong menampilkan tanda tanya', (tester) async {
      await tester.pumpWidget(
        wrap(const UserAvatar(imageUrl: null, username: '')),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('imageUrl error (URL tidak valid) fallback ke inisial',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          const UserAvatar(
            imageUrl: 'http://localhost:1/tidak-ada.png',
            username: 'budi',
          ),
        ),
      );

      // Placeholder sejak frame pertama adalah inisial; saat request gagal,
      // errorWidget juga menampilkan inisial yang sama.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 4));

      expect(find.text('B'), findsOneWidget);
    });
  });
}
