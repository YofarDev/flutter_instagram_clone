import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/models/post.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/post_detail_cubit.dart';
import '../bloc/post_detail_state.dart';
import '../widgets/comment_tile.dart';
import '../widgets/post_card.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _send() {
    final String text = _comment.text.trim();
    if (text.isEmpty) return;
    context.read<PostDetailCubit>().addComment(text);
    // ponytail: optimistic clear; failed sends surface via error snackbar and user retypes
    _comment.clear();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.postDetailTitle)),
      body: BlocListener<PostDetailCubit, PostDetailState>(
        listenWhen: (PostDetailState p, PostDetailState c) =>
            p.error != c.error,
        listener: (BuildContext context, PostDetailState state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.error ?? l10n.errorGeneric)),
              );
            context.read<PostDetailCubit>().clearError();
          }
        },
        child: BlocBuilder<PostDetailCubit, PostDetailState>(
          builder: (BuildContext context, PostDetailState state) {
            if (state.status == PostDetailStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            final Post post = state.post!;
            return Column(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: PostCard(
                      post: post,
                      isLiked: state.isLiked,
                      onLikeTap: () =>
                          context.read<PostDetailCubit>().toggleLike(),
                      onUsernameTap: () =>
                          context.push(Routes.userPath(post.authorId)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: state.comments.length,
                    itemBuilder: (BuildContext context, int index) =>
                        CommentTile(comment: state.comments[index]),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _comment,
                            decoration: InputDecoration(
                              hintText: l10n.postAddComment,
                            ),
                            onSubmitted: (_) => _send(),
                            textInputAction: TextInputAction.send,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: state.sending ? null : _send,
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
