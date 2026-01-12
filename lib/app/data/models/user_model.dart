// lib/app/data/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final String? roleId;
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
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'],
      roleId: json['roleId'] is String 
          ? json['roleId'] 
          : json['roleId']?['_id']?.toString(),
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
      'roleId': roleId,
      'status': status,
      'bookmarks': bookmarks,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}