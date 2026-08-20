# Seed expansion report

Date: 2026-08-18 · Branch: `feat/ig-fidelity-phase1` · Commit: `6cb84f3` (this file not committed)

## What changed

### `gen_assets.py`
- Icon/wordmark generation untouched.
- Dummy media now downloaded (was: procedural PIL), cached into `scripts/seed/assets/` — re-runs skip existing files (verified: second run did zero downloads, 125 files listed).
- Downloads via `urllib.request` with a browser User-Agent, one retry per URL, PIL fallback per slot on final failure (legacy generators kept: gradient avatar, `art_image` post, gradient story, `two_stop` reel frame). Fallbacks used this run: **0** (all downloads succeeded).
- Deterministic slugs:
  - Avatars: `https://i.pravatar.cc/300?img=N`, N ∈ {1,3,5,7,8,9,10,11,12,13,15,16} (spot-checked: resolve) → `avatars/<name>.jpg` (12)
  - Posts: `https://picsum.photos/seed/insta-<user>-<i>/1080/<H>`, H cycling 1350/1080/810 (4:5 / 1:1 / 16:9) → `posts/insta-<user>-<i>.jpg` (60 = 12 users × 5)
  - Stories: `https://picsum.photos/seed/story-<user>-1/1080/1920` → `stories/story-<user>-1.jpg` (12)
  - Reels: 5 frames each `https://picsum.photos/seed/reel-<n>-<f>/720/1280` (`reels/frames/`), stitched with the same `subprocess.run(ffmpeg, check=True)` style: `-framerate 5/6` (5 frames ≈ 6 s), `libx264`, `yuv420p`, `-an` → `reels/r1..r6.mp4` (verified duration: 6.000 s)
- Stale procedural media (p01..18.jpg, s1..6.jpg, *.png avatars, r1..3.mp4) deleted from assets before regen.

### `seed.js`
- 12 users (added grace, henry, iris, jack, kate, leo) with new bios + `fullName` (extra field; UserDto ignores unknown keys). uids stay `seed_<name>`.
- 60 posts (5/user), 60 hand-written themed captions with varied hashtags (#goldenhour #coffee #streetstyle #hiking #design #foodie #travel #surf #vinyl #architecture ...), createdAt spread 12 h apart over ~30 days.
- Comments: 2–4 per post from other users (deterministic pick, seeded text from a 16-entry pool) — **180 total**; `commentCount` = actual comment docs.
- Like docs: 3–6 seeded likers per post (app reads `likes/{uid}` for isLiked state); `likeCount` = seeded random 20–400 (mulberry32, stable across runs) per approved design — note this intentionally diverges from the like-doc count.
- Stories: 12, created 4 h → 23.25 h ago → each expires within the next ~20 h (app cutoff: createdAt > now−24 h).
- Reels: 6 (alice, chloe, dave, eve, jack, kate) with captions + `audioTitle: "original audio — @<user>"` (extra field, DTO ignores it until supported) and 2–5 like docs.
- Follows: each user follows exactly 6 (ring offsets {1,2,3,5,7,9}); offsets 3/5/7/9 are mutual → mutual clusters. `followerCount`/`followingCount` derived from actual edge docs (verified: seed_leo following 7 = 6 seeds + me; seed_alice followers 7 = 6 seeds + me).
- Notifications: 12 for `--me` (4 unread), mix like/comment/follow referencing real seeded posts.
- Conversations: 4 threads (--me + alice/chloe/eve/iris), 8/6/10/7 messages of realistic back-and-forth over the last 2 days.
- `--reset` extended: 60 posts × (likes for 12 names + 4 comments + post), 12 stories, 6 reels + likes, 12 notifications, 4 conversations × 10 messages, full follow-edge subcollection scans for 12 users. All writes/deletes now go through a `ChunkedBatch` (400-op chunks) because the seed batch exceeds Firestore's 500-op limit.
- Uploads concurrency-limited to 8 (was unbounded `Promise.all` over 90 uploads).
- `--me` wiring unchanged; net-zero count fix for --me's real user doc preserved.

## Verification (end-to-end)

1. `python3 scripts/seed/gen_assets.py` → `generated 125 files`, zero fallbacks, cache-stable re-run.
2. `node seed.js --reset --me=umWQI7IW02ZMbofqkL3kTZEHy222` →
   `Seeded 12 users, 60 posts (180 comments), 12 stories, 6 reels, 12 notifications, 4 conversations.` then `Done.`
3. Firestore spot-check (admin SDK): posts 60, stories 12, reels 6, notifications 12, conversations 4, post_01 comments 3, follow counts consistent.
4. Public URLs (curl -I → 200):
   - Post: https://storage.googleapis.com/flutter-insta-clone-yofardev.firebasestorage.app/posts/seed_leo/1787044383039.jpg
   - Avatar: https://storage.googleapis.com/flutter-insta-clone-yofardev.firebasestorage.app/avatars/seed_alice.jpg
   - Reel: https://storage.googleapis.com/flutter-insta-clone-yofardev.firebasestorage.app/reels/seed_alice/1786957983039.mp4

## Concerns / notes

- `likeCount` (20–400, seeded) intentionally does not match the number of like docs (3–6) — per approved design; the app's like toggle increments `likeCount`, so the display stays consistent going forward.
- Old storage objects from the previous 18-post seed (paths under `posts/seed_*/…` with old timestamps) are not deleted by `--reset` (docs are; orphaned blobs remain, harmless).
- picsum.photos rejects HEAD requests (405) — GET works; the Python downloader uses GET.
