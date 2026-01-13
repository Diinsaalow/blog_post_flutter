// lib/app/modules/favorites/controllers/favorites_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/models/post_model.dart';
import '../../../core/services/storage_service.dart';
import '../../../routes/app_pages.dart';

class FavoritesController extends GetxController {
  final PostRepository _postRepository = Get.find<PostRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  final RxList<PostModel> favoritePosts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    if (!StorageService.isLoggedIn) {
      favoritePosts.clear();
      return;
    }

    try {
      isLoading.value = true;

      // Fetch bookmarks from backend
      final bookmarksData = await _userRepository.getBookmarks();

      if (bookmarksData.isEmpty) {
        favoritePosts.clear();
        // Clear local storage if backend has no bookmarks
        await StorageService.syncFavoritesFromBackend([]);
        return;
      }

      // Convert bookmarks data to PostModel list with better error handling
      final List<PostModel> posts = [];
      for (var bookmarkData in bookmarksData) {
        try {
          final post = PostModel.fromJson(bookmarkData);
          posts.add(post);
        } catch (parseError) {
          print('Failed to parse bookmark: $parseError');
          print('Data: $bookmarkData');
          // Continue with other bookmarks instead of failing completely
        }
      }

      favoritePosts.value = posts;

      // Sync local storage with backend data
      final bookmarkIds = posts.map((post) => post.id).toList();
      await StorageService.syncFavoritesFromBackend(bookmarkIds);
    } catch (e, stackTrace) {
      print('Error loading bookmarks: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load bookmarks: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );

      // Fallback to local storage if backend fails
      try {
        final favoriteIds = StorageService.getFavorites();
        if (favoriteIds.isNotEmpty) {
          final allPosts = await _postRepository.getAllPosts();
          favoritePosts.value = allPosts
              .where((post) => favoriteIds.contains(post.id))
              .toList();
        }
      } catch (fallbackError) {
        // Silently fail fallback
        print('Fallback load also failed: $fallbackError');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(PostModel post) async {
    if (!StorageService.isLoggedIn) {
      Get.snackbar(
        'Login Required',
        'Please login to bookmark posts',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.1),
        colorText: Colors.orange,
      );
      return;
    }

    try {
      // Check against the actual loaded favorites list, not just local storage
      final isCurrentlyFavorite = favoritePosts.any((p) => p.id == post.id);

      if (isCurrentlyFavorite) {
        await _userRepository.removeBookmark(post.id);
        favoritePosts.removeWhere((p) => p.id == post.id);
        // Get.snackbar(
        //   'Removed',
        //   'Removed from bookmarks',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.orange.withOpacity(0.1),
        //   colorText: Colors.orange,
        // );
      } else {
        await _userRepository.addBookmark(post.id);
        // Only add if not already in the list
        if (!favoritePosts.any((p) => p.id == post.id)) {
          favoritePosts.add(post);
        }
        // Get.snackbar(
        //   'Added',
        //   'Added to bookmarks',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
        //   colorText: Get.theme.primaryColor,
        // );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update bookmark: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      // Reload favorites to ensure sync with backend on error
      await loadFavorites();
    }
  }

  Future<void> refreshFavorites() async {
    await loadFavorites();
  }

  void navigateToPostDetail(PostModel post) {
    Get.toNamed(Routes.POST_DETAIL, arguments: post);
  }

  bool isFavorite(String postId) {
    // Check against loaded favorites first, fall back to storage
    if (favoritePosts.isNotEmpty) {
      return favoritePosts.any((post) => post.id == postId);
    }
    return StorageService.isFavorite(postId);
  }
}
