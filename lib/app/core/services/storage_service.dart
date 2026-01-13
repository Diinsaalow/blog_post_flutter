// lib/app/core/services/storage_service.dart
import 'package:get_storage/get_storage.dart';

class StorageService {
  static final GetStorage _storage = GetStorage();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _favoritesKey = 'favorites';

  // Token
  static Future<void> saveToken(String token) async {
    await _storage.write(_tokenKey, token);
  }

  static String? getToken() => _storage.read(_tokenKey);

  static Future<void> removeToken() async {
    await _storage.remove(_tokenKey);
  }

  // User
  static Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(_userKey, user);
    // Sync favorites from user bookmarks if available
    if (user['bookmarks'] != null && user['bookmarks'] is List) {
      final bookmarks = List<String>.from(user['bookmarks']);
      await _storage.write(_favoritesKey, bookmarks);
    }
  }

  static Map<String, dynamic>? getUser() => _storage.read(_userKey);

  // Favorites - now synced with backend bookmarks
  static Future<void> addFavorite(String postId) async {
    final favorites = getFavorites();
    if (!favorites.contains(postId)) {
      favorites.add(postId);
      await _storage.write(_favoritesKey, favorites);

      // Update user data in storage to reflect the change
      final user = getUser();
      if (user != null) {
        user['bookmarks'] = favorites;
        await _storage.write(_userKey, user);
      }
    }
  }

  static Future<void> removeFavorite(String postId) async {
    final favorites = getFavorites();
    favorites.remove(postId);
    await _storage.write(_favoritesKey, favorites);

    // Update user data in storage to reflect the change
    final user = getUser();
    if (user != null) {
      user['bookmarks'] = favorites;
      await _storage.write(_userKey, user);
    }
  }

  static List<String> getFavorites() {
    // First try to get from user data (synced with backend)
    final user = getUser();
    if (user != null &&
        user['bookmarks'] != null &&
        user['bookmarks'] is List) {
      return List<String>.from(user['bookmarks']);
    }

    // Fallback to local favorites
    final favorites = _storage.read<List<dynamic>>(_favoritesKey);
    return favorites?.map((e) => e.toString()).toList() ?? [];
  }

  static bool isFavorite(String postId) {
    return getFavorites().contains(postId);
  }

  /// Sync local favorites with backend bookmarks
  /// This ensures local storage matches the source of truth (backend)
  static Future<void> syncFavoritesFromBackend(List<String> bookmarkIds) async {
    await _storage.write(_favoritesKey, bookmarkIds);

    // Update user data in storage to reflect the synced bookmarks
    final user = getUser();
    if (user != null) {
      user['bookmarks'] = bookmarkIds;
      await _storage.write(_userKey, user);
    }
  }

  // Auth status
  static bool get isLoggedIn => getToken() != null;

  // Clear all
  static Future<void> clearAll() async {
    await _storage.erase();
  }
}
