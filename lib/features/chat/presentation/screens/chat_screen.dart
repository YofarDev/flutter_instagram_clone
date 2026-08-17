import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/models/app_user.dart';
import '../../../../core/router/route_constants.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/models/chat_message.dart';
import '../bloc/chat_cubit.dart';
import '../bloc/chat_state.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatCubit>().send(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String myUid = context.watch<AuthCubit>().state.user!.uid;
    final AppUser otherUser =
        context.read<ChatCubit>().state.conversation.otherUser;
    final String username = otherUser.username ?? '';
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () => context.push(Routes.userPath(otherUser.uid)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircleAvatar(
                radius: 16,
                backgroundImage: otherUser.avatarUrl != null
                    ? NetworkImage(otherUser.avatarUrl!)
                    : null,
                child: otherUser.avatarUrl == null
                    ? Text(
                        username.isNotEmpty ? username[0].toUpperCase() : '?',
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Flexible(child: Text(username, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
      body: BlocListener<ChatCubit, ChatState>(
        listenWhen: (ChatState p, ChatState c) => p.error != c.error,
        listener: (BuildContext context, ChatState state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
            context.read<ChatCubit>().clearError();
          }
        },
        child: BlocBuilder<ChatCubit, ChatState>(
          buildWhen: (ChatState p, ChatState c) =>
              p.messages != c.messages || p.sending != c.sending,
          builder: (BuildContext context, ChatState state) {
            return Column(
              children: <Widget>[
                Expanded(
                  child: state.messages.isEmpty
                      ? Center(
                          child: Text(
                            l10n.chatEmpty,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(8),
                          itemCount: state.messages.length,
                          itemBuilder: (BuildContext context, int index) {
                            final ChatMessage message = state.messages[
                                state.messages.length - 1 - index];
                            final bool mine = message.senderId == myUid;
                            return Align(
                              alignment: mine
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                ),
                                decoration: BoxDecoration(
                                  color: mine
                                      ? Theme.of(context)
                                          .colorScheme
                                          .primaryContainer
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(message.text),
                              ),
                            );
                          },
                        ),
                ),
                if (state.sending)
                  const LinearProgressIndicator(minHeight: 2),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: l10n.dmHint,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              filled: true,
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          tooltip: l10n.dmSend,
                          onPressed: _send,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
