// lib/app/modules/allPosts/views/all_posts_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/post_card.dart';
import '../../../widgets/loading_widget.dart';
import '../../../core/controllers/navigation_controller.dart';
import '../../../core/services/storage_service.dart';
import '../controllers/all_posts_controller.dart';

class AllPostsView extends GetView<AllPostsController> {
  const AllPostsView({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();
    navigationController.currentIndex.value = 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Posts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Filter button
          Obx(
            () =>
                controller.selectedCategory.value.isNotEmpty ||
                    controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: controller.clearFilters,
                    tooltip: 'Clear filters',
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search posts...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(
                  () => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => controller.searchPosts(''),
                        )
                      : const SizedBox.shrink(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (controller.searchQuery.value != value) {
                    controller.searchPosts(value);
                  }
                });
              },
            ),
          ),

          // Category Filter Chips (Optional)
          Obx(() {
            final categories = _getUniqueCategories(controller.posts);
            if (categories.isEmpty) return const SizedBox.shrink();

            return Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected =
                      controller.selectedCategory.value == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        controller.filterByCategory(selected ? category : '');
                      },
                      selectedColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
            );
          }),

          // Posts List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.refreshPosts(),
              child: Obx(() {
                if (controller.isLoading.value && controller.posts.isEmpty) {
                  return const LoadingWidget(message: 'Loading posts...');
                }

                if (controller.posts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: controller.posts.length,
                  itemBuilder: (context, index) {
                    final post = controller.posts[index];
                    return PostCard(
                      post: post,
                      onTap: () => controller.navigateToPostDetail(post),
                      onFavoriteTap: () {
                        if (StorageService.isFavorite(post.id)) {
                          StorageService.removeFavorite(post.id);
                        } else {
                          StorageService.addFavorite(post.id);
                        }
                        controller.update();
                      },
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: navigationController.currentIndex.value,
          onTap: navigationController.changePage,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              activeIcon: Icon(Icons.article),
              label: 'All Posts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // Helper to get unique categories
  List<String> _getUniqueCategories(List posts) {
    final categories = <String>{};
    for (var post in posts) {
      if (post.category != null && post.category.isNotEmpty) {
        categories.add(post.category);
      }
    }
    return categories.toList()..sort();
  }
}
