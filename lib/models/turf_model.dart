class Turf {
  final String id;
  final String ownerId;
  final String name;
  final String sportId;
  final String sportName;
  final String? description;
  final String location;
  final double? latitude;
  final double? longitude;
  final double pricePerSlot;
  final String? rules;
  final List<String> imageUrls;
  final bool isActive;
  final DateTime createdAt;
  final List<String> facilities;

  Turf({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.sportId,
    required this.sportName,
    this.description,
    required this.location,
    this.latitude,
    this.longitude,
    required this.pricePerSlot,
    this.rules,
    required this.imageUrls,
    this.isActive = true,
    required this.createdAt,
    this.facilities = const [],
  });

  factory Turf.fromJson(Map<String, dynamic> json) {
    return Turf(
      id: json['id'] ?? '',
      ownerId: json['owner_id'] ?? '',
      name: json['name'] ?? '',
      sportId: json['sport_id'] ?? '',
      sportName: json['sport_name'] ?? 'Unknown',
      description: json['description'],
      location: json['location'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      pricePerSlot: double.tryParse(json['price_per_slot'].toString()) ?? 0.0,
      rules: json['rules'],
      imageUrls: List<String>.from(json['image_urls'] ?? []),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
    );
  }
}
