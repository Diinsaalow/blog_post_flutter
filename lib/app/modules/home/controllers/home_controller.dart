// lib/app/modules/home/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/models/post_model.dart';
import '../../../routes/app_pages.dart';
import '../../../core/services/storage_service.dart';

class HomeController extends GetxController {
  final PostRepository _postRepository = Get.find<PostRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  final RxList<PostModel> featuredPosts = <PostModel>[].obs;
  final RxList<PostModel> recentPosts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
    // Sync bookmarks from backend on app start if logged in
    if (StorageService.isLoggedIn) {
      _syncBookmarksFromBackend();
    }
  }

  /// Sync bookmarks from backend to local storage
  Future<void> _syncBookmarksFromBackend() async {
    try {
      await _userRepository.getProfile();
    } catch (e) {
      // Silently fail sync, don't interrupt user experience
      print('Failed to sync bookmarks on app start: $e');
    }
  }

  Future<void> loadPosts() async {
    try {
      isLoading.value = true;
      final featured = await _postRepository.getFeaturedPosts();
      final recent = await _postRepository.getRecentPosts();

      featuredPosts.value = featured;
      recentPosts.value = recent;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load posts: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPosts() async {
    await loadPosts();
  }

  void navigateToPostDetail(PostModel post) {
    Get.toNamed(Routes.POST_DETAIL, arguments: post);
  }

  /// Toggle bookmark for a post (syncs with backend)
  Future<void> toggleBookmark(String postId) async {
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
      final isBookmarked = StorageService.isFavorite(postId);

      if (isBookmarked) {
        await _userRepository.removeBookmark(postId);
        Get.snackbar(
          'Success',
          'Removed from bookmarks',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          duration: const Duration(seconds: 2),
        );
      } else {
        await _userRepository.addBookmark(postId);
        // Get.snackbar(
        //   'Success',
        //   'Added to bookmarks',
        //   snackPosition: SnackPosition.BOTTOM,
        //   backgroundColor: Colors.green.withOpacity(0.1),
        //   colorText: Colors.green,
        //   duration: const Duration(seconds: 2),
        // );
      }

      // Trigger UI update
      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update bookmark: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }
}
