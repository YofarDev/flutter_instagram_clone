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

  Failure _mapError(Object e) {
    return Failure.serverError(message: e.toString());
  }
}
