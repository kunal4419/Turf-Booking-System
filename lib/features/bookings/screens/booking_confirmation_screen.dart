import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/turf_controller.dart';
import '../../../controllers/booking_controller.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final turfController = Get.find<TurfController>();
    final bookingController = Get.find<BookingController>();

    final turf = turfController.selectedTurf.value;
    final slot = bookingController.selectedSlot.value;
    final date = bookingController.selectedDate.value;

    if (turf == null || slot == null || date == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Incomplete booking details. Please go back.')),
      );
    }

    final formattedDate = '${date.day}/${date.month}/${date.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                image: turf.imageUrls.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(turf.imageUrls[0]),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: turf.imageUrls.isEmpty
                  ? const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    )
                  : null,
            ),
            const SizedBox(height: 24),
            Text(
              turf.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 18),
                const SizedBox(width: 4),
                Text(turf.location, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Date', formattedDate),
                  const Divider(height: 24),
                  _buildDetailRow('Time', slot.displayLabel),
                  const Divider(height: 24),
                  _buildDetailRow('Price', '₹${slot.price}', isTotal: true),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 16, color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Obx(() => ElevatedButton(
                      onPressed: bookingController.isLoading.value
                          ? null
                          : () async {
                              // Use the turf ID that's selected
                              bookingController.selectedTurfId.value = turf.id;
                              await bookingController.createBooking();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: bookingController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Confirm Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 18 : 16,
            color: isTotal ? Colors.green[800] : Colors.black87,
          ),
        ),
      ],
    );
  }
}
