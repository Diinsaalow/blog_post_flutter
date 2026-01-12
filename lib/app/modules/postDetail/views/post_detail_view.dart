// lib/app/modules/postDetail/views/post_detail_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../widgets/loading_widget.dart';
import '../controllers/post_detail_controller.dart';

class PostDetailView extends GetView<PostDetailController> {
  const PostDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final commentController = TextEditingController();

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.post.value == null) {
          return const LoadingWidget(message: 'Loading post...');
        }

        final post = controller.post.value;
        if (post == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Post not found'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            // App Bar with Cover Image
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Cover Image
                    post.coverImageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: post.coverImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error, size: 50),
                            ),
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 80),
                          ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Obx(
                  () => IconButton(
                    icon: Icon(
                      controller.isFavorite.value
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: controller.isFavorite.value
                          ? Colors.red
                          : Colors.white,
                    ),
                    onPressed: controller.toggleFavorite,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // TODO: Implement share functionality
                    Get.snackbar('Share', 'Share functionality coming soon');
                  },
                ),
              ],
            ),

            // Post Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category & Reading Time
                    Row(
                      children: [
                        if (post.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              post.category!.substring(0, 1).toUpperCase() +
                                  post.category!.substring(1).toLowerCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.readingTimeMin} min read',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.views}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Author Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: post.author?.avatarUrl != null
                              ? CachedNetworkImageProvider(
                                  post.author!.avatarUrl!,
                                )
                              : null,
                          backgroundColor: Colors.grey[300],
                          child: post.author?.avatarUrl == null
                              ? Icon(Icons.person, color: Colors.grey[600])
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.author?.username ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'MMMM dd, yyyy',
                                ).format(post.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Content
                    if (post.content != null)
                      Text(
                        post.content!,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          letterSpacing: 0.2,
                        ),
                      ),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 24),

                    // Comments Section Header
                    Row(
                      children: [
                        const Icon(Icons.comment_outlined, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Comments (${controller.comments.length})',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Add Comment Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: const InputDecoration(
                                hintText: 'Write a comment...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.send,
                              color: Theme.of(context).primaryColor,
                            ),
                            onPressed: () {
                              if (commentController.text.trim().isNotEmpty) {
                                controller.addComment(commentController.text);
                                commentController.clear();
                                FocusScope.of(context).unfocus();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Comments List
                    Obx(() {
                      if (controller.isCommentsLoading.value) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (controller.comments.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No comments yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Be the first to comment!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.comments.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final comment = controller.comments[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundImage:
                                          comment.author?.avatarUrl != null
                                          ? CachedNetworkImageProvider(
                                              comment.author!.avatarUrl!,
                                            )
                                          : null,
                                      backgroundColor: Colors.grey[300],
                                      child: comment.author?.avatarUrl == null
                                          ? Icon(
                                              Icons.person,
                                              size: 16,
                                              color: Colors.grey[600],
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment.author?.username ??
                                                'Unknown',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            DateFormat(
                                              'MMM dd, yyyy • hh:mm a',
                                            ).format(comment.createdAt),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  comment.content,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
