import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/explore/presentation/bloc/explore_cubit.dart';
import '../../features/explore/presentation/bloc/hashtag_cubit.dart';
import '../../features/explore/presentation/bloc/search_cubit.dart';
import '../../features/explore/presentation/screens/hashtag_screen.dart';
import '../../features/explore/presentation/screens/search_screen.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';
import '../../features/notifications/presentation/bloc/notifications_state.dart';
import '../../features/notifications/presentation/widgets/badge_icon.dart';
import '../models/app_user.dart';
import '../models/post.dart';
import '../../features/feed/presentation/bloc/create_post_cubit.dart';
import '../../features/feed/presentation/bloc/feed_cubit.dart';
import '../../features/feed/presentation/bloc/post_detail_cubit.dart';
import '../../features/feed/presentation/screens/create_post_screen.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/feed/presentation/screens/post_detail_screen.dart';
import '../../features/profile/presentation/bloc/edit_profile_cubit.dart';
import '../../features/profile/presentation/bloc/follow_list_cubit.dart';
import '../../features/profile/presentation/bloc/profile_cubit.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/user_list_screen.dart';
import '../../features/stories/presentation/bloc/create_story_cubit.dart';
import '../../features/stories/presentation/bloc/stories_cubit.dart';
import '../../features/stories/presentation/bloc/story_viewer_cubit.dart';
import '../../features/stories/presentation/screens/create_story_screen.dart';
import '../../features/stories/presentation/screens/story_viewer_screen.dart';
import '../di/service_locator.dart';
import 'go_router_refresh.dart';
import 'route_constants.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _feedNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _searchNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _createNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _activityNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _profileNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: GoRouterRefreshStream(getIt<AuthCubit>().stream),
    redirect: (BuildContext context, GoRouterState state) {
      final AuthStatus status = getIt<AuthCubit>().state.status;
      final String loc = state.matchedLocation;
      final bool onAuthPage =
          loc == Routes.splash ||
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
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              // Idempotent — safe on every router rebuild; shell is post-auth
              // (redirect guarantees user is non-null here).
              final NotificationsCubit notificationsCubit =
                  getIt<NotificationsCubit>()
                    ..init(getIt<AuthCubit>().state.user!.uid);
              return BlocProvider<NotificationsCubit>.value(
                value: notificationsCubit,
                child: Scaffold(
                  body: navigationShell,
                  bottomNavigationBar:
                      BlocBuilder<NotificationsCubit, NotificationsState>(
                    buildWhen: (NotificationsState previous,
                            NotificationsState current) =>
                        previous.unreadCount != current.unreadCount,
                    builder: (BuildContext context, NotificationsState state) =>
                        NavigationBar(
                      selectedIndex: navigationShell.currentIndex,
                      onDestinationSelected: (int i) => navigationShell.goBranch(
                        i,
                        initialLocation: i == navigationShell.currentIndex,
                      ),
                      destinations: <NavigationDestination>[
                        const NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: 'Feed',
                        ),
                        const NavigationDestination(
                          icon: Icon(Icons.search),
                          selectedIcon: Icon(Icons.search),
                          label: 'Search',
                        ),
                        const NavigationDestination(
                          icon: Icon(Icons.add_box_outlined),
                          selectedIcon: Icon(Icons.add_box),
                          label: 'Create',
                        ),
                        NavigationDestination(
                          icon: BadgeIcon(
                            icon: Icons.favorite_outline,
                            count: state.unreadCount,
                          ),
                          selectedIcon: BadgeIcon(
                            icon: Icons.favorite,
                            count: state.unreadCount,
                          ),
                          label: 'Activity',
                        ),
                        const NavigationDestination(
                          icon: Icon(Icons.person_outline),
                          selectedIcon: Icon(Icons.person),
                          label: 'Profile',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: _feedNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: Routes.feed,
                name: 'Feed',
                builder: (BuildContext context, GoRouterState state) =>
                    MultiBlocProvider(
                      providers: <BlocProvider<dynamic>>[
                        BlocProvider<AuthCubit>.value(
                          value: getIt<AuthCubit>(),
                        ),
                        BlocProvider<FeedCubit>(
                          create: (_) => getIt<FeedCubit>(
                            param1: getIt<AuthCubit>().state.user!.uid,
                          ),
                        ),
                        BlocProvider<StoriesCubit>(
                          create: (_) => getIt<StoriesCubit>(
                            param1: getIt<AuthCubit>().state.user!.uid,
                          ),
                        ),
                      ],
                      child: const FeedScreen(),
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: Routes.search,
                name: 'Search',
                builder: (BuildContext context, GoRouterState state) =>
                    MultiBlocProvider(
                  providers: <BlocProvider<dynamic>>[
                    BlocProvider<ExploreCubit>(
                      create: (_) => getIt<ExploreCubit>(
                        param1: getIt<AuthCubit>().state.user!.uid,
                      ),
                    ),
                    BlocProvider<SearchCubit>(
                      create: (_) => getIt<SearchCubit>(),
                    ),
                  ],
                  child: const SearchScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _createNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: Routes.create,
                name: 'CreatePost',
                builder: (BuildContext context, GoRouterState state) =>
                    BlocProvider<CreatePostCubit>(
                      create: (_) => getIt<CreatePostCubit>(),
                      child: const CreatePostScreen(),
                    ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _activityNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: Routes.activity,
                name: 'Activity',
                builder: (BuildContext context, GoRouterState state) =>
                    // TODO(phase6-task-5): replace with ActivityScreen
                    const Scaffold(
                  body: Center(child: Text('Activity')),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: Routes.profile,
                name: 'Profile',
                builder: (BuildContext context, GoRouterState state) {
                  final String uid = getIt<AuthCubit>().state.user!.uid;
                  return BlocProvider<ProfileCubit>(
                    create: (_) => getIt<ProfileCubit>(
                      param1: ProfileArgs(uid: uid, isMe: true),
                    ),
                    child: const ProfileScreen(),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.postDetail,
        name: 'PostDetail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          if (extra is! Post) {
            return const Scaffold(body: Center(child: Text('Post not found')));
          }
          final Post post = extra;
          return BlocProvider<PostDetailCubit>(
            create: (_) => getIt<PostDetailCubit>(param1: post),
            child: const PostDetailScreen(),
          );
        },
      ),
      GoRoute(
        path: Routes.hashtag,
        name: 'Hashtag',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final String? tag = state.pathParameters['tag'];
          if (tag == null || tag.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('Hashtag not found')),
            );
          }
          return BlocProvider<HashtagCubit>(
            create: (_) => getIt<HashtagCubit>(param1: tag),
            child: HashtagScreen(tag: tag),
          );
        },
      ),
      GoRoute(
        path: Routes.user,
        name: 'UserProfile',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final String uid = state.pathParameters['uid']!;
          final bool isMe = uid == getIt<AuthCubit>().state.user!.uid;
          return BlocProvider<ProfileCubit>(
            create: (_) => getIt<ProfileCubit>(
              param1: ProfileArgs(uid: uid, isMe: isMe),
            ),
            child: const ProfileScreen(),
          );
        },
      ),
      GoRoute(
        path: Routes.userFollowers,
        name: 'UserFollowers',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            BlocProvider<FollowListCubit>(
              create: (_) => getIt<FollowListCubit>()
                ..load(uid: state.pathParameters['uid']!, followersMode: true),
              child: const UserListScreen(followersMode: true),
            ),
      ),
      GoRoute(
        path: Routes.userFollowing,
        name: 'UserFollowing',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            BlocProvider<FollowListCubit>(
              create: (_) => getIt<FollowListCubit>()
                ..load(uid: state.pathParameters['uid']!, followersMode: false),
              child: const UserListScreen(followersMode: false),
            ),
      ),
      GoRoute(
        path: Routes.profileEdit,
        name: 'EditProfile',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          if (extra is! AppUser) {
            return const Scaffold(body: Center(child: Text('User not found')));
          }
          return BlocProvider<EditProfileCubit>(
            create: (_) => getIt<EditProfileCubit>(param1: extra),
            child: const EditProfileScreen(),
          );
        },
      ),
      GoRoute(
        path: Routes.createStory,
        name: 'CreateStory',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) =>
            BlocProvider<CreateStoryCubit>(
              create: (_) => getIt<CreateStoryCubit>(),
              child: const CreateStoryScreen(),
            ),
      ),
      GoRoute(
        path: Routes.storyViewer,
        name: 'StoryViewer',
        parentNavigatorKey: rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          if (extra is! StoryViewerArgs) {
            return const Scaffold(
              body: Center(child: Text('Stories not found')),
            );
          }
          return BlocProvider<StoryViewerCubit>(
            create: (_) => getIt<StoryViewerCubit>(param1: extra),
            child: const StoryViewerScreen(),
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
