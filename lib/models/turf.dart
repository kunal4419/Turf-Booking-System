class Turf {
  final String id;
  final String name;
  final String location;
  final double pricePerSlot;
  final List<String> images;
  final List<String> facilities;

  Turf({
    required this.id,
    required this.name,
    required this.location,
    required this.pricePerSlot,
    required this.images,
    required this.facilities,
  });

  factory Turf.fromJson(Map<String, dynamic> json) {
    return Turf(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      pricePerSlot: (json['price_per_slot'] ?? 0.0).toDouble(),
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      facilities: json['facilities'] != null
          ? List<String>.from(json['facilities'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'price_per_slot': pricePerSlot,
      'images': images,
      'facilities': facilities,
    };
  }
}
