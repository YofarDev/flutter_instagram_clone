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

  // --- Cubits (app-scoped) ---
  getIt.registerLazySingleton<AuthCubit>(
    () => AuthCubit(getIt<IAuthRepository>()),
  );
}
