import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/router/route_constants.dart';
import '../../domain/models/reel.dart';

class ReelItem extends StatefulWidget {
  const ReelItem({
    required this.reel,
    required this.isCurrent,
    required this.isLiked,
    required this.onLikeTap,
    this.forcePause = false,
    super.key,
  });

  final Reel reel;
  final bool isCurrent;
  final bool forcePause;
  final bool isLiked;
  final VoidCallback onLikeTap;

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  late final VideoPlayerController _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.videoUrl),
    );
    _controller.initialize().then((_) {
      if (!mounted) return;
      _controller
        ..setLooping(true)
        ..setVolume(0);
      _syncPlayback();
      setState(() {});
    }).catchError((Object _) {
      if (mounted) setState(() => _failed = true);
    });
  }

  void _syncPlayback() {
    if (!_controller.value.isInitialized) return;
    if (widget.isCurrent && !widget.forcePause) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void didUpdateWidget(covariant ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isCurrent != widget.isCurrent ||
        oldWidget.forcePause != widget.forcePause) {
      _syncPlayback();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _controller.setVolume(_controller.value.volume == 0 ? 1 : 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: Icon(Icons.error_outline, color: Colors.white),
        ),
      );
    }
    if (!_controller.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        GestureDetector(
          onTap: _toggleMute,
          onDoubleTap: widget.isLiked ? null : widget.onLikeTap,
          child: SizedBox.expand(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 72,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    onTap: () =>
                        context.push(Routes.userPath(widget.reel.uid)),
                    child: Text(
                      widget.reel.authorUsername,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (widget.reel.caption.isNotEmpty)
                    Text(
                      widget.reel.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    widget.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: widget.isLiked ? Colors.red : Colors.white,
                  ),
                  onPressed: widget.onLikeTap,
                ),
                Text(
                  '${widget.reel.likeCount}',
                  style: const TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: Icon(
                    _controller.value.volume == 0
                        ? Icons.volume_off
                        : Icons.volume_up,
                    color: Colors.white,
                  ),
                  onPressed: _toggleMute,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
