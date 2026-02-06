// lib/app/modules/home/controllers/home_controller.dart
import 'package:blog_post_flutter/app/modules/allPosts/views/all_posts_view.dart';
import 'package:blog_post_flutter/app/modules/favorites/views/favorites_view.dart';
import 'package:blog_post_flutter/app/modules/home/views/tabs/home_tab.dart';
import 'package:blog_post_flutter/app/modules/createPost/views/create_post_view.dart';
import 'package:blog_post_flutter/app/modules/profile/views/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/menu_repository.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/menu_model.dart';
import '../../../routes/app_pages.dart';
import '../../../core/services/storage_service.dart';

class HomeController extends GetxController {
  final PostRepository _postRepository = Get.find<PostRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();
  final MenuRepository _menuRepository = Get.find<MenuRepository>();

  final RxList<PostModel> featuredPosts = <PostModel>[].obs;
  final RxList<PostModel> recentPosts = <PostModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxList<MenuModel> menus = <MenuModel>[].obs;

  int currentTab = 0;

  updateCurrentTab(int tab) {
    currentTab = tab;
    update();
  }

  // Dynamic tabs based on fetched menus
  List<Widget> get tabs {
    return menus.map((menu) => _getTabWidget(menu.name)).toList();
  }

  // Dynamic navigation items based on fetched menus
  List<BottomNavigationBarItem> get navItems {
    return menus.map((menu) => _getNavItem(menu)).toList();
  }

  // Map menu name to corresponding widget
  Widget _getTabWidget(String menuName) {
    switch (menuName) {
      case 'Home':
        return HomeTab();
      case 'All Posts':
        return AllPostsView();
      case 'Create':
        return CreatePostView();
      case 'Favourites':
        return FavoritesView();
      case 'Profile':
        return ProfileView();
      default:
        return Center(child: Text('Unknown tab: $menuName'));
    }
  }

  // Map menu to navigation item
  BottomNavigationBarItem _getNavItem(MenuModel menu) {
    IconData icon;
    IconData activeIcon;

    switch (menu.name) {
      case 'Home':
        icon = Icons.home_outlined;
        activeIcon = Icons.home;
        break;
      case 'All Posts':
        icon = Icons.article_outlined;
        activeIcon = Icons.article;
        break;
      case 'Create':
        icon = Icons.add_box_outlined;
        activeIcon = Icons.add_box;
        break;
      case 'Favourites':
        icon = Icons.favorite_outline;
        activeIcon = Icons.favorite;
        break;
      case 'Profile':
        icon = Icons.person_outline;
        activeIcon = Icons.person;
        break;
      default:
        icon = Icons.help_outline;
        activeIcon = Icons.help;
    }

    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(activeIcon),
      label: menu.name,
    );
  }

  @override
  void onInit() {
    super.onInit();
    loadMenus();
    loadPosts();
    // Sync bookmarks from backend on app start if logged in
    if (StorageService.isLoggedIn) {
      _syncBookmarksFromBackend();
    }
  }

  /// Load menus from backend
  Future<void> loadMenus() async {
    try {
      final fetchedMenus = await _menuRepository.getMenus();
      menus.value = fetchedMenus;
      update(); // Trigger UI rebuild
    } catch (e) {
      print('Failed to load menus: $e');
      // Fallback to default menus if API fails
      _setDefaultMenus();
    }
  }

  /// Set default menus as fallback
  void _setDefaultMenus() {
    menus.value = [
      MenuModel(id: '1', name: 'Home', path: '/', order: 1),
      MenuModel(id: '2', name: 'All Posts', path: '/posts', order: 2),
      MenuModel(id: '3', name: 'Favourites', path: '/favourites', order: 3),
      MenuModel(id: '4', name: 'Profile', path: '/profile', order: 4),
    ];
    update();
  }

  /// Sync bookmarks from backend to local storage
  Future<void> _syncBookmarksFromBackend() async {
    try {
      await _userRepository.getProfile();
    } catch (e) {
      // Silently fail sync, don't interrupt user experience
      print('Failed to sync bookmarks on app start: $e');
    }
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

  /// Toggle bookmark for a post (syncs with backend)
  Future<void> toggleBookmark(String postId) async {
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
      final isBookmarked = StorageService.isFavorite(postId);

      if (isBookmarked) {
        await _userRepository.removeBookmark(postId);
        Get.snackbar(
          'Success',
          'Removed from bookmarks',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          duration: const Duration(seconds: 2),
        );
      } else {
        await _userRepository.addBookmark(postId);
        Get.snackbar(
          'Success',
          'Added to bookmarks',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
          duration: const Duration(seconds: 2),
        );
      }

      // Trigger UI update
      update();
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
}
