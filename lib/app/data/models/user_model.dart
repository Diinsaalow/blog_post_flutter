// lib/app/data/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final dynamic roleId; // Can be String or Map
  final String? status;
  final List<String> bookmarks;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    this.roleId,
    this.status,
    this.bookmarks = const [],
    this.createdAt,
    this.updatedAt,
  });

  // Helper to get role name from nested or string roleId
  String? get roleName {
    if (roleId == null) return null;
    if (roleId is Map) {
      return roleId['name']?.toString();
    }
    return null;
  }

  // Helper to get role ID string
  String? get roleIdString {
    if (roleId == null) return null;
    if (roleId is String) return roleId;
    if (roleId is Map) return roleId['_id']?.toString();
    return null;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'],
      roleId: json['roleId'], // Keep as dynamic
      status: json['status'],
      bookmarks: json['bookmarks'] != null
          ? List<String>.from(json['bookmarks'])
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'username': username,
      'avatarUrl': avatarUrl,
      'roleId': roleIdString,
      'status': status,
      'bookmarks': bookmarks,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}
