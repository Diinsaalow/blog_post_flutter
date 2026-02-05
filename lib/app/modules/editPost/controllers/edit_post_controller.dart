import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/models/post_model.dart';
import 'package:blog_post_flutter/app/modules/home/controllers/home_controller.dart';
import 'package:blog_post_flutter/app/modules/postDetail/controllers/post_detail_controller.dart';

class EditPostController extends GetxController {
  final PostRepository _postRepository = Get.find<PostRepository>();

  late PostModel _post;

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final excerptController = TextEditingController();
  final categoryController = TextEditingController();

  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString currentImageUrl = ''.obs;
  final RxBool isLoading = false.obs;
  final RxBool isFeatured = false.obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is PostModel) {
      _post = Get.arguments as PostModel;
      _initializeFields();
    } else {
      Get.snackbar('Error', 'Post data missing');
      Get.back();
    }
  }

  void _initializeFields() {
    titleController.text = _post.title;
    contentController.text = _post.content ?? '';
    excerptController.text = _post.excerpt ?? '';
    categoryController.text = _post.category ?? '';
    isFeatured.value = _post.isFeatured;
    if (_post.coverImageUrl != null) {
      currentImageUrl.value = _post.coverImageUrl!;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    excerptController.dispose();
    categoryController.dispose();
    super.onClose();
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  void removeImage() {
    selectedImage.value = null;
    // Note: We don't remove currentImageUrl here because currently API doesn't support
    // removing image without replacing it comfortably, or we can add logic later.
    // For now, removing new image reverts to showing nothing selected (will keep old image on server)
  }

  Future<void> updatePost() async {
    if (titleController.text.isEmpty || contentController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Title and Content are required',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    try {
      isLoading.value = true;
      final updatedPost = await _postRepository.updatePost(
        id: _post.id,
        title: titleController.text,
        content: contentController.text,
        excerpt: excerptController.text,
        category: categoryController.text.isEmpty
            ? 'General'
            : categoryController.text,
        imageFile: selectedImage.value,
        isFeatured: isFeatured.value,
      );

      Get.snackbar(
        'Success',
        'Post updated successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

      // Update data in other controllers if they exist
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().refreshPosts();
      }

      // Also strictly refresh the detail controller if it's still alive
      if (Get.isRegistered<PostDetailController>()) {
        final detailController = Get.find<PostDetailController>();
        if (detailController.post.value?.id == _post.id) {
          detailController.post.value = updatedPost;
        }
      }

      // Reset loading before navigating back to avoid issues
      isLoading.value = false;

      // Return updated post to detail view
      Get.back(result: updatedPost);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update post: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      // Ensure loading is reset if error occurred or if not already reset
      if (!isClosed && isLoading.value) {
        isLoading.value = false;
      }
    }
  }
}
