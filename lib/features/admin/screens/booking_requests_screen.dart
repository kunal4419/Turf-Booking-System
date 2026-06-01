import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../controllers/admin_controller.dart';

class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AdminController>().getPendingBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Requests'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.getPendingBookings(),
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
              final isLoading = controller.isLoading.value && controller.pendingRequests.isEmpty;

              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.pendingRequests.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No booking requests found',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                );
              }

              // 1. Sort bookings
              final sortedBookings = List<Map<String, dynamic>>.from(controller.pendingRequests);
              sortedBookings.sort((a, b) {
                final statusA = a['status']?.toString() ?? 'Pending';
                final statusB = b['status']?.toString() ?? 'Pending';

                int getStatusPriority(String status) {
                  switch (status.toLowerCase()) {
                    case 'pending':
                      return 1;
                    case 'approved':
                      return 2;
                    case 'rejected':
                      return 3;
                    default:
                      return 4;
                  }
                }

                final pA = getStatusPriority(statusA);
                final pB = getStatusPriority(statusB);

                if (pA != pB) {
                  return pA.compareTo(pB);
                }

                // If same status, sort by created_at desc (latest first)
                final dateStrA = a['created_at']?.toString() ?? '';
                final dateStrB = b['created_at']?.toString() ?? '';
                return dateStrB.compareTo(dateStrA);
              });

              // 2. Filter bookings
              final filteredBookings = sortedBookings.where((booking) {
                if (_selectedFilter == 'All') return true;
                final status = booking['status']?.toString() ?? 'Pending';
                return status.toLowerCase() == _selectedFilter.toLowerCase();
              }).toList();

              if (filteredBookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No $selectedFilter bookings found',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.getPendingBookings(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    final booking = filteredBookings[index];
                    return _buildRequestCard(context, booking, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String get selectedFilter => _selectedFilter;

  Widget _buildFilterChips() {
    final filters = ['All', 'Pending', 'Approved', 'Rejected'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
              selectedColor: Colors.blueGrey[900],
              backgroundColor: Colors.grey[100],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey[300]!,
                ),
              ),
            ),
          );
        },
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

  Widget _buildRequestCard(
      BuildContext context, Map<String, dynamic> booking, AdminController controller) {
    final customerName = booking['customer_name'] ?? 'Unknown User';
    final turfName = booking['turf_name'] ?? 'Unknown Turf';
    final bookingDate = booking['booking_date'] ?? '';
    final slotDisplay = booking['slot_display'] ?? '';
    final price = booking['price'];
    final bookingId = booking['booking_id'] ?? booking['id'] ?? '';
    final createdAt = booking['created_at'];
    final status = booking['status']?.toString() ?? 'Pending';

    String timeAgoStr = '';
    if (booking['time_since_request'] != null) {
      timeAgoStr = '${booking['time_since_request']}';
    } else if (createdAt != null) {
      try {
        timeAgoStr = timeago.format(DateTime.parse(createdAt.toString()));
      } catch (_) {}
    }

    final isPending = status.toLowerCase() == 'pending';

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
            // Header: customer avatar + info + status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  radius: 20,
                  child: Text(
                    customerName.isNotEmpty ? customerName[0].toUpperCase() : 'U',
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
                      Text(customerName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(turfName,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(status),
                    if (timeAgoStr.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(timeAgoStr,
                          style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Booking details bar
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
                  Text(bookingDate,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  if (slotDisplay.isNotEmpty) ...[
                    const Text(' • ', style: TextStyle(color: Colors.grey)),
                    Text(slotDisplay,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  ],
                  const Spacer(),
                  if (price != null)
                    Text('₹$price',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Theme.of(context).primaryColor)),
                ],
              ),
            ),

            // Actions row (only shown for Pending bookings)
            if (isPending) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.isProcessing.value
                          ? null
                          : () => _showRejectDialog(context, bookingId, controller),
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
                      onPressed: controller.isProcessing.value
                          ? null
                          : () => _showApproveConfirmationDialog(context, bookingId, controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: controller.isProcessing.value
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

  void _showApproveConfirmationDialog(
      BuildContext context, String bookingId, AdminController controller) {
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
              controller.approveBooking(bookingId);
            },
            child: const Text('Approve', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(
      BuildContext context, String bookingId, AdminController controller) {
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
              controller.rejectBooking(
                bookingId: bookingId,
                reason: reasonController.text.isNotEmpty
                    ? reasonController.text
                    : 'Rejected by admin',
              );
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
