// lib/app/data/repositories/user_repository.dart
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';
import '../models/user_model.dart';

class UserRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Get user profile with bookmarks
  Future<UserModel> getProfile() async {
    try {
      final response = await _apiService.get(ApiConstants.userProfile);

      if (response['success'] == true && response['data'] != null) {
        final user = UserModel.fromJson(response['data']);
        // Update local storage with latest user data
        await StorageService.saveUser(user.toJson());
        return user;
      }

      throw Exception(response['message'] ?? 'Failed to get profile');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({String? username, String? avatarUrl}) async {
    try {
      final body = <String, dynamic>{};
      if (username != null) body['username'] = username;
      if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

      final response = await _apiService.put(ApiConstants.userProfile, body);

      if (response['success'] == true && response['data'] != null) {
        final user = UserModel.fromJson(response['data']);
        await StorageService.saveUser(user.toJson());
        return user;
      }

      throw Exception(response['message'] ?? 'Failed to update profile');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Add a post to bookmarks
  Future<void> addBookmark(String postId) async {
    try {
      final response = await _apiService.post(
        ApiConstants.addBookmark(postId),
        null,
      );

      if (response['success'] == true) {
        // Update local storage
        await StorageService.addFavorite(postId);

        // Optionally, fetch updated user profile to sync bookmarks
        await _syncBookmarks();
      } else {
        throw Exception(response['message'] ?? 'Failed to add bookmark');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Remove a post from bookmarks
  Future<void> removeBookmark(String postId) async {
    try {
      final response = await _apiService.delete(
        ApiConstants.removeBookmark(postId),
      );

      if (response['success'] == true) {
        // Update local storage
        await StorageService.removeFavorite(postId);

        // Optionally, fetch updated user profile to sync bookmarks
        await _syncBookmarks();
      } else {
        throw Exception(response['message'] ?? 'Failed to remove bookmark');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Get all bookmarked posts
  Future<List<Map<String, dynamic>>> getBookmarks() async {
    try {
      final response = await _apiService.get(ApiConstants.userBookmarks);

      if (response['success'] == true && response['data'] != null) {
        return List<Map<String, dynamic>>.from(response['data']);
      }

      throw Exception(response['message'] ?? 'Failed to get bookmarks');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Sync bookmarks from backend to local storage
  Future<void> _syncBookmarks() async {
    try {
      await getProfile();
      // The profile call already updates storage with latest bookmarks
    } catch (e) {
      // Silently fail sync, don't affect the main operation
      print('Failed to sync bookmarks: $e');
    }
  }

  /// Check if a post is bookmarked (from local storage)
  bool isBookmarked(String postId) {
    return StorageService.isFavorite(postId);
  }
}
