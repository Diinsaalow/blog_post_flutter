// lib/app/data/repositories/post_repository.dart
import 'package:get/get.dart';
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
}