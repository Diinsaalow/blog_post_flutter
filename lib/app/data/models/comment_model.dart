// lib/app/data/models/comment_model.dart
import 'user_model.dart';

class CommentModel {
  final String id;
  final String postId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? author;

  CommentModel({
    required this.id,
    required this.postId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['_id'] ?? json['id'] ?? '',
      postId: json['postId'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      author: json['authorId'] != null
          ? UserModel.fromJson(json['authorId'])
          : null,
    );
  }
}
