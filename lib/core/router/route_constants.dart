abstract final class Routes {
  static const String splash = '/splash';
  static const String feed = '/';
  static const String create = '/create';
  static const String postDetail = '/post/:id';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String onboarding = '/onboarding';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String user = '/user/:uid';
  static const String userFollowers = '/user/:uid/followers';
  static const String userFollowing = '/user/:uid/following';
  static const String createStory = '/create-story';
  static const String storyViewer = '/story-viewer';

  static String userPath(String uid) => user.replaceFirst(':uid', uid);
  static String userFollowersPath(String uid) =>
      userFollowers.replaceFirst(':uid', uid);
  static String userFollowingPath(String uid) =>
      userFollowing.replaceFirst(':uid', uid);
  static String postDetailPath(String id) => postDetail.replaceFirst(':id', id);
}
