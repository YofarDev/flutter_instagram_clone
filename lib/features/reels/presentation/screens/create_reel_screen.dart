import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/haptics.dart';
import '../bloc/create_reel_cubit.dart';
import '../bloc/create_reel_state.dart';

class CreateReelScreen extends StatefulWidget {
  const CreateReelScreen({super.key});

  @override
  State<CreateReelScreen> createState() => _CreateReelScreenState();
}

class _CreateReelScreenState extends State<CreateReelScreen> {
  final TextEditingController _caption = TextEditingController();

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.createReelTitle)),
      body: BlocListener<CreateReelCubit, CreateReelState>(
        listenWhen: (CreateReelState p, CreateReelState c) =>
            p.success != c.success || p.error != c.error,
        listener: (BuildContext context, CreateReelState state) {
          if (state.success) {
            AppHaptics.success();
            context.pop();
          } else if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.error ?? l10n.errorGeneric)),
              );
          }
        },
        child: BlocBuilder<CreateReelCubit, CreateReelState>(
          builder: (BuildContext context, CreateReelState state) {
            if (state.pickedPath == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<CreateReelCubit>()
                          .pickVideo(ImageSource.gallery),
                      icon: const Icon(Icons.video_library_outlined),
                      label: Text(l10n.reelPickVideo),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<CreateReelCubit>()
                          .pickVideo(ImageSource.camera),
                      icon: const Icon(Icons.videocam_outlined),
                      label: Text(l10n.reelRecordVideo),
                    ),
                  ],
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                _VideoPreview(
                  key: ValueKey<String?>(state.pickedPath),
                  filePath: state.pickedPath!,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _caption,
                  decoration: InputDecoration(hintText: l10n.reelCaptionHint),
                  maxLines: 2,
                  onChanged: (String value) =>
                      context.read<CreateReelCubit>().captionChanged(value),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: state.submitting
                      ? null
                      : () => context.read<CreateReelCubit>().submit(),
                  child: state.submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.reelShare),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  const _VideoPreview({required this.filePath, super.key});

  final String filePath;

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late final VideoPlayerController _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.filePath));
    _controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          _controller
            ..setLooping(true)
            ..setVolume(0)
            ..play();
          setState(() {});
        })
        .catchError((Object _) {
          if (mounted) setState(() => _failed = true);
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return const AspectRatio(
        aspectRatio: 1,
        child: ColoredBox(
          color: Colors.grey,
          child: Center(child: Icon(Icons.error_outline, color: Colors.white)),
        ),
      );
    }
    if (!_controller.value.isInitialized) {
      return const AspectRatio(
        aspectRatio: 1,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
      child: AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
