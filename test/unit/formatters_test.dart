import 'package:flutter_test/flutter_test.dart';

import 'package:kata/core/formatters.dart';

void main() {
  group('formatRelativeTime', () {
    test('null atau kosong mengembalikan string kosong', () {
      expect(formatRelativeTime(null), '');
      expect(formatRelativeTime(''), '');
    });

    test('waktu di masa depan tampil "baru saja"', () {
      final future = DateTime.now().add(const Duration(hours: 2));
      expect(formatRelativeTime(future.toIso8601String()), 'baru saja');
    });

    test('kurang dari satu menit tampil "baru saja"', () {
      final justNow = DateTime.now().subtract(const Duration(seconds: 10));
      expect(formatRelativeTime(justNow.toIso8601String()), 'baru saja');
    });

    test('beberapa menit lalu tampil dalam menit', () {
      final minutes = DateTime.now().subtract(const Duration(minutes: 5));
      expect(formatRelativeTime(minutes.toIso8601String()), '5 menit');
    });

    test('beberapa jam lalu tampil dalam jam', () {
      final hours = DateTime.now().subtract(const Duration(hours: 3));
      expect(formatRelativeTime(hours.toIso8601String()), '3 jam');
    });

    test('beberapa hari lalu tampil dalam hari', () {
      final days = DateTime.now().subtract(const Duration(days: 2));
      expect(formatRelativeTime(days.toIso8601String()), '2 hari');
    });

    test('lebih dari seminggu tampil sebagai tanggal d/m/y', () {
      final weeks = DateTime.now().subtract(const Duration(days: 20));
      expect(
        formatRelativeTime(weeks.toIso8601String()),
        '${weeks.day}/${weeks.month}/${weeks.year}',
      );
    });

    test('string bukan tanggal dikembalikan apa adanya', () {
      expect(formatRelativeTime('bukan-tanggal'), 'bukan-tanggal');
    });
  });
}
