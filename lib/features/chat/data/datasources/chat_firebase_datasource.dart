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

  /// Shares a feed post into the conversation (type 'post').
  Future<void> sendPostMessage({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String postId,
    required String imageUrl,
  });

  /// Story reply: sends [text] quoting the story (type 'story'; the story
  /// id rides the postId field).
  Future<void> sendStoryReply({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String text,
    required String storyId,
    required String imageUrl,
  });

  /// Live `typingUid` field on the conversation doc (null = nobody typing).
  Stream<String?> watchTyping({required String conversationId});

  /// Read receipts: stamps readAt on the given messages. The caller is
  /// expected to pass only incoming (not sent-by-me) unread ids.
  Future<void> markMessagesRead({
    required String conversationId,
    required String myUid,
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
  }) => _writeMessage(
    conversationId: conversationId,
    myUid: myUid,
    otherUid: otherUid,
    text: imageUrl == null ? text : '',
    type: imageUrl == null ? 'text' : 'image',
    imageUrl: imageUrl,
  );

  @override
  Future<void> sendPostMessage({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String postId,
    required String imageUrl,
  }) => _writeMessage(
    conversationId: conversationId,
    myUid: myUid,
    otherUid: otherUid,
    text: '',
    type: 'post',
    imageUrl: imageUrl,
    postId: postId,
  );

  @override
  Future<void> sendStoryReply({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String text,
    required String storyId,
    required String imageUrl,
  }) => _writeMessage(
    conversationId: conversationId,
    myUid: myUid,
    otherUid: otherUid,
    text: text,
    type: 'story',
    imageUrl: imageUrl,
    postId: storyId,
  );

  /// One batch: the message doc, the conversation's lastMessage preview,
  /// and the receiver's unread badge bump.
  Future<void> _writeMessage({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String text,
    required String type,
    String? imageUrl,
    String? postId,
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
        type: type,
        imageUrl: imageUrl,
        postId: postId,
      ).toMap(),
    );
    batch.update(
      _db.collection('conversations').doc(conversationId),
      <String, dynamic>{
        'lastMessage': <String, dynamic>{
          // preview text is empty for media; readers render a localized
          // "Photo"/"Post" off the type field
          'text': text,
          'type': type,
          'senderId': myUid,
          'createdAt': millis,
        },
        'updatedAt': millis,
        // receiver's denormalized unread counter for list badges
        'unread.$otherUid': FieldValue.increment(1),
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
    required String myUid,
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
    // my unread counter resets alongside the receipts
    batch.update(
      _db.collection('conversations').doc(conversationId),
      <String, dynamic>{'unread.$myUid': 0},
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
