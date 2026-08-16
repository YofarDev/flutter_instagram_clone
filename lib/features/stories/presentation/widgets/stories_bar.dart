import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/models/app_user.dart';
import '../../../../core/router/route_constants.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/models/story.dart';
import '../../domain/models/story_tray.dart';
import '../bloc/stories_cubit.dart';
import '../bloc/stories_state.dart';
import '../bloc/story_viewer_cubit.dart';
import 'story_tray_avatar.dart';

class StoriesBar extends StatelessWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocBuilder<StoriesCubit, StoriesState>(
      buildWhen: (StoriesState p, StoriesState c) =>
          p.trays != c.trays || p.viewedIds != c.viewedIds,
      builder: (BuildContext context, StoriesState state) {
        if (state.trays.isEmpty) {
          final AppUser? user = context.read<AuthCubit>().state.user;
          if (user == null) return const SizedBox.shrink();
          final StoryTray mine = StoryTray(
            uid: user.uid,
            username: user.username ?? '',
            avatarUrl: user.avatarUrl,
            stories: <Story>[],
          );
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: StoryTrayAvatar(
                  tray: mine,
                  unviewed: true,
                  label: l10n.storiesYourStory,
                  isMine: true,
                  onTap: () => context.push(Routes.createStory),
                ),
              ),
              const Divider(height: 1),
            ],
          );
        }
        return Column(
          children: <Widget>[
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                itemCount: state.trays.length,
                itemBuilder: (BuildContext context, int index) {
                  final StoryTray tray = state.trays[index];
                  final bool unviewed = tray.stories.any(
                    (Story s) => !state.viewedIds.contains(s.id),
                  );
                  return StoryTrayAvatar(
                    tray: tray,
                    unviewed: unviewed,
                    label: tray.username,
                    isMine:
                        tray.uid == context.read<AuthCubit>().state.user?.uid,
                    onTap: () => context.push(
                      Routes.storyViewer,
                      extra: StoryViewerArgs(
                        trays: state.trays,
                        initialTrayIndex: index,
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
          ],
        );
      },
    );
  }
}
