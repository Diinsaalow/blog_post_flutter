// lib/app/data/repositories/post_repository.dart
import 'package:get/get.dart';
import 'dart:io';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../models/post_model.dart';

class PostRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<PostModel>> getAllPosts({
    String? search,
    String? category,
    String sortBy = 'createdAt',
    String order = 'desc',
  }) async {
    String query = '?sortBy=$sortBy&order=$order';
    if (search != null && search.isNotEmpty) {
      query += '&search=$search';
    }
    if (category != null && category.isNotEmpty) {
      query += '&category=$category';
    }

    final response = await _apiService.get('${ApiConstants.posts}$query');

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> postsJson = response['data'];
      return postsJson.map((json) => PostModel.fromJson(json)).toList();
    }

    return [];
  }

  Future<List<PostModel>> getFeaturedPosts() async {
    final response = await _apiService.get(ApiConstants.featuredPosts);

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> postsJson = response['data'];
      return postsJson.map((json) => PostModel.fromJson(json)).toList();
    }

    return [];
  }

  Future<List<PostModel>> getRecentPosts() async {
    final response = await _apiService.get(ApiConstants.recentPosts);

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> postsJson = response['data'];
      return postsJson.map((json) => PostModel.fromJson(json)).toList();
    }

    return [];
  }

  Future<PostModel> getPostBySlug(String slug) async {
    final response = await _apiService.get('${ApiConstants.posts}/$slug');

    if (response['success'] == true && response['data'] != null) {
      return PostModel.fromJson(response['data']);
    }

    throw Exception(response['message'] ?? 'Post not found');
  }

  Future<PostModel> createPost({
    required String title,
    required String content,
    String? excerpt,
    String? category,
    required File imageFile,
    bool isFeatured = false,
    bool isPublished = true,
  }) async {
    final fields = {
      'title': title,
      'content': content,
      'excerpt': excerpt ?? '',
      'category': category ?? 'General',
      'isFeatured': isFeatured.toString(),
      'isPublished': isPublished.toString(),
    };

    final response = await _apiService.uploadWithFile(
      endpoint: ApiConstants.posts,
      method: "POST",
      file: imageFile,
      fileFieldName: 'coverImage',
      fields: fields,
    );

    if (response['success'] == true && response['data'] != null) {
      return PostModel.fromJson(response['data']);
    }

    throw Exception(response['message'] ?? 'Failed to create post');
  }

  Future<PostModel> updatePost({
    required String id,
    String? title,
    String? content,
    String? excerpt,
    String? category,
    File? imageFile,
    bool? isFeatured,
    bool? isPublished,
  }) async {
    final fields = <String, String>{};
    if (title != null) fields['title'] = title;
    if (content != null) fields['content'] = content;
    if (excerpt != null) fields['excerpt'] = excerpt;
    if (category != null) fields['category'] = category;
    if (isFeatured != null) fields['isFeatured'] = isFeatured.toString();
    if (isPublished != null) fields['isPublished'] = isPublished.toString();

    final response = await _apiService.uploadWithFile(
      endpoint: '${ApiConstants.posts}/$id',
      method: "PUT",
      file: imageFile,
      fileFieldName: 'coverImage',
      fields: fields,
    );

    if (response['success'] == true && response['data'] != null) {
      return PostModel.fromJson(response['data']);
    }

    throw Exception(response['message'] ?? 'Failed to update post');
  }

  Future<void> deletePost(String id) async {
    final response = await _apiService.delete('${ApiConstants.posts}/$id');

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to delete post');
    }
  }
}
