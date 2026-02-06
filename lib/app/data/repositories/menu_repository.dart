// lib/app/data/repositories/menu_repository.dart
import 'package:get/get.dart';
import '../../core/services/api_service.dart';
import '../models/menu_model.dart';

class MenuRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  /// Get menus based on user role (works for guests too)
  Future<List<MenuModel>> getMenus() async {
    try {
      final response = await _apiService.get('/menus');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> menusJson = response['data'];
        return menusJson.map((json) => MenuModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching menus: $e');
      rethrow;
    }
  }
}
