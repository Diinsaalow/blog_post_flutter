// lib/app/data/models/post_model.dart
import 'user_model.dart';
import 'comment_model.dart';

class PostModel {
  final String id;
  final String title;
  final String? excerpt;
  final String? content;
  final String? coverImageUrl;
  final String? category;
  final bool isFeatured;
  final bool isPublished;
  final int views;
  final int readingTimeMin;
  final String slug;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? author;
  final List<CommentModel>? comments;

  PostModel({
    required this.id,
    required this.title,
    this.excerpt,
    this.content,
    this.coverImageUrl,
    this.category,
    this.isFeatured = false,
    this.isPublished = true,
    this.views = 0,
    this.readingTimeMin = 1,
    required this.slug,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.comments,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    List<CommentModel>? commentsList;
    if (json['comments'] != null && json['comments'] is List) {
      commentsList = (json['comments'] as List)
          .map((comment) => CommentModel.fromJson(comment))
          .toList();
    }

    return PostModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      excerpt: json['excerpt'],
      content: json['content'],
      coverImageUrl: json['coverImageUrl'],
      category: json['category'],
      isFeatured: json['isFeatured'] ?? false,
      isPublished: json['isPublished'] ?? true,
      views: json['views'] ?? 0,
      readingTimeMin: json['readingTimeMin'] ?? 1,
      slug: json['slug'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      author: json['authorId'] != null
          ? UserModel.fromJson(json['authorId'])
          : null,
      comments: commentsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'excerpt': excerpt,
      'content': content,
      'coverImageUrl': coverImageUrl,
      'category': category,
      'isFeatured': isFeatured,
      'isPublished': isPublished,
      'views': views,
      'readingTimeMin': readingTimeMin,
      'slug': slug,
    };
  }
}
