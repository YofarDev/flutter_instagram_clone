# Promo kit

Everything here is copy-paste. Regenerate the banner any time:

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless --disable-gpu --screenshot=banner.png \
  --window-size=1280,640 --hide-scrollbars --force-device-scale-factor=2 \
  "file://$(pwd)/banner.html"
```

## 1. GitHub setup (2 minutes)

- **Social preview**: Settings → General → Social preview → upload `assets/screenshots/banner.png` (2560×1280, under 5 MB ✓)
- **Description**: `Instagram clone written entirely by AI agents — Flutter, Firebase, clean architecture, 270 tests, receipts included`
- **Topics** (Settings → General → Topics): `flutter` `firebase` `instagram-clone` `clean-architecture` `flutter-app` `ai-agents` `vibe-coding` `bloc` `firestore` `llm`

## 2. Show HN

**Title:** Show HN: An Instagram clone where zero lines of Dart were written by a human

I let AI agents (opencode / Claude Code on GLM 5.3) build a full Instagram clone in Flutter — every feature, test and commit came out of agent sessions, one feature slice at a time.

It's not a mockup: real Firebase backend (Auth, Firestore, Storage), real-time following-filtered feed, stories with 24h expiry, reels, image DMs with read receipts, unread badges, share-post-to-DM, story replies. English + French. 270 tests, CI on every push.

The point wasn't the app — it was finding out how far "vibe coding" actually gets you, and leaving receipts you can check instead of claims you have to trust:

- 9 dated implementation plans (~3,000 lines) in docs/plans/, one per feature slice
- 120+ conventional commits in a repeating rhythm: plan → per-layer slices → review pass → phase complete
- The agent rules (AGENTS.md) and 5 custom enforcement skills that kept the architecture honest — including a `ponytail:` comment convention marking every deliberate shortcut with its revisit condition (50+ in the code today)
- Field-level Firestore security rules, a deterministic idempotent seeder, and a test suite that runs with zero Firebase setup

What surprised me: the discipline tooling mattered more than the model. Rules like "cubits never depend on other cubits" and auto-running dart fix on every edit did more for code quality than any prompt.

Try it: README has a 5-minute path (tests run against mocks, no Firebase needed).

## 3. r/FlutterDev

**Title:** I let AI agents write an entire Instagram clone in Flutter (zero hand-written Dart) — here's the architecture that kept it honest

Same body as Show HN, but lead with the Flutter specifics: feature-first clean architecture, freezed + flutter_bloc (cubits), go_router StatefulShellRoute, get_it with a single service_locator.dart, fpdart Either for failures. Then the receipts. Link the repo, not the GIF (subreddit rules — put the GIF in comments if needed).

## 4. X thread (6 tweets)

1. I built an Instagram clone in Flutter without writing a single line of Dart.

   Every feature, test and commit came from AI agent sessions. Real Firebase, not mocks. 🧵

   [attach banner.png]

2. What works end-to-end: real-time feed with optimistic likes, stories with 24h expiry, reels, explore with hashtag search, image DMs — typing indicators, read receipts, unread badges, share-post-to-DM, story replies.

3. The claim is checkable, not vibes:
   — 9 dated plans (~3k lines) in docs/plans/
   — 120+ commits in a repeating rhythm: plan → slices → review → phase complete
   — 270 tests, CI on every push

4. The real lesson: tooling > prompting.

   The agents worked under written rules (AGENTS.md) + 5 custom enforcement skills. "Cubits never depend on cubits" did more for quality than any clever prompt.

5. Every deliberate shortcut is marked inline with `ponytail:` + its revisit condition. 50+ of them. The laziness is documented, not hidden.

6. Repo (MIT, receipts included): github.com/YofarDev/flutter_instagram_clone

   Tests run with zero Firebase setup — 5 minutes from clone to green.

## 5. Order of operations

1. Upload social preview + topics + description (above)
2. Fresh demo GIF: the README GIF predates Hero flights, unread badges, share-to-DM and story replies — `scripts/screenshots.sh`, then re-record
3. Post X thread first (fastest feedback), then Show HN in the morning US time, r/FlutterDev a day later
4. Pin the repo on your profile
