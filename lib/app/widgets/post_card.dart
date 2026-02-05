// lib/app/widgets/post_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../data/models/post_model.dart';
import '../core/services/storage_service.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool showFavoriteButton;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onFavoriteTap,
    this.showFavoriteButton = true,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = StorageService.isFavorite(widget.post.id);
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    isFavorite = StorageService.isFavorite(widget.post.id);
  }

  void _handleFavoriteTap() {
    if (widget.onFavoriteTap != null) {
      widget.onFavoriteTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Stack(
                children: [
                  widget.post.coverImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: widget.post.coverImageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error, size: 50),
                          ),
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 50),
                        ),
                  // Featured Badge
                  if (widget.post.isFeatured)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'Featured',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Reading Time
                  Row(
                    children: [
                      if (widget.post.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.post.category!
                                    .substring(0, 1)
                                    .toUpperCase() +
                                widget.post.category!
                                    .substring(1)
                                    .toLowerCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.post.readingTimeMin} min read',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const Spacer(),
                      if (widget.showFavoriteButton &&
                          widget.onFavoriteTap != null)
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: _handleFavoriteTap,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    widget.post.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Excerpt
                  if (widget.post.excerpt != null)
                    Text(
                      widget.post.excerpt!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),
                  // Author & Stats
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundImage: widget.post.author?.avatarUrl != null
                            ? CachedNetworkImageProvider(
                                widget.post.author!.avatarUrl!,
                              )
                            : null,
                        backgroundColor: Colors.grey[300],
                        child: widget.post.author?.avatarUrl == null
                            ? Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.grey[600],
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.author?.username ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              DateFormat(
                                'MMM dd, yyyy',
                              ).format(widget.post.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.post.views}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
