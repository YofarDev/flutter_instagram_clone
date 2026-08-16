import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/models/app_user.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/follow_list_cubit.dart';
import '../bloc/follow_list_state.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({required this.followersMode, super.key});

  final bool followersMode;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title:
            Text(followersMode ? l10n.followersTitle : l10n.followingTitle),
      ),
      body: BlocListener<FollowListCubit, FollowListState>(
        listenWhen: (FollowListState p, FollowListState c) =>
            p.error != c.error,
        listener: (BuildContext context, FollowListState state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        child: BlocBuilder<FollowListCubit, FollowListState>(
          buildWhen: (FollowListState p, FollowListState c) =>
              p.loading != c.loading || p.users != c.users,
          builder: (BuildContext context, FollowListState state) {
            if (state.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.users.isEmpty) {
              return const SizedBox.shrink();
            }
            return ListView.builder(
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
                        ? Text(username.isNotEmpty
                            ? username[0].toUpperCase()
                            : '?')
                        : null,
                  ),
                  title: Text(username),
                  onTap: () => context.push(Routes.userPath(user.uid)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
