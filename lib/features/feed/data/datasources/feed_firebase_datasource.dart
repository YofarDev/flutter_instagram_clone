import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/models/comment.dart';
import '../../../../core/models/post.dart';
import '../models/comment_dto.dart';
import '../../../../core/models/post_dto.dart';

abstract interface class IFeedDataSource {
  Stream<List<Post>> watchFeed({required int limit});
  Future<void> createPost({
    required String caption,
    required String filePath,
  });
  Future<Set<String>> fetchLikedPostIds({required List<String> postIds});
  Future<void> toggleLike({
    required String postId,
    required bool currentlyLiked,
  });
  Stream<List<Comment>> watchComments({required String postId});
  Future<void> addComment({
    required String postId,
    required String text,
  });
}

class FeedFirebaseDataSource implements IFeedDataSource {
  const FeedFirebaseDataSource();

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // ponytail: users-doc read per write; cache if read costs ever matter
  Future<({String username, String? avatarUrl})> _currentUserProfile() async {
    final User user = FirebaseAuth.instance.currentUser!;
    final DocumentSnapshot<Object?> profile =
        await _db.collection('users').doc(user.uid).get();
    final Map<String, dynamic> data =
        profile.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return (
      username: data['username'] as String? ?? user.email ?? '?',
      avatarUrl: data['avatarUrl'] as String?,
    );
  }

  @override
  Stream<List<Post>> watchFeed({required int limit}) => _db
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map((QuerySnapshot<Object?> snap) => snap.docs
          .map((QueryDocumentSnapshot<Object?> doc) =>
              PostDto.fromMap(doc.id, doc.data() as Map<String, dynamic>)
                  .toDomain(doc.id))
          .toList());

  @override
  Future<void> createPost({
    required String caption,
    required String filePath,
  }) async {
    final ({String username, String? avatarUrl}) profile =
        await _currentUserProfile();
    final int millis = DateTime.now().millisecondsSinceEpoch;
    final Reference ref = _storage.ref('posts/$_uid/$millis.jpg');
    await ref.putFile(File(filePath));
    final String imageUrl = await ref.getDownloadURL();
    // ponytail: client timestamp + denormalized author fields
    try {
      await _db.collection('posts').add(PostDto(
            authorId: _uid,
            authorUsername: profile.username,
            authorAvatarUrl: profile.avatarUrl,
            imageUrl: imageUrl,
            caption: caption,
            createdAtMillis: millis,
          ).toMap());
    } catch (e) {
      // ponytail: best-effort cleanup, orphan possible if delete fails too
      unawaited(ref.delete().catchError((_) => ref));
      rethrow;
    }
  }

  @override
  Future<Set<String>> fetchLikedPostIds({
    required List<String> postIds,
  }) async {
    if (postIds.isEmpty) return <String>{};
    final List<DocumentReference<Object?>> refs = postIds
        .map((String id) =>
            _db.collection('posts').doc(id).collection('likes').doc(_uid))
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
  Future<void> toggleLike({
    required String postId,
    required bool currentlyLiked,
  }) {
    final DocumentReference<Object?> likeRef =
        _db.collection('posts').doc(postId).collection('likes').doc(_uid);
    final DocumentReference<Object?> postRef =
        _db.collection('posts').doc(postId);
    return _db.runTransaction((Transaction tx) async {
      tx.update(postRef, <String, dynamic>{
        'likeCount': FieldValue.increment(currentlyLiked ? -1 : 1),
      });
      if (currentlyLiked) {
        tx.delete(likeRef);
      } else {
        tx.set(likeRef, <String, dynamic>{});
      }
    });
  }

  @override
  Stream<List<Comment>> watchComments({required String postId}) => _db
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .orderBy('createdAt')
      .snapshots()
      .map((QuerySnapshot<Object?> snap) => snap.docs
          .map((QueryDocumentSnapshot<Object?> doc) =>
              CommentDto.fromMap(doc.id, doc.data() as Map<String, dynamic>)
                  .toDomain(doc.id, postId))
          .toList());

  @override
  Future<void> addComment({
    required String postId,
    required String text,
  }) async {
    final ({String username, String? avatarUrl}) profile =
        await _currentUserProfile();
    final DocumentReference<Object?> postRef =
        _db.collection('posts').doc(postId);
    return _db.runTransaction((Transaction tx) async {
      tx.update(postRef, <String, dynamic>{
        'commentCount': FieldValue.increment(1),
      });
      tx.set(
        postRef.collection('comments').doc(),
        CommentDto(
          authorId: _uid,
          authorUsername: profile.username,
          text: text,
          createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        ).toMap(),
      );
    });
  }
}
