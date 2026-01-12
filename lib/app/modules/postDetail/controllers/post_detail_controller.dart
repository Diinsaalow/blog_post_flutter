// lib/app/modules/postDetail/controllers/post_detail_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/comment_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/comment_model.dart';
import '../../../core/services/storage_service.dart';

class PostDetailController extends GetxController {
  final PostRepository _postRepository = Get.find<PostRepository>();
  final CommentRepository _commentRepository = Get.find<CommentRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  final Rx<PostModel?> post = Rx<PostModel?>(null);
  final RxList<CommentModel> comments = <CommentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCommentsLoading = false.obs;
  final RxBool isFavorite = false.obs;

  @override
  void onInit() {
    super.onInit();
    final postArg = Get.arguments as PostModel?;
    if (postArg != null) {
      post.value = postArg;
      isFavorite.value = StorageService.isFavorite(postArg.id);

      // Fetch full post details by slug to get content
      loadPostBySlug(postArg.slug);
    } else {
      final slug = Get.parameters['slug'];
      if (slug != null) {
        loadPostBySlug(slug);
      }
    }
  }

  Future<void> loadPostBySlug(String slug) async {
    try {
      isLoading.value = true;
      final postData = await _postRepository.getPostBySlug(slug);
      post.value = postData;
      isFavorite.value = StorageService.isFavorite(postData.id);
      loadComments();
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadComments() async {
    if (post.value == null) return;

    try {
      isCommentsLoading.value = true;
      final commentsData = await _commentRepository.getCommentsByPost(
        post.value!.id,
      );
      comments.value = commentsData;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load comments: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isCommentsLoading.value = false;
    }
  }

  Future<void> toggleFavorite() async {
    if (post.value == null) return;

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
      if (isFavorite.value) {
        await _userRepository.removeBookmark(post.value!.id);
        isFavorite.value = false;
        Get.snackbar(
          'Removed',
          'Removed from bookmarks',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
        );
      } else {
        await _userRepository.addBookmark(post.value!.id);
        isFavorite.value = true;
        Get.snackbar(
          'Added',
          'Added to bookmarks',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
          colorText: Get.theme.primaryColor,
        );
      }
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

  Future<void> addComment(String content) async {
    if (post.value == null || content.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Comment cannot be empty',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      final comment = await _commentRepository.createComment(
        postId: post.value!.id,
        content: content.trim(),
      );
      comments.insert(0, comment);
      Get.snackbar(
        'Success',
        'Comment added',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
        colorText: Get.theme.primaryColor,
      );
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

  Future<void> refreshComments() async {
    await loadComments();
  }
}
