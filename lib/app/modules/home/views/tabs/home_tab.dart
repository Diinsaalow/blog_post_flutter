import 'package:blog_post_flutter/app/modules/home/controllers/home_controller.dart';
import 'package:blog_post_flutter/app/widgets/loading_widget.dart';
import 'package:blog_post_flutter/app/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return RefreshIndicator(
          onRefresh: () => controller.refreshPosts(),
          child: Obx(() {
            if (controller.isLoading.value &&
                controller.featuredPosts.isEmpty &&
                controller.recentPosts.isEmpty) {
              return const LoadingWidget(message: 'Loading posts...');
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Featured Posts Section
                  if (controller.featuredPosts.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // const Icon(Icons.star, color: Colors.amber, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Featured Posts',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 450, // Increased from 320 to 380
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: controller.featuredPosts.length,
                        itemBuilder: (context, index) {
                          final post = controller.featuredPosts[index];
                          return SizedBox(
                            width: 320,
                            child: PostCard(
                              post: post,
                              onTap: () =>
                                  controller.navigateToPostDetail(post),
                              onFavoriteTap: () =>
                                  controller.toggleBookmark(post.id),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Recent Posts Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // const Icon(Icons.access_time, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Recent Posts',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (controller.recentPosts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No posts available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.recentPosts.length,
                      itemBuilder: (context, index) {
                        final post = controller.recentPosts[index];
                        return PostCard(
                          post: post,
                          onTap: () => controller.navigateToPostDetail(post),
                          onFavoriteTap: () =>
                              controller.toggleBookmark(post.id),
                        );
                      },
                    ),
                  const SizedBox(height: 80), // Space for bottom nav
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
