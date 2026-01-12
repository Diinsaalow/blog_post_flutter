// lib/app/modules/allPosts/controllers/all_posts_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/models/post_model.dart';
import '../../../routes/app_pages.dart';
import '../../../core/services/storage_service.dart';

class AllPostsController extends GetxController {
  final PostRepository _postRepository = Get.find<PostRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;

  Timer? _debounceTimer;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      isLoading.value = true;
      final allPosts = await _postRepository.getAllPosts(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
        category: selectedCategory.value.isEmpty
            ? null
            : selectedCategory.value,
      );
      posts.value = allPosts;
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

  void searchPosts(String query) {
    // Cancel the previous timer
    _debounceTimer?.cancel();

    // Update the search query immediately for UI feedback
    searchQuery.value = query;

    // Set a new timer for debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      loadPosts();
    });
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    loadPosts();
  }

  void clearFilters() {
    searchQuery.value = '';
    searchController.clear();
    selectedCategory.value = '';
    loadPosts();
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
        Get.snackbar(
          'Success',
          'Added to bookmarks',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          duration: const Duration(seconds: 2),
        );
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

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
