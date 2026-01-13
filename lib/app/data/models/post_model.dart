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

    // Helper to safely convert to String
    String safeString(dynamic value, String defaultValue) {
      if (value == null) return defaultValue;
      return value.toString();
    }

    return PostModel(
      id: safeString(json['_id'] ?? json['id'], ''),
      title: safeString(json['title'], ''),
      excerpt: json['excerpt']?.toString(),
      content: json['content']?.toString(),
      coverImageUrl: json['coverImageUrl']?.toString(),
      category: json['category']?.toString(),
      isFeatured: json['isFeatured'] == true || json['isFeatured'] == 'true',
      isPublished: json['isPublished'] == true || json['isPublished'] == 'true',
      views: int.tryParse(json['views']?.toString() ?? '0') ?? 0,
      readingTimeMin: int.tryParse(json['readingTimeMin']?.toString() ?? '1') ?? 1,
      slug: safeString(json['slug'], ''),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString()) 
          : DateTime.now(),
      author: json['authorId'] != null && json['authorId'] is Map
          ? UserModel.fromJson(Map<String, dynamic>.from(json['authorId']))
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
