import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_instagram_clone/features/notifications/data/models/notification_dto.dart';
import 'package:flutter_instagram_clone/features/notifications/domain/models/notification_item.dart';

Map<String, dynamic> _map(String type) => <String, dynamic>{
      'ownerUid': 'owner',
      'type': type,
      'actorId': 'actor',
      'actorUsername': 'yo',
      'createdAt': 1000,
      'read': true,
    };

void main() {
  test('roundtrips item through toMap/fromMap/toDomain', () {
    final NotificationItem item = NotificationItem(
      id: 'n1',
      type: NotificationType.comment,
      ownerUid: 'owner',
      actorId: 'actor',
      actorUsername: 'yo',
      actorAvatarUrl: 'http://img/a',
      postId: 'p1',
      postImageUrl: 'http://img/p',
      commentText: 'nice',
      createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
      read: true,
    );
    final NotificationDto dto = NotificationDto(
      ownerUid: item.ownerUid,
      type: item.type,
      actorId: item.actorId,
      actorUsername: item.actorUsername,
      actorAvatarUrl: item.actorAvatarUrl,
      postId: item.postId,
      postImageUrl: item.postImageUrl,
      commentText: item.commentText,
      createdAtMillis: 1000,
      read: item.read,
    );

    final NotificationItem result =
        NotificationDto.fromMap('n1', dto.toMap()).toDomain('n1');

    expect(result, item);
  });

  test('maps type strings to enum and back by name', () {
    for (final NotificationType t in NotificationType.values) {
      final NotificationDto dto = NotificationDto.fromMap('n1', _map(t.name));
      expect(dto.type, t);
      expect(dto.toMap()['type'], t.name);
    }
  });
}
