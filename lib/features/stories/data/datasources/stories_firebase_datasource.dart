import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/models/story.dart';
import '../models/story_dto.dart';

abstract interface class IStoriesDataSource {
  Stream<List<Story>> watchStories();
  Future<void> createStory({required String filePath});
  Future<Set<String>> fetchViewedStoryIds({required List<String> storyIds});
  Future<void> markViewed({required String storyId});
}

class StoriesFirebaseDataSource implements IStoriesDataSource {
  const StoriesFirebaseDataSource();

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
  Stream<List<Story>> watchStories() {
    // ponytail: cutoff fixed at subscribe; stories outliving 24h vanish on
    // next snapshot only if cutoff recomputed — accepted staleness
    final int cutoff =
        DateTime.now().subtract(const Duration(hours: 24)).millisecondsSinceEpoch;
    return _db
        .collection('stories')
        .where('createdAt', isGreaterThan: cutoff)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Object?> snap) => snap.docs
            .map((QueryDocumentSnapshot<Object?> doc) => StoryDto.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ).toDomain(doc.id))
            .toList());
  }

  @override
  Future<void> createStory({required String filePath}) async {
    final ({String username, String? avatarUrl}) profile =
        await _currentUserProfile();
    final int millis = DateTime.now().millisecondsSinceEpoch;
    final Reference ref = _storage.ref('stories/$_uid/$millis.jpg');
    await ref.putFile(File(filePath));
    final String imageUrl = await ref.getDownloadURL();
    try {
      await _db.collection('stories').add(StoryDto(
            uid: _uid,
            authorUsername: profile.username,
            authorAvatarUrl: profile.avatarUrl,
            imageUrl: imageUrl,
            createdAtMillis: millis,
          ).toMap());
    } catch (e) {
      // ponytail: best-effort cleanup, orphan possible if delete fails too
      unawaited(ref.delete().catchError((_) => ref));
      rethrow;
    }
  }

  @override
  Future<Set<String>> fetchViewedStoryIds({
    required List<String> storyIds,
  }) async {
    if (storyIds.isEmpty) return <String>{};
    final List<DocumentReference<Object?>> refs = storyIds
        .map((String id) =>
            _db.collection('stories').doc(id).collection('viewers').doc(_uid))
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
  Future<void> markViewed({required String storyId}) {
    return _db
        .collection('stories')
        .doc(storyId)
        .collection('viewers')
        .doc(_uid)
        .set(<String, dynamic>{}, SetOptions(merge: true));
  }
}
