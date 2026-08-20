import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/app_user.dart';
import '../../domain/models/conversation.dart';

part 'new_chat_state.freezed.dart';

@freezed
sealed class NewChatState with _$NewChatState {
  const factory NewChatState({
    @Default('') String query,
    @Default(<AppUser>[]) List<AppUser> users,
    @Default(<AppUser>[]) List<AppUser> suggestions,
    @Default(true) bool suggestionsLoading,
    @Default(false) bool searching,
    @Default(false) bool opening,
    String? error,
    Conversation? opened,
  }) = _NewChatState;
}
