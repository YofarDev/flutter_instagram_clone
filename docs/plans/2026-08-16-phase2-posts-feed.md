# Phase 2 — Posts & Feed Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Image posts (gallery/camera + caption), live home feed with pagination, likes (optimistic), and comments.

**Architecture:** Single `feed` feature (list, creation, detail are one capability). Three cubits split along visible UI concerns: `FeedCubit` (list + likes + pagination), `CreatePostCubit` (pick/upload/publish), `PostDetailCubit` (comments). Firestore is the source of truth; the feed is a **live snapshots stream** — creation and comments update the UI with zero manual refresh.

**Tech Stack:** cloud_firestore (snapshots streams, `FieldValue.increment`, `getAll`), firebase_storage, image_picker, flutter_bloc, freezed, fpdart, go_router.

**Key decisions (ponytail-approved):**

- **Feed = ALL posts, chronological** until Phase 3 adds the follow graph; then the query swaps to `authorId whereIn followed`. Documented, one-line swap.
- **Pagination by growing limit**: `watchFeed(limit)` re-subscribes with `limit + 10` on loadMore. No cursor bookkeeping. Fine at POC scale.
- **Likes**: `posts/{id}/likes/{uid}` doc existence + `likeCount` via `FieldValue.increment`. `isLiked` hydration = one `db.getAll` batch per page (not N gets).
- **`isLiked` lives in FeedState (`Set<String> likedIds`), NOT on Post** — keeps the domain model pure.
- **Client-side `DateTime.now()` as createdAt** (millis int in Firestore) — avoids the serverTimestamp null-pending dance. Clock skew irrelevant for POC.
- **Denormalized author (username/avatar) on the post** at creation time. Stale after profile edits — accepted, Phase 3 concern.
- **Post passed to detail route via `extra`** — no re-fetch. Route-scoped cubits use `BlocProvider(create:)` (only AuthCubit is a singleton).

---

### Task 1: Models + DTOs

**Files:**
- Create: `lib/features/feed/domain/models/post.dart`, `lib/features/feed/domain/models/comment.dart`
- Create: `lib/features/feed/data/models/post_dto.dart`, `lib/features/feed/data/models/comment_dto.dart`

`post.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';

@freezed
sealed class Post with _$Post {
  const factory Post({
    required String id,
    required String authorId,
    required String authorUsername,
    String? authorAvatarUrl,
    required String imageUrl,
    @Default('') String caption,
    required DateTime createdAt,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
  }) = _Post;
}
```

`comment.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment.freezed.dart';

@freezed
sealed class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String postId,
    required String authorId,
    required String authorUsername,
    required String text,
    required DateTime createdAt,
  }) = _Comment;
}
```

`post_dto.dart`:

```dart
import '../../domain/models/post.dart';

// domain import in data layer is allowed (data → domain).

class PostDto {
  const PostDto({
    required this.authorId,
    required this.authorUsername,
    this.authorAvatarUrl,
    required this.imageUrl,
    this.caption = '',
    required this.createdAtMillis,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  factory PostDto.fromMap(String id, Map<String, dynamic> map) => PostDto(
        authorId: map['authorId'] as String,
        authorUsername: map['authorUsername'] as String,
        authorAvatarUrl: map['authorAvatarUrl'] as String?,
        imageUrl: map['imageUrl'] as String,
        caption: map['caption'] as String? ?? '',
        createdAtMillis: map['createdAt'] as int,
        likeCount: map['likeCount'] as int? ?? 0,
        commentCount: map['commentCount'] as int? ?? 0,
      );

  final String authorId;
  final String authorUsername;
  final String? authorAvatarUrl;
  final String imageUrl;
  final String caption;
  final int createdAtMillis;
  final int likeCount;
  final int commentCount;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'authorId': authorId,
        'authorUsername': authorUsername,
        'authorAvatarUrl': authorAvatarUrl,
        'imageUrl': imageUrl,
        'caption': caption,
        'createdAt': createdAtMillis,
        'likeCount': likeCount,
        'commentCount': commentCount,
      };

  Post toDomain(String id) => Post(
        id: id,
        authorId: authorId,
        authorUsername: authorUsername,
        authorAvatarUrl: authorAvatarUrl,
        imageUrl: imageUrl,
        caption: caption,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
        likeCount: likeCount,
        commentCount: commentCount,
      );
}
```

(Plain DTO class — no freezed needed, it's a dumb mapper. No `part` files.)

`comment_dto.dart`: same pattern — `authorId`, `authorUsername`, `text`, `createdAt` millis; `fromMap(id, map)`, `toMap()`, `toDomain(id, postId)`.

Run `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze`. Commit: `feat(feed): post and comment models`.

---

### Task 2: Datasource + repository contracts

**Files:**
- Create: `lib/features/feed/domain/repositories/feed_repository.dart`
- Create: `lib/features/feed/data/datasources/feed_firebase_datasource.dart`

`feed_repository.dart`:

```dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../models/comment.dart';
import '../models/post.dart';

abstract interface class IFeedRepository {
  /// Live feed, newest first. Raw stream — errors surface via onError.
  Stream<List<Post>> watchFeed({required int limit});

  Future<Either<Failure, void>> createPost({
    required String caption,
    required String filePath,
  });

  Future<Either<Failure, Set<String>>> fetchLikedPostIds({
    required List<String> postIds,
  });

  Future<Either<Failure, void>> toggleLike({
    required Post post,
    required bool currentlyLiked,
  });

  Stream<List<Comment>> watchComments({required String postId});

  Future<Either<Failure, void>> addComment({
    required String postId,
    required String text,
  });
}
```

`feed_firebase_datasource.dart`:

```dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/models/comment.dart';
import '../../domain/models/post.dart';
import '../models/comment_dto.dart';
import '../models/post_dto.dart';

abstract interface class IFeedDataSource {
  Stream<List<Post>> watchFeed({required int limit});
  Future<void> createPost({
    required String caption,
    required String filePath,
    required String uid,
    required String username,
    required String? avatarUrl,
  });
  Future<Set<String>> fetchLikedPostIds({required List<String> postIds});
  Future<void> toggleLike({
    required String postId,
    required bool currentlyLiked,
  });
  Stream<List<Comment>> watchComments({required String postId});
  Future<void> addComment({
    required String postId,
    required String text,
    required String uid,
    required String username,
  });
}

class FeedFirebaseDataSource implements IFeedDataSource {
  const FeedFirebaseDataSource();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  @override
  Stream<List<Post>> watchFeed({required int limit}) => _db
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((QuerySnapshot<Object?> snap) => snap.docs
          .map((QueryDocumentSnapshot<Object?> doc) =>
              PostDto.fromMap(doc.id, doc.data() as Map<String, dynamic>)
                  .toDomain(doc.id))
          .toList());

  @override
  Future<void> createPost({
    required String caption,
    required String filePath,
    required String uid,
    required String username,
    required String? avatarUrl,
  }) async {
    final int millis = DateTime.now().millisecondsSinceEpoch;
    final Reference ref = _storage.ref('posts/$uid/$millis.jpg');
    await ref.putFile(File(filePath));
    final String imageUrl = await ref.getDownloadURL();
    // ponytail: client timestamp, serverTimestamp if ordering disputes matter
    await _db.collection('posts').add(PostDto(
          authorId: uid,
          authorUsername: username,
          authorAvatarUrl: avatarUrl,
          imageUrl: imageUrl,
          caption: caption,
          createdAtMillis: millis,
        ).toMap());
  }

  @override
  Future<Set<String>> fetchLikedPostIds({required List<String> postIds}) async {
    if (postIds.isEmpty) return <String>{};
    final List<DocumentReference<Object?>> refs = postIds
        .map((String id) => _db.collection('posts').doc(id).collection('likes').doc(_uid))
        .toList();
    final List<DocumentSnapshot<Object?>> snaps = await _db.getAll(refs);
    return <String>{
      for (final DocumentSnapshot<Object?> s in snaps)
        if (s.exists) s.reference.parent.parent!.id,
    };
  }

  @override
  Future<void> toggleLike({
    required String postId,
    required bool currentlyLiked,
  }) {
    final DocumentReference<Object?> likeRef =
        _db.collection('posts').doc(postId).collection('likes').doc(_uid);
    final DocumentReference<Object?> postRef =
        _db.collection('posts').doc(postId);
    return _db.runTransaction((Transaction tx) async {
      tx.update(postRef, <String, dynamic>{
        'likeCount': FieldValue.increment(currentlyLiked ? -1 : 1),
      });
      currentlyLiked ? tx.delete(likeRef) : tx.set(likeRef, <String, dynamic>{});
    });
  }

  @override
  Stream<List<Comment>> watchComments({required String postId}) => _db
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .orderBy('createdAt')
      .snapshots()
      .map((QuerySnapshot<Object?> snap) => snap.docs
          .map((QueryDocumentSnapshot<Object?> doc) =>
              CommentDto.fromMap(doc.id, doc.data() as Map<String, dynamic>)
                  .toDomain(doc.id, postId))
          .toList());

  @override
  Future<void> addComment({
    required String postId,
    required String text,
    required String uid,
    required String username,
  }) async {
    final DocumentReference<Object?> postRef =
        _db.collection('posts').doc(postId);
    await _db.runTransaction((Transaction tx) async {
      tx.update(postRef, <String, dynamic>{
        'commentCount': FieldValue.increment(1),
      });
      tx.set(
        postRef.collection('comments').doc(),
        CommentDto(
          authorId: uid,
          authorUsername: username,
          text: text,
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        ).toMap(),
      );
    });
  }
}
```

Note `fetchLikedPostIds` deriving the postId back from the like doc path (`s.reference.parent.parent!.id`) — avoids needing a field on the like doc.

`flutter analyze`, commit: `feat(feed): datasource and repository contracts`.

---

### Task 3: FeedRepositoryImpl (TDD)

**Files:**
- Create: `lib/features/feed/data/repositories/feed_repository_impl.dart`
- Test: `test/features/feed/feed_repository_impl_test.dart`

Test scenarios (mocktail `MockFeedDataSource`):
- `watchFeed` passes through unchanged (stream equality on emitted list)
- `createPost` success → `Right(null)`, failure → `Left(Failure.serverError)` (datasource throws)
- `createPost` injects uid/username/avatar from datasource params? NO — repo passes through; the **uid/username/avatar resolution lives in repo** (it owns "current user" context): repo calls an injected `IAuthRepository.authStateChanges`? Simplest correct: repo reads current user from its own constructor deps — inject `IAuthDataSource`? That couples feed→auth data. Cleaner: FeedRepositoryImpl takes `AppUser? Function()` current user getter? NO — simplest: repo injects `IAuthRepository` (domain interface, cross-feature via public contract — ALLOWED) and reads `authStateChanges` latest? Streams have no "latest".

  **Decision: datasource already reads `FirebaseAuth.instance.currentUser` for uid (it does, `_uid`). Add username/avatar there too** — it's Firebase-native state, data-layer concern. Change datasource `createPost` signature to `({caption, filePath})` only; it pulls uid/username/avatar from `currentUser` (username/avatar are NOT on FirebaseUser — they're in Firestore users doc).

  FINAL simple call: datasource `createPost` fetches the user doc (`users/{uid}.get()`) for username/avatar, then writes. One extra read per post creation — irrelevant. Repository then has zero auth knowledge, mirrors IFeedRepository exactly. Adjust Task 2's datasource accordingly:

```dart
  @override
  Future<void> createPost({
    required String caption,
    required String filePath,
  }) async {
    final User user = FirebaseAuth.instance.currentUser!;
    final DocumentSnapshot<Object?> profile =
        await _db.collection('users').doc(user.uid).get();
    final Map<String, dynamic> data =
        profile.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    final int millis = DateTime.now().millisecondsSinceEpoch;
    final Reference ref = _storage.ref('posts/${user.uid}/$millis.jpg');
    await ref.putFile(File(filePath));
    final String imageUrl = await ref.getDownloadURL();
    await _db.collection('posts').add(PostDto(
          authorId: user.uid,
          authorUsername: data['username'] as String? ?? user.email ?? '?',
          authorAvatarUrl: data['avatarUrl'] as String?,
          imageUrl: imageUrl,
          caption: caption,
          createdAtMillis: millis,
        ).toMap());
  }
```

(And `IFeedDataSource.createPost` = `({caption, filePath})`.)

Tests:
- fetchLikedPostIds maps through
- toggleLike maps through
- watchComments passes through
- addComment success/failure Either

Impl: identical Either-wrapping shape as `AuthRepositoryImpl` (Task 6, Phase 1) — read it and mirror. Streams pass through raw. `_mapError`: no FirebaseAuthException mapping needed; plain `Failure.serverError(message: e.toString())` (ponytail: Firestore errors are already descriptive strings).

Commit: `feat(feed): repository implementation with failure mapping`.

---

### Task 4: FeedCubit (TDD)

**Files:**
- Create: `lib/features/feed/presentation/bloc/feed_state.dart`, `feed_cubit.dart`
- Test: `test/features/feed/feed_cubit_test.dart`

`feed_state.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/post.dart';

part 'feed_state.freezed.dart';

enum FeedStatus { loading, ready }

@freezed
sealed class FeedState with _$FeedState {
  const factory FeedState({
    @Default(FeedStatus.loading) FeedStatus status,
    @Default(<Post>[]) List<Post> posts,
    @Default(<String>{}) Set<String> likedIds,
    @Default(true) bool hasMore,
    String? error,
  }) = _FeedState;
}
```

`feed_cubit.dart`:

```dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/post.dart';
import '../../domain/repositories/feed_repository.dart';
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit(this._repository) : super(const FeedState()) {
    _subscribe();
  }

  static const int _pageSize = 10;

  final IFeedRepository _repository;
  StreamSubscription<List<Post>>? _sub;
  int _limit = _pageSize;

  void _subscribe() {
    _sub?.cancel();
    _sub = _repository.watchFeed(limit: _limit).listen(
          _onPosts,
          onError: (Object e) =>
              emit(state.copyWith(error: 'Failed to load feed')),
        );
  }

  Future<void> _onPosts(List<Post> posts) async {
    final liked = await _repository.fetchLikedPostIds(
      postIds: posts.map((Post p) => p.id).toList(),
    );
    liked.fold(
      (_) => emit(state.copyWith(
        status: FeedStatus.ready,
        posts: posts,
        hasMore: posts.length >= _limit,
      )), // ponytail: keep stale likedIds on hydration failure
      (Set<String> ids) => emit(state.copyWith(
        status: FeedStatus.ready,
        posts: posts,
        likedIds: ids,
        hasMore: posts.length >= _limit,
      )),
    );
  }

  void loadMore() {
    if (!state.hasMore) return;
    _limit += _pageSize;
    _subscribe();
  }

  Future<void> toggleLike(Post post) async {
    final bool wasLiked = state.likedIds.contains(post.id);
    // optimistic
    emit(state.copyWith(
      posts: state.posts
          .map((Post p) => p.id == post.id
              ? p.copyWith(likeCount: p.likeCount + (wasLiked ? -1 : 1))
              : p)
          .toList(),
      likedIds: wasLiked
          ? ({...state.likedIds}..remove(post.id))
          : {...state.likedIds, post.id},
    ));
    final result =
        await _repository.toggleLike(post: post, currentlyLiked: wasLiked);
    result.fold(
      (f) => emit(state.copyWith(
        error: f.message,
        // rollback
        posts: state.posts
            .map((Post p) => p.id == post.id
                ? p.copyWith(likeCount: p.likeCount + (wasLiked ? 1 : -1))
                : p)
            .toList(),
        likedIds: wasLiked
            ? {...state.likedIds, post.id}
            : ({...state.likedIds}..remove(post.id)),
      )),
      (_) {},
    );
  }

  void clearError() => emit(state.copyWith(error: null));

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
```

Test scenarios (bloc_test, MockFeedRepository):
1. initial: watchFeed emits 2 posts, fetchLikedPostIds → {'p1'} → state ready/posts/likedIds
2. fetchLikedPostIds failure → ready + posts, likedIds stay empty
3. watchFeed onError → error set
4. toggleLike optimistic: unliked→liked (count 5→6, id in likedIds), repo Right → stays
5. toggleLike rollback: repo Left → count and likedIds restored, error set
6. loadMore: verify watchFeed re-called with limit 20 (registering call counts), hasMore false when posts.length < limit blocks loadMore

Commit: `feat(feed): feed cubit with optimistic likes and pagination`.

---

### Task 5: CreatePostCubit + PostDetailCubit (TDD)

**Files:**
- Create: `lib/features/feed/presentation/bloc/create_post_state.dart` + `create_post_cubit.dart`
- Create: `lib/features/feed/presentation/bloc/post_detail_state.dart` + `post_detail_cubit.dart`
- Test: `test/features/feed/create_post_cubit_test.dart`, `test/features/feed/post_detail_cubit_test.dart`

CreatePostState: `pickedPath String?`, `caption` (default ''), `submitting`, `String? error`, `bool success` (or `saved` flag — screen pops on true).

CreatePostCubit:
- `pickImage(ImageSource source)` → image_picker (gallery/camera), maxWidth 1080, quality 70 → set pickedPath
- `captionChanged(String)` → emit caption
- `submit()` → guard pickedPath != null && !submitting → submitting true → repo.createPost → Left: error, Right: success true
- error cleared per submit

PostDetailState: `post Post`, `comments List<Comment>`, `sending`, `String? error`.

PostDetailCubit(post): subscribes `watchComments(postId)` (onError → error). `addComment(text)` → guard text.trim() not empty && !sending → sending true → repo → fold (error / sending false). Stream updates comments automatically.

Tests mirror Phase 1 patterns (stream stubs, Either stubs, optimistic-none — create/detail are direct).

Commit: `feat(feed): create post and post detail cubits`.

---

### Task 6: DI + routes

**Files:**
- Modify: `lib/core/di/service_locator.dart`, `lib/core/router/route_constants.dart`, `lib/core/router/app_router.dart`

DI additions: `IFeedDataSource → FeedFirebaseDataSource`, `IFeedRepository → FeedRepositoryImpl`, factories: `FeedCubit`, `CreatePostCubit`, `PostDetailCubit` (registerFactoryParam<PostDetailCubit, Post, void>).

Routes additions: `create = '/create'`, `postDetail = '/post/:id'`.

Router:
- feed route: wrap FeedScreen in `BlocProvider<FeedCubit>(create: (_) => getIt<FeedCubit>())` (route-scoped — `create:` correct here)
- create route: `BlocProvider<CreatePostCubit>(create: ...)` + CreatePostScreen
- postDetail route: `final Post post = state.extra! as Post;` → `BlocProvider<PostDetailCubit>(create: (_) => getIt<PostDetailCubit>(param1: post))` + PostDetailScreen

Commit: `feat(feed): di and routes for create/detail`.

---

### Task 7: l10n

```bash
fstr feedNewPost "Nouveau post" "New post"
fstr createPostTitle "Nouvelle publication" "New post"
fstr postCaptionHint "Écris une légende…" "Write a caption…"
fstr postShare "Partager" "Share"
fstr postAddPhoto "Choisir une photo" "Choose a photo"
fstr postTakePhoto "Prendre une photo" "Take a photo"
fstr postComments "Voir les commentaires" "View comments"
fstr postAddComment "Ajouter un commentaire…" "Add a comment…"
fstr postSend "Envoyer" "Send"
fstr postDetailTitle "Publication" "Post"
fstr feedEmpty "Aucun post pour l'instant — sois le premier !" "No posts yet — be the first!"
fstr postCommentsSection "Commentaires" "Comments"
fstr errorGeneric "Une erreur est survenue" "Something went wrong"
fstr postRetry "Réessayer" "Try again"
```

Commit: `chore(l10n): feed and post strings`.

---

### Task 8: Post card + feed screen

**Files:**
- Create: `lib/features/feed/presentation/widgets/post_card.dart`
- Rewrite: `lib/features/feed/presentation/screens/feed_screen.dart`

PostCard widget (StatelessWidget, takes `Post`, reads FeedCubit via context):
- Header: CircleAvatar (NetworkImage authorAvatarUrl or initials fallback) + username + createdAt relative (`timeago`? NO — new dep. Lazy: `'${max(1, hoursAgo)}h'`-style helper or just the date. Use a tiny `_timeAgo` helper, ponytail comment.)
- Image: `Image.network` with `frameBuilder` fade, aspectRatio 1, errorBuilder → grey box
- Actions row: heart IconButton (filled red when liked — `state.likedIds.contains(post.id)`), comment IconButton (→ push detail)
- Counts: likeCount, commentCount texts
- Caption: username + caption

FeedScreen rewrite:
- keep logout IconButton + add FAB (+) → `context.push(Routes.create)`
- BlocBuilder on status: loading spinner / empty state (l10n.feedEmpty + hint to use +) / ListView.builder of PostCards + bottom `hasMore` trigger (NotificationListener<ScrollNotification> near end → `context.read<FeedCubit>().loadMore()` or a trailing "load more" button — button is lazier and testable: Visibility when hasMore)
- BlocListener: error → snackbar + clearError
- PostCard tap (image or comment icon) → `context.push('/post/${post.id}', extra: post)`

Commit: `feat(feed): feed screen with post cards`.

---

### Task 9: Create + detail screens

**Files:**
- Create: `lib/features/feed/presentation/screens/create_post_screen.dart`, `lib/features/feed/presentation/screens/post_detail_screen.dart`
- Create: `lib/features/feed/presentation/widgets/comment_tile.dart`

CreatePostScreen:
- preview area: picked image or two big buttons (photo library / camera via l10n keys)
- caption TextField (multiline), share FilledButton (disabled while submitting or no image)
- BlocListener success → `context.pop()`; error → snackbar
- Controllers per house rules (StatefulWidget)

PostDetailScreen:
- PostCard at top (reads FeedCubit? NO — detail route has no FeedCubit provider. PostCard must work standalone: refactor PostCard to take optional callbacks or read PostDetailCubit for like? LAZY: PostCard takes `isLiked` + `onLike` + `onComment` as constructor params — feed screen wires them to FeedCubit, detail screen wires them to PostDetailCubit (which needs toggleLike too — add `toggleLike()` to PostDetailCubit delegating to repo, optimistic on its own state: add `liked bool` + `likeCount` override to PostDetailState initialized from... it doesn't know isLiked! Feed knew via likedIds. Detail would need fetchLikedPostIds([post.id]). Fine — PostDetailCubit.init fetches it. Add to Task 5.)
- comments list (CommentTile: username, text, time), bottom input bar: TextField + send button, sending disables input
- BlocListener error snackbar

Commit: `feat(feed): create post and post detail screens`.

---

### Task 10: iOS permissions + widget test + final verify

- `ios/Runner/Info.plist`: add `NSPhotoLibraryUsageDescription` ("Add photos to your posts"), `NSCameraUsageDescription` ("Take photos for your posts"), `NSMicrophoneUsageDescription` NOT needed (no video).
- Widget test `test/features/feed/post_card_widget_test.dart`: pump PostCard inside BlocProvider with real FeedCubit + MockFeedRepository (stubbed watchFeed = empty stream), seed ready state with one post unliked → tap heart → icon becomes filled AND verify repo.toggleLike was called (optimistic UI without waiting).
- Full gate: `flutter analyze` && `flutter test` all green.
- README: tick Phase 2. Commit: `chore: complete phase 2`.

Manual smoke (user): create post from gallery + camera, see it appear live in feed, like/unlike (count changes, persists across reload), comment (count updates, appears in detail), pagination with 12+ posts, logout/login still works.

---

## Deferred

- Bottom nav shell (Phase 3, with profile)
- Follows-based feed query (Phase 3 — swap in `watchFeed`)
- Double-tap-to-like animation, video posts (Phase 7)
- Firestore security rules (rules file with `allow read, write: if request.auth != null` would be a cheap win — Phase 3 with username uniqueness)
