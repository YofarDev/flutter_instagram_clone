#!/usr/bin/env node
// Dummy-data seeder. Doc shapes mirror the app's datasources/DTOs:
//   users: auth_firebase_datasource.dart + UserDto (+ follower/following/post counts)
//   posts (+likes/+comments): PostDto, CommentDto, FeedFirebaseDataSource
//   stories: StoryDto (keys: uid/username/avatarUrl/imageUrl/createdAt)
//   reels (+likes): ReelDto (same key naming as stories)
//   notifications: NotificationDto (type: like|comment|follow, queried by ownerUid)
//   conversations (+messages): ChatFirebaseDataSource (id = sorted uids joined '_')
//   follow edges: ProfileFirebaseDataSource (following/followers, {uid, username, avatarUrl, since})
// Admin SDK bypasses firestore.rules (users create is owner-only) — that's the point.
//
// Usage: node seed.js --me=<yourUid> [--reset] [--bucket=<storageBucket>]
// Re-runs are idempotent: every doc id is deterministic and all writes are merge-sets.

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

const NAMES = ['alice', 'bob', 'chloe', 'dave', 'eve', 'frank'];
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

const BIOS = {
  alice: 'Golden hour chaser 🌅',
  bob: 'Coffee, code, contrasts ☕',
  chloe: 'Streets & frames 📷',
  dave: 'Trail runner. Peak collector ⛰️',
  eve: 'Salt water therapy 🌊',
  frank: 'Analog dreams, digital life',
};

const CAPTIONS = [
  'Rooftop blues before the city woke up #skyline #morning #nofilter',
  'Third espresso, first good idea of the day #coffee #slowliving',
  'She said she would be ready in five minutes #goldenhour #portait #filmisnotdead',
  'Shadows doing all the work here #minimal #shadowplay #monochrome',
  'The harbor at dusk never disappoints #sunset #harbor #vibes',
  'My desk setup finally feels done #setup #devlife #coffee',
  'Crosswalk geometry #streets #patterns #citylife',
  'Rainy window kind of afternoon #rain #mood #cozy',
  'Found this doorway in the old town #doorway #travel #details',
  'Sunrise from the east ridge — worth the alarm #sunrise #hiking #mountains',
  'Switchbacks for days #trail #trailrunning #mountains',
  'Cold plunge after the summit #wildswimming #coldwater #nature',
  'Tide pools at low tide #ocean #tidepools #coastline',
  'Surf report said stay home. Surf report lied #surf #waves #ocean',
  'Beach clean-up haul with the crew #beachcleanup #ocean #community',
  'Fresh roll back from the lab #filmphotography #35mm #analog',
  'Neon and rain, classic combo #neon #nightphotography #rain',
  'Last frame of the trip #travel #filmisnotdead #goodbye',
];

// Each seed user follows exactly 3 others.
const FOLLOW_EDGES = {
  alice: ['bob', 'chloe', 'dave'],
  bob: ['alice', 'chloe', 'eve'],
  chloe: ['alice', 'dave', 'frank'],
  dave: ['alice', 'bob', 'frank'],
  eve: ['chloe', 'dave', 'frank'],
  frank: ['alice', 'chloe', 'eve'],
};
const ME_FOLLOWS = ['alice', 'bob', 'chloe', 'dave']; // --me follows 4 seeds

const COMMENT_TEXTS = ['Love this!', 'Amazing shot 🔥', 'Stunning!'];

// post i (1..18): author = NAMES[floor((i-1)/3)], i-th oldest of 18,
// spread over 18 * 18h ≈ 13.5 days.
const postAuthor = (i) => NAMES[Math.floor((i - 1) / 3)];
const postMillis = (i) => now - (18 - i) * 18 * HOUR;
const postId = (i) => `seed_post_${String(i).padStart(2, '0')}`;
const postLikers = (i) =>
  NAMES.filter((n) => n !== postAuthor(i)).slice(0, ((i - 1) % 4) + 1); // 1..4
const postCommenters = (i) =>
  NAMES.filter((n) => n !== postAuthor(i)).slice(0, i % 3); // 0..2

const REELS = [
  { name: 'alice', file: 'r1', caption: '60 seconds of skyline timelapse #timelapse #skyline', likes: ['bob', 'chloe'], at: now - 1 * DAY },
  { name: 'chloe', file: 'r2', caption: 'Street walk, no talking #streets #cinematic', likes: [], at: now - 2 * DAY },
  { name: 'eve', file: 'r3', caption: 'First wave of the morning #surf #ocean #morning', likes: ['alice', 'bob', 'dave', 'frank'], at: now - 3 * DAY },
];

async function upload(local, dest) {
  const [file] = await bucket.upload(path.join(__dirname, 'assets', local), {
    destination: dest,
  });
  await file.makePublic();
  return publicUrl(dest);
}

async function uploadAssets() {
  console.log('Uploading assets to Storage...');
  const avatarUrls = {};
  await Promise.all(
    NAMES.map(async (n) => {
      avatarUrls[n] = await upload(
        `avatars/${n}.png`,
        `avatars/${uidOf(n)}.jpg`,
      );
    }),
  );

  const postUrls = {};
  await Promise.all(
    Array.from({ length: 18 }, (_, k) => k + 1).map(async (i) => {
      postUrls[i] = await upload(
        `posts/p${String(i).padStart(2, '0')}.jpg`,
        `posts/${uidOf(postAuthor(i))}/${postMillis(i)}.jpg`,
      );
    }),
  );

  const storyUrls = {};
  await Promise.all(
    NAMES.map(async (n, k) => {
      storyUrls[n] = await upload(`stories/s${k + 1}.jpg`, `stories/${uidOf(n)}/${now - (k + 1) * 3 * HOUR}.jpg`);
    }),
  );

  const reelUrls = {};
  await Promise.all(
    REELS.map(async (r) => {
      reelUrls[r.file] = await upload(`reels/${r.file}.mp4`, `reels/${uidOf(r.name)}/${r.at}.mp4`);
    }),
  );
  return { avatarUrls, postUrls, storyUrls, reelUrls };
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

  const batch = db.batch();
  for (let i = 1; i <= 18; i++) {
    const ref = db.collection('posts').doc(postId(i));
    for (const n of NAMES) batch.delete(ref.collection('likes').doc(uidOf(n)));
    for (let k = 0; k < COMMENT_TEXTS.length; k++) {
      batch.delete(ref.collection('comments').doc(`seed_comment_${i}_${k}`));
    }
    batch.delete(ref);
  }
  for (let s = 1; s <= 6; s++) {
    batch.delete(db.collection('stories').doc(`seed_story_${s}`));
  }
  for (let r = 1; r <= 3; r++) {
    const ref = db.collection('reels').doc(`seed_reel_${r}`);
    for (const n of NAMES) batch.delete(ref.collection('likes').doc(uidOf(n)));
    batch.delete(ref);
  }
  for (let k = 1; k <= 5; k++) {
    batch.delete(db.collection('notifications').doc(`seed_notif_${k}`));
  }
  if (me) {
    const conv = db.collection('conversations').doc(convIdFor(me, uidOf('alice')));
    for (let k = 1; k <= 4; k++) {
      batch.delete(conv.collection('messages').doc(`seed_msg_${k}`));
    }
    batch.delete(conv);
  }
  for (const n of NAMES) {
    const userRef = db.collection('users').doc(uidOf(n));
    // ponytail: full subcollection scan per seed user; fine at 6 users
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
  for (const [a, list] of Object.entries(FOLLOW_EDGES)) {
    counts[a].g += list.length;
    for (const b of list) counts[b].f += 1;
  }
  if (me) {
    for (const n of NAMES) counts[n].g += 1; // all seeds follow --me
    for (const n of ME_FOLLOWS) counts[n].f += 1;
  }

  const batch = db.batch();
  const since = now - 5 * DAY;

  // -- users
  for (const n of NAMES) {
    batch.set(
      db.collection('users').doc(uidOf(n)),
      {
        email: `${uidOf(n)}@clone.dev`,
        username: n,
        usernameLower: n,
        bio: BIOS[n],
        avatarUrl: avatarUrls[n],
        followerCount: counts[n].f,
        followingCount: counts[n].g,
        postCount: 3,
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
  for (const [a, list] of Object.entries(FOLLOW_EDGES)) {
    for (const b of list) {
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

  // -- posts + likes + comments (counts = actual subcollection docs)
  for (let i = 1; i <= 18; i++) {
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
        likeCount: postLikers(i).length,
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
        text: COMMENT_TEXTS[k],
        createdAt: postMillis(i) + (k + 1) * HOUR,
      });
    });
  }

  // -- stories (fresh, all within the last 24h)
  NAMES.forEach((n, k) => {
    batch.set(
      db.collection('stories').doc(`seed_story_${k + 1}`),
      {
        uid: uidOf(n),
        username: n,
        avatarUrl: avatarUrls[n],
        imageUrl: storyUrls[n],
        createdAt: now - (k + 1) * 3 * HOUR,
      },
      { merge: true },
    );
  });

  // -- reels + likes
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
        createdAt: r.at,
        likeCount: r.likes.length,
      },
      { merge: true },
    );
    for (const liker of r.likes) {
      batch.set(ref.collection('likes').doc(uidOf(liker)), {}, { merge: true });
    }
  });

  // -- notifications for --me (mix like/comment/follow, some unread)
  if (me) {
    const notifs = [
      { type: 'like', actor: 'alice', postId: postId(18), postImageUrl: postUrls[18], at: now - 10 * MIN, read: false },
      { type: 'comment', actor: 'bob', postId: postId(18), postImageUrl: postUrls[18], commentText: 'This is unreal 🔥', at: now - 1 * HOUR, read: false },
      { type: 'follow', actor: 'chloe', at: now - 3 * HOUR, read: false },
      { type: 'like', actor: 'dave', postId: postId(15), postImageUrl: postUrls[15], at: now - 1 * DAY, read: true },
      { type: 'follow', actor: 'eve', at: now - 2 * DAY, read: true },
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
          postImageUrl: ntf.postImageUrl ?? null,
          commentText: ntf.commentText ?? null,
          createdAt: ntf.at,
          read: ntf.read,
        },
        { merge: true },
      );
    });
  }

  // -- conversation --me <-> alice (+4 alternating messages, deterministic id)
  if (me) {
    const convRef = db
      .collection('conversations')
      .doc(convIdFor(me, uidOf('alice')));
    const messages = [
      { senderId: uidOf('alice'), text: 'Hey! Thanks for the follow 😊', at: now - 16 * MIN },
      { senderId: me, text: 'Hey alice! Loving your feed', at: now - 12 * MIN },
      { senderId: uidOf('alice'), text: 'Haha thanks! Golden hour never misses', at: now - 8 * MIN },
      { senderId: me, text: 'Just saw your story, that beach!', at: now - 4 * MIN },
    ];
    messages.forEach((m, k) => {
      batch.set(
        convRef.collection('messages').doc(`seed_msg_${k + 1}`),
        { senderId: m.senderId, text: m.text, createdAt: m.at },
        { merge: true },
      );
    });
    const last = messages[messages.length - 1];
    batch.set(
      convRef,
      {
        participants: [me, uidOf('alice')].sort(),
        participantMeta: {
          [me]: { username: meProfile.username, avatarUrl: meProfile.avatarUrl },
          [uidOf('alice')]: { username: 'alice', avatarUrl: avatarUrls['alice'] },
        },
        lastMessage: { text: last.text, senderId: last.senderId, createdAt: last.at },
        updatedAt: last.at,
      },
      { merge: true },
    );
  }

  await batch.commit();
  console.log(`Seeded 6 users, 18 posts, 6 stories, 3 reels${me ? ', 5 notifications, 1 conversation' : ''}.`);

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
