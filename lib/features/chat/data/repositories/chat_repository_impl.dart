import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/conversation.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_firebase_datasource.dart';

class ChatRepositoryImpl implements IChatRepository {
  const ChatRepositoryImpl(this._ds);

  final IChatDataSource _ds;

  @override
  Stream<List<Conversation>> watchConversations({required String myUid}) =>
      _ds.watchConversations(myUid: myUid);

  @override
  Stream<List<ChatMessage>> watchMessages({required String conversationId}) =>
      _ds.watchMessages(conversationId: conversationId);

  @override
  Future<Either<Failure, Conversation>> getOrCreateConversation({
    required String myUid,
    required String otherUid,
  }) async {
    try {
      return Right<Failure, Conversation>(
        await _ds.getOrCreateConversation(myUid: myUid, otherUid: otherUid),
      );
    } catch (e) {
      return Left<Failure, Conversation>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String text,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.sendMessage(
          conversationId: conversationId,
          myUid: myUid,
          otherUid: otherUid,
          text: text,
        ),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> sendImageMessage({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String filePath,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.sendImageMessage(
          conversationId: conversationId,
          myUid: myUid,
          otherUid: otherUid,
          filePath: filePath,
        ),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> sendPostMessage({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String postId,
    required String imageUrl,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.sendPostMessage(
          conversationId: conversationId,
          myUid: myUid,
          otherUid: otherUid,
          postId: postId,
          imageUrl: imageUrl,
        ),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> sendStoryReply({
    required String conversationId,
    required String myUid,
    required String otherUid,
    required String text,
    required String storyId,
    required String imageUrl,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.sendStoryReply(
          conversationId: conversationId,
          myUid: myUid,
          otherUid: otherUid,
          text: text,
          storyId: storyId,
          imageUrl: imageUrl,
        ),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  @override
  Stream<String?> watchTyping({required String conversationId}) =>
      _ds.watchTyping(conversationId: conversationId);

  @override
  Future<Either<Failure, void>> markMessagesRead({
    required String conversationId,
    required String myUid,
    required List<String> messageIds,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.markMessagesRead(
          conversationId: conversationId,
          myUid: myUid,
          messageIds: messageIds,
        ),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> setTyping({
    required String conversationId,
    required String myUid,
    required bool typing,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.setTyping(
          conversationId: conversationId,
          typingUid: typing ? myUid : null,
        ),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    return Failure.serverError(message: e.toString());
  }
}
