import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_firebase_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/chat/data/datasources/chat_firebase_datasource.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/presentation/bloc/chat_cubit.dart';
import '../../features/chat/presentation/bloc/conversations_cubit.dart';
import '../../features/chat/presentation/bloc/new_chat_cubit.dart';
import '../../features/explore/data/datasources/explore_firebase_datasource.dart';
import '../../features/explore/data/repositories/explore_repository_impl.dart';
import '../../features/explore/domain/repositories/explore_repository.dart';
import '../../features/explore/presentation/bloc/explore_cubit.dart';
import '../../features/explore/presentation/bloc/hashtag_cubit.dart';
import '../../features/explore/presentation/bloc/search_cubit.dart';
import '../../features/feed/data/datasources/feed_firebase_datasource.dart';
import '../../features/feed/data/repositories/feed_repository_impl.dart';
import '../models/app_user.dart';
import '../models/post.dart';
import '../../features/feed/domain/repositories/feed_repository.dart';
import '../../features/feed/presentation/bloc/create_post_cubit.dart';
import '../../features/feed/presentation/bloc/feed_cubit.dart';
import '../../features/feed/presentation/bloc/post_detail_cubit.dart';
import '../../features/notifications/data/datasources/notifications_firebase_datasource.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/presentation/bloc/notifications_cubit.dart';
import '../../features/profile/data/datasources/profile_firebase_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/edit_profile_cubit.dart';
import '../../features/profile/presentation/bloc/follow_list_cubit.dart';
import '../../features/profile/presentation/bloc/profile_cubit.dart';
import '../../features/reels/data/datasources/reels_firebase_datasource.dart';
import '../../features/reels/data/repositories/reels_repository_impl.dart';
import '../../features/reels/domain/repositories/reels_repository.dart';
import '../../features/reels/presentation/bloc/create_reel_cubit.dart';
import '../../features/reels/presentation/bloc/reels_cubit.dart';
import '../../features/stories/data/datasources/stories_firebase_datasource.dart';
import '../../features/stories/data/repositories/stories_repository_impl.dart';
import '../../features/stories/domain/repositories/stories_repository.dart';
import '../../features/stories/presentation/bloc/create_story_cubit.dart';
import '../../features/stories/presentation/bloc/stories_cubit.dart';
import '../../features/stories/presentation/bloc/story_viewer_cubit.dart';

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
  getIt.registerFactoryParam<FeedCubit, String, void>(
    (String uid, _) => FeedCubit(
      getIt<IFeedRepository>(),
      getIt<IProfileRepository>(),
      myUid: uid,
    ),
  );
  getIt.registerFactory<CreatePostCubit>(
    () => CreatePostCubit(getIt<IFeedRepository>()),
  );
  getIt.registerFactoryParam<PostDetailCubit, Post?, String?>(
    (Post? post, String? postId) => PostDetailCubit(
      getIt<IFeedRepository>(),
      post: post,
      postId: postId,
    ),
  );

  // --- Profile feature ---
  getIt.registerLazySingleton<IProfileDataSource>(
    () => ProfileFirebaseDataSource(),
  );
  getIt.registerLazySingleton<IProfileRepository>(
    () => ProfileRepositoryImpl(getIt<IProfileDataSource>()),
  );
  getIt.registerFactoryParam<ProfileCubit, ProfileArgs, void>(
    (ProfileArgs args, _) => ProfileCubit(
      getIt<IProfileRepository>(),
      uid: args.uid,
      isMe: args.isMe,
    ),
  );
  getIt.registerFactoryParam<EditProfileCubit, AppUser, void>(
    (AppUser user, _) =>
        EditProfileCubit(getIt<IAuthRepository>(), user: user),
  );
  getIt.registerFactory<FollowListCubit>(
    () => FollowListCubit(getIt<IProfileRepository>()),
  );

  // --- Explore feature ---
  getIt.registerLazySingleton<IExploreDataSource>(
    () => ExploreFirebaseDataSource(),
  );
  getIt.registerLazySingleton<IExploreRepository>(
    () => ExploreRepositoryImpl(getIt<IExploreDataSource>()),
  );
  getIt.registerFactoryParam<ExploreCubit, String, void>(
    (String uid, _) => ExploreCubit(
      getIt<IExploreRepository>(),
      getIt<IProfileRepository>(),
      myUid: uid,
    ),
  );
  getIt.registerFactory<SearchCubit>(
    () => SearchCubit(getIt<IExploreRepository>()),
  );
  getIt.registerFactoryParam<HashtagCubit, String, void>(
    (String tag, _) => HashtagCubit(getIt<IExploreRepository>(), tag: tag),
  );

  // --- Stories feature ---
  getIt.registerLazySingleton<IStoriesDataSource>(
    () => StoriesFirebaseDataSource(),
  );
  getIt.registerLazySingleton<IStoriesRepository>(
    () => StoriesRepositoryImpl(getIt<IStoriesDataSource>()),
  );
  getIt.registerFactoryParam<StoriesCubit, String, void>(
    (String uid, _) => StoriesCubit(
      getIt<IStoriesRepository>(),
      myUid: uid,
    ),
  );
  getIt.registerFactory<CreateStoryCubit>(
    () => CreateStoryCubit(getIt<IStoriesRepository>()),
  );
  getIt.registerFactoryParam<StoryViewerCubit, StoryViewerArgs, void>(
    (StoryViewerArgs args, _) => StoryViewerCubit(
      getIt<IStoriesRepository>(),
      trays: args.trays,
      initialTrayIndex: args.initialTrayIndex,
    ),
  );

  // --- Notifications feature ---
  getIt.registerLazySingleton<INotificationsDataSource>(
    () => const NotificationsFirebaseDataSource(),
  );
  getIt.registerLazySingleton<INotificationsRepository>(
    () => NotificationsRepositoryImpl(getIt<INotificationsDataSource>()),
  );
  getIt.registerLazySingleton<NotificationsCubit>(
    () => NotificationsCubit(getIt<INotificationsRepository>()),
  );

  // --- Chat feature ---
  getIt.registerLazySingleton<IChatDataSource>(
    () => ChatFirebaseDataSource(),
  );
  getIt.registerLazySingleton<IChatRepository>(
    () => ChatRepositoryImpl(getIt<IChatDataSource>()),
  );
  getIt.registerFactoryParam<ConversationsCubit, String, void>(
    (String uid, _) => ConversationsCubit(
      getIt<IChatRepository>(),
      myUid: uid,
    ),
  );
  getIt.registerFactoryParam<ChatCubit, ChatArgs, void>(
    (ChatArgs args, _) => ChatCubit(
      getIt<IChatRepository>(),
      conversation: args.conversation,
      myUid: args.myUid,
    ),
  );
  getIt.registerFactoryParam<NewChatCubit, String, void>(
    (String uid, _) => NewChatCubit(
      getIt<IExploreRepository>(),
      getIt<IChatRepository>(),
      myUid: uid,
    ),
  );

  // --- Reels feature ---
  getIt.registerLazySingleton<IReelsDataSource>(
    () => const ReelsFirebaseDataSource(),
  );
  getIt.registerLazySingleton<IReelsRepository>(
    () => ReelsRepositoryImpl(getIt<IReelsDataSource>()),
  );
  getIt.registerFactory<ReelsCubit>(
    () => ReelsCubit(getIt<IReelsRepository>()),
  );
  getIt.registerFactory<CreateReelCubit>(
    () => CreateReelCubit(getIt<IReelsRepository>()),
  );
}
