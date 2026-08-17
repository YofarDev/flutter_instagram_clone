# Phase 9 — Polish & Launch Prep Implementation Plan

> **For Claude:** implement task-by-task. Direct execution (visual iteration + small diffs) rather than subagent dispatch.

**Goal:** Instagram look: app icon, wordmark branding, native splash, display name. Seedable dummy data. Screenshot pipeline + GitHub README section.

**Decisions:**

- **Icon**: custom-drawn camera glyph on Instagram-gradient rounded square — generated programmatically (uv + Pillow), not a trademark copy. Android adaptive (gradient background + glyph foreground) + iOS full square.
- **Wordmark**: Grand Hotel (free Billabong-alike, OFL) — used for in-app "Instagram" titles (feed appbar, login) and rendered to PNG for native splash. Downloaded from Google Fonts GitHub.
- **Splash**: `flutter_native_splash` — white bg + dark wordmark (light) / black bg + light wordmark (dark).
- **Dummy data**: `scripts/seed/` — Python generates avatars/posts/stories images (+ ffmpeg reels) into `scripts/seed/assets/`; Node script (firebase-admin, service-account key) uploads to Storage + seeds Firestore. `--me=<uid>` wires the developer's account (follows, notifications, a conversation).
- **Screenshots**: `scripts/screenshots.sh` — adb screencap with countdown prompts as you navigate; output to `assets/screenshots/`. README gains Screenshots + Dummy Data sections.

---

### Task 1: Brand asset generation (uv + Pillow + ffmpeg)

`scripts/seed/gen_assets.py` — writes to `scripts/seed/assets/`:
- `icon_full.png` 1024 (gradient + rounded-square + camera glyph), `icon_fg.png` (glyph, transparent, 66% safe zone), `icon_bg.png` (gradient)
- `wordmark_dark.png` / `wordmark_light.png` (~1600x400, Grand Hotel)
- `avatars/alice..frank.png` 512 (gradient circle + initial)
- `posts/p01..p18.jpg` 1080×1080 abstract art (gradient bands + shapes, varied palettes)
- `stories/s1..s6.jpg` 720×1280
- `reels/r1..r3.mp4` (ffmpeg: animated gradient + drawtext, 6s, 720x1280, h264, silent)

Grand Hotel TTF fetched from Google Fonts GitHub into `assets/fonts/GrandHotel/`.

### Task 2: Icon + splash + wordmark wiring

- `flutter pub add -d flutter_launcher_icons flutter_native_splash` + `flutter pub add google_fonts`? NO — bundle the TTF as asset (offline-safe): add font family in pubspec.
- `flutter_launcher_icons.yaml` + `flutter_native_splash.yaml` → run both generators.
- Display name → "Instagram Clone" (AndroidManifest label + iOS CFBundleDisplayName).
- Feed appbar + login/signup titles → wordmark font widget `core/widgets/wordmark.dart`.

### Task 3: Dummy data seeding

- `scripts/seed/seed.js` (firebase-admin): users (6, fixed uids `seed_*`), profiles w/ usernameLower + bios, avatars→Storage; posts (18, captions with hashtags via same normalization, tags array, likeCount/commentCount + real like/comment docs among seed users); follows (each seed user ↔ others + `--me`); stories (6, fresh timestamps); reels (3); notifications for `--me`; conversation `--me`↔alice + 4 messages. Idempotent: skips docs that exist (or `--reset` to wipe seed_* first).
- README: Dummy Data section (service-account key download, `npm i`, run command).
- `serviceAccount.json` gitignored.

### Task 4: Screenshots + README

- `scripts/screenshots.sh`: countdown → `adb exec-out screencap -p` → `assets/screenshots/NN-name.png` (login, feed, stories-viewer, explore/search, reels, activity, profile, chat…).
- README: Screenshots table + Dummy Data + a short feature/stack blurb refresh.

## Deferred
- Real Billabong licensing (trademark font), CI screenshot automation, App Store icon variations
