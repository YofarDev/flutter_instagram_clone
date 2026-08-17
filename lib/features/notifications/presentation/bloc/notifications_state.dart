import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/notification_item.dart';

part 'notifications_state.freezed.dart';

enum NotificationsStatus { loading, ready }

@freezed
sealed class NotificationsState with _$NotificationsState {
  const factory NotificationsState({
    @Default(NotificationsStatus.loading) NotificationsStatus status,
    @Default(<NotificationItem>[]) List<NotificationItem> items,
    @Default(0) int unreadCount,
    String? error,
  }) = _NotificationsState;
}
