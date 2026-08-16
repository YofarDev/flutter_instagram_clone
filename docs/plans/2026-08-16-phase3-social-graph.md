# Phase 3 — Social Graph Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Follow/unfollow with optimistic UI, profile screens (own + other users) with post grid, followers/following lists, username uniqueness, bottom-nav shell, follows-based feed, Firestore security rules.

**Architecture:** New `profile` feature (social graph + profiles) + edits to `auth` (username claim), `feed` (follows filter + postCount), router (shell). `AppUser` moves to `core/models` (shared business data — auth, profile, feed all need it now).

**Key decisions:**

- **Follow edges denormalized**: `users/{uid}/followers/{fuid}` = `{uid, username, avatarUrl}` and `users/{uid}/following/{tuid}` mirror edge. Batch write + `followerCount`/`followingCount` FieldValue.increment on user docs. List reads = one query, no joins.
- **Username lock**: `usernames/{username}` → `{uid}`. `saveProfile` (auth) becomes transactional: claim/release lock when username changes. Onboarding claims its first lock too.
- **Feed follows filter**: client-side. `watchFeed` stays "all posts"; FeedCubit combines with `watchFollowingIds` (live stream) + own uid → filters. `// ponytail:` documented ceiling (fetches all recent posts, filters locally; server-side whereIn caps at 10 followees). Live snapshots + pagination keep working.
- **Edge docs snapshot at follow time** → stale usernames in lists accepted (POC).
- **Shell**: `StatefulShellRoute.indexedStack`, 3 tabs (Feed / Create / Profile-own). postDetail pushes on ROOT navigator (covers tabs). `/user/:uid` pushes profile-others; `/user/:uid/followers|following` lists; `/profile/edit` modal-ish push.
- **postCount** denormalized on user doc, incremented in `createPost` (P2 datasource edit).
- **Firestore rules**: auth-only reads/writes + ownership rules for users docs + username lock. Deployed via firebase CLI.

---

### Task 1: Shared AppUser + profile models + contracts

1. Move `lib/features/auth/domain/models/app_user.dart` → `lib/core/models/app_user.dart` (update imports across auth feature + tests + service_locator; freezed regen — part file moves too).
2. `lib/features/profile/domain/models/user_profile.dart` — flat freezed: uid, email, username?, bio?, avatarUrl?, followerCount=0, followingCount=0, postCount=0; `factory fromAppUser(AppUser, {int followerCount, int followingCount, int postCount})`.
3. `lib/features/profile/domain/repositories/profile_repository.dart`:

```dart
abstract interface class IProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile({required String uid});
  Stream<List<String>> watchFollowingIds({required String uid});
  Stream<bool> watchIsFollowing({required String uid});
  Future<Either<Failure, void>> toggleFollow({
    required String uid,
    required String username,
    String? avatarUrl,
    required bool currentlyFollowing,
  });
  Future<Either<Failure, List<AppUser>>> fetchFollowers({required String uid});
  Future<Either<Failure, List<AppUser>>> fetchFollowing({required String uid});
  Stream<List<Post>> watchUserPosts({required String uid, required int limit});
}
```

4. `lib/features/profile/data/datasources/profile_firebase_datasource.dart` — IProfileDataSource (same minus Either) + impl:
   - getProfile: users/{uid} get → counts fields (default 0)
   - toggleFollow: batch — following/{me}/{uid} set/delete edge {uid, username, avatarUrl} + followers/{uid}/{me} set/delete edge {me's username/avatar from users doc} + both user docs increment(±1). Current user's username/avatar resolved via users/{me} get before batch (one read).
   - fetchFollowers/fetchFollowing: edge collection orderBy... no ordering field needed — `get()` → map edge docs to AppUser(uid: edgeUid, username: edgeUsername, avatarUrl: edgeAvatar). Edge doc id IS the user's uid.
   - watchFollowingIds / watchIsFollowing: snapshots on edge collections → bool from doc existence (snapshots on a doc: users/{uid}/followers/{me}.snapshots() → exists).
   - watchUserPosts: posts where authorId == uid orderBy createdAt desc limit, reuse PostDto from feed feature? CROSS-FEATURE data import — NO. PostDto lives in feed/data. Profile datasource importing feed's data layer = internal import. LAZY fix: duplicate a minimal post mapper in profile data layer? Or move PostDto to core? Posts are shared business data now. MOVE Post + PostDto: post.dart → core/models/post.dart, post_dto.dart → core/models/post_dto.dart (feed feature imports update). Comment model stays in feed (only feed uses it).
5. build_runner, analyze, test. Commit: `feat(profile): shared models and profile contracts`.

### Task 2: Username uniqueness (auth feature edit)

- AuthFirebaseDataSource.saveProfileDoc → replaced by `saveProfileDocTransactional(uid, data, previousUsername?)`: runTransaction — if username in data != previousUsername: read usernames/{new}; if exists && != uid → throw `UsernameTakenException` (plain class in auth data layer); else set usernames/{new}={uid}, delete usernames/{old} if old != null; set users/{uid} data (merge).
- IAuthRepository.saveProfile signature unchanged; AuthRepositoryImpl maps UsernameTakenException → Failure.serverError('Username is taken') (localized in UI via message match? LAZY: l10n later — keep English message, screens show it raw. No — set message 'username-taken' sentinel? Ugly. POC: message 'Username is taken', fine).
- Datasource needs previousUsername: repo reads current doc first (one read) or AuthCubit passes state.user.username. Repo-side read is simpler: saveProfile impl → fetch current users doc → pass previousUsername.
- Tests: update/extend auth repo tests (mock datasource throw UsernameTakenException → Left('Username is taken')).
- Commit: `feat(auth): username uniqueness via lock collection`.

### Task 3: ProfileRepositoryImpl (TDD)

Mirror house Either pattern. Test all 7 members (success/failure for Futures, pass-through for streams, toggleFollow param mapping). Commit: `feat(profile): repository implementation`.

### Task 4: Three cubits (TDD)

- `ProfileCubit(repo, {required String uid, required bool isMe})` — state: UserProfile? profile, List<Post> posts, isFollowing bool, followerCount mirror for optimistic toggle (or read from profile), status loading/ready, error. Subscribes watchIsFollowing (not-me) + watchUserPosts; loads getProfile. toggleFollow optimistic (count ±1, bool flip) + rollback. loadMore grows limit + resubscribe.
- `EditProfileCubit(authRepo)` — reuse uploadAvatar + saveProfile (IAuthRepository). State: initial AppUser, username/bio/avatarPath fields, submitting, success, error. submit: optional upload → saveProfile(AppUser copyWith).
- `FollowListCubit(repo)` — state: users List<AppUser>, loading, error; `load(uid, mode)` → fetchFollowers/fetchFollowing.
- Tests for each (optimistic toggle with rollback, guards, Either folds). Commit: `feat(profile): profile, edit, and follow list cubits`.

### Task 5: Feed follows filter

- FeedCubit gains `IProfileRepository` + `String myUid` ctor params (registerFactoryParam). Subscribes watchFollowingIds(myUid) → re-filter: posts where authorId == myUid || following.contains(authorId). Emits combined state. loadMore unchanged (raw limit grows).
- State: add `followingIds Set<String>`? Needed for filter only — keep private field, posts already filtered in state. But isLiked-hydration etc unchanged. Update ALL existing FeedCubit tests: new ctor args (stub watchFollowingIds → empty stream / Stream.value({})).
- Router create: `getIt<FeedCubit>(param1: getIt<AuthCubit>().state.user!.uid)`.
- `// ponytail:` client-side filter ceiling comment.
- Commit: `feat(feed): follows-based feed filter`.

### Task 6: Shell + routes + l10n

- rootNavigatorKey; StatefulShellRoute.indexedStack branches: feed '/', create '/create' (as tab), profile '/profile'. postDetail + login/signup/onboarding/splash stay root. New: '/user/:uid', '/user/:uid/followers', '/user/:uid/following', '/profile/edit'. All push routes get parentNavigatorKey: rootNavigatorKey where they must cover tabs (postDetail, user routes, edit).
- DI: profile registrations (datasource/repo singletons; ProfileCubit registerFactoryParam<String uid, bool isMe>? two params → registerFactoryParam<ProfileCubit, ProfileArgs, void> with a tiny `ProfileArgs({uid, isMe})` record/class; EditProfileCubit factory; FollowListCubit factory).
- l10n: profileFollowers/profileFollowing/profilePosts/profileFollow/profileUnfollow/profileEdit/editProfileTitle/profileSave/usernameTaken/followersTitle/followingTitle/editProfileChangePhoto.
- Commit: `feat(profile): navigation shell and routes`.

### Task 7: Screens

- `profile_screen.dart`: BlocBuilder — header (avatar, username, counts row: posts/followers/following — followers/following tappable → lists), bio; Edit button (isMe) → /profile/edit; Follow/Unfollow button (not me, optimistic); grid: GridView.builder 3-col of post thumbnails (Image.network, errorBuilder grey). AppBar username. Logout stays on feed appbar.
- `user_list_screen.dart`: one screen, mode via route path — AppBar title followers/following, ListView of users (avatar, username) + optional Follow toggle per row? LAZY: no per-row follow button (rows navigate to that user's profile) — POC-sufficient.
- `edit_profile_screen.dart`: avatar picker (reuse pattern), username field, bio field, Save → EditProfileCubit.submit; success → pop; 'Username is taken' error surfaced via snackbar.
- PostCard: add `onUsernameTap` callback (nullable) → feed + detail screens wire it to push `/user/${post.authorId}`.
- Wire: profile grid tile tap → post detail push (extra: post).
- Commit: `feat(profile): profile, lists, and edit screens`.

### Task 8: postCount + Firestore rules + deploy

- P2 datasource createPost: users/{uid} update postCount increment(1) (in the same add flow — separate update call OK, or transaction; separate update fine).
- `firestore.rules` at repo root:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() { return request.auth != null; }
    match /users/{uid} {
      allow read: if signedIn();
      allow write: if signedIn() && request.auth.uid == uid;
      match /followers/{fuid} {
        allow read: if signedIn();
        // follower edge written BY the follower
        allow write: if signedIn() && request.auth.uid == fuid;
      }
      match /following/{tuid} {
        allow read: if signedIn();
        allow write: if signedIn() && request.auth.uid == request.resource.data.uid == ... 
      }
    }
    match /usernames/{username} {
      allow read: if signedIn();
      // claim: anyone signed in can create; only owner can change/delete
      allow create: if signedIn() && request.resource.data.uid == request.auth.uid;
      allow update, delete: if signedIn() && resource.data.uid == request.auth.uid;
    }
    match /posts/{pid} {
      allow read: if signedIn();
      allow create: if signedIn() && request.resource.data.authorId == request.auth.uid;
      allow update, delete: if signedIn() && resource.data.authorId == request.auth.uid;
      match /likes/{uid} { allow read, write: if signedIn() && request.auth.uid == uid; }
      match /comments/{cid} {
        allow read: if signedIn();
        allow create: if signedIn() && request.resource.data.authorId == request.auth.uid;
        allow update, delete: if signedIn() && resource.data.authorId == request.auth.uid;
      }
    }
  }
}
```

(following edge rule: written by edge owner: `allow write: if signedIn() && request.auth.uid == tuid`? NO — following/{me}/{target}: the doc lives under users/{me}/following, written by me: path segment = me. So `allow write: if signedIn() && request.auth.uid == uid;` where uid is the parent user. And followers/{uid}/{me}: written by ME = fuid segment: `request.auth.uid == fuid`. BUT the batch also increments counts on users/{target} — counts update violates users write rule (only owner)! Adjust: users doc `allow update` also when... FieldValue.increment server-side ops can't be field-scoped in rules easily. LAZY correct-enough: users write: `if signedIn() && (request.auth.uid == uid || exists(/databases/$(database)/documents/users/$(request.auth.uid)/following/$(uid)))` — i.e. you may update the user doc of someone you follow (only ever used for count increments). Document the hole: a follower could also scribble fields on that doc — POC-accepted, ponytail comment. Cleaner alternative is cloud functions — deferred.)

- firebase.json: add firestore.rules section. Deploy: `firebase deploy --only firestore:rules` (user CLI logged in).
- Commit: `feat: firestore security rules and post counts`.

### Task 9: Widget tests + final gate

- Profile screen widget test: header renders counts; follow tap flips button optimistically (Completer-gated repo).
- User list widget test light. Edit profile validation test (empty username blocked).
- flutter analyze + flutter test all green; README tick Phase 3. Commit: `chore: complete phase 3`.

Manual smoke: follow/unfollow someone (count changes both sides), followers/following lists, other-user profile grid, own profile edit (username change + taken error + avatar), feed only shows followed + own posts, tabs persist state, deep push detail from grid.
