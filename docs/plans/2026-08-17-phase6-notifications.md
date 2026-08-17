# Phase 6 — Notifications Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers: implement this plan task-by-task via subagent-driven-development.

**Goal:** Notifications feed: "X liked your post", "X commented on your post", "X started following you" with unread badge on the heart/activity tab, marked-read on open.

**Architecture:** New `notifications` feature. Notification docs written at the SOURCE of the event (like toggle, comment add, follow) — no Cloud Functions (client-side fan-out, documented ceiling: a user liking their own post can suppress their own notification client-side, real systems need server-side writes). 5th bottom-nav slot = Activity (heart icon + badges). `NotificationsCubit` = live snapshots + unread count from state (badge = unread > 0). Marked-read = batch field update on open.

**Key decisions (ponytail):**

- **Doc shape**: `notifications/{id}` = {type: 'like'|'comment'|'follow', actorId, actorUsername, actorAvatarUrl?, postId?, postImageUrl?, commentText?, createdAt millis, read bool}. Post thumbnail denormalized (`postImageUrl`) so the list needs zero joins.
- **Writes at event sites**: `toggleLike` (on like, not unlike), `addComment`, `toggleFollow` (on follow, not unfollow) — datasource methods in feed/profile features gain a notification write. Cross-feature: notification doc write duplicated inline in each datasource (~10 lines each, no shared import — same trade as explore's query copy; third consumer → extract).
  Wait — cleaner: `INotificationsDataSource.createNotification(...)` called FROM feed/profile datasources = data-layer cross-feature import of a public contract. Data importing another feature's data interface... house rule bans importing another feature's internals; an interface in domain is the public surface. FEED datasource depending on NOTIFICATIONS datasource interface = data→domain of another feature = same shape as cubit→IProfileRepository. Acceptable. Use DI injection: feed/profile datasources receive `INotificationsDataSource?` optional ctor param? They're const-constructed in DI — make them non-const with injected dep. LAZY FINAL: inline duplicate write (3 call sites × 8 lines), `// ponytail:` comment, extract on 4th consumer. NO new coupling.
- **Self-notification suppression**: skip write when actorId == post/follow owner (client-side; bypassable — noted).
- **Unread badge**: NavigationBar Badge on heart icon — no package, small Stack overlay widget.
- **Read marking**: entering the activity tab marks ALL visible as read (batch update, cap 50). No per-item read tracking UI.
- **Rules**: notifications create = any signed-in (actors write others' notifications); read = owner only; update (markRead) = owner only. Block type/postId spoofing? POC-open, noted.

---

### Task 1: Model + contracts + datasource + event-site writes

1. `lib/features/notifications/domain/models/notification_item.dart` — freezed sealed: id, type (enum NotificationType {like, comment, follow}), actorId, actorUsername, actorAvatarUrl?, postId?, postImageUrl?, commentText?, createdAt, read bool.
2. `lib/features/notifications/data/models/notification_dto.dart` — plain mapper (type string ↔ enum).
3. `lib/features/notifications/domain/repositories/notifications_repository.dart`:

```dart
abstract interface class INotificationsRepository {
  Stream<List<NotificationItem>> watchNotifications({required String uid});
  Future<Either<Failure, void>> markAllRead({required String uid});
  Future<Either<Failure, void>> createNotification({
    required String ownerUid,
    required NotificationType type,
    required String actorId,
    required String actorUsername,
    String? actorAvatarUrl,
    String? postId,
    String? postImageUrl,
    String? commentText,
  });
}
```

(createNotification lives on the repo for TESTS + future server migration; datasources duplicate the raw write.)

4. Datasource: watch (orderBy createdAt desc, limit 50, snapshots), markAllRead (where read == false → batch update read true, cap 50), addNotificationDoc (private raw write).
5. Event-site inline writes:
   - feed datasource `toggleLike`: after transaction success, if !currentlyLiked && post.authorId != _uid → add notifications doc (type like, postImageUrl: post.imageUrl — toggleLike has postId only! Post imageUrl needed — check signature: toggleLike({postId, currentlyLiked}). CHANGE: pass `post.imageUrl` too — adjust IFeedDataSource + IFeedRepository + FeedCubit + PostDetailCubit call sites (they have full Post).
   - feed datasource `addComment`: after transaction, if post owner != me → notification (type comment, commentText).
   - profile datasource `toggleFollow`: after batch, if following → notification (type follow). toggleFollow({uid, currentlyFollowing}) — owner = uid. No post fields.
   - Each site: `// ponytail: inline notification write, extract to shared service on 4th consumer` + try/catch swallow (notification failure must NOT fail the like/comment/follow).
6. Tests: update feed/profile datasource-adjacent tests? Datasources untested (Firebase). Cubit tests: toggleLike now passes imageUrl — update stubs (any(named:) already — check). Model/DTO pure tests: 2 (roundtrip, type mapping).
7. Commit: `feat(notifications): model, contracts, and event-site writes`

### Task 2: NotificationsRepositoryImpl (TDD) + rules

House pattern. watch raw; markAllRead/createNotification Either. ~6 tests.
Rules block:

```
match /notifications/{id} {
  allow read: if signedIn() && resource.data.ownerUid == request.auth.uid;
  // hmm — ownerUid field on doc (add to shape: ownerUid required). Query is where ownerUid == me — rules resource.data check works for get/list when field present.
  allow create: if signedIn();
  allow update, delete: if signedIn() && resource.data.ownerUid == request.auth.uid;
}
```

Add ownerUid to doc shape (datasource write sites + DTO). Deploy firestore rules.
Commit: `feat(notifications): repository implementation and rules`

### Task 3: NotificationsCubit (TDD)

State: status loading/ready, items List<NotificationItem>, unreadCount int (derived emit), error?.
Ctor(repo, {required myUid}) — sub watchNotifications: emit ready + items + unreadCount (where !read length); onError → error. markAllRead() → repo call (fold Left → error; unread resets via snapshot anyway — snapshot updates read flags → unreadCount 0 naturally; no manual reset). isClosed guards, close cancels. clearError.
Tests: live items + unread count, markAllRead success (unread → 0 via re-emitted snapshot), error case. (~4)
Commit: `feat(notifications): notifications cubit`

### Task 4: Routes + DI + l10n + shell badge

- Routes: `activity = '/activity'` (TAB, 5th branch — insert before Profile? Order: home, search, create, heart, profile — Instagram layout).
- DI: datasource/repo singletons; NotificationsCubit registerFactoryParam<String uid, void>.
- Badge widget: `lib/features/notifications/presentation/widgets/badge_icon.dart` — Stack(icon, if count>0 red dot Container top-right). Used in NavigationBar destination icon.
- PROBLEM: NavigationBar destinations are const icons; badge needs the cubit's unread count → the SHELL BUILDER must watch NotificationsCubit. Shell is app-level (single instance for all tabs). Register NotificationsCubit as the SECOND app-scoped cubit? Route-scoped per tab-visit would kill the badge when leaving the tab. DECISION: NotificationsCubit = lazySingleton (app-scoped like AuthCubit), created after auth (needs myUid at creation — PROBLEM: singleton created pre-auth). Options: (a) create on first feed/activity build via factoryParam and keep alive via manual provider at shell level, (b) cubit subscribes lazily — myUid injected at init() called from shell builder post-auth. LAZY: (b) — NotificationsCubit() singleton with `init(uid)` idempotent; shell builder (runs post-auth, redirect guarantees auth) calls getIt<NotificationsCubit>().init(uid) then wraps shell in BlocProvider.value. Badge in NavigationBar icon reads state.unreadCount.
- l10n: activityTitle "Activité" "Activity", notifLikedPost "{user} a aimé ta publication" "{user} liked your post", notifCommentedPost "{user} a commenté : {text}" "{user} commented: {text}", notifStartedFollowing "{user} a commencé à te suivre" "{user} started following you", notifFollow "Suivre" "Follow" (row action), notifEmpty "Aucune activité pour l'instant" "No activity yet".
  NOTE placeholders {user}/{text} — check arb placeholder syntax (the fstr script writes plain strings; placeholders need arb metadata. If fstr can't, hand-edit arb with "placeholders" block per Flutter l10n docs — verify generated getters take args).
- Commit: `feat(notifications): activity tab, badge, di, strings`

### Task 5: Activity screen + tap-throughs

- `activity_screen.dart`: AppBar l10n.activityTitle; BlocBuilder: loading spinner / empty (l10n.notifEmpty) / ListView of notification rows:
  - like/comment: avatar (tap → user profile), TEXT via l10n placeholders, post thumbnail right (tap → post detail — needs full Post! Row only has postId + postImageUrl. Push detail with extra: Post? We lack full post. LAZY: fetch on tap? Simplest: push('/post/id') WITHOUT extra → current detail route requires extra Post. OPTIONS: (a) detail route accepts extra null → fetch by id (add repo method getPostById + cubit path), (b) row thumbnail no-op. Instagram-quality = tap works. Do (a): IFeedRepository.getPostById(postId) → Either<Post>; PostDetailCubit gets optional initialPost param — if null, fetch on init. Moderate; worth it.
  - follow: avatar + text + Follow button? (follow back) — needs follow state per row... YAGNI: text only, avatar tap → profile.
- markAllRead: on screen initState (cubit.markAllRead()).
- PostDetailCubit + repo + datasource changes for fetch-by-id; tests updated (~3 new).
- Commit: `feat(notifications): activity screen and post fetch by id`

### Task 6: Widget tests + final gate + quality review

- activity screen test: rows render (liked/commented/follow fixtures), unread badge dot visible when unreadCount>0 (shell-level too heavy — test BadgeIcon widget in isolation + activity screen with seeded cubit), markAllRead called on mount.
- badge widget test: count 0 → no dot; 3 → dot with '3'.
- flutter analyze + test; README tick Phase 6; commit `chore: complete phase 6`; then consolidated quality review (same pattern).

## Deferred

- Server-side notification writes (Cloud Functions) — client writes are spoofable
- Per-notification read state / seen lists (likes seen-count collapse)
- Push notifications (FCM)
- Notification deletion
