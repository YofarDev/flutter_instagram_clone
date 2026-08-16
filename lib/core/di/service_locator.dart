import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_firebase_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/feed/data/datasources/feed_firebase_datasource.dart';
import '../../features/feed/data/repositories/feed_repository_impl.dart';
import '../../features/feed/domain/models/post.dart';
import '../../features/feed/domain/repositories/feed_repository.dart';
import '../../features/feed/presentation/bloc/create_post_cubit.dart';
import '../../features/feed/presentation/bloc/feed_cubit.dart';
import '../../features/feed/presentation/bloc/post_detail_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // --- Data Sources ---
  getIt.registerLazySingleton<IAuthDataSource>(() => AuthFirebaseDataSource());

  // --- Repositories ---
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(getIt<IAuthDataSource>()),
  );

  // --- Cubits (app-scoped) ---
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(getIt<IAuthRepository>()),
  );

  // --- Feed feature ---
  getIt.registerLazySingleton<IFeedDataSource>(() => FeedFirebaseDataSource());
  getIt.registerLazySingleton<IFeedRepository>(
    () => FeedRepositoryImpl(getIt<IFeedDataSource>()),
  );
  getIt.registerFactory<FeedCubit>(() => FeedCubit(getIt<IFeedRepository>()));
  getIt.registerFactory<CreatePostCubit>(
    () => CreatePostCubit(getIt<IFeedRepository>()),
  );
  getIt.registerFactoryParam<PostDetailCubit, Post, void>(
    (Post post, _) => PostDetailCubit(getIt<IFeedRepository>(), post: post),
  );
}
