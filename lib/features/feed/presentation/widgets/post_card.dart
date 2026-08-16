import 'package:flutter/material.dart';

import '../../../../core/models/post.dart';
import '../../../../core/utils/time_ago.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    required this.post,
    required this.isLiked,
    required this.onLikeTap,
    this.onCommentTap,
    this.onUsernameTap,
    super.key,
  });

  final Post post;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onUsernameTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          onTap: onUsernameTap,
          leading: CircleAvatar(
            backgroundImage: post.authorAvatarUrl != null
                ? NetworkImage(post.authorAvatarUrl!)
                : null,
            child: post.authorAvatarUrl == null
                ? Text(post.authorUsername.isNotEmpty
                    ? post.authorUsername[0].toUpperCase()
                    : '?')
                : null,
          ),
          title: Text(post.authorUsername),
          trailing:
              Text(timeAgo(post.createdAt), style: Theme.of(context).textTheme.bodySmall),
        ),
        AspectRatio(
          aspectRatio: 1,
          child: Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: Colors.grey),
            loadingBuilder: (_, Widget child, ImageChunkEvent? progress) =>
                progress == null
                    ? child
                    : Container(
                        color: Colors.grey,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
          ),
        ),
        Row(
          children: <Widget>[
            IconButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.red : null,
              ),
              onPressed: onLikeTap,
            ),
            IconButton(
              icon: const Icon(Icons.comment_outlined),
              onPressed: onCommentTap,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // TODO(l10n): plural units
              Text('${post.likeCount} likes',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              if (post.caption.isNotEmpty)
                Text('${post.authorUsername}  ${post.caption}'),
              const SizedBox(height: 4),
              Text('${post.commentCount} comments',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const Divider(height: 24),
      ],
    );
  }
}
