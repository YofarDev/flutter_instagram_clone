import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/widgets/comment_tile.dart';
import '../../../../core/widgets/skeleton/skeletons.dart';
import '../bloc/reel_comments_cubit.dart';
import '../bloc/reel_comments_state.dart';

/// Bottom sheet listing a reel's comments with an input bar.
/// Expects a ReelCommentsCubit from the enclosing BlocProvider.
class ReelCommentsSheet extends StatefulWidget {
  const ReelCommentsSheet({super.key});

  @override
  State<ReelCommentsSheet> createState() => _ReelCommentsSheetState();
}

class _ReelCommentsSheetState extends State<ReelCommentsSheet> {
  final TextEditingController _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _send() {
    final String text = _comment.text.trim();
    if (text.isEmpty) return;
    context.read<ReelCommentsCubit>().addComment(text);
    // ponytail: optimistic clear; failed sends surface via snackbar
    _comment.clear();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocListener<ReelCommentsCubit, ReelCommentsState>(
      listenWhen: (ReelCommentsState p, ReelCommentsState c) =>
          p.error != c.error,
      listener: (BuildContext context, ReelCommentsState state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.error ?? l10n.errorGeneric)),
            );
          context.read<ReelCommentsCubit>().clearError();
        }
      },
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: BlocBuilder<ReelCommentsCubit, ReelCommentsState>(
                buildWhen: (ReelCommentsState p, ReelCommentsState c) =>
                    p.status != c.status || p.comments != c.comments,
                builder: (BuildContext context, ReelCommentsState state) {
                  if (state.status == ReelCommentsStatus.loading) {
                    return ListView(
                      children: List<SkeletonListRow>.generate(
                        5,
                        (_) => const SkeletonListRow(),
                      ),
                    );
                  }
                  if (state.comments.isEmpty) {
                    return Center(child: Text(l10n.commentsEmpty));
                  }
                  return ListView.builder(
                    itemCount: state.comments.length,
                    itemBuilder: (BuildContext context, int index) =>
                        CommentTile(comment: state.comments[index]),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
              child: BlocBuilder<ReelCommentsCubit, ReelCommentsState>(
                buildWhen: (ReelCommentsState p, ReelCommentsState c) =>
                    p.sending != c.sending,
                builder: (BuildContext context, ReelCommentsState state) {
                  return Row(
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
