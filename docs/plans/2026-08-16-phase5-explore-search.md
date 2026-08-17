# Phase 5 — Explore & Search Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Search/Explore tab (4th bottom-nav slot): explore grid of posts from people you DON'T follow, debounced search with user results (username prefix) and hashtag results, hashtag screen with tagged post grid.

**Architecture:** New `explore` feature. `ExploreCubit` mirrors FeedCubit's dual-subscription pattern (posts stream + `IProfileRepository.watchFollowingIds` live) with the filter INVERTED (exclude self + followed). `SearchCubit` = Cubit + internal `Timer` debounce (6 lines vs BLoC event boilerplate — documented). Hashtags: extracted from caption at post creation → `tags` array on post docs (forward-only; existing posts lack tags — noted). Username search: `usernameLower` field on users docs + prefix range scan (Firestore has no substring search). No rules changes needed (posts/users reads already auth-gated).

**Key decisions (ponytail):**

- Explore = same posts query as feed, own datasource copy (~10 duplicated lines keeps features decoupled — comment it), client-side exclusion filter.
- Explore pagination = growing limit, mirrors feed.
- Hashtag tap → grid of `posts where tags array-contains tag` (live stream).
- `usernameLower` written going forward; existing docs need a one-time profile re-save (backfill note in plan, not code).
- Tags normalized: lowercase, `#` stripped, `[a-z0-9_]` only, deduped.
- Search results sections (Accounts / Hashtags) render inline under the field — no separate results route.

---

### Task 1: Tags + usernameLower + explore contracts

1. `lib/core/models/post.dart`: add `@Default(<String>[]) List<String> tags` to Post. `lib/core/models/post_dto.dart`: `tags` field, `fromMap` `((map['tags'] as List<dynamic>?) ?? <dynamic>[]).map((e) => e as String).toList()`, `toMap` includes tags.
2. Feed datasource `createPost`: extract tags from caption (regex `#[a-zA-Z0-9_]+` → normalize lowercase, strip #, dedupe) → include in PostDto. Add a small top-level function `List<String> extractTags(String caption)` in feed datasource file (pure, testable).
3. Auth datasource `saveProfileDoc`: transaction also writes `usernameLower: username.toLowerCase()` alongside the users doc set (derive from data map; keep in sync with username field — same set call, one extra key).
4. `lib/features/explore/domain/repositories/explore_repository.dart` — IExploreRepository:
   - `Stream<List<Post>> watchExplorePosts({required int limit})` (newest first, no filter server-side)
   - `Future<Either<Failure, List<AppUser>>> searchUsers({required String query})` (prefix scan on usernameLower)
   - `Stream<List<Post>> watchPostsByTag({required String tag})` (array-contains, newest first)
5. `lib/features/explore/data/datasources/explore_firebase_datasource.dart` — interface mirror + impl:
   - watchExplorePosts: posts orderBy createdAt desc limit snapshots (duplicated query — `// ponytail: mirrors feed watchFeed; extract shared posts datasource if a third consumer appears`)
   - searchUsers: query.isEmpty → return [] without RPC; `users.where('usernameLower', isGreaterThanOrEqualTo: q).where('usernameLower', isLessThan: '$q\uf8ff').limit(20).get()` → AppUser list (uid = doc.id, email from doc)
   - watchPostsByTag: `posts.where('tags', arrayContains: tag).orderBy('createdAt', descending: true).snapshots()` → posts via PostDto
6. Unit tests for `extractTags` (pure function — the cheap win: normal case, dedupe, none, mixed case).
7. build_runner; analyze; test. Commit: `feat(explore): tags, username search field, and contracts`

### Task 2: ExploreRepositoryImpl (TDD)

House Either pattern; streams raw. ~7 tests (pass-throughs, Either folds both ways, empty-query no-RPC verify). Commit: `feat(explore): repository implementation`

### Task 3: Cubits (TDD)

**ExploreCubit**(feedRepo? NO — exploreRepo, profileRepo, {myUid}): dual subs (posts limit 12 growing + followingIds live), `_visiblePosts` = posts where authorId != myUid && !followingIds.contains (INVERSE of feed). State mirrors FeedState minus likedIds: status loading/ready, posts, hasMore (raw length), error. loadMore, generation guards, isClosed, close cancels both.

**SearchCubit**(exploreRepo): state {query '', users [], tags List<String>, searching bool, error?}. `queryChanged(String)`: emit query; cancel + restart 300ms Timer → `_runSearch(trimmed)`. `_runSearch`: empty → clear users/tags, searching false; else searching true → searchUsers fold (Left → error, searching false; Right → users, searching false). Tags results: derive client-side — LAZY: no distinct-tags collection; tags list comes from... searchUsers doesn't cover tags. Decision: tag suggestions = extract from the query itself when it starts with '#' (search that tag's posts? no — the TAGS SECTION shows other tags? overkill). SIMPLIFY: hashtag search happens via the query starting with '#': when query starts with '#', SearchCubit instead queries watchPostsByTag? That changes the results UI to a grid... Two modes in one cubit = mess. LAZY FINAL: search screen shows Accounts section (username matches) + Hashtag section with ONE row when query is non-empty: `#query` (a "go to hashtag" row, not a list of distinct tags — we can't enumerate distinct tags without a tags collection). Tap → hashtag screen. So SearchCubit only handles users; the hashtag row is static UI derived from query. Update plan accordingly: SearchCubit has NO tags in state.
- `close()` cancels timer. Tests: debounce (fake async — bloc_test with wait; queryChanged twice quickly → ONE searchUsers call after 300ms), empty query clears + no RPC, results set, failure → error.

~10 tests. Commit: `feat(explore): explore and search cubits`

### Task 4: Routes + DI + l10n + shell

- Routes: `search = '/search'` (TAB — 2nd branch), `hashtag = '/hashtag/:tag'` (top-level root-nav push, grid).
- Shell: 4 branches — Feed, Search, Create, Profile (NavigationBar destinations: home, search, add_box, person icons).
- DI: explore datasource/repo singletons; ExploreCubit registerFactoryParam<String uid, void>; SearchCubit factory.
- Search tab builder: MultiBlocProvider(AuthCubit.value not needed — search screen reads AuthCubit? not needed; just ExploreCubit(param1: uid) + SearchCubit).
- Hashtag route: tag from pathParameters; needs a cubit? Simple: BlocProvider<ExploreCubit>? No — hashtag grid is small: use a FutureBuilder/StreamBuilder directly? House pattern = cubit... LAZY but house-consistent: HashtagCubit? Overkill for a read-only grid. Precedent: none. Decision: tiny `HashtagCubit(exploreRepo, tag)` — status/posts/error, sub in ctor, close cancels. +3 tests. (Consistency wins over YAGNI here; it also handles error/loading states for free.)
- l10n: searchHint "Rechercher" "Search", exploreTitle? (tab needs no title), searchAccounts "Comptes" "Accounts", searchHashtags "Hashtags" "Hashtags", searchNoResults "Aucun résultat" "No results", hashtagTitlePrefix handled via '#$tag' AppBar (no key needed).
- Commit: `feat(explore): search tab, hashtag route, di, strings`

### Task 5: Screens

- `search_screen.dart` (THE tab): AppBar-free; Padding Column: search TextField (rounded filled, l10n.searchHint, onChanged → cubit.queryChanged, controller owned+disposed) then Expanded:
  - query empty → BlocBuilder<ExploreCubit> explore grid (GridView 3-col thumbnails like profile grid, tap → post detail extra post; loading spinner; empty → SizedBox)
  - query non-empty → BlocBuilder<SearchCubit>: Accounts section header (l10n.searchAccounts) + user rows (avatar/username → push user profile); Hashtag section: one row `#${query.trim().toLowerCase().replaceFirst('#','')}` with # icon → push hashtag route; searching → thin LinearProgressIndicator; no users → l10n.searchNoResults text.
- `hashtag_screen.dart`: AppBar '#$tag'; BlocBuilder<HashtagCubit>: grid of posts (3-col), tap → detail; loading spinner; empty → SizedBox.
- Route constants helpers: `hashtagPath(String tag)`.
- Wire placeholders → real screens.
- Commit: `feat(explore): search and hashtag screens`

### Task 6: Widget tests + final gate + README tick

- search_screen test: type 'al' → debounce (pump 400ms) → accounts section shows 'alice'; hashtag row shows '#al'.
- explore grid test: stub watchExplorePosts + followingIds → posts from stranger visible, followed/self excluded (assert 1 grid image for 3-post fixture).
- analyze + test all green; README tick Phase 5. Commit: `chore: complete phase 5`.

Then: consolidated quality review (same as prior phases).

## Deferred

- Distinct-tags collection (needs Cloud Function aggregation or client backfill) — hashtag row is query-derived
- Backfill `usernameLower` + `tags` on existing docs (re-save profile / re-create posts, or console script)
- Explore ranking/interleaving (random or engagement-based) — chronological for now
- Recent-searches persistence
