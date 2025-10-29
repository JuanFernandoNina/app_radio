class Category {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final String screen; // 'home', 'grupos', 'both'
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.screen = 'home',
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
      screen: json['screen'] ?? 'home',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
      'screen': screen,
    };
  }
}
