// lib/app/data/models/menu_model.dart
class MenuModel {
  final String id;
  final String name;
  final String path;
  final String? icon;
  final int order;

  MenuModel({
    required this.id,
    required this.name,
    required this.path,
    this.icon,
    required this.order,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      path: (json['path'] ?? '').toString(),
      icon: json['icon']?.toString(),
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'path': path, 'icon': icon, 'order': order};
  }
}
