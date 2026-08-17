import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../domain/models/notification_item.dart';
import '../../domain/repositories/notifications_repository.dart';
import 'notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState());

  final INotificationsRepository _repository;
  StreamSubscription<List<NotificationItem>>? _sub;
  String? _uid;

  /// Idempotent — called post-auth from the shell builder.
  void init(String uid) {
    if (_uid == uid && _sub != null) return;
    _uid = uid;
    _sub?.cancel();
    _sub = _repository
        .watchNotifications(uid: uid)
        .listen(
          _onItems,
          onError: (Object e) {
            if (isClosed) return;
            emit(state.copyWith(error: 'Failed to load notifications'));
          },
        );
  }

  void _onItems(List<NotificationItem> items) {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: NotificationsStatus.ready,
        items: items,
        unreadCount: items.where((NotificationItem n) => !n.read).length,
      ),
    );
  }

  Future<void> markAllRead() async {
    final String? uid = _uid;
    if (uid == null) return;
    final Either<Failure, void> either = await _repository.markAllRead(
      uid: uid,
    );
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(error: f.message)),
      (_) {}, // read flags reset via snapshot → unreadCount recomputes
    );
  }

  void clearError() => emit(state.copyWith(error: null));

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
