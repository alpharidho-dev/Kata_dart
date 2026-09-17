import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kata/widgets/hashtag_text.dart';

void main() {
  group('HashtagText', () {
    testWidgets('menampilkan teks biasa tanpa hashtag', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HashtagText(text: 'Halo dunia')),
        ),
      );

      expect(find.text('Halo dunia'), findsOneWidget);
    });

    testWidgets('menampilkan hashtag sebagai bagian teks', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: HashtagText(text: 'Cek #flutter dan #dart')),
        ),
      );

      expect(find.text('Cek #flutter dan #dart'), findsOneWidget);
    });

    testWidgets('onTagTap terpanggil dengan nama tag tanpa "#"',
        (tester) async {
      String? tappedTag;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HashtagText(
              text: 'Belajar #flutter yuk',
              onTagTap: (tag) => tappedTag = tag,
            ),
          ),
        ),
      );

      // Hashtag dirender sebagai span di dalam RichText, jadi posisi ketuknya
      // dihitung dari box seleksi teks "#flutter" (index 8-16).
      final paragraph = tester.renderObject<RenderParagraph>(
        find.byType(RichText),
      );
      final box = paragraph
          .getBoxesForSelection(
            const TextSelection(baseOffset: 8, extentOffset: 16),
          )
          .first;
      final tapLocation =
          tester.getTopLeft(find.byType(RichText)) + box.toRect().center;

      await tester.tapAt(tapLocation);
      await tester.pump();

      expect(tappedTag, 'flutter');
    });

    testWidgets('maxLines memangkas teks panjang dengan ellipsis',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HashtagText(
              text:
                  'Ini teks sangat panjang sekali yang seharusnya terpotong di baris tertentu karena melebihi batas',
              maxLines: 1,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(
        find.descendant(
          of: find.byType(HashtagText),
          matching: find.byType(Text),
        ),
      );
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });
}
