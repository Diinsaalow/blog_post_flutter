// lib/app/data/models/post_model.dart
import 'user_model.dart';

class PostModel {
  final String id;
  final String title;
  final String? excerpt;
  final String? content;
  final String? coverImageUrl;
  final String? category;
  final bool isFeatured;
  final int views;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? author;
  final List<dynamic>? comments;
  
  PostModel({
    required this.id,
    required this.title,
    this.excerpt,
    this.content,
    this.coverImageUrl,
    this.category,
    this.isFeatured = false,
    this.views = 0,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.comments,
  });
  
  String get slug => title.toLowerCase().replaceAll(' ', '-');
  
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      excerpt: json['excerpt'],
      content: json['content'],
      coverImageUrl: json['coverImageUrl'],
      category: json['category'],
      isFeatured: json['isFeatured'] ?? false,
      views: json['views'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      author: json['authorId'] != null
          ? UserModel.fromJson(json['authorId'])
          : null,
      comments: json['comments'],
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
      'views': views,
    };
  }
}