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
  }
  
  static Map<String, dynamic>? getUser() => _storage.read(_userKey);
  
  // Favorites
  static Future<void> addFavorite(String postId) async {
    final favorites = getFavorites();
    if (!favorites.contains(postId)) {
      favorites.add(postId);
      await _storage.write(_favoritesKey, favorites);
    }
  }
  
  static Future<void> removeFavorite(String postId) async {
    final favorites = getFavorites();
    favorites.remove(postId);
    await _storage.write(_favoritesKey, favorites);
  }
  
  static List<String> getFavorites() {
    final favorites = _storage.read<List<dynamic>>(_favoritesKey);
    return favorites?.map((e) => e.toString()).toList() ?? [];
  }
  
  static bool isFavorite(String postId) {
    return getFavorites().contains(postId);
  }
  
  // Auth status
  static bool get isLoggedIn => getToken() != null;
  
  // Clear all
  static Future<void> clearAll() async {
    await _storage.erase();
  }
}