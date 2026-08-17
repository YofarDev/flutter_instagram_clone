import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/models/conversation.dart';
import '../bloc/conversations_cubit.dart';
import '../bloc/conversations_state.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String myUid = context.watch<AuthCubit>().state.user!.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dmsTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.person_add_alt),
            onPressed: () => context.push(Routes.newChat),
          ),
        ],
      ),
      body: BlocListener<ConversationsCubit, ConversationsState>(
        listenWhen: (ConversationsState p, ConversationsState c) =>
            p.error != c.error,
        listener: (BuildContext context, ConversationsState state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
            context.read<ConversationsCubit>().clearError();
          }
        },
        child: BlocBuilder<ConversationsCubit, ConversationsState>(
          buildWhen: (ConversationsState p, ConversationsState c) =>
              p.status != c.status || p.conversations != c.conversations,
          builder: (BuildContext context, ConversationsState state) {
            if (state.status == ConversationsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.conversations.isEmpty) {
              return Center(child: Text(l10n.dmEmpty));
            }
            return ListView.separated(
              itemCount: state.conversations.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (BuildContext context, int index) {
                final Conversation conversation = state.conversations[index];
                final String username = conversation.otherUser.username ?? '';
                final String prefix =
                    conversation.lastMessageSenderId == myUid
                        ? l10n.dmYouPrefix
                        : '';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: conversation.otherUser.avatarUrl != null
                        ? NetworkImage(conversation.otherUser.avatarUrl!)
                        : null,
                    child: conversation.otherUser.avatarUrl == null
                        ? Text(username.isNotEmpty
                            ? username[0].toUpperCase()
                            : '?')
                        : null,
                  ),
                  title: Text(
                    username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '$prefix${conversation.lastMessageText}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: conversation.lastMessageAt == null
                      ? null
                      : Text(timeAgo(conversation.lastMessageAt!)),
                  onTap: () =>
                      context.push(Routes.chat, extra: conversation),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
