// lib/app/modules/allPosts/controllers/all_posts_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/models/post_model.dart';
import '../../../routes/app_pages.dart';

class AllPostsController extends GetxController {
  final PostRepository _postRepository = Get.find<PostRepository>();

  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;

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
    searchQuery.value = query;
    loadPosts();
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
    loadPosts();
  }

  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = '';
    loadPosts();
  }

  Future<void> refreshPosts() async {
    await loadPosts();
  }

  void navigateToPostDetail(PostModel post) {
    Get.toNamed(Routes.POST_DETAIL, arguments: post);
  }
}
