// lib/app/core/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class ApiService extends GetxService {
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  String get baseUrl => ApiConstants.baseUrl;
  
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (StorageService.getToken() != null)
      'Authorization': 'Bearer ${StorageService.getToken()}',
  };
  
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
          )
          .timeout(timeoutDuration);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeoutDuration);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'An error occurred');
    }
  }
  
  String _handleError(dynamic error) {
    if (error.toString().contains('TimeoutException')) {
      return 'Request timeout. Please check your connection.';
    } else if (error.toString().contains('SocketException')) {
      return 'No internet connection.';
    }
    return error.toString();
  }
}