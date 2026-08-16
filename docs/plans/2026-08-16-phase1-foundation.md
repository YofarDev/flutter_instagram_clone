# Phase 1 — Foundation: Firebase + Auth + Onboarding Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Wire Firebase (Auth, Firestore, Storage) and deliver the full auth flow: login, signup, Google sign-in, onboarding (username + avatar + bio), and a placeholder feed screen with logout.

**Architecture:** Feature-based Clean Architecture (`presentation → domain ← data`) per the project template. One app-scoped `AuthCubit` (singleton) owns the session state machine; `go_router` redirects based on it. Firebase lives only in the data-source layer, so tests mock `IAuthDataSource` / `IAuthRepository` and never touch Firebase.

**Tech Stack:** Flutter 3.44, `firebase_core` / `firebase_auth` / `cloud_firestore` / `firebase_storage`, `google_sign_in` (v7 API), `image_picker`, `flutter_bloc`, `freezed`, `fpdart`, `go_router`, `get_it`.

**Key decisions:**

- `AuthState` is a single freezed class + `AuthStatus` enum (not a union) because it mixes session status (routing) with form state (submitting/error) — a union would make redirect logic awkward.
- `AuthCubit` is a `registerLazySingleton` (app-scoped). Route builders wrap screens with `BlocProvider.value` (NOT `BlocProvider(create:)` — that would dispose the singleton on pop).
- Google sign-in cancel is reported as `Failure.serverError(message: '')`; the cubit ignores empty messages instead of showing a snackbar. `// ponytail: empty-message-as-cancel sentinel, proper sealed failure when screens need to distinguish`
- `fgen.sh` is NOT used — this plan provides the complete files. Worktree isolation skipped (fresh repo, single session).

---

### Task 0: Initialize git

**Files:** none

**Step 1:** Run:

```bash
git init && git add -A && git commit -m "chore: baseline template + phase 1 plan"
```

Expected: initial commit succeeds.

---

### Task 1: Add Firebase packages

**Step 1:** Run:

```bash
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage google_sign_in image_picker
```

**Step 2:** Verify with `flutter pub get` (should be a no-op). Commit: `chore: add firebase and media packages`.

---

### Task 2: Strip template features

**Files:**
- Delete: `lib/features/counter/` (entire), `lib/features/home/` (entire), `lib/core/services/example_service.dart`
- Rewrite: `lib/core/di/service_locator.dart`, `lib/core/router/app_router.dart`, `lib/core/router/route_constants.dart`
- Delete: `remove_counter.sh`
- Delete: any orphaned `test/` files covering counter/home (check `ls test/`)

**Step 1:** Delete the folders/files above.

**Step 2:** Replace `lib/core/di/service_locator.dart` with:

```dart
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // --- Auth feature registrations land here in Task 8 ---
}
```

**Step 3:** Replace `lib/core/router/app_router.dart` with a minimal router (auth routes are added in Task 8):

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_constants.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: Routes.feed,
        name: 'Feed',
        builder: (BuildContext context, GoRouterState state) =>
            const Scaffold(body: Center(child: Text('Feed placeholder'))),
      ),
    ],
  );
}
```

**Step 4:** Replace `lib/core/router/route_constants.dart` with:

```dart
abstract final class Routes {
  static const String splash = '/splash';
  static const String feed = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String onboarding = '/onboarding';
}
```

**Step 5:** Run `flutter analyze` — must pass. Commit: `chore: remove template counter/home features`.

---

### Task 3: Firebase project + wiring

**USER ACTION (interactive, needs Google login).** In Firebase console for the project:

1. **Authentication → Sign-in method:** enable **Email/Password** and **Google**.
2. **Firestore Database:** create database (test mode is fine for the POC — note the 30-day open-rules expiry).
3. **Storage:** get started (test mode).
4. Android: add app (package `com.example.flutterInstagramClone` or your actual id from `android/app/build.gradle.kts` `applicationId`) — **and before Google sign-in will work on Android, add the debug SHA-1** (see Task 14). iOS: add app (bundle id from `ios/Runner.xcodeproj`).

Then run:

```bash
flutterfire configure
```

Select the project + Android/iOS platforms. It generates `lib/firebase_options.dart` (already git-ignored).

**Files:**
- Modify: `lib/main.dart`

**Step 1:** Replace `lib/main.dart` with:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/service_locator.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupServiceLocator();
  runApp(const MyApp());
}
```

**Step 2:** Run `flutter analyze` — must pass (proves `firebase_options.dart` was generated). Commit: `feat: initialize firebase in main`.

---

### Task 4: Auth feature — models

**Files:**
- Create: `lib/features/auth/domain/models/app_user.dart`
- Create: `lib/features/auth/data/models/user_dto.dart`

**Step 1:** Create `app_user.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String email,
    String? username,
    String? bio,
    String? avatarUrl,
  }) = _AppUser;
}
```

**Step 2:** Create `user_dto.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';

@freezed
class UserDto with _$UserDto {
  const factory UserDto({
    required String email,
    String? username,
    String? bio,
    String? avatarUrl,
  }) = _UserDto;

  factory UserDto.fromMap(Map<String, dynamic> map) => UserDto(
        email: map['email'] as String,
        username: map['username'] as String?,
        bio: map['bio'] as String?,
        avatarUrl: map['avatarUrl'] as String?,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'email': email,
        'username': username,
        'bio': bio,
        'avatarUrl': avatarUrl,
      };
}

/// Firestore doc id IS the uid; DTO never carries it.
extension UserDtoX on UserDto {
  String? get createdAt => null; // ponytail: createdAt added when ordering by it matters
}
```

(Delete the extension if `dart fix`/analyze flags it as unused — it is optional.)

**Step 3:** Run `dart run build_runner build --delete-conflicting-outputs`. Commit: `feat(auth): app user model and firestore dto`.

---

### Task 5: Auth repository + datasource contracts

**Files:**
- Create: `lib/features/auth/domain/repositories/auth_repository.dart`
- Create: `lib/features/auth/data/datasources/auth_firebase_datasource.dart`

**Step 1:** Create the repository interface:

```dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../models/app_user.dart';

abstract interface class IAuthRepository {
  /// Emits a bare AppUser (uid + email only) or null on logout.
  Stream<AppUser?> get authStateChanges;

  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  /// Full profile from Firestore; null if the profile doc doesn't exist yet.
  Future<Either<Failure, AppUser?>> findProfile({
    required String uid,
    required String email,
  });

  Future<Either<Failure, void>> saveProfile({required AppUser user});

  /// Uploads local image, returns its Storage download URL.
  Future<Either<Failure, String>> uploadAvatar({
    required String uid,
    required String filePath,
  });
}
```

**Step 2:** Create the datasource interface + Firebase implementation in the same file:

```dart
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/models/app_user.dart';

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

  AppUser _toUser(User? user) =>
      user == null ? null : AppUser(uid: user.uid, email: user.email ?? '');

  @override
  Stream<AppUser?> get authStateChanges =>
      _auth.authStateChanges().map(_toUser);

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
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
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return AppUser(uid: cred.user!.uid, email: cred.user!.email ?? email);
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    await GoogleSignIn.instance.initialize();
    final account = await GoogleSignIn.instance.authenticate();
    final authentication = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: authentication.accessToken,
      idToken: authentication.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    return AppUser(uid: cred.user!.uid, email: cred.user!.email ?? account.email);
  }

  @override
  Future<void> signOut() async {
    if (GoogleSignIn.instance.currentUser != null) {
      await GoogleSignIn.instance.disconnect();
    }
    await _auth.signOut();
  }

  @override
  Future<Map<String, dynamic>?> fetchProfileDoc(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
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
    final ref = _storage.ref('avatars/$uid.jpg');
    await ref.putFile(File(filePath));
    return ref.getDownloadURL();
  }
}
```

Note: if `account.authentication` is not a `Future` in the installed google_sign_in version, drop the `await` — the analyzer will say so immediately.

Commit: `feat(auth): repository and datasource contracts`.

---

### Task 6: AuthRepositoryImpl (TDD)

**Files:**
- Create: `lib/features/auth/data/repositories/auth_repository_impl.dart`
- Test: `test/features/auth/auth_repository_impl_test.dart`

**Step 1:** Write the failing test:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:flutter_instagram_clone/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_instagram_clone/features/auth/domain/models/app_user.dart';
import 'package:fpdart/fpdart.dart';

class MockAuthDataSource extends Mock implements IAuthDataSource {}

void main() {
  late MockAuthDataSource ds;
  late AuthRepository repo;

  const user = AppUser(uid: 'u1', email: 'a@b.c');

  setUp(() {
    ds = MockAuthDataSource();
    repo = AuthRepository(ds);
  });

  group('signUp', () {
    test('maps datasource user to Right', () async {
      when(() => ds.signUp(email: 'a@b.c', password: 'pw'))
          .thenAnswer((_) async => user);

      final result = await repo.signUp(email: 'a@b.c', password: 'pw');

      expect(result, const Right<Failure, AppUser>(user));
    });

    test('maps invalid-credential to friendly failure', () async {
      when(() => ds.signUp(email: 'a@b.c', password: 'pw')).thenThrow(
        FirebaseAuthException(code: 'email-already-in-use'),
      );

      final result = await repo.signUp(email: 'a@b.c', password: 'pw');

      expect(
        result.getLeft().toNullable()?.message,
        'Email already in use',
      );
    });

    test('maps network failure', () async {
      when(() => ds.signUp(email: 'a@b.c', password: 'pw')).thenThrow(
        FirebaseAuthException(code: 'network-request-failed'),
      );

      final result = await repo.signUp(email: 'a@b.c', password: 'pw');

      expect(result.getLeft().toNullable(), isA<Failure>()
          .having((f) => f, 'is network', predicate<Failure>(
              (f) => f.maybeMap(networkError: (_) => true, orElse: () => false))));
    });
  });

  group('signInWithGoogle', () {
    test('user cancel produces empty-message failure', () async {
      when(() => ds.signInWithGoogle()).thenThrow(
        GoogleSignInException(
          code: GoogleSignInExceptionCode.canceled,
          description: 'canceled',
        ),
      );

      final result = await repo.signInWithGoogle();

      expect(result.getLeft().toNullable()?.message, '');
    });
  });

  group('findProfile', () {
    test('missing doc returns Right(null)', () async {
      when(() => ds.fetchProfileDoc('u1')).thenAnswer((_) async => null);

      final result = await repo.findProfile(uid: 'u1', email: 'a@b.c');

      expect(result.getRight().toNullable(), isNull);
    });

    test('doc maps to full AppUser', () async {
      when(() => ds.fetchProfileDoc('u1')).thenAnswer(
        (_) async => <String, dynamic>{
          'email': 'a@b.c',
          'username': 'yo',
          'bio': null,
          'avatarUrl': 'http://x',
        },
      );

      final result = await repo.findProfile(uid: 'u1', email: 'a@b.c');

      expect(
        result.getRight().toNullable(),
        const AppUser(uid: 'u1', email: 'a@b.c', username: 'yo', avatarUrl: 'http://x'),
      );
    });
  });
}
```

**Step 2:** Run `flutter test test/features/auth/auth_repository_impl_test.dart` — expect compile failure (`AuthRepository` doesn't exist).

**Step 3:** Create `auth_repository_impl.dart`:

```dart
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';
import '../models/user_dto.dart';

class AuthRepository implements IAuthRepository {
  const AuthRepository(this._ds);

  final IAuthDataSource _ds;

  @override
  Stream<AppUser?> get authStateChanges => _ds.authStateChanges;

  @override
  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return Right(await _ds.signUp(email: email, password: password));
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return Right(await _ds.signIn(email: email, password: password));
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      return Right(await _ds.signInWithGoogle());
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      return Right(await _ds.signOut());
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> findProfile({
    required String uid,
    required String email,
  }) async {
    try {
      final map = await _ds.fetchProfileDoc(uid);
      if (map == null) return const Right(null);
      final dto = UserDto.fromMap(map);
      return Right(AppUser(
        uid: uid,
        email: dto.email,
        username: dto.username,
        bio: dto.bio,
        avatarUrl: dto.avatarUrl,
      ));
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> saveProfile({required AppUser user}) async {
    try {
      return Right(await _ds.saveProfileDoc(
        uid: user.uid,
        data: UserDto(
          email: user.email,
          username: user.username,
          bio: user.bio,
          avatarUrl: user.avatarUrl,
        ).toMap(),
      ));
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String uid,
    required String filePath,
  }) async {
    try {
      return Right(await _ds.uploadAvatar(uid: uid, filePath: filePath));
    } catch (e) {
      return Left(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    if (e is GoogleSignInException) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // ponytail: empty message = silent cancel sentinel, cubit ignores it
        return const Failure.serverError(message: '');
      }
      return Failure.serverError(message: e.description);
    }
    if (e is FirebaseAuthException) {
      return switch (e.code) {
        'network-request-failed' => const Failure.networkError(),
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' ||
        'invalid-credential-password' ||
        'invalid-credential-email' =>
          const Failure.serverError(message: 'Invalid email or password'),
        'email-already-in-use' =>
          const Failure.serverError(message: 'Email already in use'),
        'weak-password' =>
          const Failure.serverError(message: 'Password is too weak'),
        _ => Failure.serverError(message: e.message ?? 'Authentication error'),
      };
    }
    return Failure.serverError(message: e.toString());
  }
}
```

**Step 4:** Run the test — all pass. Commit: `feat(auth): repository implementation with failure mapping`.

---

### Task 7: AuthCubit (TDD)

**Files:**
- Create: `lib/features/auth/presentation/bloc/auth_state.dart`
- Create: `lib/features/auth/presentation/bloc/auth_cubit.dart`
- Test: `test/features/auth/auth_cubit_test.dart`

**Step 1:** Create `auth_state.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/app_user.dart';

part 'auth_state.freezed.dart';

enum AuthStatus { loading, unauthenticated, needsProfile, authenticated }

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.loading) AuthStatus status,
    AppUser? user,
    @Default(false) bool submitting,
    String? error,
  }) = _AuthState;
}
```

**Step 2:** Create `auth_cubit.dart`:

```dart
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState()) {
    _sub = _repository.authStateChanges.listen(_onUserChanged);
  }

  final IAuthRepository _repository;
  late final StreamSubscription<AppUser?> _sub;

  Future<void> _onUserChanged(AppUser? user) async {
    if (user == null) {
      emit(state.copyWith(user: null, status: AuthStatus.unauthenticated));
      return;
    }
    final result =
        await _repository.findProfile(uid: user.uid, email: user.email);
    result.fold(
      (_) => emit(state.copyWith(
        user: user,
        status: AuthStatus.authenticated,
      )), // ponytail: profile-check failure lets user in; revisit when profiles gate content
      (profile) => emit(state.copyWith(
        user: profile ?? user,
        status:
            profile == null ? AuthStatus.needsProfile : AuthStatus.authenticated,
      )),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    await _runAction(() => _repository.signIn(email: email, password: password));
  }

  Future<void> signUp({required String email, required String password}) async {
    await _runAction(() => _repository.signUp(email: email, password: password));
  }

  Future<void> signInWithGoogle() async {
    await _runAction(_repository.signInWithGoogle);
  }

  Future<void> completeProfile({
    required String username,
    String? bio,
    String? avatarPath,
  }) async {
    final user = state.user;
    if (user == null) return;
    emit(state.copyWith(submitting: true, error: null));
    String? avatarUrl;
    if (avatarPath != null) {
      final upload = await _repository.uploadAvatar(
        uid: user.uid,
        filePath: avatarPath,
      );
      upload.fold(
        (f) => emit(state.copyWith(submitting: false, error: f.message)),
        (url) => avatarUrl = url,
      );
      if (avatarUrl == null) return;
    }
    final saved = user.copyWith(username: username, bio: bio, avatarUrl: avatarUrl);
    final result = await _repository.saveProfile(user: saved);
    result.fold(
      (f) => emit(state.copyWith(submitting: false, error: f.message)),
      (_) => emit(
        state.copyWith(user: saved, submitting: false, status: AuthStatus.authenticated),
      ),
    );
  }

  Future<void> signOut() => _repository.signOut();

  Future<void> _runAction(
    Future<dynamic> Function() action,
  ) async {
    emit(state.copyWith(submitting: true, error: null));
    final result = await action();
    result.fold(
      (f) => emit(state.copyWith(
        submitting: false,
        // ponytail: empty message = google cancel sentinel, stay quiet
        error: f.message.isEmpty ? null : f.message,
      )),
      (_) => emit(state.copyWith(submitting: false)),
    );
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
```

Note: `Either.fold` returns different types per branch — since `_runAction` types `action` as `Future<dynamic>`, `result.fold` still resolves. If the analyzer complains about `fold` on `dynamic`, type the helper as `Future<Either<Failure, Object?>> Function()` and import fpdart.

**Step 3:** Write the failing test `auth_cubit_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/auth/domain/models/app_user.dart';
import 'package:flutter_instagram_clone/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_instagram_clone/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_instagram_clone/features/auth/presentation/bloc/auth_state.dart';
import 'package:fpdart/fpdart.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

const user = AppUser(uid: 'u1', email: 'a@b.c');
const profile = AppUser(uid: 'u1', email: 'a@b.c', username: 'yo');

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
    registerFallbackValue(profile);
  });

  blocTest<AuthCubit, AuthState>(
    'null auth event → unauthenticated',
    build: () {
      when(() => repo.authStateChanges).thenAnswer((_) => Stream.value(null));
      return AuthCubit(repo);
    },
    expect: () => const <AuthState>[
      AuthState(status: AuthStatus.unauthenticated),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'user without profile doc → needsProfile',
    build: () {
      when(() => repo.authStateChanges).thenAnswer((_) => Stream.value(user));
      when(() => repo.findProfile(uid: 'u1', email: 'a@b.c'))
          .thenAnswer((_) async => const Right(null));
      return AuthCubit(repo);
    },
    expect: () => const <AuthState>[
      AuthState(status: AuthStatus.needsProfile, user: user),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'user with profile → authenticated',
    build: () {
      when(() => repo.authStateChanges).thenAnswer((_) => Stream.value(user));
      when(() => repo.findProfile(uid: 'u1', email: 'a@b.c'))
          .thenAnswer((_) async => const Right(profile));
      return AuthCubit(repo);
    },
    expect: () => const <AuthState>[
      AuthState(status: AuthStatus.authenticated, user: profile),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'signIn failure → error set, submitting reset',
    build: () {
      when(() => repo.authStateChanges).thenAnswer((_) => const Stream.empty());
      when(() => repo.signIn(email: 'a@b.c', password: 'bad'))
          .thenAnswer((_) async =>
              const Left(Failure.serverError(message: 'Invalid email or password')));
      return AuthCubit(repo);
    },
    act: (cubit) => cubit.signIn(email: 'a@b.c', password: 'bad'),
    expect: () => const <AuthState>[
      AuthState(submitting: true),
      AuthState(submitting: false, error: 'Invalid email or password'),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'google cancel → no error shown',
    build: () {
      when(() => repo.authStateChanges).thenAnswer((_) => const Stream.empty());
      when(() => repo.signInWithGoogle())
          .thenAnswer((_) async => const Failure.serverError(message: '') as dynamic);
      return AuthCubit(repo);
    },
    act: (cubit) => cubit.signInWithGoogle(),
    expect: () => const <AuthState>[
      AuthState(submitting: true),
      AuthState(submitting: false),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'completeProfile saves and authenticates',
    build: () {
      when(() => repo.authStateChanges).thenAnswer((_) => const Stream.empty());
      when(() => repo.uploadAvatar(uid: 'u1', filePath: '/tmp/p.jpg'))
          .thenAnswer((_) async => const Right('http://avatar'));
      when(() => repo.saveProfile(user: any(named: 'user')))
          .thenAnswer((_) async => const Right(null));
      return AuthCubit(repo);
    },
    seed: () => const AuthState(status: AuthStatus.needsProfile, user: user),
    act: (cubit) => cubit.completeProfile(
      username: 'yo',
      bio: 'hi',
      avatarPath: '/tmp/p.jpg',
    ),
    verify: (_) {
      final captured =
          verify(() => repo.saveProfile(user: captureAny(named: 'user'))).captured;
      expect(
        captured.single,
        const AppUser(
          uid: 'u1',
          email: 'a@b.c',
          username: 'yo',
          bio: 'hi',
          avatarUrl: 'http://avatar',
        ),
      );
    },
    expect: () => const <AuthState>[
      AuthState(status: AuthStatus.needsProfile, user: user, submitting: true),
      AuthState(
        status: AuthStatus.authenticated,
        user: AppUser(uid: 'u1', email: 'a@b.c', username: 'yo', bio: 'hi', avatarUrl: 'http://avatar'),
      ),
    ],
  );
}
```

Note: the google-cancel stub typing (`as dynamic`) may need adjusting to the exact `Either` type; if `dart fix` rewrites it wrongly, replace with `thenAnswer((_) async => Left<Failure, AppUser>(const Failure.serverError(message: '')))`.

**Step 4:** Run `flutter test test/features/auth/` — all pass. Run `dart run build_runner build --delete-conflicting-outputs` for `auth_state.freezed.dart` if not yet generated. Commit: `feat(auth): auth cubit session state machine`.

---

### Task 8: DI + router redirect + splash

**Files:**
- Modify: `lib/core/di/service_locator.dart`
- Create: `lib/core/router/go_router_refresh.dart`
- Modify: `lib/core/router/app_router.dart`
- Create: `lib/features/auth/presentation/screens/splash_screen.dart`

**Step 1:** Register in `service_locator.dart`:

```dart
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_firebase_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // --- Data Sources ---
  getIt.registerLazySingleton<IAuthDataSource>(() => AuthFirebaseDataSource());

  // --- Repositories ---
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(getIt<IAuthDataSource>()),
  );

  // --- Cubits ---
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(getIt<IAuthRepository>()),
  );
}
```

**Step 2:** Create `go_router_refresh.dart`:

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adapts any Stream (e.g. a Cubit) into a Listenable for GoRouter's
/// refreshListenable.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription =
        stream.asBroadcastStream().listen((dynamic _) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
```

**Step 3:** Create `splash_screen.dart`:

```dart
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
```

**Step 4:** Replace `app_router.dart` (login/signup/onboarding screens come in Tasks 10–12; temporary inline placeholders keep it compiling until then — or do Tasks 9–13 before running):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../di/service_locator.dart';
import 'go_router_refresh.dart';
import 'route_constants.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    refreshListenable: GoRouterRefreshStream(getIt<AuthCubit>().stream),
    redirect: (BuildContext context, GoRouterState state) {
      final status = getIt<AuthCubit>().state.status;
      final loc = state.matchedLocation;
      final onAuthPage = loc == Routes.splash ||
          loc == Routes.login ||
          loc == Routes.signup ||
          loc == Routes.onboarding;
      return switch (status) {
        AuthStatus.loading => loc == Routes.splash ? null : Routes.splash,
        AuthStatus.unauthenticated => onAuthPage ? null : Routes.login,
        AuthStatus.needsProfile =>
          loc == Routes.onboarding ? null : Routes.onboarding,
        AuthStatus.authenticated => onAuthPage ? Routes.feed : null,
      };
    },
    routes: <RouteBase>[
      GoRoute(
        path: Routes.feed,
        name: 'Feed',
        builder: (BuildContext context, GoRouterState state) =>
            const FeedScreen(),
      ),
      GoRoute(
        path: Routes.splash,
        name: 'Splash',
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: Routes.login,
        name: 'Login',
        builder: (BuildContext context, GoRouterState state) =>
            BlocProvider<AuthCubit>.value(
          value: getIt<AuthCubit>(),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: Routes.signup,
        name: 'Signup',
        builder: (BuildContext context, GoRouterState state) =>
            BlocProvider<AuthCubit>.value(
          value: getIt<AuthCubit>(),
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: Routes.onboarding,
        name: 'Onboarding',
        builder: (BuildContext context, GoRouterState state) =>
            BlocProvider<AuthCubit>.value(
          value: getIt<AuthCubit>(),
          child: const OnboardingScreen(),
        ),
      ),
    ],
  );
}
```

**IMPORTANT:** `BlocProvider.value` (not `create:`) — the cubit is an app-scoped singleton and must not be disposed by the router.

Commit (after Tasks 10–13 make it compile): combined commit `feat(auth): routing, redirect guard, di`.

---

### Task 9: Localization strings

**Step 1:** Run each (the hook regenerates l10n):

```bash
fstr authLoginTitle "Connexion" "Log in"
fstr authSignupTitle "Créer un compte" "Create account"
fstr authEmail "Adresse e-mail" "Email address"
fstr authPassword "Mot de passe" "Password"
fstr authConfirmPassword "Confirmer le mot de passe" "Confirm password"
fstr authLogin "Se connecter" "Log in"
fstr authSignup "S'inscrire" "Sign up"
fstr authGoogleButton "Continuer avec Google" "Continue with Google"
fstr authNoAccount "Pas de compte ?" "No account?"
fstr authHasAccount "Déjà un compte ?" "Already have an account?"
fstr authOr "ou" "or"
fstr onboardingTitle "Crée ton profil" "Create your profile"
fstr onboardingUsername "Nom d'utilisateur" "Username"
fstr onboardingBio "Bio" "Bio"
fstr onboardingAddPhoto "Ajouter une photo" "Add a photo"
fstr onboardingDone "Terminer" "Done"
fstr feedPlaceholder "Le fil arrive en Phase 2" "Feed coming in Phase 2"
fstr actionLogout "Se déconnecter" "Log out"
```

If `fstr` is not on PATH, use `./scripts/fstr.sh <key> <fr> <en>` instead.

---

### Task 10: Login screen

**Files:**
- Create: `lib/features/auth/presentation/screens/login_screen.dart`
- Create: `lib/features/auth/presentation/widgets/auth_text_field.dart`

**Step 1:** Create shared `auth_text_field.dart`:

```dart
import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    required this.label,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
```

**Step 2:** Create `login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(state.error!)));
                }
              },
              child: BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (p, c) => p.submitting != c.submitting,
                builder: (context, state) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Instagram',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),
                      AuthTextField(
                        label: l10n.authEmail,
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        label: l10n.authPassword,
                        controller: _password,
                        obscure: true,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: state.submitting
                            ? null
                            : () => context.read<AuthCubit>().signIn(
                                  email: _email.text.trim(),
                                  password: _password.text,
                                ),
                        child: Text(l10n.authLogin),
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.authOr, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: state.submitting
                            ? null
                            : () => context.read<AuthCubit>().signInWithGoogle(),
                        icon: const Icon(Icons.login),
                        label: Text(l10n.authGoogleButton),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => context.go(Routes.signup),
                        child: Text('${l10n.authNoAccount} ${l10n.authSignup}'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### Task 11: Signup screen

**Files:**
- Create: `lib/features/auth/presentation/screens/signup_screen.dart`

**Step 1:** Same structure as login, plus confirm-password and a password-mismatch guard:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/router/route_constants.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.authSignupTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(state.error!)));
                }
              },
              child: BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (p, c) => p.submitting != c.submitting,
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AuthTextField(
                        label: l10n.authEmail,
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        label: l10n.authPassword,
                        controller: _password,
                        obscure: true,
                      ),
                      const SizedBox(height: 12),
                      AuthTextField(
                        label: l10n.authConfirmPassword,
                        controller: _confirm,
                        obscure: true,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: state.submitting ? null : _submit,
                        child: Text(l10n.authSignup),
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.authOr, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: state.submitting
                            ? null
                            : () => context.read<AuthCubit>().signInWithGoogle(),
                        icon: const Icon(Icons.login),
                        label: Text(l10n.authGoogleButton),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () => context.go(Routes.login),
                        child: Text('${l10n.authHasAccount} ${l10n.authLogin}'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_password.text != _confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    context.read<AuthCubit>().signUp(
          email: _email.text.trim(),
          password: _password.text,
        );
  }
}
```

---

### Task 12: Onboarding screen

**Files:**
- Create: `lib/features/auth/presentation/screens/onboarding_screen.dart`

**Step 1:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _username = TextEditingController();
  final _bio = TextEditingController();
  String? _avatarPath;

  @override
  void dispose() {
    _username.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 70,
    );
    if (picked != null) setState(() => _avatarPath = picked.path);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardingTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(state.error!)));
                }
              },
              child: BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (p, c) => p.submitting != c.submitting,
                builder: (context, state) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: CircleAvatar(
                          radius: 48,
                          backgroundImage: _avatarPath != null
                              ? FileImage(Uri.parse(_avatarPath!).toFile())
                              : null,
                          child: _avatarPath == null
                              ? const Icon(Icons.add_a_photo)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _pickAvatar,
                        child: Text(l10n.onboardingAddPhoto),
                      ),
                      TextField(
                        controller: _username,
                        decoration: InputDecoration(
                          labelText: l10n.onboardingUsername,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _bio,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: l10n.onboardingBio,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: state.submitting || _username.text.isEmpty
                            ? null
                            : () => context.read<AuthCubit>().completeProfile(
                                  username: _username.text.trim(),
                                  bio: _bio.text.trim().isEmpty
                                      ? null
                                      : _bio.text.trim(),
                                  avatarPath: _avatarPath,
                                ),
                        child: Text(l10n.onboardingDone),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

Note: `FileImage(Uri.parse(...).toFile())` needs `import 'dart:io';` + `import 'package:flutter/foundation.dart';` — simpler: `FileImage(File(_avatarPath!))` with `import 'dart:io';`. Use that.

---

### Task 13: Feed placeholder + logout

**Files:**
- Create: `lib/features/feed/presentation/screens/feed_screen.dart`
- Modify: `lib/app.dart` (title)

**Step 1:** Feed placeholder (Phase 2 replaces the body):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthCubit>().state.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instagram'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.feedPlaceholder),
            const SizedBox(height: 8),
            if (user?.username != null) Text('@${user!.username}'),
          ],
        ),
      ),
    );
  }
}
```

**Step 2:** In `lib/app.dart`, change `title:` to `'Instagram Clone'`.

**Step 3:** Run `flutter analyze` — zero errors. Run `flutter test` — all green. Commit: `feat(auth): login, signup, onboarding, feed placeholder screens`.

---

### Task 14: Native Google Sign-In config

**Android:**

```bash
cd android && ./gradlew signingReport
```

Copy the `SHA1` line of the `debug` variant. In Firebase console → Project settings → Your apps (Android) → Add fingerprint → paste SHA-1 → download the new `google-services.json` → replace `android/app/google-services.json`. (Enable Google sign-in in the console usually auto-creates the web client (type 3); if gradle still complains about `serverClientId`, add a Web app in console and re-download.)

**iOS:** `flutterfire configure` writes `GoogleService-Info.plist` handling. Verify in Xcode (`ios/Runner.xcodeproj`):
1. `Runner > Runner` contains `GoogleService-Info.plist`.
2. Info.plist has `CFBundleURLTypes` with the reversed client ID scheme (from GoogleService-Info.plist's `REVERSED_CLIENT_ID`).
3. If google_sign_in throws "clientId must be provided on iOS", add `GIDClientID` (the plain client ID) to Info.plist.

**Step: verify** `flutter analyze` + commit `chore: native google sign-in config`.

---

### Task 15: Final verification

**Step 1:**

```bash
flutter analyze && flutter test
```

Expected: no issues, all tests pass.

**Step 2: Manual smoke (`flutter run` on a device/emulator):**

- [ ] Splash → Login (cold start, signed out)
- [ ] Signup with bad password → snackbar "Password is too weak"
- [ ] Signup success → Onboarding
- [ ] Pick avatar + username + bio → Done → Feed with @username
- [ ] Logout → back to Login
- [ ] Login with created account → straight to Feed (profile exists)
- [ ] Google sign-in → onboarding (first time) → feed
- [ ] Firestore console shows `users/{uid}` doc; Storage shows `avatars/{uid}.jpg`

**Step 3:** In `README.md`, tick `Phase 1`. Commit: `chore: complete phase 1`.

---

## Deferred (later phases)

- Firestore security rules beyond test mode
- Username uniqueness check (Phase 3 — needs a `usernames` collection)
- Email verification / password reset
- Instagram-style visual design (fonts, colors) — polish phase
