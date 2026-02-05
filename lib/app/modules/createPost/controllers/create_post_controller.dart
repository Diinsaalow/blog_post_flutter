import 'dart:io';
import 'package:blog_post_flutter/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../core/controllers/navigation_controller.dart';
import '../../../core/services/storage_service.dart';

class CreatePostController extends GetxController {
  final PostRepository _postRepository = Get.find<PostRepository>();

  // We might want to access NavigationController to switch tabs after creation
  // Or just use Get.back() if it was a separate screen, but here it's a tab?
  // If it's a tab, we probably need to reset the tab index in Home/Navigation controller.

  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final excerptController = TextEditingController();
  final categoryController = TextEditingController();

  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isFeatured = false.obs;
  final ImagePicker _picker = ImagePicker();

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
  }

  Future<void> createPost() async {
    if (!StorageService.isLoggedIn) {
      Get.snackbar('Error', 'You must be logged in to create a post');
      return;
    }

    if (selectedImage.value == null) {
      Get.snackbar(
        'Error',
        'Please select a cover image',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

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
      await _postRepository.createPost(
        title: titleController.text,
        content: contentController.text,
        excerpt: excerptController.text,
        category: categoryController.text.isEmpty
            ? 'General'
            : categoryController.text,
        imageFile: selectedImage.value!,
        isFeatured: isFeatured.value,
      );

      Get.snackbar(
        'Success',
        'Post created successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

      // Clear form
      titleController.clear();
      contentController.clear();
      excerptController.clear();
      categoryController.clear();
      selectedImage.value = null;
      isFeatured.value = false;

      // Navigate to Home tab (index 0)
      if (Get.isRegistered<NavigationController>()) {
        Get.find<NavigationController>().changePage(0);
      }
      // Also refresh home posts if possible
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().refreshPosts();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create post: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
