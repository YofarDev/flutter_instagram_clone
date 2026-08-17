import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/models/app_user.dart';
import '../../../../core/models/post.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/widgets/ig_icon.dart';
import '../../../../core/widgets/ig_icons.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/models/user_profile.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (ProfileState p, ProfileState c) => p.error != c.error,
      listener: (BuildContext context, ProfileState state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.error!)));
          context.read<ProfileCubit>().clearError();
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        buildWhen: (ProfileState p, ProfileState c) =>
            p.status != c.status ||
            p.profile != c.profile ||
            p.posts != c.posts ||
            p.isFollowing != c.isFollowing,
        builder: (BuildContext context, ProfileState state) {
          if (state.status == ProfileStatus.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final UserProfile? profile = state.profile;
          return Scaffold(
            appBar: AppBar(
              title: Text(profile?.username ?? ''),
              actions: <Widget>[
                // Own profile only — placeholder until the P4 more-menu sheet.
                if (state.isMe)
                  IconButton(
                    tooltip: l10n.navLogout,
                    icon: IgIcon(
                      IgIcons.moreDots,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () => context.read<AuthCubit>().signOut(),
                  ),
              ],
            ),
            body: profile == null
                ? const SizedBox.shrink()
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: <Widget>[
                              CircleAvatar(
                                radius: 32,
                                backgroundImage: profile.avatarUrl != null
                                    ? NetworkImage(profile.avatarUrl!)
                                    : null,
                                child: profile.avatarUrl == null
                                    ? Text(
                                        profile.username?.isNotEmpty == true
                                            ? profile.username![0].toUpperCase()
                                            : '?',
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    _CountColumn(
                                      count: profile.postCount,
                                      label: l10n.profilePosts,
                                    ),
                                    InkWell(
                                      onTap: () => context.push(
                                        Routes.userFollowersPath(profile.uid),
                                      ),
                                      child: _CountColumn(
                                        count: profile.followerCount,
                                        label: l10n.profileFollowers,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => context.push(
                                        Routes.userFollowingPath(profile.uid),
                                      ),
                                      child: _CountColumn(
                                        count: profile.followingCount,
                                        label: l10n.profileFollowing,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                profile.username ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (profile.bio?.isNotEmpty == true)
                                Text(profile.bio!),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: state.isMe
                                    ? OutlinedButton(
                                        onPressed: () => context.push(
                                          Routes.profileEdit,
                                          extra: AppUser(
                                            uid: profile.uid,
                                            email: profile.email,
                                            username: profile.username,
                                            bio: profile.bio,
                                            avatarUrl: profile.avatarUrl,
                                          ),
                                        ),
                                        child: Text(l10n.profileEdit),
                                      )
                                    : (state.isFollowing
                                          ? OutlinedButton(
                                              onPressed: () => context
                                                  .read<ProfileCubit>()
                                                  .toggleFollow(),
                                              child: Text(l10n.profileUnfollow),
                                            )
                                          : FilledButton(
                                              onPressed: () => context
                                                  .read<ProfileCubit>()
                                                  .toggleFollow(),
                                              child: Text(l10n.profileFollow),
                                            )),
                              ),
                            ],
                          ),
                        ),
                        if (state.posts.isNotEmpty)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1,
                                  mainAxisSpacing: 2,
                                  crossAxisSpacing: 2,
                                ),
                            itemCount: state.posts.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Post post = state.posts[index];
                              return InkWell(
                                onTap: () => context.push(
                                  Routes.postDetailPath(post.id),
                                  extra: post,
                                ),
                                child: Image.network(
                                  post.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      Container(color: Colors.grey),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _CountColumn extends StatelessWidget {
  const _CountColumn({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label),
      ],
    );
  }
}
