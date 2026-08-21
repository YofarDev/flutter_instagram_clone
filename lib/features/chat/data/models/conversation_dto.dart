import '../../../../core/models/app_user.dart';
import '../../domain/models/conversation.dart';

class ConversationDto {
  const ConversationDto._();

  static Conversation fromMap(
    String id,
    Map<String, dynamic> map,
    String myUid,
  ) {
    final List<String> participants = List<String>.from(
      map['participants'] as List<dynamic>? ?? <dynamic>[],
    );
    // ponytail: self-chat falls back to myUid; real 1:1 always has an other
    final String otherUid = participants.firstWhere(
      (String uid) => uid != myUid,
      orElse: () => myUid,
    );
    final Map<String, dynamic> meta =
        map['participantMeta'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic> otherMeta =
        meta[otherUid] as Map<String, dynamic>? ?? <String, dynamic>{};
    final Map<String, dynamic>? lastMessage =
        map['lastMessage'] as Map<String, dynamic>?;
    final Map<String, dynamic> unread =
        map['unread'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return Conversation(
      id: id,
      otherUser: AppUser(
        uid: otherUid,
        email: '',
        username: otherMeta['username'] as String? ?? '',
        avatarUrl: otherMeta['avatarUrl'] as String?,
      ),
      lastMessageText: lastMessage?['text'] as String? ?? '',
      lastMessageSenderId: lastMessage?['senderId'] as String?,
      lastMessageType: lastMessage?['type'] as String? ?? 'text',
      lastMessageAt: lastMessage == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              lastMessage['createdAt'] as int,
            ),
      unreadCount: (unread[myUid] as num?)?.toInt() ?? 0,
    );
  }
}
