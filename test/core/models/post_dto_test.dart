import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_instagram_clone/core/models/post_dto.dart';

void main() {
  group('PostDto', () {
    test('toMap writes cover scalar and imageUrls array', () {
      final Map<String, dynamic> map = PostDto(
        authorId: 'u1',
        authorUsername: 'alice',
        imageUrls: const <String>['http://a', 'http://b'],
        createdAtMillis: 0,
      ).toMap();

      expect(map['imageUrl'], 'http://a');
      expect(map['imageUrls'], const <String>['http://a', 'http://b']);
    });

    test('fromMap reads carousel docs', () {
      final PostDto dto = PostDto.fromMap('p1', <String, dynamic>{
        'authorId': 'u1',
        'authorUsername': 'alice',
        'imageUrl': 'http://a',
        'imageUrls': const <String>['http://a', 'http://b'],
        'createdAt': 0,
      });

      expect(dto.imageUrls, const <String>['http://a', 'http://b']);
      expect(dto.toDomain('p1').imageUrl, 'http://a');
    });

    test('fromMap falls back to legacy imageUrl-only docs', () {
      final PostDto dto = PostDto.fromMap('p1', <String, dynamic>{
        'authorId': 'u1',
        'authorUsername': 'alice',
        'imageUrl': 'http://legacy',
        'createdAt': 0,
      });

      expect(dto.imageUrls, const <String>['http://legacy']);
    });
  });
}
