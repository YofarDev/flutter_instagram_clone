import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../../../core/models/post.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileArgs {
  const ProfileArgs({required this.uid, required this.isMe});

  final String uid;
  final bool isMe;
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._repository, {
    required String uid,
    required bool isMe,
  }  )  : _uid = uid, // ignore: prefer_initializing_formals
        _isMe = isMe, // ignore: prefer_initializing_formals
        super(ProfileState(isMe: isMe)) {
    _subscribe();
    if (!_isMe) {
      _subFollow = _repository
          .watchIsFollowing(uid: _uid)
          .listen((bool following) => _onFollowing(following));
    }
    _loadProfile();
  }

  static const int _pageSize = 12;

  final IProfileRepository _repository;
  final String _uid;
  final bool _isMe;
  StreamSubscription<List<Post>>? _sub;
  StreamSubscription<bool>? _subFollow;
  int _limit = _pageSize;
  int _gen = 0;

  void _subscribe() {
    _sub?.cancel();
    final int gen = ++_gen;
    _sub = _repository.watchUserPosts(uid: _uid, limit: _limit).listen(
          (List<Post> posts) => _onPosts(posts, gen),
          onError: (Object e) {
            if (isClosed) return;
            emit(state.copyWith(error: 'Failed to load posts'));
          },
        );
  }

  void _onPosts(List<Post> posts, int gen) {
    if (isClosed || gen != _gen) return;
    emit(state.copyWith(
      status: ProfileStatus.ready,
      posts: posts,
      hasMore: posts.length >= _limit,
    ));
  }

  void _onFollowing(bool following) {
    if (isClosed) return;
    emit(state.copyWith(isFollowing: following));
  }

  Future<void> _loadProfile() async {
    final Either<Failure, UserProfile> either =
        await _repository.getProfile(uid: _uid);
    if (isClosed) return;
    either.fold(
      (Failure f) =>
          emit(state.copyWith(status: ProfileStatus.ready, error: f.message)),
      (UserProfile profile) => emit(
        state.copyWith(status: ProfileStatus.ready, profile: profile),
      ),
    );
  }

  Future<void> toggleFollow() async {
    if (_isMe) return;
    final bool was = state.isFollowing;
    final UserProfile? profile = state.profile;
    emit(state.copyWith(
      isFollowing: !was,
      profile: profile?.copyWith(
        followerCount: profile.followerCount + (was ? -1 : 1),
      ),
    ));
    final Either<Failure, void> either =
        await _repository.toggleFollow(uid: _uid, currentlyFollowing: was);
    if (isClosed) return;
    either.fold(
      (Failure f) {
        final UserProfile? current = state.profile;
        emit(state.copyWith(
          isFollowing: was,
          profile: current?.copyWith(
            followerCount: current.followerCount + (was ? 1 : -1),
          ),
          error: f.message,
        ));
      },
      (_) {},
    );
  }

  void loadMore() {
    if (!state.hasMore) return;
    _limit += _pageSize;
    _subscribe();
  }

  void clearError() => emit(state.copyWith(error: null));

  @override
  Future<void> close() {
    _sub?.cancel();
    _subFollow?.cancel();
    return super.close();
  }
}
