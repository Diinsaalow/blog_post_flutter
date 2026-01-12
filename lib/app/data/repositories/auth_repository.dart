// lib/app/data/repositories/auth_repository.dart
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/storage_service.dart';
import '../models/user_model.dart';

class AuthRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();
  
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConstants.register,
      {
        'email': email,
        'username': username,
        'password': password,
      },
    );
    
    if (response['success'] == true && response['data'] != null) {
      final user = UserModel.fromJson(response['data']['user']);
      final token = response['data']['token'];
      
      await StorageService.saveToken(token);
      await StorageService.saveUser(user.toJson());
      
      return {'success': true, 'user': user, 'token': token};
    }
    
    throw Exception(response['message'] ?? 'Registration failed');
  }
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConstants.login,
      {
        'email': email,
        'password': password,
      },
    );
    
    if (response['success'] == true && response['data'] != null) {
      final user = UserModel.fromJson(response['data']['user']);
      final token = response['data']['token'];
      
      await StorageService.saveToken(token);
      await StorageService.saveUser(user.toJson());
      
      return {'success': true, 'user': user, 'token': token};
    }
    
    throw Exception(response['message'] ?? 'Login failed');
  }
  
  Future<void> logout() async {
    await StorageService.clearAll();
  }
}