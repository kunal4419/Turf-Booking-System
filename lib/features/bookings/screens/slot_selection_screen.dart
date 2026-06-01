import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/turf_controller.dart';
import '../../../controllers/booking_controller.dart';

class SlotSelectionScreen extends StatefulWidget {
  const SlotSelectionScreen({super.key});

  @override
  State<SlotSelectionScreen> createState() => _SlotSelectionScreenState();
}

class _SlotSelectionScreenState extends State<SlotSelectionScreen> {
  final turfController = Get.find<TurfController>();
  final bookingController = Get.find<BookingController>();
  int _selectedDateIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial slots for today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSlots(DateTime.now());
    });
  }

  void _loadSlots(DateTime date) {
    bookingController.setSelectedDate(date);
    if (turfController.selectedTurf.value != null) {
      final formattedDate = date.toIso8601String().split('T')[0];
      turfController.getSlotAvailability(turfController.selectedTurf.value!.id, formattedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Date & Time')),
      body: Obx(() {
        if (turfController.selectedTurf.value == null) {
          return const Center(child: Text('No turf selected'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildDateStrip(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Available Slots',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: turfController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : turfController.selectedSlots.isEmpty
                      ? const Center(child: Text('No slots available for this date'))
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.1,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: turfController.selectedSlots.length,
                          itemBuilder: (context, index) {
                            final slot = turfController.selectedSlots[index];
                            final isAvailable = slot.isAvailable;
                            final isSelected = bookingController.selectedSlot.value?.id == slot.id;
                            final reason = slot.availabilityReason.toLowerCase();

                            Color itemColor;
                            Color borderCol;
                            Color textColor;
                            String statusText;

                            if (isSelected) {
                              itemColor = Theme.of(context).primaryColor;
                              borderCol = Theme.of(context).primaryColor;
                              textColor = Colors.white;
                              statusText = 'Selected';
                            } else if (reason == 'booked') {
                              itemColor = Colors.red[50]!;
                              borderCol = Colors.red[200]!;
                              textColor = Colors.red[800]!;
                              statusText = 'Booked';
                            } else if (reason == 'blocked') {
                              itemColor = Colors.grey[100]!;
                              borderCol = Colors.grey[300]!;
                              textColor = Colors.grey[600]!;
                              statusText = 'Blocked';
                            } else {
                              itemColor = Colors.white;
                              borderCol = Theme.of(context).primaryColor.withOpacity(0.5);
                              textColor = Theme.of(context).primaryColor;
                              statusText = 'Available';
                            }

                            return InkWell(
                              onTap: isAvailable
                                  ? () {
                                      bookingController.setSelectedSlot(slot);
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: itemColor,
                                  border: Border.all(
                                    color: borderCol,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      slot.displayLabel,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${slot.price.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white70 : Colors.grey[700],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white24
                                            : (reason == 'booked'
                                                ? Colors.red[100]
                                                : (reason == 'blocked'
                                                    ? Colors.grey[200]
                                                    : Theme.of(context).primaryColor.withOpacity(0.1))),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        statusText,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : textColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            if (bookingController.selectedSlot.value != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Selected', style: TextStyle(color: Colors.grey)),
                        Text(
                          bookingController.selectedSlot.value!.displayLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.toNamed('/booking-confirmation');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildDateStrip() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index));
          final isSelected = _selectedDateIndex == index;
          
          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          final dayName = days[date.weekday - 1];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDateIndex = index;
              });
              // Reset slot selection
              bookingController.selectedSlot.value = null;
              _loadSlots(date);
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green[700] : Colors.white,
                border: Border.all(
                  color: isSelected ? Colors.green[700]! : Colors.grey[300]!,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
