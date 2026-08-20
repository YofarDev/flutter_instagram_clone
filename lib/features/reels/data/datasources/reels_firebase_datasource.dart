import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../../core/models/comment.dart';
import '../../../../core/models/comment_dto.dart';
import '../../domain/models/reel.dart';
import '../models/reel_dto.dart';

abstract interface class IReelsDataSource {
  Stream<List<Reel>> watchReels({required int limit});
  Future<void> createReel({required String caption, required String filePath});
  Future<Set<String>> fetchLikedReelIds({required List<String> reelIds});
  Future<void> toggleReelLike({
    required String reelId,
    required String reelOwnerId,
    required bool currentlyLiked,
  });
  Stream<List<Comment>> watchReelComments({required String reelId});
  Future<void> addReelComment({
    required String reelId,
    required String reelOwnerId,
    required String text,
  });
}

class ReelsFirebaseDataSource implements IReelsDataSource {
  const ReelsFirebaseDataSource();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ponytail: users-doc read per write; cache if read costs ever matter
  Future<({String username, String? avatarUrl})> _currentUserProfile() async {
    final User user = FirebaseAuth.instance.currentUser!;
    final DocumentSnapshot<Object?> profile = await _db
        .collection('users')
        .doc(user.uid)
        .get();
    final Map<String, dynamic> data =
        profile.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return (
      username: data['username'] as String? ?? user.email ?? '?',
      avatarUrl: data['avatarUrl'] as String?,
    );
  }

  @override
  Stream<List<Reel>> watchReels({required int limit}) => _db
      .collection('reels')
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map(
        (QuerySnapshot<Object?> snap) => snap.docs
            .map(
              (QueryDocumentSnapshot<Object?> doc) => ReelDto.fromMap(
                doc.data() as Map<String, dynamic>,
              ).toDomain(doc.id),
            )
            .toList(),
      );

  @override
  Future<void> createReel({
    required String caption,
    required String filePath,
  }) async {
    final ({String username, String? avatarUrl}) profile =
        await _currentUserProfile();
    final int millis = DateTime.now().millisecondsSinceEpoch;
    final Reference ref = _storage.ref('reels/$_uid/$millis.mp4');
    await ref.putFile(File(filePath));
    final String videoUrl = await ref.getDownloadURL();
    try {
      await _db
          .collection('reels')
          .add(
            ReelDto(
              uid: _uid,
              authorUsername: profile.username,
              authorAvatarUrl: profile.avatarUrl,
              videoUrl: videoUrl,
              caption: caption,
              createdAtMillis: millis,
              likeCount: 0,
            ).toMap(),
          );
    } catch (e) {
      // ponytail: best-effort cleanup, orphan possible if delete fails too
      unawaited(ref.delete().catchError((_) => ref));
      rethrow;
    }
  }

  @override
  Future<Set<String>> fetchLikedReelIds({required List<String> reelIds}) async {
    if (reelIds.isEmpty) return <String>{};
    final List<DocumentReference<Object?>> refs = reelIds
        .map(
          (String id) =>
              _db.collection('reels').doc(id).collection('likes').doc(_uid),
        )
        .toList();
    // ponytail: per-doc gets instead of getAll (not exposed by cloud_firestore
    // 6.x); same N reads, N RPCs — batch if feed size makes it matter
    final List<DocumentSnapshot<Object?>> snaps = await Future.wait(
      refs.map((DocumentReference<Object?> ref) => ref.get()),
    );
    return <String>{
      for (final DocumentSnapshot<Object?> s in snaps)
        if (s.exists) s.reference.parent.parent!.id,
    };
  }

  @override
  Future<void> toggleReelLike({
    required String reelId,
    required String reelOwnerId,
    required bool currentlyLiked,
  }) async {
    final DocumentReference<Object?> likeRef = _db
        .collection('reels')
        .doc(reelId)
        .collection('likes')
        .doc(_uid);
    final DocumentReference<Object?> reelRef = _db
        .collection('reels')
        .doc(reelId);
    await _db.runTransaction((Transaction tx) async {
      tx.update(reelRef, <String, dynamic>{
        'likeCount': FieldValue.increment(currentlyLiked ? -1 : 1),
      });
      if (currentlyLiked) {
        tx.delete(likeRef);
      } else {
        tx.set(likeRef, <String, dynamic>{});
      }
    });
    if (!currentlyLiked && reelOwnerId != _uid) {
      unawaited(
        _notifyOwner(ownerUid: reelOwnerId, reelId: reelId, type: 'like'),
      );
    }
  }

  @override
  Stream<List<Comment>> watchReelComments({required String reelId}) => _db
      .collection('reels')
      .doc(reelId)
      .collection('comments')
      .orderBy('createdAt')
      .snapshots()
      .map(
        (QuerySnapshot<Object?> snap) => snap.docs
            .map(
              (QueryDocumentSnapshot<Object?> doc) => CommentDto.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ).toDomain(doc.id, reelId),
            )
            .toList(),
      );

  @override
  Future<void> addReelComment({
    required String reelId,
    required String reelOwnerId,
    required String text,
  }) async {
    final ({String username, String? avatarUrl}) profile =
        await _currentUserProfile();
    final DocumentReference<Object?> reelRef = _db
        .collection('reels')
        .doc(reelId);
    await _db.runTransaction((Transaction tx) async {
      tx.update(reelRef, <String, dynamic>{
        'commentCount': FieldValue.increment(1),
      });
      tx.set(
        reelRef.collection('comments').doc(),
        CommentDto(
          authorId: _uid,
          authorUsername: profile.username,
          text: text,
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        ).toMap(),
      );
    });
    if (reelOwnerId != _uid) {
      unawaited(
        _notifyOwner(
          ownerUid: reelOwnerId,
          reelId: reelId,
          type: 'comment',
          commentText: text,
        ),
      );
    }
  }

  // ponytail: inline notification write, extract on 4th consumer
  // (feed like, feed comment, profile follow are the other three)
  Future<void> _notifyOwner({
    required String ownerUid,
    required String reelId,
    required String type,
    String? commentText,
  }) async {
    try {
      final ({String username, String? avatarUrl}) profile =
          await _currentUserProfile();
      await _db.collection('notifications').add(<String, dynamic>{
        'ownerUid': ownerUid,
        'type': type,
        'actorId': _uid,
        'actorUsername': profile.username,
        'actorAvatarUrl': profile.avatarUrl,
        // ponytail: reel notifications reuse postId; no thumbnail (no image)
        'postId': reelId,
        'commentText': ?commentText,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'read': false,
      });
    } catch (_) {
      // notification drop must not fail the like/comment
    }
  }
}
