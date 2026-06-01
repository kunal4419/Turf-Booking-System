import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/owner_controller.dart';
import '../../../models/booking_model.dart';
import 'package:intl/intl.dart';

class TurfBookingsScreen extends StatefulWidget {
  const TurfBookingsScreen({Key? key}) : super(key: key);

  @override
  State<TurfBookingsScreen> createState() => _TurfBookingsScreenState();
}

class _TurfBookingsScreenState extends State<TurfBookingsScreen> {
  final _ownerController = Get.find<OwnerController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ownerController.loadBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _ownerController.loadBookings(),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          _buildFilterChips(),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (_ownerController.isLoading.value && _ownerController.allBookings.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_ownerController.filteredBookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No ${_ownerController.selectedStatusFilter.value} bookings found',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => _ownerController.loadBookings(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: _ownerController.filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = _ownerController.filteredBookings[index];
                    return _buildRequestCard(context, booking);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Pending', 'Approved', 'Cancelled', 'Rejected', 'Completed'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Obx(() {
            final isSelected = _ownerController.selectedStatusFilter.value == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(filter),
                selected: isSelected,
                selectedColor: Theme.of(context).primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) {
                    _ownerController.setStatusFilter(filter);
                  }
                },
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Booking booking) {
    final isPending = booking.status.toLowerCase() == 'pending';
    final parsedDate = DateTime.tryParse(booking.bookingDate);
    final dateStr = parsedDate != null
        ? DateFormat('dd MMM yyyy').format(parsedDate)
        : booking.bookingDate;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  radius: 20,
                  child: Text(
                    booking.customerName != null && booking.customerName!.isNotEmpty
                        ? booking.customerName![0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.customerName ?? 'Unknown Customer',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(booking.turfName,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(booking.status),
              ],
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(dateStr,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  if (booking.slotDisplay.isNotEmpty) ...[
                    const Text(' • ', style: TextStyle(color: Colors.grey)),
                    Text(booking.slotDisplay,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  ],
                  const Spacer(),
                  Text('₹${booking.price.toStringAsFixed(0)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Theme.of(context).primaryColor)),
                ],
              ),
            ),

            if (isPending) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _ownerController.isProcessing.value
                          ? null
                          : () => _showRejectDialog(context, booking.bookingId),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _ownerController.isProcessing.value
                          ? null
                          : () => _showApproveConfirmationDialog(context, booking.bookingId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _ownerController.isProcessing.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showApproveConfirmationDialog(BuildContext context, String bookingId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Booking'),
        content: const Text(
          'Are you sure you want to approve this booking? All other pending requests for the same slot will be rejected automatically.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _ownerController.approveBooking(bookingId);
            },
            child: const Text('Approve', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = Colors.amber[50]!;
        textColor = Colors.amber[800]!;
        break;
      case 'approved':
        bgColor = Colors.green[50]!;
        textColor = Colors.green[800]!;
        break;
      case 'rejected':
        bgColor = Colors.red[50]!;
        textColor = Colors.red[800]!;
        break;
      case 'cancelled':
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        break;
      case 'completed':
        bgColor = Colors.blue[50]!;
        textColor = Colors.blue[800]!;
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.capitalizeFirst ?? status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String bookingId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Booking'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter rejection reason',
            border: OutlineInputBorder(),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _ownerController.rejectBooking(
                bookingId,
                reason: reasonController.text.isNotEmpty
                    ? reasonController.text
                    : 'Rejected by owner',
              );
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
