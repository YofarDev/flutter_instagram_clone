import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    String? imageUrl,
  });

  /// Uploads the image to Storage, then sends it as an image message.
  /// Cleans the orphan upload up if the Firestore write fails.
  Future<void> sendImageMessage({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String filePath,
  });

  /// Live `typingUid` field on the conversation doc (null = nobody typing).
  Stream<String?> watchTyping({required String conversationId});

  /// Read receipts: stamps readAt on the given messages. The caller is
  /// expected to pass only incoming (not sent-by-me) unread ids.
  Future<void> markMessagesRead({
    required String conversationId,
    required List<String> messageIds,
  });

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
    String? imageUrl,
  }) async {
    final int millis = DateTime.now().millisecondsSinceEpoch;
    final bool isImage = imageUrl != null;
    final WriteBatch batch = _db.batch();
    batch.set(
      _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(),
      ChatMessageDto(
        senderId: myUid,
        text: isImage ? '' : text,
        createdAtMillis: millis,
        type: isImage ? 'image' : 'text',
        imageUrl: imageUrl,
      ).toMap(),
    );
    batch.update(
      _db.collection('conversations').doc(conversationId),
      <String, dynamic>{
        'lastMessage': <String, dynamic>{
          // preview text is empty for images; readers render a localized
          // "Photo" off the type field
          'text': isImage ? '' : text,
          'type': isImage ? 'image' : 'text',
          'senderId': myUid,
          'createdAt': millis,
        },
        'updatedAt': millis,
      },
    );
    await batch.commit();
  }

  @override
  Future<void> sendImageMessage({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String filePath,
  }) async {
    final int millis = DateTime.now().millisecondsSinceEpoch;
    final Reference ref = FirebaseStorage.instance.ref(
      'chats/$myUid/$millis.jpg',
    );
    await ref.putFile(File(filePath));
    final String url = await ref.getDownloadURL();
    try {
      await sendMessage(
        conversationId: conversationId,
        myUid: myUid,
        otherUid: otherUid,
        text: '',
        imageUrl: url,
      );
    } catch (e) {
      // ponytail: best-effort cleanup, orphan possible if delete fails too
      unawaited(ref.delete().catchError((_) => ref));
      rethrow;
    }
  }

  @override
  Future<void> markMessagesRead({
    required String conversationId,
    required List<String> messageIds,
  }) async {
    if (messageIds.isEmpty) return;
    final int now = DateTime.now().millisecondsSinceEpoch;
    final WriteBatch batch = _db.batch();
    final CollectionReference<Object?> messages = _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages');
    for (final String id in messageIds) {
      batch.update(messages.doc(id), <String, dynamic>{'readAt': now});
    }
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
