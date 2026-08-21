import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_instagram_clone/core/utils/time_ago.dart';

void main() {
  group('timeAgo', () {
    final DateTime now = DateTime.now();

    test('english short units', () {
      expect(timeAgo(now), 'now');
      expect(timeAgo(now.subtract(const Duration(minutes: 5))), '5m');
      expect(timeAgo(now.subtract(const Duration(hours: 3))), '3h');
      expect(timeAgo(now.subtract(const Duration(days: 2))), '2d');
    });

    test('french units are spaced and use min/h/j', () {
      expect(timeAgo(now, locale: 'fr'), "à l'instant");
      expect(
        timeAgo(now.subtract(const Duration(minutes: 5)), locale: 'fr'),
        '5 min',
      );
      expect(
        timeAgo(now.subtract(const Duration(hours: 3)), locale: 'fr'),
        '3 h',
      );
      expect(
        timeAgo(now.subtract(const Duration(days: 2)), locale: 'fr'),
        '2 j',
      );
    });

    test('french canadian resolves to the fr forms', () {
      expect(
        timeAgo(now.subtract(const Duration(minutes: 5)), locale: 'fr_CA'),
        '5 min',
      );
    });
  });
}
