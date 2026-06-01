class User {
  final String id;
  final String authId;
  final String email;
  final String name;
  final String? phone;
  final String role; // customer, admin, turf_owner
  final String? location;
  final String? profileImageUrl;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.authId,
    required this.email,
    required this.name,
    this.phone,
    required this.role,
    this.location,
    this.profileImageUrl,
    this.isActive = true,
    required this.createdAt,
  });

  // Convert from JSON (API response)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      authId: json['auth_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'customer',
      location: json['location'],
      profileImageUrl: json['profile_image_url'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
    );
  }

  // Convert to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auth_id': authId,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'location': location,
      'profile_image_url': profileImageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
