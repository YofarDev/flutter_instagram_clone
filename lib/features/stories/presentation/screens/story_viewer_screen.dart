import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nested/nested.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/models/story.dart';
import '../../domain/models/story_tray.dart';
import '../bloc/story_viewer_cubit.dart';
import '../bloc/story_viewer_state.dart';

class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({super.key});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late final StoryViewerCubit _cubit;
  final TextEditingController _replyController = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<StoryViewerCubit>()..init();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _replyController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) _cubit.next();
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _startTimer();
  }

  void _sendReply(String text) {
    if (text.trim().isEmpty) return;
    _cubit.reply(text);
    _resetTimer();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String myUid = context.watch<AuthCubit>().state.user!.uid;
    return MultiBlocListener(
      listeners: <SingleChildWidget>[
        BlocListener<StoryViewerCubit, StoryViewerState>(
          listenWhen: (StoryViewerState p, StoryViewerState c) =>
              !p.finished && c.finished,
          listener: (BuildContext context, StoryViewerState state) =>
              context.pop(),
        ),
        BlocListener<StoryViewerCubit, StoryViewerState>(
          listenWhen: (StoryViewerState p, StoryViewerState c) =>
              p.replySent != c.replySent && c.replySent,
          listener: (BuildContext context, StoryViewerState state) {
            _replyController.clear();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(l10n.storyReplySent)));
            _cubit.clearReplySent();
          },
        ),
        BlocListener<StoryViewerCubit, StoryViewerState>(
          listenWhen: (StoryViewerState p, StoryViewerState c) =>
              p.error != c.error && c.error != null,
          listener: (BuildContext context, StoryViewerState state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
            _cubit.clearError();
          },
        ),
      ],
      child: BlocBuilder<StoryViewerCubit, StoryViewerState>(
        buildWhen: (StoryViewerState p, StoryViewerState c) =>
            p.trayIndex != c.trayIndex || p.storyIndex != c.storyIndex,
        builder: (BuildContext context, StoryViewerState state) {
          final Story? story = _cubit.currentStory;
          if (story == null) {
            return const SizedBox.shrink();
          }
          final StoryTray tray = state.trays[state.trayIndex];
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: <Widget>[
                        for (int i = 0; i < tray.stories.length; i++)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: _Segment(
                                key: ValueKey<String>(tray.stories[i].id),
                                current: i == state.storyIndex,
                                past: i < state.storyIndex,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 14,
                          backgroundImage: tray.avatarUrl != null
                              ? NetworkImage(tray.avatarUrl!)
                              : null,
                          child: tray.avatarUrl == null
                              ? Text(
                                  tray.username.isNotEmpty
                                      ? tray.username[0].toUpperCase()
                                      : '?',
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tray.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                         Text(
                           timeAgo(
                             story.createdAt,
                             locale:
                                 Localizations.localeOf(
                                   context,
                                 ).languageCode,
                           ),
                           style: const TextStyle(color: Colors.white70),
                         ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Image.network(
                            story.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) =>
                                Container(color: Colors.grey.shade900),
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    _cubit.previous();
                                    _resetTimer();
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    _cubit.next();
                                    _resetTimer();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (tray.uid != myUid)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: TextField(
                              controller: _replyController,
                              minLines: 1,
                              maxLines: 3,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: l10n.storyReplyHint(
                                  tray.username,
                                ),
                                hintStyle: const TextStyle(
                                  color: Colors.white54,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: const BorderSide(
                                    color: Colors.white24,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                              ),
                              onSubmitted: _sendReply,
                              textInputAction: TextInputAction.send,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () =>
                                _sendReply(_replyController.text),
                          ),
                        ],
                      ),
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

class _Segment extends StatelessWidget {
  const _Segment({required this.current, required this.past, super.key});

  final bool current;
  final bool past;

  @override
  Widget build(BuildContext context) {
    if (current) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(seconds: 5),
        builder: (BuildContext context, double v, _) => SizedBox(
          height: 3,
          child: LinearProgressIndicator(
            value: v,
            color: Colors.white,
            backgroundColor: Colors.white24,
          ),
        ),
      );
    }
    return Container(height: 3, color: past ? Colors.white : Colors.white24);
  }
}
