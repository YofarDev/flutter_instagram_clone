# Phase 7 — Reels Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: implement this plan task-by-task via subagent-driven-development.

**Goal:** Short video posts (reels): vertical swipe feed with autoplay/pause on page change, like with optimistic UI + double-tap-to-like, reel creation (pick video + caption), 6th bottom-nav tab.

**Architecture:** New `reels` feature mirroring feed's shape minus follows-filter/comments. `ReelsCubit` = live snapshots + likedIds hydration + optimistic toggle (likes only — comments on reels deferred, documented). `ReelsScreen` owns the PageView + current index; `ReelItem` widgets own their `VideoPlayerController` lifecycle (initialize on mount, play only when current index, dispose on unmount). Creation: separate `CreateReelScreen` pushed from a FAB on the reels screen (no change to the Create tab).

**Key decisions (ponytail):**

- **New dep: `video_player`** (official Flutter plugin — no way around a player).
- **Reels are global** (no follow filter — matches Instagram discovery nature; FeedCubit's dual-sub complexity avoided).
- **Likes mirror posts exactly**: `reels/{id}/likes/{uid}` + transaction increment. Comments on reels: DEFERRED (comment UI is post-coupled; reels comments need their own sheet — Phase 8 candidate).
- **Playback control via PageView index** — no visibility_detector package; onPageChanged drives play/pause. No preloading of neighbors (documented).
- **Muted by default** + tap toggles mute (autoplay sound is hostile; one bool).
- **Pagination**: growing limit, `loadMore` triggered when page index reaches length-2.
- **6 tabs** on NavigationBar (Feed, Search, Create, Reels, Activity, Profile) — crowded but fine; labels hide gracefully.

---

### Task 1: Reel model + DTO + contracts + datasource

1. `lib/features/reels/domain/models/reel.dart` — freezed sealed: id, uid, authorUsername, authorAvatarUrl?, videoUrl, @Default('') caption, createdAt, likeCount.
2. `lib/features/reels/data/models/reel_dto.dart` — plain mapper (storage keys uid/username/avatarUrl/videoUrl/caption/createdAt/likeCount).
3. `lib/features/reels/domain/repositories/reels_repository.dart` — IReelsRepository: watchReels({limit}) Stream, createReel({caption, filePath}) Either, fetchLikedReelIds({reelIds}) Either<Set<String>>, toggleReelLike({reelId, currentlyLiked}) Either.
4. `lib/features/reels/data/datasources/reels_firebase_datasource.dart` — mirror + impl:
   - watchReels: orderBy createdAt desc limit snapshots
   - createReel: profile fetch (local copy), storage `reels/{uid}/{millis}.mp4`, orphan-cleanup add (mirror createStory/createPost)
   - fetchLikedReelIds: Future.wait viewers-pattern (reels/{id}/likes/{me}), path-derived ids
   - toggleReelLike: transaction increment + like doc set/delete (NO notification write — reels notifications deferred; note in Deferred)
5. Add `video_player` dep: `flutter pub add video_player`.
6. Commit: `feat(reels): reel models, contracts, and datasource`

### Task 2: ReelsRepositoryImpl (TDD) + rules deploy

House pattern; streams raw. ~6 tests.
Rules — reels block (mirror posts):

```
match /reels/{reelId} {
  allow read: if signedIn();
  allow create: if signedIn() && request.resource.data.uid == request.auth.uid;
  allow update: if signedIn() && request.resource.data.diff(resource.data)
      .affectedKeys().hasOnly(['likeCount']);
  allow delete: if signedIn() && resource.data.uid == request.auth.uid;
  match /likes/{uid} {
    allow read: if signedIn();
    allow create, delete: if signedIn() && request.auth.uid == uid;
  }
}
```

Deploy. Commit: `feat(reels): repository implementation and rules`

### Task 3: ReelsCubit (TDD)

State: status loading/ready, reels List<Reel>, likedIds Set<String>, hasMore, error?.
Ctor(repo): sub watchReels(limit 10): on emission → hydrate fetchLikedReelIds (stale-keep on Left, silent) → ready + reels + likedIds + hasMore (length >= limit); onError → error. loadMore: guard, limit += 10, gen-guarded resubscribe. toggleReelLike(reel): optimistic count ±1 + likedIds flip, rollback on Left. clearError. isClosed guards. close cancels.
Tests (~7): hydration, stale-keep, error, optimistic + success, rollback, loadMore limit growth, blocked when !hasMore.
Commit: `feat(reels): reels cubit`

### Task 4: Routes + DI + l10n + 6th tab

- Routes: `reels = '/reels'` (TAB), `createReel = '/create-reel'` (root-nav push).
- DI: datasource/repo singletons; ReelsCubit factory; CreateReelCubit factory.
- Shell: 6th branch + destination (movie/play icon: Icons.movie_outlined/movie) inserted after Create, before Activity. Reels tab builder: BlocProvider<ReelsCubit>(create: getIt<ReelsCubit>()) + placeholder screen. CreateReel route: placeholder.
- l10n: reelsTitle "Reels" "Reels", createReelTitle "Nouvelle réalisation" "New reel", reelShare "Partager" "Share", reelCaptionHint "Écris une légende…" "Write a caption…", reelPickVideo "Choisir une vidéo" "Choose a video", reelRecordVideo "Filmer une vidéo" "Record a video", reelMuted? (no text — icon).
- Commit: `feat(reels): reels tab, create route, di, strings`

### Task 5: Screens + video widgets

- `CreateReelCubit` (mirror CreateStoryCubit + caption field like CreatePostCubit): pickVideo(ImageSource, maxDuration 60s) → pickedPath; captionChanged; submit → createReel → success/error. TDD (3-4 tests).
- `create_reel_screen.dart`: mirror create_post_screen: no-video → pick/record buttons (l10n.reelPickVideo/reelRecordVideo); video → preview via `VideoPlayerController.file` (init in StatefulWidget, dispose, muted autoplay loop for preview), caption field, Share button → submit; success → pop; submitting spinner.
- `reels_screen.dart`: StatefulWidget — PageView(scrollDirection: vertical, controller, itemCount: reels.length + (hasMore?1:0)? LAZY: trailing loader page when hasMore and index reaches it → loadMore + spinner page). onPageChanged: setState currentIndex + context.read<ReelsCubit>().loadMore() when index >= length-2; FAB (Icons.add) → push createReel.
- `reel_item.dart` (StatefulWidget per page): VideoPlayerController.network(reel.videoUrl) — init (muted, loop) in initState (async, mounted guards); plays/pauses reactively: `if (widget.isCurrent) play else pause` in didUpdateWidget; mute toggle button; overlay bottom-left: username (bold, tap → user profile) + caption; right-side action column: heart (optimistic via cubit likedIds) + count, mute icon toggle; double-tap anywhere → toggleReelLike when unliked; errorBuilder-ish: FutureBuilder/initialized check → black + spinner while loading.
- Router: replace placeholders.
- Commit: `feat(reels): reels and create reel screens`

### Task 6: Tests + final gate + quality review

- Cubit tests already in Task 3; CreateReelCubit tests in Task 5.
- Widget tests: video player can't init in test env — test OVERLAY logic only where feasible: skip player widget tests entirely (document). Light test: reels_screen renders page structure with mocked... no. LAZY: no widget tests this phase — player mocks are worse than no tests. Quality review compensates.
- flutter analyze + test; README tick Phase 7; commit `chore: complete phase 7`; consolidated quality review (same pattern as prior phases); fix findings.

## Deferred

- Reel comments + notifications for reel likes (needs comment sheet UI + notification type)
- Video preloading/caching (cached_video_player or PreloadPageView when perceived slowness matters)
- Video trimming/compression before upload (full-size videos upload slow — noted ceiling)
- Reel audio attribution/trending audio
- Web/desktop player (kIsWeb guards absent — mobile-only POC)
