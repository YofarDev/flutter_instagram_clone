# Phase 4 — Stories Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 24h disappearing stories — story bar on feed (rings, own tray with +), story creation (gallery/camera), full-screen viewer with progress segments, tap/auto advance, viewed tracking (grey rings).

**Architecture:** New `stories` feature (one capability: list + create + view). Firestore `stories/{id}` docs (uid, username, avatarUrl, imageUrl, createdAt) — each item its own doc, author denormalized (same pattern as posts). Viewed tracking: `stories/{id}/viewers/{uid}` existence (same pattern as likes). Three cubits: `StoriesCubit` (trays + viewed hydration), `CreateStoryCubit` (pick/upload), `StoryViewerCubit` (progression + viewed marking). Viewer screen owns the advance Timer (widget lifecycle), cubit owns indices.

**Key decisions (ponytail):**

- **Expiry = client-side filter**: query `createdAt > now-24h`. Old docs accumulate forever — cleanup via scheduled Cloud Function deferred (commented ceiling). Storage files too.
- **Tray = client-side grouping**: snapshots of active stories → group by uid → own tray first, others by most-recent-story desc.
- **Ring state**: `fetchViewedStoryIds` batch (mirrors likes hydration). Tray unviewed if ANY item unviewed.
- **markViewed fire-and-forget**: cubit calls repo, ignores errors (ring stays colored — acceptable).
- **Viewer progression**: tap zones + 5s Timer in the screen; `next()`/`previous()` in cubit emit index state; closing at end pops route.
- **Storage rules**: deploy auth-required bucket rules now (test mode expires in 30 days — prevents Phase 1 timebomb).

---

### Task 1: Story models + contracts + datasource

- `lib/features/stories/domain/models/story.dart` — freezed sealed: id, uid, authorUsername, authorAvatarUrl?, imageUrl, createdAt.
- `lib/features/stories/data/models/story_dto.dart` — plain mapper (fromMap/toMap/toDomain), same pattern as PostDto.
- `lib/features/stories/domain/repositories/stories_repository.dart` — IStoriesRepository:
  - `Stream<List<Story>> watchStories()` — active stories (createdAt > now-24h cutoff computed at subscribe), newest first
  - `Future<Either<Failure, void>> createStory({required String filePath})`
  - `Future<Either<Failure, Set<String>>> fetchViewedStoryIds({required List<String> storyIds})`
  - `Future<Either<Failure, void>> markViewed({required String storyId})`
- `lib/features/stories/data/datasources/stories_firebase_datasource.dart` — IStoriesDataSource + impl:
  - watchStories: `stories.where('createdAt', isGreaterThan: cutoff).orderBy('createdAt', descending: true).snapshots()` → Story list. Cutoff fixed at subscribe time (comment: liveness accepted).
  - createStory: current user profile read (username/avatar — local `_currentUserProfile` copy), upload `stories/{uid}/{millis}.jpg`, add doc. Reuse orphan-cleanup try/catch pattern from createPost.
  - fetchViewedStoryIds: batch existence of `stories/{id}/viewers/{me}` → Set<String> via path derivation (parent.parent.id) — mirror likes.
  - markViewed: set `stories/{id}/viewers/{me}` {} (merge — idempotent re-view).
- Commit: `feat(stories): story models and contracts`

### Task 2: StoriesRepositoryImpl (TDD) + rules deploy

- House Either pattern; streams raw; ~6 tests (pass-throughs + Either folds + empty-ids no-call).
- `firestore.rules`: add stories block — read signedIn; create `request.resource.data.uid == request.auth.uid`; delete owner; viewers subcollection: read signedIn, create self-only.
- NEW `firebase.storage.rules` at root (auth-required read/write all paths — POC-open but not public; ponytail comment re per-folder scoping). firebase.json gains `storage.rules` entry. Deploy BOTH: `firebase deploy --only firestore:rules,storage --project flutter-insta-clone-yofardev`.
- Commit: `feat(stories): repository implementation and rules`

### Task 3: Cubits (TDD)

**StoriesCubit** (`stories_cubit.dart` + state): ctor(repo, {required String myUid}) — subscribes watchStories; on emission: group into trays (`StoryTray` value object: uid, username, avatarUrl, stories List<Story> sorted asc, lastStoryAt) — own tray first, then others by lastStoryAt desc; hydrate viewedIds via fetchViewedStoryIds(all ids) (stale-keep on failure, mirrors feed); state: status loading/ready, trays, viewedIds Set, error. `trayUnviewed(tray)` helper or UI computes. close cancels. isClosed + generation guards.
- Also owns: refresh not needed (live).

**CreateStoryCubit**: pickedPath?, submitting, success, error?. pickImage(source) (maxWidth 1080, quality 70), submit → createStory → fold. Same shape as CreatePostCubit minus caption.

**StoryViewerCubit**: ctor(trays, viewedIds?, initialTrayIndex) — state: trays, trayIndex, storyIndex, viewedIds Set, finished bool. `currentStory` getter. next(): markViewed(current) fire-and-forget; advance storyIndex; wrap → next tray storyIndex 0; past last tray → finished true. previous(): inverse (storyIndex-- ; wrap to prev tray LAST story). markViewed updates viewedIds Set optimistically (UI ring feedback when re-opening). Guards.

Tests: tray grouping/order (own first, recency), viewed hydration failure keeps stale, next/previous wrapping across trays, finished at end, markViewed called per advance + set updated, CreateStory guards/success/failure. ~12 tests.
- Commit: `feat(stories): stories, create, and viewer cubits`

### Task 4: Routes + DI + l10n

- Routes: `createStory = '/create-story'`, `storyViewer = '/story-viewer'` (extra: StoryViewerArgs(trays, initialIndex) — small class; or pass trays + index via extra record; class is cleaner for extra type-guard).
- Router: both top-level root-nav; createStory → BlocProvider(create: CreateStoryCubit factory); storyViewer → extra guard `is! StoryViewerArgs` → not-found scaffold; BlocProvider(create: getIt<StoryViewerCubit>(param1: args)).
- DI: datasource/repo singletons; StoriesCubit registerFactoryParam<String, void>; CreateStoryCubit factory; StoryViewerCubit registerFactoryParam<StoryViewerArgs, void>.
- Feed route builder: add second provider — BlocProvider<StoriesCubit> NESTED inside FeedCubit provider (multi-provider: use MultiBlocProvider or nested — house rule MultiBlocProvider).
- l10n: storiesYourStory "Ton histoire" "Your story", storiesAddToStory "Ajouter à l'histoire" "Add to story", createStoryTitle "Nouvelle histoire" "New story", storiesEmptyTray hint not needed.
- Commit: `feat(stories): routes, di, and strings`

### Task 5: Widgets + screens

- `lib/features/stories/presentation/widgets/story_tray_avatar.dart` — avatar with ring: unviewed (any story not in viewedIds) → colored border (Theme primary / gradient-ish two-tone Border), viewed → grey; own tray gets blue + badge overlay. Radius ~28. onTap callback.
- `lib/features/stories/presentation/widgets/stories_bar.dart` — horizontal ListView of tray avatars + username labels (own: l10n.storiesYourStory), own first with + overlay → onTap: own tray has stories ? open viewer at own index : push createStory. Shown ABOVE posts in feed (feed_screen: Column[StoriesBar, Expanded(posts list)] — restructure feed body carefully keeping existing states).
- `create_story_screen.dart` — mirror create_post_screen minus caption: preview/choose buttons (reuse l10n.postAddPhoto/postTakePhoto), FilledButton l10n.storiesAddToStory → submit; success → pop; submitting spinner.
- `story_viewer_screen.dart` — full-screen black Scaffold:
  - Top: progress segments row (Expanded AnimatedContainers per story in current tray — filled for past, animating for current via Timer-driven double progress... LAZY: use a 5s Timer + TweenAnimationBuilder or just fill segments discretely: past = full, current = animated via AnimationController the screen owns, future = empty)
  - Header: avatar + username + timeAgo (reuse time_ago helper — it's in feed feature widgets... cross-feature presentation import! MOVE `time_ago.dart` → `lib/core/utils/time_ago.dart` now (two features use it), update feed imports)
  - Tap zones: GestureDetector left third → previous(), right two-thirds → next(); restart timer on advance
  - Timer: 5s → next(); cancelled on dispose; finished (cubit) → BlocListener pop
  - markViewed already driven by cubit next()/previous()... viewer also marks the FIRST story on open: cubit ctor marks initial? Add `init()` call from screen initState → markViewed(current). 
- Commit: `feat(stories): stories bar, creation, and viewer screens`

### Task 6: Widget tests + final gate

- stories_bar widget test: trays render (own first + others), unviewed ring color vs viewed, own-empty taps → verify push? (push verification needs router — LAZY: assert callback invocation via injected onTap? StoriesBar takes callbacks per tray — test with real StoriesCubit + stubs, tap own tray → verify navigation is overkill; assert builder state changes if trivially observable. Keep: render + ring assertions + own-first ordering.)
- viewer cubit already unit-tested; screen test light: pump viewer with args, tap right zone → storyIndex advanced (progress segments count/fill changes), finished → pop called (mock NavigationObserver or just verify finished state via cubit).
- flutter analyze + flutter test all green; README tick Phase 4. Commit: `chore: complete phase 4`.

Manual smoke: add story (gallery), ring appears on your bar + viewers see it, viewer auto-advances 5s, tap zones work, viewed ring turns grey after watching, story vanishes after 24h (verify with a backdated doc if keen).

## Deferred

- Story captions/text overlays, replies to stories (Phase 8 territory)
- Server-side TTL cleanup (Cloud Function) + storage lifecycle rules
- Viewed-by list for story owner
- Server "createdAt isGreaterThan" uses subscribe-time cutoff — live expiry boundary slightly stale (documented)
