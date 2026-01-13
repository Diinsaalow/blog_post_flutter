// lib/app/core/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
          .get(Uri.parse('$baseUrl$endpoint'), headers: _headers)
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

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic>? body,
  ) async {
    try {
      final response = await http
          .put(
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

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl$endpoint'), headers: _headers)
          .timeout(timeoutDuration);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload file with multipart/form-data
  Future<Map<String, dynamic>> uploadWithFile({
    required String endpoint,
    required String method, // 'POST' or 'PUT'
    File? file,
    String? fileFieldName,
    Map<String, String>? fields,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest(method, uri);

      // Add authorization header
      if (StorageService.getToken() != null) {
        request.headers['Authorization'] =
            'Bearer ${StorageService.getToken()}';
      }

      // Add text fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add file if provided
      if (file != null && fileFieldName != null) {
        final fileExtension = file.path.split('.').last.toLowerCase();
        final mimeType = _getMimeType(fileExtension);

        request.files.add(
          await http.MultipartFile.fromPath(
            fileFieldName,
            file.path,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60), // Longer timeout for file uploads
      );

      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Get MIME type based on file extension
  String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
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
