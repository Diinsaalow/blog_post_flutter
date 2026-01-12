// lib/app/modules/favorites/controllers/favorites_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/models/post_model.dart';
import '../../../core/services/storage_service.dart';
import '../../../routes/app_pages.dart';

class FavoritesController extends GetxController {
  final PostRepository _postRepository = Get.find<PostRepository>();

  final RxList<PostModel> favoritePosts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      isLoading.value = true;
      final favoriteIds = StorageService.getFavorites();

      if (favoriteIds.isEmpty) {
        favoritePosts.clear();
        return;
      }

      // Load all posts and filter favorites
      final allPosts = await _postRepository.getAllPosts();
      favoritePosts.value = allPosts
          .where((post) => favoriteIds.contains(post.id))
          .toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load favorites: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(PostModel post) async {
    try {
      if (StorageService.isFavorite(post.id)) {
        await StorageService.removeFavorite(post.id);
        favoritePosts.removeWhere((p) => p.id == post.id);
        Get.snackbar(
          'Removed',
          'Removed from favorites',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
        );
      } else {
        await StorageService.addFavorite(post.id);
        favoritePosts.add(post);
        Get.snackbar(
          'Added',
          'Added to favorites',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
          colorText: Get.theme.primaryColor,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  Future<void> refreshFavorites() async {
    await loadFavorites();
  }

  void navigateToPostDetail(PostModel post) {
    Get.toNamed(Routes.POST_DETAIL, arguments: post);
  }

  bool isFavorite(String postId) {
    return StorageService.isFavorite(postId);
  }
}
