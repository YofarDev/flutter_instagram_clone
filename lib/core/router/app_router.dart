import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../di/service_locator.dart';
import 'go_router_refresh.dart';
import 'route_constants.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    refreshListenable: GoRouterRefreshStream(getIt<AuthCubit>().stream),
    redirect: (BuildContext context, GoRouterState state) {
      final AuthStatus status = getIt<AuthCubit>().state.status;
      final String loc = state.matchedLocation;
      final bool onAuthPage = loc == Routes.splash ||
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
            const Scaffold(body: Center(child: Text('Feed placeholder'))),
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
          child: const Scaffold(
            body: Center(child: Text('Login placeholder')),
          ), // TODO(phase1-tasks-10-13): replace with LoginScreen
        ),
      ),
      GoRoute(
        path: Routes.signup,
        name: 'Signup',
        builder: (BuildContext context, GoRouterState state) =>
            BlocProvider<AuthCubit>.value(
          value: getIt<AuthCubit>(),
          child: const Scaffold(
            body: Center(child: Text('Signup placeholder')),
          ), // TODO(phase1-tasks-10-13): replace with SignupScreen
        ),
      ),
      GoRoute(
        path: Routes.onboarding,
        name: 'Onboarding',
        builder: (BuildContext context, GoRouterState state) =>
            BlocProvider<AuthCubit>.value(
          value: getIt<AuthCubit>(),
          child: const Scaffold(
            body: Center(child: Text('Onboarding placeholder')),
          ), // TODO(phase1-tasks-10-13): replace with OnboardingScreen
        ),
      ),
    ],
  );
}
