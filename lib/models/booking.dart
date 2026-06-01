class Booking {
  final String bookingId;
  final String turfName;
  final String date;
  final String slotTime;
  final String status;
  final double price;

  Booking({
    required this.bookingId,
    required this.turfName,
    required this.date,
    required this.slotTime,
    required this.status,
    required this.price,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['booking_id']?.toString() ?? '',
      turfName: json['turf_name'] ?? 'Unknown Turf',
      date: json['booking_date'] ?? '',
      slotTime: json['slot_time'] ?? '', // Might need to compute from slot_id relation depending on Supabase view
      status: json['status'] ?? 'Pending',
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'turf_name': turfName,
      'booking_date': date,
      'slot_time': slotTime,
      'status': status,
      'price': price,
    };
  }
}
