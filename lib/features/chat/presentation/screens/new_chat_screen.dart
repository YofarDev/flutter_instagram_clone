import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/models/app_user.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/new_chat_cubit.dart';
import '../bloc/new_chat_state.dart';

class NewChatScreen extends StatefulWidget {
  const NewChatScreen({super.key});

  @override
  State<NewChatScreen> createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.newDmTitle)),
      body: BlocListener<NewChatCubit, NewChatState>(
        listenWhen: (NewChatState p, NewChatState c) =>
            p.opened != c.opened || p.error != c.error,
        listener: (BuildContext context, NewChatState state) {
          if (state.opened != null) {
            context.push(Routes.chat, extra: state.opened);
            context.read<NewChatCubit>().clearOpened();
          } else if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
            context.read<NewChatCubit>().clearError();
          }
        },
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: l10n.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                ),
                onChanged: (String query) =>
                    context.read<NewChatCubit>().queryChanged(query),
              ),
            ),
            BlocBuilder<NewChatCubit, NewChatState>(
              buildWhen: (NewChatState p, NewChatState c) =>
                  p.query != c.query ||
                  p.users != c.users ||
                  p.suggestions != c.suggestions ||
                  p.suggestionsLoading != c.suggestionsLoading ||
                  p.searching != c.searching ||
                  p.opening != c.opening,
              builder: (BuildContext context, NewChatState state) {
                if (state.searching) {
                  return const LinearProgressIndicator(minHeight: 2);
                }
                if (state.query.trim().isEmpty) {
                  if (state.suggestions.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(
                            l10n.newDmSuggestions,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.suggestions.length,
                            itemBuilder: (BuildContext context, int index) {
                              final AppUser user = state.suggestions[index];
                              final String username = user.username ?? '';
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: user.avatarUrl != null
                                      ? NetworkImage(user.avatarUrl!)
                                      : null,
                                  child: user.avatarUrl == null
                                      ? Text(
                                          username.isNotEmpty
                                              ? username[0].toUpperCase()
                                              : '?',
                                        )
                                      : null,
                                ),
                                title: Text(username),
                                trailing: state.opening
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : null,
                                onTap: () => context
                                    .read<NewChatCubit>()
                                    .startConversation(user),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (state.users.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text(l10n.searchNoResults)),
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: state.users.length,
                    itemBuilder: (BuildContext context, int index) {
                      final AppUser user = state.users[index];
                      final String username = user.username ?? '';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user.avatarUrl != null
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                          child: user.avatarUrl == null
                              ? Text(
                                  username.isNotEmpty
                                      ? username[0].toUpperCase()
                                      : '?',
                                )
                              : null,
                        ),
                        title: Text(username),
                        trailing: state.opening
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : null,
                        onTap: () => context
                            .read<NewChatCubit>()
                            .startConversation(user),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
