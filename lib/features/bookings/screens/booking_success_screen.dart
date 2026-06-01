import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/booking_controller.dart';
import '../../../controllers/turf_controller.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookingController = Get.find<BookingController>();
    final turfController = Get.find<TurfController>();

    // Retrieve last booking data stored before navigation
    final bookingId = bookingController.lastBookingId.value;
    final status = bookingController.lastBookingStatus.value.isEmpty
        ? 'Pending'
        : bookingController.lastBookingStatus.value;

    // These were set before form clear (on confirmation screen)
    final turf = turfController.selectedTurf.value;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Success Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 24,
                        spreadRadius: 4,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: const Icon(Icons.check_rounded, size: 72, color: Colors.white),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Booking Request Sent!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your booking request has been submitted successfully. You will be notified once it is approved by the turf owner.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.6),
              ),
              const SizedBox(height: 36),

              // Booking Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (bookingId.isNotEmpty) ...[
                      _buildDetailRow(
                        Icons.confirmation_number_outlined,
                        'Booking ID',
                        bookingId,
                        valueColor: Colors.green.shade700,
                        bold: true,
                      ),
                      const Divider(height: 24),
                    ],
                    if (turf != null) ...[
                      _buildDetailRow(
                        Icons.sports_soccer,
                        'Turf',
                        turf.name,
                      ),
                      const SizedBox(height: 14),
                      _buildDetailRow(
                        Icons.location_on_outlined,
                        'Location',
                        turf.location,
                      ),
                      const Divider(height: 24),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Colors.grey.shade500),
                            const SizedBox(width: 8),
                            Text('Status',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // View Bookings Button
              ElevatedButton.icon(
                icon: const Icon(Icons.book_online_outlined),
                label: const Text('View My Bookings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  // Navigate to home and switch to Bookings tab (index 1)
                  Get.offAllNamed('/home', arguments: {'tab': 1});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => Get.offAllNamed('/home'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: Colors.grey.shade700,
                ),
                child: const Text('Back to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey.shade500),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              fontSize: bold ? 15 : 14,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
