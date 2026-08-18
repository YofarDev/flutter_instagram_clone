#!/usr/bin/env node
// Dummy-data seeder. Doc shapes mirror the app's datasources/DTOs:
//   users: auth_firebase_datasource.dart + UserDto (+ follower/following/post counts)
//   posts (+likes/+comments): PostDto, CommentDto, FeedFirebaseDataSource
//   stories: StoryDto (keys: uid/username/avatarUrl/imageUrl/createdAt)
//   reels (+likes): ReelDto (same key naming as stories; audioTitle is extra,
//     ignored by the DTO until the app supports it)
//   notifications: NotificationDto (type: like|comment|follow, queried by ownerUid)
//   conversations (+messages): ChatFirebaseDataSource (id = sorted uids joined '_')
//   follow edges: ProfileFirebaseDataSource (following/followers, {uid, username, avatarUrl, since})
// Admin SDK bypasses firestore.rules (users create is owner-only) — that's the point.
//
// Usage: node seed.js --me=<yourUid> [--reset] [--bucket=<storageBucket>]
// Re-runs are idempotent: every doc id is deterministic and all writes are merge-sets.
//
// Scale: 12 users, 60 posts (5/user), 12 stories, 6 reels, ~12 notifications,
// 4 conversations. All randomness is seeded (mulberry32) so runs are stable.

'use strict';

const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const args = Object.fromEntries(
  process.argv
    .slice(2)
    .map((a) => a.match(/^--([^=]+)(?:=(.*))?$/))
    .filter(Boolean)
    .map((m) => [m[1], m[2] === undefined ? true : m[2]]),
);
const me = typeof args.me === 'string' && args.me ? args.me : null;

const keyPath = path.join(__dirname, 'serviceAccount.json');
if (!fs.existsSync(keyPath)) {
  console.error(
    'Missing scripts/seed/serviceAccount.json — Firebase console > Project settings > Service accounts > Generate new private key.',
  );
  process.exit(1);
}

const serviceAccount = require(keyPath);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  // Newer (post-2024) projects use <projectId>.firebasestorage.app;
  // older ones use <projectId>.appspot.com. Override with --bucket=<name>.
  storageBucket:
    (typeof args.bucket === 'string' && args.bucket) ||
    process.env.STORAGE_BUCKET ||
    `${serviceAccount.project_id}.firebasestorage.app`,
});
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;
const bucket = admin.storage().bucket();

const NAMES = [
  'alice', 'bob', 'chloe', 'dave', 'eve', 'frank',
  'grace', 'henry', 'iris', 'jack', 'kate', 'leo',
];
const uidOf = (n) => `seed_${n}`;
const MIN = 60e3;
const HOUR = 60 * MIN;
const DAY = 24 * HOUR;
const now = Date.now();
const publicUrl = (p) =>
  `https://storage.googleapis.com/${bucket.name}/${p
    .split('/')
    .map(encodeURIComponent)
    .join('/')}`;

// Deterministic conversation id — identical to conversationIdFor() in
// chat_firebase_datasource.dart (lexicographic sort, '_'-joined).
const convIdFor = (a, b) => [a, b].sort().join('_');

// extractTags equivalent for ASCII captions (feed_firebase_datasource.dart):
// '#word' matches, lowercased, deduped, first-occurrence order kept.
const extractTags = (caption) => [
  ...new Set(
    (caption.match(/#([a-zA-Z0-9_]+)/g) || []).map((t) =>
      t.slice(1).toLowerCase(),
    ),
  ),
];

// mulberry32 — tiny seeded PRNG so counts/picks are stable across runs.
const mulberry32 = (seed) => () => {
  seed |= 0;
  seed = (seed + 0x6d2b79f5) | 0;
  let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
};

const BIOS = {
  alice: 'Golden hour chaser 🌅',
  bob: 'Coffee, code, contrasts ☕',
  chloe: 'Streets & frames 📷',
  dave: 'Trail runner. Peak collector ⛰️',
  eve: 'Salt water therapy 🌊',
  frank: 'Analog dreams, digital life',
  grace: 'Designer. Rearranging furniture since forever ✨',
  henry: 'Concrete apologist. Facades & stairwills 🏛️',
  iris: 'Cooking my way through the weekend 🍜',
  jack: 'Carry-on only 🧳 Slow travel, fast trains',
  kate: 'Thrifted fits & sneaker math 👟',
  leo: 'Sourdough attempts, city walks, one good dog 🐕',
};

const FULLNAMES = {
  alice: 'Alice Marchetti',
  bob: 'Bob Nakamura',
  chloe: 'Chloe Dubois',
  dave: 'Dave Lindqvist',
  eve: 'Eve Sandoval',
  frank: 'Frank Okafor',
  grace: 'Grace Lindberg',
  henry: 'Henry Osei',
  iris: 'Iris Petrova',
  jack: 'Jack Moreau',
  kate: 'Kate Ellery',
  leo: 'Leo Rinaldi',
};

// 5 captions per user, in post order (oldest -> newest). post i (1..60):
// author = NAMES[floor((i-1)/5)], caption = CAPTIONS[i-1].
const CAPTIONS_BY_USER = {
  alice: [
    'Golden hour did all the work today #goldenhour #nofilter #sunset',
    'She said five more minutes of light, please #portrait #filmisnotdead #goldenhour',
    'Rooftop blues before the city woke up #skyline #morning #goldenhour',
    'Caught the last light on the water #ocean #sunset #filmphotography',
    'Backlit and unbothered #portrait #goldenhour #shootfilm',
  ],
  bob: [
    'Third espresso, first good idea of the day #coffee #slowliving',
    'Desk setup finally feels done #setup #devlife #coffee #minimal',
    'Single origin, double shot, zero meetings #coffee #foodie #mornings',
    'Debugging by daylight, roasting by night #coffee #devlife',
    'Found the best flat white in town #coffee #cafehopping #foodie',
  ],
  chloe: [
    'Crosswalk geometry #streetstyle #patterns #citylife',
    'Rainy window kind of afternoon #rain #mood #cozy',
    'Neon and puddles, classic combo #neon #nightphotography #rain',
    'Found this doorway in the old town #travel #details #architecture',
    'Sunday walkers, no rush #streetphotography #citylife #slowliving',
  ],
  dave: [
    'Sunrise from the east ridge — worth the alarm #sunrise #hiking #mountains',
    'Switchbacks for days #trail #trailrunning #mountains',
    'Cold plunge after the summit #wildswimming #coldwater #nature',
    'Above the clouds, above the week #hiking #viewfromthetop #mountains',
    'Pack light, go far #ultralight #hiking #adventure',
  ],
  eve: [
    'Surf report said stay home. Surf report lied #surf #waves #ocean',
    'Tide pools at low tide #ocean #tidepools #coastline',
    'Salt water therapy, session two of the day #surf #saltwater #ocean',
    'Board repair day, patience required #surf #diy #beachlife',
    'Glassy at dawn, gone by eight #surf #dawnpatrol #ocean',
  ],
  frank: [
    'Fresh roll back from the lab #filmphotography #35mm #analog',
    'New crate haul: two blue notes and a moody monday #vinyl #records #jazz',
    'Last frame of the trip #travel #filmisnotdead #goodbye',
    'Crate digging is a full-body sport #vinyl #cratedigging #music',
    'Tape hiss and rainy afternoons #analog #music #mood',
  ],
  grace: [
    'New studio corner, finally clutter-free #design #interiors #minimal',
    'Swatches on swatches #design #colors #wip',
    'Sunday reset: one plant at a time #interiors #plants #slowliving',
    'Client work shipped, shelf dusted #design #studio #worklife',
    'Light study for the new space #architecture #light #interiors',
  ],
  henry: [
    'Brutalism appreciators, rise #architecture #brutalism #concrete',
    'Stairs that go somewhere #architecture #minimal #geometry',
    'Facade Friday: terracotta edition #architecture #facade #details',
    'Old library, newer thoughts #architecture #travel #library',
    'Lines meeting at the top #architecture #geometry #sky',
  ],
  iris: [
    'Four-hour broth, four-minute slurp #foodie #ramen #homecooking',
    'Market haul: tomatoes that actually smell like tomatoes #foodie #market #fresh',
    'Poached egg practice, day twelve #foodie #breakfast #foodstyling',
    'Best pastry in the city, fight me #foodie #pastry #brunch',
    'Sunday sauce day #homecooking #foodie #pasta',
  ],
  jack: [
    'Carry-on only, regrets zero #travel #packinglight #airport',
    'Night train south, window seat #travel #train #slowtravel',
    'Layover wander turned into the best photos #travel #streetphotography',
    'Hostel rooftop, someone\'s guitar, zero plans #travel #backpacking #vibes',
    'Home tomorrow, already planning the next one #travel #wanderlust',
  ],
  kate: [
    'Thrifted the whole fit, don\'t tell anyone #streetstyle #thrift #ootd',
    'One coat, three seasons #streetstyle #fashion #minimal',
    'Sneaker rotation, spring cleaning edition #sneakers #streetstyle #fashion',
    'Window shopping is a sport #streetstyle #citylife #fashion',
    'Monochrome monday #ootd #streetstyle #monochrome',
  ],
  leo: [
    'Morning run, city still asleep #running #citylife #sunrise',
    'Weekend baking: sourdough attempt no. 9 #baking #sourdough #homecooking',
    'Best friend insists on the long route #dog #walks #citylife',
    'Espresso and people watching #coffee #foodie #mornings',
    'Rooftop tomatoes are happening #gardening #urbangarden #foodie',
  ],
};
const CAPTIONS = NAMES.flatMap((n) => CAPTIONS_BY_USER[n]);

// Each seed user follows exactly 6 others (ring + chords). Offsets 3/5/7/9 are
// mutual (both directions), giving every user a mutual cluster.
const FOLLOW_OFFSETS = [1, 2, 3, 5, 7, 9];
const followsOf = (n) =>
  FOLLOW_OFFSETS.map(
    (o) => NAMES[(NAMES.indexOf(n) + o) % NAMES.length],
  );
const ME_FOLLOWS = ['alice', 'chloe', 'dave', 'eve', 'iris', 'jack']; // --me follows 6 seeds

const COMMENT_TEXTS = [
  'Love this!', 'Amazing shot 🔥', 'Stunning!', 'This is so good',
  'Colors are perfect', 'Need to go there', 'Saving this', 'Wow 😍',
  'Great eye!', 'Perfect light', 'Okay this is unreal', 'Instant classic',
  'Vibes ✨', 'Bookmarked for inspiration', 'Take me with you next time',
  'Composition is chef\'s kiss',
];

const POSTS_PER_USER = 5;
const POST_COUNT = NAMES.length * POSTS_PER_USER; // 60

// post i (1..60): author = NAMES[floor((i-1)/5)], i-th oldest of 60,
// spread over 59 * 12h ≈ 30 days.
const postAuthor = (i) => NAMES[Math.floor((i - 1) / POSTS_PER_USER)];
const postMillis = (i) => now - (POST_COUNT - i) * 12 * HOUR;
const postSlug = (i) => `insta-${postAuthor(i)}-${((i - 1) % POSTS_PER_USER) + 1}`;
const postId = (i) => `seed_post_${String(i).padStart(2, '0')}`;
// Display like count: seeded random 20–400 (independent of the handful of
// like docs seeded below for the "liked by" state).
const postLikeCount = (i) => 20 + Math.floor(mulberry32(i * 2654435761)() * 381);
// 3–6 actual likers (deterministic), so isLiked-checks and like avatars work.
const postLikers = (i) =>
  NAMES.filter((n) => n !== postAuthor(i))
    .filter((n, k) => k < 3 + ((i * 7) % 4));
// 2–4 commenters (deterministic).
const postCommenters = (i) =>
  NAMES.filter((n) => n !== postAuthor(i))
    .filter((n, k) => k < 2 + (i % 3));
const commentText = (i, k) =>
  COMMENT_TEXTS[Math.floor(mulberry32(i * 97 + k * 13)() * COMMENT_TEXTS.length)];

// 12 stories, created 4h..23.25h ago → each expires within the next ~20h.
const storyMillis = (k) => now - Math.round((4 + k * 1.75) * HOUR); // k = 0..11

const REELS = [
  { name: 'alice', file: 'r1', caption: '60 seconds of skyline timelapse #timelapse #skyline', likes: ['bob', 'chloe', 'dave'], at: now - 1 * DAY },
  { name: 'chloe', file: 'r2', caption: 'Street walk, no talking #streets #cinematic', likes: ['alice', 'kate', 'frank'], at: now - 2 * DAY },
  { name: 'eve', file: 'r3', caption: 'First wave of the morning #surf #ocean #morning', likes: ['alice', 'bob', 'dave', 'frank', 'iris'], at: now - 3 * DAY },
  { name: 'dave', file: 'r4', caption: 'Summit push in 30 seconds #hiking #sunrise #mountains', likes: ['eve', 'jack'], at: now - 4 * DAY },
  { name: 'jack', file: 'r5', caption: '48 hours in Lisbon #travel #cinematic #slowtravel', likes: ['kate', 'alice', 'iris', 'leo'], at: now - 5 * DAY },
  { name: 'kate', file: 'r6', caption: 'Fit check, city edition #streetstyle #fashion #ootd', likes: ['chloe', 'grace'], at: now - 6 * HOUR },
];

const CONVERSATIONS = [
  {
    partner: 'alice',
    messages: [
      { from: 'alice', text: 'Hey! Saw you liked my golden hour shot 😊', at: now - 2 * DAY + 1 * HOUR },
      { from: 'me', text: 'That sky was unreal. Where was it?', at: now - 2 * DAY + 2 * HOUR },
      { from: 'alice', text: 'Rooftop bar downtown, ten minute walk from mine', at: now - 2 * DAY + 3 * HOUR },
      { from: 'me', text: 'Adding it to my list for Friday', at: now - 2 * DAY + 4 * HOUR },
      { from: 'alice', text: 'Go at 7:15, the light is perfect for like ten minutes', at: now - 1 * DAY },
      { from: 'me', text: 'Booking the reminder now lol', at: now - 6 * HOUR },
      { from: 'alice', text: 'Bring the film camera, you will thank me', at: now - 1 * HOUR },
      { from: 'me', text: 'Say less 📷', at: now - 20 * MIN },
    ],
  },
  {
    partner: 'chloe',
    messages: [
      { from: 'chloe', text: 'Your comment on my crosswalk shot made my day', at: now - 2 * DAY + 5 * HOUR },
      { from: 'me', text: 'It\'s a banger, the geometry is perfect', at: now - 2 * DAY + 6 * HOUR },
      { from: 'chloe', text: 'Shot it on the 35mm, half roll left after', at: now - 2 * DAY + 8 * HOUR },
      { from: 'me', text: 'Developed yourself?', at: now - 1 * DAY - 6 * HOUR },
      { from: 'chloe', text: 'Lab around the corner. Too impatient for home dev', at: now - 1 * DAY - 4 * HOUR },
      { from: 'me', text: 'Fair. Send the rest of the roll when it\'s back', at: now - 5 * HOUR },
    ],
  },
  {
    partner: 'eve',
    messages: [
      { from: 'eve', text: 'Morning! Surf looks clean tomorrow', at: now - 2 * DAY + 2 * HOUR },
      { from: 'me', text: 'Size?', at: now - 2 * DAY + 2 * HOUR + 10 * MIN },
      { from: 'eve', text: 'Chest high, light offshore wind', at: now - 2 * DAY + 3 * HOUR },
      { from: 'me', text: 'I\'m in. What time?', at: now - 2 * DAY + 3 * HOUR + 30 * MIN },
      { from: 'eve', text: '6:30, before the crowd', at: now - 2 * DAY + 4 * HOUR },
      { from: 'me', text: 'Painful but fine. Coffee after?', at: now - 2 * DAY + 5 * HOUR },
      { from: 'eve', text: 'Obviously. New place near the pier', at: now - 2 * DAY + 6 * HOUR },
      { from: 'me', text: 'The one with the sourdough?', at: now - 1 * DAY - 10 * HOUR },
      { from: 'eve', text: 'That\'s the one 🥐', at: now - 1 * DAY - 8 * HOUR },
      { from: 'me', text: 'Sold. See you at 6:15', at: now - 1 * DAY - 7 * HOUR },
    ],
  },
  {
    partner: 'iris',
    messages: [
      { from: 'iris', text: 'Made your ramen recipe last night', at: now - 2 * DAY + 9 * HOUR },
      { from: 'me', text: 'And? Be honest', at: now - 2 * DAY + 10 * HOUR },
      { from: 'iris', text: 'Restaurant level. The broth especially', at: now - 2 * DAY + 11 * HOUR },
      { from: 'me', text: 'It\'s all in the simmer time', at: now - 1 * DAY - 12 * HOUR },
      { from: 'iris', text: 'Four hours was worth it apparently', at: now - 1 * DAY - 11 * HOUR },
      { from: 'me', text: 'Next time add the charred garlic oil', at: now - 1 * DAY - 10 * HOUR },
      { from: 'iris', text: 'Documenting that for the weekend, thanks!', at: now - 1 * DAY - 9 * HOUR },
    ],
  },
];

async function upload(local, dest) {
  const [file] = await bucket.upload(path.join(__dirname, 'assets', local), {
    destination: dest,
  });
  await file.makePublic();
  return publicUrl(dest);
}

// Promise.all over 90 uploads can trip rate limits; run ~8 at a time.
async function mapLimit(items, limit, fn) {
  const out = new Array(items.length);
  let next = 0;
  const workers = Array.from({ length: Math.min(limit, items.length) }, async () => {
    while (next < items.length) {
      const k = next++;
      out[k] = await fn(items[k], k);
    }
  });
  await Promise.all(workers);
  return out;
}

async function uploadAssets() {
  console.log('Uploading assets to Storage...');
  const avatarUrls = {};
  await mapLimit(NAMES, 8, async (n) => {
    avatarUrls[n] = await upload(`avatars/${n}.jpg`, `avatars/${uidOf(n)}.jpg`);
  });

  const postUrls = {};
  await mapLimit(
    Array.from({ length: POST_COUNT }, (_, k) => k + 1),
    8,
    async (i) => {
      postUrls[i] = await upload(
        `posts/${postSlug(i)}.jpg`,
        `posts/${uidOf(postAuthor(i))}/${postMillis(i)}.jpg`,
      );
    },
  );

  const storyUrls = {};
  await mapLimit(NAMES, 8, async (n, k) => {
    storyUrls[n] = await upload(
      `stories/story-${n}-1.jpg`,
      `stories/${uidOf(n)}/${storyMillis(k)}.jpg`,
    );
  });

  const reelUrls = {};
  await mapLimit(REELS, 8, async (r) => {
    reelUrls[r.file] = await upload(`reels/${r.file}.mp4`, `reels/${uidOf(r.name)}/${r.at}.mp4`);
  });
  return { avatarUrls, postUrls, storyUrls, reelUrls };
}

// Firestore batches cap at 500 ops — auto-chunk queued writes/deletes.
class ChunkedBatch {
  constructor() {
    this.ops = []; // { kind, ref, data?, opts? }
  }

  set(ref, data, opts) {
    this.ops.push({ kind: 'set', ref, data, opts });
  }

  delete(ref) {
    this.ops.push({ kind: 'delete', ref });
  }

  async commit() {
    for (let k = 0; k < this.ops.length; k += 400) {
      const b = db.batch();
      for (const op of this.ops.slice(k, k + 400)) {
        if (op.kind === 'set') b.set(op.ref, op.data, op.opts);
        else b.delete(op.ref);
      }
      await b.commit();
    }
  }
}

// Count existing seed_* follow edges under --me's doc so count fixes are
// net-zero on re-runs (reset deletes them first, so count is 0 afterwards).
async function countSeedEdgesUnderMe() {
  if (!me) return { followers: 0, following: 0 };
  const [f, g] = await Promise.all([
    db.collection('users').doc(me).collection('followers').get(),
    db.collection('users').doc(me).collection('following').get(),
  ]);
  return {
    followers: f.docs.filter((d) => d.id.startsWith('seed_')).length,
    following: g.docs.filter((d) => d.id.startsWith('seed_')).length,
  };
}

async function reset() {
  console.log('Resetting previously seeded data...');
  const { followers, following } = await countSeedEdgesUnderMe();
  if (me && (followers || following)) {
    await db
      .collection('users')
      .doc(me)
      .set(
        {
          followerCount: FieldValue.increment(-followers),
          followingCount: FieldValue.increment(-following),
        },
        { merge: true },
      );
  }

  const batch = new ChunkedBatch();
  for (let i = 1; i <= POST_COUNT; i++) {
    const ref = db.collection('posts').doc(postId(i));
    for (const n of NAMES) batch.delete(ref.collection('likes').doc(uidOf(n)));
    for (let k = 0; k < 4; k++) {
      batch.delete(ref.collection('comments').doc(`seed_comment_${i}_${k}`));
    }
    batch.delete(ref);
  }
  for (let s = 1; s <= 12; s++) {
    batch.delete(db.collection('stories').doc(`seed_story_${s}`));
  }
  for (let r = 1; r <= REELS.length; r++) {
    const ref = db.collection('reels').doc(`seed_reel_${r}`);
    for (const n of NAMES) batch.delete(ref.collection('likes').doc(uidOf(n)));
    batch.delete(ref);
  }
  for (let k = 1; k <= 12; k++) {
    batch.delete(db.collection('notifications').doc(`seed_notif_${k}`));
  }
  if (me) {
    for (const c of CONVERSATIONS) {
      const conv = db.collection('conversations').doc(convIdFor(me, uidOf(c.partner)));
      for (let k = 1; k <= 10; k++) {
        batch.delete(conv.collection('messages').doc(`seed_msg_${k}`));
      }
      batch.delete(conv);
    }
  }
  for (const n of NAMES) {
    const userRef = db.collection('users').doc(uidOf(n));
    // full subcollection scan per seed user; fine at 12 users
    for (const coll of ['following', 'followers']) {
      const snap = await userRef.collection(coll).get();
      snap.forEach((d) => batch.delete(d.ref));
    }
    batch.delete(userRef);
  }
  await batch.commit();
  console.log('Reset done.');
}

async function seed({ avatarUrls, postUrls, storyUrls, reelUrls }) {
  let meProfile = { username: 'you', avatarUrl: null };
  if (me) {
    const snap = await db.collection('users').doc(me).get();
    const data = snap.data() || {};
    meProfile = {
      username: data.username || 'you',
      avatarUrl: data.avatarUrl ?? null,
    };
  }

  // Follower/following counts derived from the actual edge set below.
  const counts = Object.fromEntries(NAMES.map((n) => [n, { f: 0, g: 0 }]));
  for (const a of NAMES) {
    const list = followsOf(a);
    counts[a].g += list.length;
    for (const b of list) counts[b].f += 1;
  }
  if (me) {
    for (const n of NAMES) counts[n].g += 1; // all seeds follow --me
    for (const n of ME_FOLLOWS) counts[n].f += 1;
  }

  const batch = new ChunkedBatch();
  const since = now - 5 * DAY;

  // -- users
  for (const n of NAMES) {
    batch.set(
      db.collection('users').doc(uidOf(n)),
      {
        email: `${uidOf(n)}@clone.dev`,
        username: n,
        usernameLower: n,
        fullName: FULLNAMES[n],
        bio: BIOS[n],
        avatarUrl: avatarUrls[n],
        followerCount: counts[n].f,
        followingCount: counts[n].g,
        postCount: POSTS_PER_USER,
      },
      { merge: true },
    );
  }

  // -- follow edges (both directions, same shape as toggleFollow)
  const edge = (owner, coll, otherId, otherName, otherAvatar) =>
    batch.set(
      db.collection('users').doc(owner).collection(coll).doc(otherId),
      { uid: otherId, username: otherName, avatarUrl: otherAvatar, since },
      { merge: true },
    );
  for (const a of NAMES) {
    for (const b of followsOf(a)) {
      edge(uidOf(a), 'following', uidOf(b), b, avatarUrls[b]);
      edge(uidOf(b), 'followers', uidOf(a), a, avatarUrls[a]);
    }
  }
  if (me) {
    for (const n of NAMES) {
      edge(uidOf(n), 'following', me, meProfile.username, meProfile.avatarUrl);
      edge(me, 'followers', uidOf(n), n, avatarUrls[n]);
    }
    for (const n of ME_FOLLOWS) {
      edge(me, 'following', uidOf(n), n, avatarUrls[n]);
      edge(uidOf(n), 'followers', me, meProfile.username, meProfile.avatarUrl);
    }
  }

  // -- posts + likes + comments
  //    commentCount = actual comment docs; likeCount = seeded 20–400 display
  //    number (a few like docs are also seeded for isLiked checks).
  for (let i = 1; i <= POST_COUNT; i++) {
    const author = postAuthor(i);
    const ref = db.collection('posts').doc(postId(i));
    batch.set(
      ref,
      {
        authorId: uidOf(author),
        authorUsername: author,
        authorAvatarUrl: avatarUrls[author],
        imageUrl: postUrls[i],
        caption: CAPTIONS[i - 1],
        createdAt: postMillis(i),
        likeCount: postLikeCount(i),
        commentCount: postCommenters(i).length,
        tags: extractTags(CAPTIONS[i - 1]),
      },
      { merge: true },
    );
    for (const liker of postLikers(i)) {
      batch.set(ref.collection('likes').doc(uidOf(liker)), {}, { merge: true });
    }
    postCommenters(i).forEach((c, k) => {
      batch.set(ref.collection('comments').doc(`seed_comment_${i}_${k}`), {
        authorId: uidOf(c),
        authorUsername: c,
        text: commentText(i, k),
        createdAt: postMillis(i) + (k + 1) * HOUR,
      });
    });
  }

  // -- stories (created 4–23h ago → expire over the next ~20h)
  NAMES.forEach((n, k) => {
    batch.set(
      db.collection('stories').doc(`seed_story_${k + 1}`),
      {
        uid: uidOf(n),
        username: n,
        avatarUrl: avatarUrls[n],
        imageUrl: storyUrls[n],
        createdAt: storyMillis(k),
      },
      { merge: true },
    );
  });

  // -- reels + likes (+ audioTitle for when the app surfaces it)
  REELS.forEach((r, k) => {
    const ref = db.collection('reels').doc(`seed_reel_${k + 1}`);
    batch.set(
      ref,
      {
        uid: uidOf(r.name),
        username: r.name,
        avatarUrl: avatarUrls[r.name],
        videoUrl: reelUrls[r.file],
        caption: r.caption,
        audioTitle: `original audio — @${r.name}`,
        createdAt: r.at,
        likeCount: r.likes.length,
      },
      { merge: true },
    );
    for (const liker of r.likes) {
      batch.set(ref.collection('likes').doc(uidOf(liker)), {}, { merge: true });
    }
  });

  // -- notifications for --me (mix like/comment/follow referencing real posts)
  if (me) {
    const notifs = [
      { type: 'like', actor: 'alice', postId: postId(60), at: now - 10 * MIN, read: false },
      { type: 'comment', actor: 'bob', postId: postId(60), commentText: 'This is unreal 🔥', at: now - 30 * MIN, read: false },
      { type: 'follow', actor: 'chloe', at: now - 2 * HOUR, read: false },
      { type: 'like', actor: 'dave', postId: postId(55), at: now - 5 * HOUR, read: false },
      { type: 'comment', actor: 'eve', postId: postId(52), commentText: 'Take me next time!', at: now - 8 * HOUR, read: true },
      { type: 'like', actor: 'frank', postId: postId(48), at: now - 12 * HOUR, read: true },
      { type: 'follow', actor: 'grace', at: now - 1 * DAY, read: true },
      { type: 'like', actor: 'henry', postId: postId(45), at: now - 28 * HOUR, read: true },
      { type: 'comment', actor: 'iris', postId: postId(42), commentText: 'Recipe please 🙏', at: now - 36 * HOUR, read: true },
      { type: 'like', actor: 'jack', postId: postId(38), at: now - 44 * HOUR, read: true },
      { type: 'follow', actor: 'kate', at: now - 60 * HOUR, read: true },
      { type: 'like', actor: 'leo', postId: postId(33), at: now - 3 * DAY, read: true },
    ];
    notifs.forEach((ntf, k) => {
      batch.set(
        db.collection('notifications').doc(`seed_notif_${k + 1}`),
        {
          ownerUid: me,
          type: ntf.type,
          actorId: uidOf(ntf.actor),
          actorUsername: ntf.actor,
          actorAvatarUrl: avatarUrls[ntf.actor],
          postId: ntf.postId ?? null,
          postImageUrl: ntf.postId ? postUrls[Number(ntf.postId.split('_').pop())] ?? null : null,
          commentText: ntf.commentText ?? null,
          createdAt: ntf.at,
          read: ntf.read,
        },
        { merge: true },
      );
    });
  }

  // -- conversations --me <-> seed partner (+ messages, deterministic ids)
  if (me) {
    for (const c of CONVERSATIONS) {
      const convRef = db.collection('conversations').doc(convIdFor(me, uidOf(c.partner)));
      const senderOf = (from) => (from === 'me' ? me : uidOf(c.partner));
      c.messages.forEach((m, k) => {
        batch.set(
          convRef.collection('messages').doc(`seed_msg_${k + 1}`),
          { senderId: senderOf(m.from), text: m.text, createdAt: m.at },
          { merge: true },
        );
      });
      const last = c.messages[c.messages.length - 1];
      batch.set(
        convRef,
        {
          participants: [me, uidOf(c.partner)].sort(),
          participantMeta: {
            [me]: { username: meProfile.username, avatarUrl: meProfile.avatarUrl },
            [uidOf(c.partner)]: { username: c.partner, avatarUrl: avatarUrls[c.partner] },
          },
          lastMessage: { text: last.text, senderId: senderOf(last.from), createdAt: last.at },
          updatedAt: last.at,
        },
        { merge: true },
      );
    }
  }

  await batch.commit();
  const commentTotal = Array.from({ length: POST_COUNT }, (_, k) => k + 1)
    .reduce((sum, i) => sum + postCommenters(i).length, 0);
  console.log(
    `Seeded ${NAMES.length} users, ${POST_COUNT} posts (${commentTotal} comments), 12 stories, ${REELS.length} reels` +
      `${me ? `, 12 notifications, ${CONVERSATIONS.length} conversations` : ''}.`,
  );
  console.log('Sample post media URL:', postUrls[POST_COUNT]);

  // Net-zero count fix for --me's real doc (re-runs don't inflate).
  if (me) {
    const existing = await countSeedEdgesUnderMe();
    await db
      .collection('users')
      .doc(me)
      .set(
        {
          followerCount: FieldValue.increment(NAMES.length - existing.followers),
          followingCount: FieldValue.increment(ME_FOLLOWS.length - existing.following),
        },
        { merge: true },
      );
  }
}

(async () => {
  try {
    if (args.reset) await reset();
    else if (!me) {
      console.log('Nothing to do — pass --me=<yourUid> to seed (and/or --reset).');
      return;
    }
    const urls = await uploadAssets();
    await seed(urls);
    console.log('Done.');
  } catch (e) {
    console.error('Seed failed:', e);
    if (String(e.message || e).includes('does not exist')) {
      console.error('Hint: wrong Storage bucket — try --bucket=<projectId>.firebasestorage.app');
    }
    process.exitCode = 1;
  } finally {
    process.exit();
  }
})();
