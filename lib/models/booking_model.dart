import 'package:flutter/material.dart';

class Booking {
  final String id;
  final String bookingId;
  final String customerId;
  final String turfId;
  final String turfName;
  final String turfImage;
  final String slotId;
  final String slotDisplay;
  final String bookingDate;
  final String status; // Pending, Approved, Rejected, Cancelled, Completed
  final double price;
  final String? rejectionReason;
  final String? notes;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime? cancelledAt;
  final String? customerName;
  final String? turfLocation;
  final String? startTime;
  final String? endTime;

  Booking({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.turfId,
    required this.turfName,
    required this.turfImage,
    required this.slotId,
    required this.slotDisplay,
    required this.bookingDate,
    required this.status,
    required this.price,
    this.rejectionReason,
    this.notes,
    required this.createdAt,
    this.approvedAt,
    this.rejectedAt,
    this.cancelledAt,
    this.customerName,
    this.turfLocation,
    this.startTime,
    this.endTime,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      bookingId: json['booking_id'] ?? '',
      customerId: json['customer_id'] ?? '',
      turfId: json['turf_id'] ?? '',
      turfName: json['turf_name'] ?? 'Unknown Turf',
      turfImage: json['turf_image_url'] ?? '',
      slotId: json['slot_id'] ?? '',
      slotDisplay: json['slot_display'] ?? '',
      bookingDate: json['booking_date'] ?? '',
      status: json['status'] ?? 'Pending',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      rejectionReason: json['rejection_reason'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at']) : null,
      rejectedAt: json['rejected_at'] != null ? DateTime.parse(json['rejected_at']) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.parse(json['cancelled_at']) : null,
      customerName: json['customer_name'],
      turfLocation: json['turf_location'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  double get totalPrice => price;

  bool get isCancellable => status == 'Pending' || status == 'Approved';
  
  Color get statusColor {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }
}
