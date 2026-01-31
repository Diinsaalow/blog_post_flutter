// lib/app/modules/profile/controllers/profile_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../allPosts/controllers/all_posts_controller.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  // Text controllers for edit form
  final usernameController = TextEditingController();
  final avatarUrlController = TextEditingController();

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();
  final Rx<File?> selectedImage = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUser();
  }

  void loadUser() {
    final userData = StorageService.getUser();
    if (userData != null) {
      user.value = UserModel.fromJson(userData);
    }
  }

  bool isLoggedIn() {
    return StorageService.isLoggedIn;
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authRepository.logout();

      // Clear all app state
      _resetAppState();

      // Use offNamedUntil to avoid trying to delete permanent controllers
      Get.offNamedUntil(Routes.HOME, (route) => false);
      Get.snackbar(
        'Success',
        'Logged out successfully!',
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
    } finally {
      isLoading.value = false;
    }
  }

  void _resetAppState() {
    // 1. Reset Profile
    user.value = null;

    // 2. Clear Favorites
    if (Get.isRegistered<FavoritesController>()) {
      Get.find<FavoritesController>().favoritePosts.clear();
    }

    // 3. Reset All Posts Filters
    if (Get.isRegistered<AllPostsController>()) {
      final allPostsController = Get.find<AllPostsController>();
      allPostsController.clearFilters();
      // Reload to ensure fresh state (e.g. remove any user specific data if any)
      allPostsController.loadPosts();
    }

    // 4. Reset Home Tab to 0 (Home)
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      homeController.currentTab = 0;
      homeController.update();
      // Also reload home posts
      homeController.loadPosts();
    }
  }

  Future<void> refreshUser() async {
    try {
      isLoading.value = true;
      final updatedUser = await _userRepository.getProfile();
      user.value = updatedUser;
      Get.snackbar(
        'Success',
        'Profile refreshed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
        colorText: Get.theme.primaryColor,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to refresh profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      // Fallback to local storage
      loadUser();
    } finally {
      isLoading.value = false;
    }
  }

  /// Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Read bytes and verify file exists
        final bytes = await pickedFile.readAsBytes();

        // Create a temporary file
        final tempDir = Directory.systemTemp;
        final tempFile = File(
          '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        // Write bytes to temp file
        await tempFile.writeAsBytes(bytes);

        selectedImage.value = tempFile;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  /// Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Read bytes and verify file exists
        final bytes = await pickedFile.readAsBytes();

        // Create a temporary file
        final tempDir = Directory.systemTemp;
        final tempFile = File(
          '${tempDir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        // Write bytes to temp file
        await tempFile.writeAsBytes(bytes);

        selectedImage.value = tempFile;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  /// Remove selected image
  void removeSelectedImage() {
    selectedImage.value = null;
  }

  /// Show image source selection dialog
  void showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Profile Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library, color: Colors.blue),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.green),
              ),
              title: const Text('Take a Photo'),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
            if (selectedImage.value != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: const Text('Remove Photo'),
                onTap: () {
                  Get.back();
                  removeSelectedImage();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> updateProfile({String? username, String? avatarUrl}) async {
    try {
      isUpdating.value = true;

      final updatedUser = await _userRepository.updateProfile(
        username: username,
        avatarUrl: avatarUrl,
        profilePicture: selectedImage.value,
      );

      user.value = updatedUser;
      selectedImage.value =
          null; // Clear selected image after successful update

      Get.back(); // Close dialog
      Get.snackbar(
        'Success',
        'Profile updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor.withOpacity(0.1),
        colorText: Get.theme.primaryColor,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isUpdating.value = false;
    }
  }

  void showEditProfileDialog() {
    if (user.value != null) {
      usernameController.text = user.value!.username;
      avatarUrlController.text = user.value!.avatarUrl ?? '';
      selectedImage.value = null; // Reset selected image
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    avatarUrlController.dispose();
    super.onClose();
  }
}
