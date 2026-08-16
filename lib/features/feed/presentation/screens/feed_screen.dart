import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_constants.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../../core/models/post.dart';
import '../bloc/feed_cubit.dart';
import '../bloc/feed_state.dart';
import '../widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? username = context.watch<AuthCubit>().state.user?.username;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.create),
        child: const Icon(Icons.add),
      ),
      body: BlocListener<FeedCubit, FeedState>(
        listenWhen: (FeedState p, FeedState c) => p.error != c.error,
        listener: (BuildContext context, FeedState state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.error ?? l10n.errorGeneric)),
              );
            context.read<FeedCubit>().clearError();
          }
        },
        child: BlocBuilder<FeedCubit, FeedState>(
          buildWhen: (FeedState p, FeedState c) =>
              p.status != c.status || p.posts != c.posts || p.likedIds != c.likedIds,
          builder: (BuildContext context, FeedState state) {
            if (state.status == FeedStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.photo_library_outlined, size: 64),
                    const SizedBox(height: 8),
                    Text(l10n.feedEmpty),
                    if (username != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text('@$username'),
                    ],
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: state.posts.length + (state.hasMore ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (index < state.posts.length) {
                  final Post post = state.posts[index];
                  return PostCard(
                    post: post,
                    isLiked: state.likedIds.contains(post.id),
                    onLikeTap: () =>
                        context.read<FeedCubit>().toggleLike(post),
                    onCommentTap: () => context.push('/post/${post.id}',
                        extra: post),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: TextButton(
                      onPressed: () =>
                          context.read<FeedCubit>().loadMore(),
                      child: Text(l10n.feedLoadMore),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
