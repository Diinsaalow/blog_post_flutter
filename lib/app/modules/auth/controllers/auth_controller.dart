// lib/app/modules/auth/controllers/auth_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/services/storage_service.dart';
import '../../../routes/app_pages.dart';
import '../../home/controllers/home_controller.dart';
import '../../favorites/controllers/favorites_controller.dart';
import '../../allPosts/controllers/all_posts_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  void checkAuthStatus() {
    isLoggedIn.value = StorageService.isLoggedIn;
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      await _authRepository.register(
        email: email,
        username: username,
        password: password,
      );

      // Sync user profile after registration
      try {
        await _userRepository.getProfile();
      } catch (syncError) {
        // Don't fail registration if profile sync fails
        print('Failed to sync profile: $syncError');
      }

      isLoggedIn.value = true;

      // Refresh app state on register
      _refreshAppStateOnLogin();

      Get.offAllNamed(Routes.HOME);
      Get.snackbar(
        'Success',
        'Registration successful!',
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

  Future<void> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      await _authRepository.login(email: email, password: password);

      // Sync bookmarks from backend after login
      try {
        await _userRepository.getProfile();
      } catch (syncError) {
        // Don't fail login if bookmark sync fails
        print('Failed to sync bookmarks: $syncError');
      }

      isLoggedIn.value = true;

      // Refresh app state on login to ensure fresh data
      _refreshAppStateOnLogin();

      Get.offAllNamed(Routes.HOME);
      Get.snackbar(
        'Success',
        'Login successful!',
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

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      isLoggedIn.value = false;

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
    }
  }

  void _resetAppState() {
    // 1. Clear Favorites
    if (Get.isRegistered<FavoritesController>()) {
      Get.find<FavoritesController>().favoritePosts.clear();
    }

    // 2. Reset All Posts Filters
    if (Get.isRegistered<AllPostsController>()) {
      final allPostsController = Get.find<AllPostsController>();
      allPostsController.clearFilters();
      allPostsController.loadPosts();
    }

    // 3. Reset Home Tab to 0 (Home)
    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      homeController.currentTab = 0;
      homeController.update();
      homeController.loadPosts();
    }

    // 4. Reset Profile
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().user.value = null;
    }
  }

  void _refreshAppStateOnLogin() {
    // Reload favorites
    if (Get.isRegistered<FavoritesController>()) {
      Get.find<FavoritesController>().loadFavorites();
    }

    // Reload Profile
    if (Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().loadUser();
    }

    // Reload Home posts (to update bookmark status)
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadPosts();
    }

    // Reload All Posts (to update bookmark status)
    if (Get.isRegistered<AllPostsController>()) {
      Get.find<AllPostsController>().loadPosts();
    }
  }
}
