// lib/app/modules/favorites/views/favorites_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/post_card.dart';
import '../../../widgets/loading_widget.dart';
import '../../../core/controllers/navigation_controller.dart';
import '../controllers/favorites_controller.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();
    navigationController.currentIndex.value = 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshFavorites(),
        child: Obx(() {
          if (controller.isLoading.value && controller.favoritePosts.isEmpty) {
            return const LoadingWidget(message: 'Loading favorites...');
          }

          if (controller.favoritePosts.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 100,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No favorites yet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Start adding posts to your favorites',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the heart icon on any post to save it here',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          navigationController.changePage(0);
                        },
                        icon: const Icon(Icons.explore),
                        label: const Text('Explore Posts'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: controller.favoritePosts.length,
            itemBuilder: (context, index) {
              final post = controller.favoritePosts[index];
              return PostCard(
                post: post,
                onTap: () => controller.navigateToPostDetail(post),
                onFavoriteTap: () {
                  controller.toggleFavorite(post);
                },
              );
            },
          );
        }),
      ),
      // bottomNavigationBar: Obx(
      //   () => BottomNavigationBar(
      //     currentIndex: navigationController.currentIndex.value,
      //     onTap: navigationController.changePage,
      //     type: BottomNavigationBarType.fixed,
      //     selectedItemColor: Theme.of(context).primaryColor,
      //     unselectedItemColor: Colors.grey,
      //     items: const [
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.home_outlined),
      //         activeIcon: Icon(Icons.home),
      //         label: 'Home',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.article_outlined),
      //         activeIcon: Icon(Icons.article),
      //         label: 'All Posts',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.favorite_outline),
      //         activeIcon: Icon(Icons.favorite),
      //         label: 'Favorites',
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.person_outline),
      //         activeIcon: Icon(Icons.person),
      //         label: 'Profile',
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}
