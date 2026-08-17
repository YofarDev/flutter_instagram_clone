# Instagram Fidelity Polish — Design

**Date:** 2026-08-17
**Status:** Approved (design sections 1–5)
**Goal:** Make the app indistinguishable in feel from real Instagram — pixel-level visual fidelity, micro-interactions, motion, and the missing IG surfaces. Both dark and light themes. Real data throughout (Firestore + seed).

## Scope decisions (user-locked)

- **Full fidelity**: micro-interactions + pixel-fidelity of existing screens + missing IG surfaces (highlights, saved, suggestions).
- **Both themes** matched to real Instagram.
- **Extend Firestore** (schema + rules + seed) for new surfaces. No client-side fakes.
- Structure: **Hybrid approach C** — foundations first, then phases ordered by visibility.

## Non-goals

- Camera filters/editing, video trimming, Notes, Shop, AI features, algorithmic feed ranking.
- Light-mode-only or dark-mode-only shortcuts — both themes ship matched.
- Categories chips on explore (no category data — skipped rather than faked).

---

## Phase 1 — Foundations + nav shell

### Design tokens (replace `lib/core/theme/app_theme.dart`, both themes)

| Token | Dark | Light |
|---|---|---|
| background | `#000000` | `#FFFFFF` |
| appbar/elevated | `#000000` | `#FAFAFA` |
| input fill | `#262626` | `#EFEFEF` |
| divider | `#262626` | `#DBDBDB` |
| primary text | `#F5F5F5` | `#262626` |
| secondary text | `#A8A8A8` | `#8E8E8E` |
| accent blue | `#0095F6` | `#0095F6` |
| like red | `#FF3040` | `#FF3040` |
| unlike/alert | `#ED4956` | `#ED4956` |

- Typography: system font. Scale: 13 (meta/secondary), 14 (body/captions), 16 (buttons), 22 (stat numbers, semibold), 28 (large titles). Tabular figures on counts.
- Hairline dividers (0.5 logical px).
- `SplashFactory.noSplash` globally — IG uses opacity flashes on icon taps, not Material ripple.

### Custom icon set

`core/widgets/ig_icons.dart` — ~14 CustomPainter paths matching IG geometry: home (outline/filled), search, reels, heart, comment bubble, paper plane, bookmark, plus-square, more-dots, camera, chevron, grid, tagged, mic/send. Stroke weight matched to IG's ~1.8 visual weight.

### Nav shell

- 5 unlabeled destinations: Feed · Search · Create(+) · Reels · Profile.
- Profile tab = user's avatar image with active-state ring (fallback: person icon).
- **Activity leaves the nav bar** → heart icon in feed appbar (right, next to DM plane) with unread badge.
- Tab switch: instant + selection haptic. No Material indicator animation.

### Utilities

- `core/utils/haptics.dart` — `HapticFeedback` wrapper: selection (tab), medium impact (like), light (follow), success (post shared).
- `core/widgets/skeleton/` — shimmer painter + `SkeletonPostCard`, `SkeletonAvatar`, `SkeletonGridTile`, theme-aware.

### Tests

Nav shell widget (5 tabs, avatar tab, heart badge), theme token assertions, skeleton smoke.

---

## Phase 2 — Feed + stories

### PostCard (shared by feed + detail)

- Header: 32px avatar with **gradient story ring when author has live story** (tap → viewer), username semibold + `• 5h` inline secondary, more-dots right.
- **Double-tap image = like + heart burst** (scale + fade + slight rotation, ~600ms). Like button pop animation, fills `#FF3040`.
- **"Liked by alice and 12 others"** — leading avatar stack, bold name, tap → likers list (reuse user-list screen).
- Caption: bold username inline, "more" expand/collapse, hashtags/mentions blue + tappable (→ hashtag screen).
- Action row: heart · comment · share plane (system share sheet) · **bookmark right-aligned → saved posts**.
- Options sheet (more-dots): Save / Copy link / Report / Cancel, grab handle.
- Aspect ratio persisted per post at create time; variable heights, cap 4:5.
- **"New posts" pill** when fresh content exists above viewport.
- Pull-to-refresh (IG spinner) + `SkeletonPostCard` ×2 cold load.
- Feed appbar: wordmark left · heart (badge) + DM plane (badge) right.

### Stories bar + viewer

- Bar: **IG gradient ring** (yellow→orange→pink→purple) unseen / gray `#DBDBDB` seen. Own story: avatar + blue `+` badge, "Your story" 12px.
- Viewer: segmented progress bars, 5s auto-advance, tap left/right third = prev/next, **hold = pause**, X close, header avatar+name+time+more-dots.
- Footer: "Send message" reply field (→ DM thread) + quick heart.
- Own story: viewers count + seen-by list (viewers subcollection exists).

### Schema (phase 2 batch)

- `savedPosts/{uid}_{postId}` + rules.
- `users/{uid}/prefs.lastSeenPostAt` for new-posts pill.
- Seed: extra likers so "Liked by" has faces.

### Tests

Post-card widget states (burst trigger, expand, bookmark), save cubit, ring seen/unseen, viewer timer + gesture zones.

---

## Phase 3 — Reels + explore + activity

### Reels

- Overlay: bottom-left @username bold + **Follow pill** (blue → "Following" gray) · 1-line caption + more · "♫ original audio — @user" row.
- Side rail: heart+count · comment+count · share+count · more-dots · **spinning album disc**.
- Double-tap heart burst (shared component), like pop.
- Mute toggle remembered; precache next reel; pause on visibility.
- `core/utils/format_count.dart`: `1,234 → 1.2K`, `1,234,567 → 1.2M` (feed + activity reuse).

### Explore + search

- Search pill (input-fill token, radius 10, icon + placeholder + clear X), **recents persisted** (shared_preferences).
- Results: account rows (avatar · username bold · fullname · inline follow shortcut) + hashtag rows.
- **Explore mosaic**: 3-col grid where every 5th tile (indices 4, 9, 14, …) spans 2 rows, shimmer skeleton on load.
- Tile tap → fullscreen post detail, swipe-down dismiss.

### Activity

- Sections: **"New" · "This week" · "This month" · "Earlier"**; blue dot unread.
- Row: actor avatar · bold action + time · right slot = post thumbnail or **Follow-back pill**.
- **Cluster collapsing**: same-post likes collapse → stacked avatars + "alice and 3 others liked your post".

### Tests

Reels overlay (burst, follow pill), mosaic pattern, activity grouping cubit, formatCount units.

---

## Phase 4 — Profile + highlights + saved + suggestions

### Profile

- **Sliver appbar collapse** to username row on scroll.
- Header: 86px avatar · stats (22px semibold tabular) · name bold + bio + link · own: "Edit profile" gray full-width · other: **Follow blue pill** → "Message" + "Following" + chevron row.
- **Highlights row**: 64px circles + titles; "New" circle with `+` on own; tap → viewer with highlight title.
- **Tab trio: Grid · Saved (own) · Tagged** — IG custom icons.
- Edit profile: IG grouped-list rows + chevrons, avatar with camera badge.
- Follower/following rows get inline follow pills.

### Highlights model

`highlights/{id}: {uid, title, coverUrl, storyIds[]}`. Stories flip to `archived` instead of delete at expiry. New-highlight flow: pick archived stories → title → cover. Viewer reused.

### Suggestions

- **Feed card inserted after every 5 posts** (max 2 per loaded feed page): horizontal carousel — avatar · name · Follow pill · X dismiss (persisted).
- Ranking: friends-of-friends (mutual count), exclude self/following/hidden; seeded fallback.

### Schema (phase 4 batch)

`highlights`, `taggedPosts`, `hiddenSuggestions`, archived-stories flag. Rules: own-write / public-read patterns like existing. Seed: 2 highlights + 3 tagged posts for alice, denser follow graph.

### Tests

Profile header own/other, highlights row, saved grid cubit, suggestions mutual-count ranking, tagged empty state.

---

## Phase 5 — Chat + transitions + final sweep

### Chat

- List: search pill · rows: avatar · name · last message ("You: " prefix) · time · **unread bold + blue dot**.
- Thread: mine = **blue→purple gradient** bubble · theirs = input-fill · no tails · consecutive grouping · date dividers · their avatar on group-first.
- **Seen receipt** (`seenAt` on open), **double-tap message = heart reaction** (toggle).
- Input bar: camera circle (blue) · gallery thumb · pill field · **mic↔send morph** · send haptic.
- Typing indicator: conversation doc `typingUid`, 3-dot bubble.

### Motion system

`core/router/page_transitions.dart`: push = slide-from-right · modal = slide-from-bottom (create, sheets, new chat) · fullscreen fade (story/reel viewers). 200–300ms ease-out. Tabs instant. Sheets: grab handle + rounded top 12px.

### Sweep + final gate

- Skeletons on every cold list: feed, explore, activity, chat, profile grid.
- Pull-to-refresh on all; IG-style "Couldn't refresh" bar + retry.
- Unified empty states; keyboard/safe-area audit; all strings via `fstr` (fr + en).
- **Re-shoot 10 screenshots × dark + light**, README refresh, `flutter analyze` + full test gate.

### Tests

Bubble grouping + date dividers, reaction toggle, seen-receipt cubit, transition builders smoke, per-screen skeleton presence.

---

## Cross-cutting conventions

- Follows existing feature-based clean architecture (flutter-architecture skill): new features via `fgen`, DI in `service_locator.dart`, routes in `app_router.dart`.
- Every phase: analyze clean + tests green before commit.
- Reused components (heart burst, story ring, skeleton, follow pill) live in `core/widgets/` — built once, used everywhere.
