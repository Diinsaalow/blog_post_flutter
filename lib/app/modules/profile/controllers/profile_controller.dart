// lib/app/modules/profile/controllers/profile_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_pages.dart';

class ProfileController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final Rx<UserModel?> user = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

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

  void refreshUser() {
    loadUser();
  }
}
