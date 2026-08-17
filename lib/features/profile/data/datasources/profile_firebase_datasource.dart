import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/models/post.dart';
import '../../../../core/models/post_dto.dart';
import '../../domain/models/user_profile.dart';

abstract interface class IProfileDataSource {
  Future<UserProfile> getProfile({required String uid});
  Stream<List<String>> watchFollowingIds({required String uid});
  Stream<bool> watchIsFollowing({required String uid});
  Future<void> toggleFollow({
    required String uid,
    required bool currentlyFollowing,
  });
  Future<List<AppUser>> fetchFollowers({required String uid});
  Future<List<AppUser>> fetchFollowing({required String uid});
  Stream<List<Post>> watchUserPosts({required String uid, required int limit});
}

class ProfileFirebaseDataSource implements IProfileDataSource {
  const ProfileFirebaseDataSource();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Future<Map<String, dynamic>> _userDoc(String uid) async {
    final DocumentSnapshot<Object?> snap =
        await _db.collection('users').doc(uid).get();
    return snap.data() as Map<String, dynamic>? ?? <String, dynamic>{};
  }

  @override
  Future<UserProfile> getProfile({required String uid}) async {
    final DocumentSnapshot<Object?> snap =
        await _db.collection('users').doc(uid).get();
    if (!snap.exists) throw StateError('Profile not found');
    final Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    return UserProfile(
      uid: snap.id,
      email: data['email'] as String? ?? '',
      username: data['username'] as String?,
      bio: data['bio'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
      followerCount: data['followerCount'] as int? ?? 0,
      followingCount: data['followingCount'] as int? ?? 0,
      postCount: data['postCount'] as int? ?? 0,
    );
  }

  @override
  Future<void> toggleFollow({
    required String uid,
    required bool currentlyFollowing,
  }) async {
    // mine feeds the follower edge, theirs feeds the following edge
    // (following edge must show the followed user's name/avatar)
    final List<Map<String, dynamic>> docs = await Future.wait(
      <Future<Map<String, dynamic>>>[_userDoc(_uid), _userDoc(uid)],
    );
    final Map<String, dynamic> mine = docs[0];
    final Map<String, dynamic> theirs = docs[1];
    final int since = DateTime.now().millisecondsSinceEpoch;
    final WriteBatch batch = _db.batch();
    final DocumentReference<Object?> followingEdge =
        _db.collection('users').doc(_uid).collection('following').doc(uid);
    final DocumentReference<Object?> followerEdge =
        _db.collection('users').doc(uid).collection('followers').doc(_uid);
    if (currentlyFollowing) {
      batch.delete(followingEdge);
      batch.delete(followerEdge);
      batch.update(_db.collection('users').doc(_uid),
          <String, dynamic>{'followingCount': FieldValue.increment(-1)});
      batch.update(_db.collection('users').doc(uid),
          <String, dynamic>{'followerCount': FieldValue.increment(-1)});
    } else {
      batch.set(followingEdge, <String, dynamic>{
        'uid': uid,
        'username': theirs['username'],
        'avatarUrl': theirs['avatarUrl'],
        'since': since,
      });
      batch.set(followerEdge, <String, dynamic>{
        'uid': _uid,
        'username': mine['username'],
        'avatarUrl': mine['avatarUrl'],
        'since': since,
      });
      batch.update(_db.collection('users').doc(_uid),
          <String, dynamic>{'followingCount': FieldValue.increment(1)});
      batch.update(_db.collection('users').doc(uid),
          <String, dynamic>{'followerCount': FieldValue.increment(1)});
    }
    await batch.commit();
    if (!currentlyFollowing && uid != _uid) {
      unawaited(_notifyFollow(ownerUid: uid, mine: mine));
    }
  }

  // ponytail: inline notification write, extract on 4th consumer
  Future<void> _notifyFollow({
    required String ownerUid,
    required Map<String, dynamic> mine,
  }) async {
    try {
      await _db.collection('notifications').add(<String, dynamic>{
        'ownerUid': ownerUid,
        'type': 'follow',
        'actorId': _uid,
        'actorUsername': mine['username'] as String? ?? '?',
        'actorAvatarUrl': mine['avatarUrl'],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'read': false,
      });
    } catch (_) {
      // notification drop must not fail the follow
    }
  }

  // ponytail: edge docs carry no email — '' placeholder, screens show
  // username+avatar only
  AppUser _edgeToUser(QueryDocumentSnapshot<Object?> doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: '',
      username: data['username'] as String?,
      avatarUrl: data['avatarUrl'] as String?,
    );
  }

  @override
  Future<List<AppUser>> fetchFollowers({required String uid}) async {
    final QuerySnapshot<Object?> snap = await _db
        .collection('users')
        .doc(uid)
        .collection('followers')
        .get();
    return snap.docs.map(_edgeToUser).toList();
  }

  @override
  Future<List<AppUser>> fetchFollowing({required String uid}) async {
    final QuerySnapshot<Object?> snap = await _db
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();
    return snap.docs.map(_edgeToUser).toList();
  }

  @override
  Stream<List<String>> watchFollowingIds({required String uid}) => _db
      .collection('users')
      .doc(uid)
      .collection('following')
      .snapshots()
      .map((QuerySnapshot<Object?> snap) => snap.docs
          .map((QueryDocumentSnapshot<Object?> doc) => doc.id)
          .toList());

  @override
  Stream<bool> watchIsFollowing({required String uid}) => _db
      .collection('users')
      .doc(uid)
      .collection('followers')
      .doc(_uid)
      .snapshots()
      .map((DocumentSnapshot<Object?> snap) => snap.exists);

  @override
  Stream<List<Post>> watchUserPosts({required String uid, required int limit}) =>
      _db
          .collection('posts')
          .where('authorId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((QuerySnapshot<Object?> snap) => snap.docs
              .map((QueryDocumentSnapshot<Object?> doc) =>
                  PostDto.fromMap(doc.id, doc.data() as Map<String, dynamic>)
                      .toDomain(doc.id))
              .toList());
}
