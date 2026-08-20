import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/models/post.dart';
import '../../../../core/theme/ig_colors.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/heart_burst.dart';
import '../../../../core/widgets/ig_icon.dart';
import '../../../../core/widgets/ig_icons.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    required this.post,
    required this.isLiked,
    required this.onLikeTap,
    this.isSaved = false,
    this.onSaveTap,
    this.onCommentTap,
    this.onUsernameTap,
    super.key,
  });

  final Post post;
  final bool isLiked;
  final VoidCallback onLikeTap;
  final bool isSaved;
  final VoidCallback? onSaveTap;
  final VoidCallback? onCommentTap;
  final VoidCallback? onUsernameTap;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // HeartBurst's own state detaches from this controller on dispose
  final HeartBurstController _burstController = HeartBurstController();

  void _onDoubleTap() {
    _burstController.fire();
    AppHaptics.like();
    // IG never un-likes on double-tap, only likes
    if (!widget.isLiked) widget.onLikeTap();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    final Post post = widget.post;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
          onTap: widget.onUsernameTap,
          leading: CircleAvatar(
            backgroundImage: post.authorAvatarUrl != null
                ? NetworkImage(post.authorAvatarUrl!)
                : null,
            child: post.authorAvatarUrl == null
                ? Text(
                    post.authorUsername.isNotEmpty
                        ? post.authorUsername[0].toUpperCase()
                        : '?',
                  )
                : null,
          ),
          title: Text(post.authorUsername),
          trailing: Text(
            timeAgo(post.createdAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        GestureDetector(
          onDoubleTap: _onDoubleTap,
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Image.network(
                  post.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: Colors.grey),
                  loadingBuilder:
                      (_, Widget child, ImageChunkEvent? progress) =>
                          progress == null
                          ? child
                          : Container(
                              color: Colors.grey,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                ),
                HeartBurst(controller: _burstController),
              ],
            ),
          ),
        ),
        Row(
          children: <Widget>[
            IconButton(
              tooltip: l10n.postLikes(post.likeCount),
              icon: IgIcon(
                widget.isLiked ? IgIcons.heartFilled : IgIcons.heart,
                color: widget.isLiked ? IgColors.likeRed : onSurface,
              ),
              onPressed: () {
                if (!widget.isLiked) AppHaptics.like();
                widget.onLikeTap();
              },
            ),
            IconButton(
              tooltip: l10n.postComments(post.commentCount),
              icon: IgIcon(IgIcons.comment, color: onSurface),
              onPressed: widget.onCommentTap,
            ),
            const Spacer(),
            if (widget.onSaveTap != null)
              IconButton(
                tooltip: l10n.postSaveAction,
                icon: IgIcon(
                  widget.isSaved ? IgIcons.bookmarkFilled : IgIcons.bookmark,
                  color: onSurface,
                ),
                onPressed: widget.onSaveTap,
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.postLikes(post.likeCount),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              if (post.caption.isNotEmpty)
                Text('${post.authorUsername}  ${post.caption}'),
              const SizedBox(height: 4),
              Text(
                l10n.postComments(post.commentCount),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const Divider(height: 24),
      ],
    );
  }
}
