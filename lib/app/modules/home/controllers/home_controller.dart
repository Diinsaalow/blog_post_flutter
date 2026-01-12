// lib/app/modules/home/controllers/home_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/models/post_model.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final PostRepository _postRepository = Get.find<PostRepository>();

  final RxList<PostModel> featuredPosts = <PostModel>[].obs;
  final RxList<PostModel> recentPosts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
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
}
