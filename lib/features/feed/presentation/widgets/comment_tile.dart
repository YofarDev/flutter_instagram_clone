import 'package:flutter/material.dart';

import '../../../../core/utils/time_ago.dart';
import '../../domain/models/comment.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({required this.comment, super.key});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text.rich(
        TextSpan(
          children: <InlineSpan>[
            TextSpan(
              text: comment.authorUsername,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: '  ${comment.text}'),
          ],
        ),
      ),
      trailing: Text(
        timeAgo(comment.createdAt),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
