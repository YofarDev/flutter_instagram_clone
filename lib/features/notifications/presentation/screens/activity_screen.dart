import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/utils/time_ago.dart';
import '../../domain/models/notification_item.dart';
import '../bloc/notifications_cubit.dart';
import '../bloc/notifications_state.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().markAllRead();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.activityTitle)),
      body: BlocListener<NotificationsCubit, NotificationsState>(
        listenWhen: (NotificationsState p, NotificationsState c) =>
            p.error != c.error,
        listener: (BuildContext context, NotificationsState state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.error!)));
            context.read<NotificationsCubit>().clearError();
          }
        },
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          buildWhen: (NotificationsState p, NotificationsState c) =>
              p.status != c.status || p.items != c.items,
          builder: (BuildContext context, NotificationsState state) {
            if (state.status == NotificationsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.items.isEmpty) {
              return Center(child: Text(l10n.notifEmpty));
            }
            return ListView.separated(
              itemCount: state.items.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 4),
              itemBuilder: (BuildContext context, int index) =>
                  _NotificationRow(item: state.items[index]),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    final String message = switch (item.type) {
      NotificationType.like => l10n.notifLikedPost(item.actorUsername),
      NotificationType.comment => l10n.notifCommentedPost(
        item.actorUsername,
        item.commentText ?? '',
      ),
      NotificationType.follow => l10n.notifStartedFollowing(item.actorUsername),
    };
    return Material(
      color: item.read ? null : colors.primaryContainer.withValues(alpha: 0.15),
      child: InkWell(
        onTap: () => context.push(Routes.userPath(item.actorId)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundImage: item.actorAvatarUrl != null
                    ? NetworkImage(item.actorAvatarUrl!)
                    : null,
                child: item.actorAvatarUrl == null
                    ? Text(
                        item.actorUsername.isNotEmpty
                            ? item.actorUsername[0].toUpperCase()
                            : '?',
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(message),
                    const SizedBox(height: 2),
                    Text(
                      timeAgo(item.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (item.postImageUrl != null && item.postId != null) ...<Widget>[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => context.push(
                    Routes.postDetailPath(item.postId!),
                    extra: item.postId,
                  ),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.network(
                      item.postImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) => Container(color: colors.surfaceContainerHighest),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
