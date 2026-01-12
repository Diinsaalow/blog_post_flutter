// lib/app/modules/profile/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;

  // Text controllers for edit form
  final usernameController = TextEditingController();
  final avatarUrlController = TextEditingController();

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

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _authRepository.logout();
      Get.offAllNamed(Routes.LOGIN);
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

  Future<void> updateProfile({String? username, String? avatarUrl}) async {
    try {
      isUpdating.value = true;

      final updatedUser = await _userRepository.updateProfile(
        username: username,
        avatarUrl: avatarUrl,
      );

      user.value = updatedUser;

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
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    avatarUrlController.dispose();
    super.onClose();
  }
}
