import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/models/post.dart';
import '../../../../core/models/post_dto.dart';

abstract interface class IExploreDataSource {
  Stream<List<Post>> watchExplorePosts({required int limit});
  Future<List<AppUser>> searchUsers({required String query});
  Stream<List<Post>> watchPostsByTag({required String tag});
}

class ExploreFirebaseDataSource implements IExploreDataSource {
  const ExploreFirebaseDataSource();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  @override
  // ponytail: mirrors feed watchFeed; extract shared posts datasource if a
  // third consumer appears
  Stream<List<Post>> watchExplorePosts({required int limit}) => _db
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
  Future<List<AppUser>> searchUsers({required String query}) async {
    final String q = query.trim().toLowerCase().replaceFirst('#', '');
    if (q.isEmpty) return <AppUser>[];
    final QuerySnapshot<Object?> snap = await _db
        .collection('users')
        .where('usernameLower', isGreaterThanOrEqualTo: q)
        .where('usernameLower', isLessThan: '$q\uf8ff')
        .limit(20)
        .get();
    return snap.docs.map((QueryDocumentSnapshot<Object?> doc) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return AppUser(
        uid: doc.id,
        email: data['email'] as String? ?? '',
        username: data['username'] as String?,
        avatarUrl: data['avatarUrl'] as String?,
      );
    }).toList();
  }

  @override
  Stream<List<Post>> watchPostsByTag({required String tag}) => _db
      .collection('posts')
      .where('tags', arrayContains: tag)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((QuerySnapshot<Object?> snap) => snap.docs
          .map((QueryDocumentSnapshot<Object?> doc) =>
              PostDto.fromMap(doc.id, doc.data() as Map<String, dynamic>)
                  .toDomain(doc.id))
          .toList());
}
