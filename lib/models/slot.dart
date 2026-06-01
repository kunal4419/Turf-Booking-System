class Slot {
  final String id;
  final String startTime;
  final String endTime;
  final String displayLabel;
  final bool isAvailable;
  final double price;

  Slot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.displayLabel,
    required this.isAvailable,
    required this.price,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['slot_id']?.toString() ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      displayLabel: json['display_label'] ?? '',
      isAvailable: json['is_available'] ?? false,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slot_id': id,
      'start_time': startTime,
      'end_time': endTime,
      'display_label': displayLabel,
      'is_available': isAvailable,
      'price': price,
    };
  }
}
