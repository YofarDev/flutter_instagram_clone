import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/models/app_user.dart';

abstract interface class IAuthDataSource {
  Stream<AppUser?> get authStateChanges;
  Future<AppUser> signUp({required String email, required String password});
  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser> signInWithGoogle();
  Future<void> signOut();
  Future<Map<String, dynamic>?> fetchProfileDoc(String uid);
  Future<void> saveProfileDoc({
    required String uid,
    required Map<String, dynamic> data,
  });
  Future<String> uploadAvatar({required String uid, required String filePath});
}

class AuthFirebaseDataSource implements IAuthDataSource {
  const AuthFirebaseDataSource();

  FirebaseAuth get _auth => FirebaseAuth.instance;
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  FirebaseStorage get _storage => FirebaseStorage.instance;

  AppUser? _toUser(User? user) =>
      user == null ? null : AppUser(uid: user.uid, email: user.email ?? '');

  @override
  Stream<AppUser?> get authStateChanges =>
      _auth.authStateChanges().map(_toUser);

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    final UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AppUser(uid: cred.user!.uid, email: email);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final UserCredential cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AppUser(uid: cred.user!.uid, email: cred.user!.email ?? email);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    await GoogleSignIn.instance.initialize();
    final GoogleSignInAccount account = await GoogleSignIn.instance
        .authenticate();
    final GoogleSignInAuthentication authentication = account.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: authentication.idToken,
    );
    final UserCredential cred = await _auth.signInWithCredential(credential);
    return AppUser(
      uid: cred.user!.uid,
      email: cred.user!.email ?? account.email,
    );
  }

  @override
  Future<void> signOut() async {
    // ponytail: v7 has no currentUser getter; disconnect() when signed in with
    // Google, ignore when not. Per-account check if this ever throws wrongly.
    try {
      await GoogleSignIn.instance.disconnect();
    } on Exception {
      // Not signed in with Google; nothing to disconnect.
    }
    await _auth.signOut();
  }

  @override
  Future<Map<String, dynamic>?> fetchProfileDoc(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snap = await _db
        .collection('users')
        .doc(uid)
        .get();
    return snap.data();
  }

  @override
  Future<void> saveProfileDoc({
    required String uid,
    required Map<String, dynamic> data,
  }) {
    return _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  @override
  Future<String> uploadAvatar({
    required String uid,
    required String filePath,
  }) async {
    final Reference ref = _storage.ref('avatars/$uid.jpg');
    await ref.putFile(File(filePath));
    return ref.getDownloadURL();
  }
}
