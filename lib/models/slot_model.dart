class Slot {
  final String id;
  final int slotNumber;
  final String startTime;
  final String endTime;
  final String displayLabel;
  final bool isAvailable;
  final double price;
  final String availabilityReason; // available, booked, blocked
  final String? bookedByName; // Name of the customer who booked (for owner view)

  Slot({
    required this.id,
    required this.slotNumber,
    required this.startTime,
    required this.endTime,
    required this.displayLabel,
    required this.isAvailable,
    required this.price,
    required this.availabilityReason,
    this.bookedByName,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['slot_id'] ?? '',
      slotNumber: json['slot_number'] ?? 0,
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      displayLabel: json['display_label'] ?? '',
      isAvailable: json['is_available'] ?? false,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      availabilityReason: json['availability_reason'] ?? 'unknown',
      bookedByName: json['booked_by_name'],
    );
  }
}

