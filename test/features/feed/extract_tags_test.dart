import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_instagram_clone/features/feed/data/datasources/feed_firebase_datasource.dart';

void main() {
  group('extractTags', () {
    test('dedupes and lowercases', () {
      expect(extractTags('#foo #Bar #foo'), <String>['foo', 'bar']);
    });

    test('returns empty when no tags', () {
      expect(extractTags('no tags here'), <String>[]);
    });

    test('allows underscores and digits', () {
      expect(
        extractTags('#under_score1 ok'),
        <String>['under_score1'],
      );
    });

    test('stops at punctuation boundary', () {
      expect(extractTags('#foo.'), <String>['foo']);
    });

    test('folds Latin-1 accents', () {
      expect(extractTags('#café #ÉTÉ'), <String>['cafe', 'ete']);
    });
  });
}
