import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/models/comment.dart';
import '../../../../core/models/post.dart';
import '../models/comment_dto.dart';
import '../../../../core/models/post_dto.dart';

/// #hashtag extraction: unicode word chars, Latin-1 accent fold, lowercase,
/// strip #, deduped.
const String _accents = 'àáâäèéêëìíîïòóôöùúûüçñÀÁÂÄÈÉÊËÌÍÎÏÒÓÔÖÙÚÛÜÇÑ';
const String _folded = 'aaaaeeeeiiiioooouuuucnAAAAEEEEIIIIOOOOUUUUCN';

// ponytail: Latin-1 accent fold, full ICU fold if other scripts matter
String _foldAccents(String s) => String.fromCharCodes(
  s.runes.map(
    (int r) => _accents.contains(String.fromCharCode(r))
        ? _folded.codeUnitAt(_accents.indexOf(String.fromCharCode(r)))
        : r,
  ),
);

List<String> extractTags(String caption) {
  final RegExp re = RegExp(r'#([\p{L}\p{N}_]+)', unicode: true);
  return re
      .allMatches(caption)
      .map((RegExpMatch m) => _foldAccents(m.group(1)!).toLowerCase())
      .toSet()
      .toList();
}

abstract interface class IFeedDataSource {
  Stream<List<Post>> watchFeed({required int limit});
  Future<void> createPost({required String caption, required String filePath});
  Future<Set<String>> fetchLikedPostIds({required List<String> postIds});
  Future<Set<String>> fetchSavedPostIds({required List<String> postIds});
  Future<Post> getPostById({required String postId});
  Future<void> toggleLike({
    required String postId,
    required String postOwnerId,
    required String postImageUrl,
    required bool currentlyLiked,
  });
  Future<void> toggleSave({
    required String postId,
    required bool currentlySaved,
  });
  Stream<List<Comment>> watchComments({required String postId});
  Future<void> addComment({
    required String postId,
    required String postOwnerId,
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
  Stream<List<Post>> watchFeed({required int limit}) => _db
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map(
        (QuerySnapshot<Object?> snap) => snap.docs
            .map(
              (QueryDocumentSnapshot<Object?> doc) => PostDto.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ).toDomain(doc.id),
            )
            .toList(),
      );

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
      await _db
          .collection('posts')
          .add(
            PostDto(
              authorId: _uid,
              authorUsername: profile.username,
              authorAvatarUrl: profile.avatarUrl,
              imageUrl: imageUrl,
              caption: caption,
              createdAtMillis: millis,
              tags: extractTags(caption),
            ).toMap(),
          );
    } catch (e) {
      // ponytail: best-effort cleanup, orphan possible if delete fails too
      unawaited(ref.delete().catchError((_) => ref));
      rethrow;
    }
    try {
      await _db.collection('users').doc(_uid).update(<String, dynamic>{
        'postCount': FieldValue.increment(1),
      });
    } catch (_) {
      // ponytail: count drift acceptable; profile grid is source of truth
    }
  }

  @override
  Future<Set<String>> fetchLikedPostIds({required List<String> postIds}) async {
    if (postIds.isEmpty) return <String>{};
    final List<DocumentReference<Object?>> refs = postIds
        .map(
          (String id) =>
              _db.collection('posts').doc(id).collection('likes').doc(_uid),
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
  Future<Set<String>> fetchSavedPostIds({required List<String> postIds}) async {
    if (postIds.isEmpty) return <String>{};
    final List<DocumentSnapshot<Object?>> snaps = await Future.wait(
      postIds.map(
        (String id) => _db.collection('savedPosts').doc(_savedDocId(id)).get(),
      ),
    );
    return <String>{
      for (final DocumentSnapshot<Object?> s in snaps)
        if (s.exists) s.id.substring(_uid.length + 1),
    };
  }

  /// savedPosts doc ids embed the owner: {uid}_{postId}
  String _savedDocId(String postId) => '${_uid}_$postId';

  @override
  Future<Post> getPostById({required String postId}) async {
    final DocumentSnapshot<Object?> snap = await _db
        .collection('posts')
        .doc(postId)
        .get();
    if (!snap.exists) {
      throw StateError('Post not found');
    }
    return PostDto.fromMap(
      postId,
      snap.data() as Map<String, dynamic>,
    ).toDomain(postId);
  }

  @override
  Future<void> toggleLike({
    required String postId,
    required String postOwnerId,
    required String postImageUrl,
    required bool currentlyLiked,
  }) async {
    final DocumentReference<Object?> likeRef = _db
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(_uid);
    final DocumentReference<Object?> postRef = _db
        .collection('posts')
        .doc(postId);
    await _db.runTransaction((Transaction tx) async {
      tx.update(postRef, <String, dynamic>{
        'likeCount': FieldValue.increment(currentlyLiked ? -1 : 1),
      });
      if (currentlyLiked) {
        tx.delete(likeRef);
      } else {
        tx.set(likeRef, <String, dynamic>{});
      }
    });
    if (!currentlyLiked && postOwnerId != _uid) {
      unawaited(
        _notifyLike(
          ownerUid: postOwnerId,
          postId: postId,
          postImageUrl: postImageUrl,
        ),
      );
    }
  }

  @override
  Future<void> toggleSave({
    required String postId,
    required bool currentlySaved,
  }) async {
    final DocumentReference<Object?> ref = _db
        .collection('savedPosts')
        .doc(_savedDocId(postId));
    if (currentlySaved) {
      await ref.delete();
    } else {
      await ref.set(<String, dynamic>{
        'uid': _uid,
        'postId': postId,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  // ponytail: inline notification write, extract on 4th consumer
  Future<void> _notifyLike({
    required String ownerUid,
    required String postId,
    required String postImageUrl,
  }) async {
    try {
      final ({String username, String? avatarUrl}) profile =
          await _currentUserProfile();
      await _db.collection('notifications').add(<String, dynamic>{
        'ownerUid': ownerUid,
        'type': 'like',
        'actorId': _uid,
        'actorUsername': profile.username,
        'actorAvatarUrl': profile.avatarUrl,
        'postId': postId,
        'postImageUrl': postImageUrl,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'read': false,
      });
    } catch (_) {
      // notification drop must not fail the like
    }
  }

  @override
  Stream<List<Comment>> watchComments({required String postId}) => _db
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .orderBy('createdAt')
      .snapshots()
      .map(
        (QuerySnapshot<Object?> snap) => snap.docs
            .map(
              (QueryDocumentSnapshot<Object?> doc) => CommentDto.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ).toDomain(doc.id, postId),
            )
            .toList(),
      );

  @override
  Future<void> addComment({
    required String postId,
    required String postOwnerId,
    required String text,
  }) async {
    final ({String username, String? avatarUrl}) profile =
        await _currentUserProfile();
    final DocumentReference<Object?> postRef = _db
        .collection('posts')
        .doc(postId);
    await _db.runTransaction((Transaction tx) async {
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
    if (postOwnerId != _uid) {
      unawaited(
        _notifyComment(
          ownerUid: postOwnerId,
          postId: postId,
          commentText: text,
        ),
      );
    }
  }

  // ponytail: inline notification write, extract on 4th consumer
  Future<void> _notifyComment({
    required String ownerUid,
    required String postId,
    required String commentText,
  }) async {
    try {
      final ({String username, String? avatarUrl}) profile =
          await _currentUserProfile();
      await _db.collection('notifications').add(<String, dynamic>{
        'ownerUid': ownerUid,
        'type': 'comment',
        'actorId': _uid,
        'actorUsername': profile.username,
        'actorAvatarUrl': profile.avatarUrl,
        'postId': postId,
        'commentText': commentText,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'read': false,
      });
    } catch (_) {
      // notification drop must not fail the comment
    }
  }
}
