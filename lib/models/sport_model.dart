class Sport {
  final String id;
  final String name;
  final String? iconUrl;
  final String? description;
  final bool isActive;

  Sport({
    required this.id,
    required this.name,
    this.iconUrl,
    this.description,
    this.isActive = true,
  });

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['icon_url'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }
}
