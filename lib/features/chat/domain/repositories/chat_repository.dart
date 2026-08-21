import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../models/chat_message.dart';
import '../models/conversation.dart';

abstract interface class IChatRepository {
  Stream<List<Conversation>> watchConversations({required String myUid});
  Stream<List<ChatMessage>> watchMessages({required String conversationId});
  Future<Either<Failure, Conversation>> getOrCreateConversation({
    required String myUid,
    required String otherUid,
  });
  Future<Either<Failure, void>> sendMessage({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String text,
  });

  /// Picks nothing — uploads [filePath] and sends it as an image message.
  Future<Either<Failure, void>> sendImageMessage({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String filePath,
  });

  /// Shares a feed post (cover + id) into the conversation.
  Future<Either<Failure, void>> sendPostMessage({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String postId,
    required String imageUrl,
  });

  /// Story reply: sends [text] quoting the story.
  Future<Either<Failure, void>> sendStoryReply({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String text,
    required String storyId,
    required String imageUrl,
  });

  /// Live uid of whoever is typing in this conversation (null = nobody).
  Stream<String?> watchTyping({required String conversationId});

  /// Stamps readAt on incoming messages (read receipts) and resets my
  /// unread badge counter.
  Future<Either<Failure, void>> markMessagesRead({
    required String conversationId,
    required String myUid,
    required List<String> messageIds,
  });

  /// Flags/clears [myUid] as typing.
  Future<Either<Failure, void>> setTyping({
    required String conversationId,
    required String myUid,
    required bool typing,
  });
}
