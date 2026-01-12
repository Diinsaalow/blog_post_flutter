// lib/app/data/repositories/comment_repository.dart
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/comment_model.dart';

class CommentRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<CommentModel>> getCommentsByPost(String postId) async {
    final response = await _apiService.get(ApiConstants.commentsByPost(postId));

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> commentsJson = response['data'];
      return commentsJson.map((json) => CommentModel.fromJson(json)).toList();
    }

    return [];
  }

  Future<CommentModel> createComment({
    required String postId,
    required String content,
  }) async {
    final response = await _apiService.post(
      ApiConstants.commentsByPost(postId),
      {'content': content},
    );

    if (response['success'] == true && response['data'] != null) {
      return CommentModel.fromJson(response['data']);
    }

    throw Exception(response['message'] ?? 'Failed to create comment');
  }

  Future<CommentModel> updateComment({
    required String commentId,
    required String content,
  }) async {
    final response = await _apiService.put(
      ApiConstants.updateComment(commentId),
      {'content': content},
    );

    if (response['success'] == true && response['data'] != null) {
      return CommentModel.fromJson(response['data']);
    }

    throw Exception(response['message'] ?? 'Failed to update comment');
  }

  Future<void> deleteComment(String commentId) async {
    final response = await _apiService.delete(
      ApiConstants.deleteComment(commentId),
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to delete comment');
    }
  }
}
