// lib/app/core/constants/api_constants.dart
class ApiConstants {
  // Update with your actual API URL
  static const String baseUrl =
      'https://blog-post-api-ac7ca4fe3ed0.herokuapp.com/api';
  // For Android emulator: 'http://10.0.2.5:3000/api'
  // For iOS simulator: 'http://localhost:3000/api'
  // For physical device: 'http://YOUR_IP:3000/api'

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // Posts
  static const String posts = '/posts';
  static const String featuredPosts = '/posts/featured';
  static const String recentPosts = '/posts/recent';

  // Comments
  static String commentsByPost(String postId) => '/posts/$postId/comments';
  static String comment(String id) => '/comments/$id';
  static String updateComment(String id) => '/comments/$id';
  static String deleteComment(String id) => '/comments/$id';

  // User
  static const String userProfile = '/me';
  static const String userBookmarks = '/me/bookmarks';
  static String addBookmark(String postId) => '/me/bookmarks/$postId';
  static String removeBookmark(String postId) => '/me/bookmarks/$postId';
}
