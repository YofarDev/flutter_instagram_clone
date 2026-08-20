import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/chat_message.dart';
import '../../domain/models/conversation.dart';
import '../models/chat_message_dto.dart';
import '../models/conversation_dto.dart';

/// Deterministic 1:1 conversation id. ponytail: fixed pair shape; groups later.
String conversationIdFor(String a, String b) {
  final List<String> ids = <String>[a, b]..sort();
  return '${ids[0]}_${ids[1]}';
}

abstract interface class IChatDataSource {
  Stream<List<Conversation>> watchConversations({required String myUid});
  Stream<List<ChatMessage>> watchMessages({required String conversationId});
  Future<Conversation> getOrCreateConversation({
    required String myUid,
    required String otherUid,
  });
  Future<void> sendMessage({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String text,
  });

  /// Live `typingUid` field on the conversation doc (null = nobody typing).
  Stream<String?> watchTyping({required String conversationId});

  Future<void> setTyping({
    required String conversationId,
    required String? typingUid,
  });
}

class ChatFirebaseDataSource implements IChatDataSource {
  const ChatFirebaseDataSource();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  @override
  Stream<List<Conversation>> watchConversations({required String myUid}) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: myUid)
        .orderBy('updatedAt', descending: true)
        .limit(30)
        .snapshots()
        .map(
          (QuerySnapshot<Object?> snap) => snap.docs
              .map(
                (QueryDocumentSnapshot<Object?> doc) => ConversationDto.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                  myUid,
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<List<ChatMessage>> watchMessages({required String conversationId}) {
    // ponytail: latest 50 then reversed for chronological order; load-older
    // pagination deferred until history length matters
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (QuerySnapshot<Object?> snap) => snap.docs
              .map(
                (QueryDocumentSnapshot<Object?> doc) => ChatMessageDto.fromMap(
                  doc.data() as Map<String, dynamic>,
                ).toDomain(doc.id, conversationId),
              )
              .toList()
              .reversed
              .toList(),
        );
  }

  @override
  Future<Conversation> getOrCreateConversation({
    required String myUid,
    required String otherUid,
  }) async {
    final DocumentReference<Object?> ref = _db
        .collection('conversations')
        .doc(conversationIdFor(myUid, otherUid));
    final DocumentSnapshot<Object?> snap = await ref.get();
    if (snap.exists) {
      return ConversationDto.fromMap(
        snap.id,
        snap.data() as Map<String, dynamic>,
        myUid,
      );
    }
    final List<DocumentSnapshot<Object?>> profiles =
        await Future.wait(<Future<DocumentSnapshot<Object?>>>[
          _db.collection('users').doc(myUid).get(),
          _db.collection('users').doc(otherUid).get(),
        ]);
    Map<String, dynamic> metaFor(DocumentSnapshot<Object?> profile) {
      final Map<String, dynamic> data =
          profile.data() as Map<String, dynamic>? ?? <String, dynamic>{};
      return <String, dynamic>{
        'username': data['username'] as String? ?? '',
        'avatarUrl': data['avatarUrl'] as String?,
      };
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final Map<String, dynamic> data = <String, dynamic>{
      'participants': <String>[myUid, otherUid]..sort(),
      'participantMeta': <String, dynamic>{
        myUid: metaFor(profiles[0]),
        otherUid: metaFor(profiles[1]),
      },
      'updatedAt': now,
    };
    await ref.set(data, SetOptions(merge: true));
    return ConversationDto.fromMap(ref.id, data, myUid);
  }

  @override
  Future<void> sendMessage({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String text,
  }) async {
    final int millis = DateTime.now().millisecondsSinceEpoch;
    final WriteBatch batch = _db.batch();
    batch.set(
      _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(),
      ChatMessageDto(
        senderId: myUid,
        text: text,
        createdAtMillis: millis,
      ).toMap(),
    );
    batch.update(
      _db.collection('conversations').doc(conversationId),
      <String, dynamic>{
        'lastMessage': <String, dynamic>{
          'text': text,
          'senderId': myUid,
          'createdAt': millis,
        },
        'updatedAt': millis,
      },
    );
    await batch.commit();
  }

  @override
  Stream<String?> watchTyping({required String conversationId}) => _db
      .collection('conversations')
      .doc(conversationId)
      .snapshots()
      .map(
        (DocumentSnapshot<Object?> snap) =>
            (snap.data() as Map<String, dynamic>?)?['typingUid'] as String?,
      );

  @override
  Future<void> setTyping({
    required String conversationId,
    required String? typingUid,
  }) => _db.collection('conversations').doc(conversationId).set(
    <String, dynamic>{'typingUid': typingUid},
    SetOptions(merge: true),
  );
}
