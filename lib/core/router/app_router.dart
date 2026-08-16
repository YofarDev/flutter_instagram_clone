import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/feed/domain/models/post.dart';
import '../../features/feed/presentation/bloc/create_post_cubit.dart';
import '../../features/feed/presentation/bloc/feed_cubit.dart';
import '../../features/feed/presentation/bloc/post_detail_cubit.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
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
            BlocProvider<FeedCubit>(
          create: (_) => getIt<FeedCubit>(),
          child: BlocProvider<AuthCubit>.value(
            value: getIt<AuthCubit>(),
            child: const FeedScreen(),
          ),
        ),
      ),
      GoRoute(
        path: Routes.create,
        name: 'CreatePost',
        builder: (BuildContext context, GoRouterState state) =>
            BlocProvider<CreatePostCubit>(
          create: (_) => getIt<CreatePostCubit>(),
          child: const Scaffold(
            body: Center(child: Text('Create placeholder')),
          ), // TODO(phase2-tasks-8-9): replace with CreatePostScreen
        ),
      ),
      GoRoute(
        path: Routes.postDetail,
        name: 'PostDetail',
        builder: (BuildContext context, GoRouterState state) {
          final Post post = state.extra! as Post;
          return BlocProvider<PostDetailCubit>(
            create: (_) => getIt<PostDetailCubit>(param1: post),
            child: const Scaffold(
              body: Center(child: Text('Detail placeholder')),
            ), // TODO(phase2-tasks-8-9): replace with PostDetailScreen
          );
        },
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
