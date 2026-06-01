import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_controller.dart';
import '../../../models/slot_model.dart';

class BlockSlotsScreen extends StatefulWidget {
  const BlockSlotsScreen({super.key});

  @override
  State<BlockSlotsScreen> createState() => _BlockSlotsScreenState();
}

class _BlockSlotsScreenState extends State<BlockSlotsScreen> {
  final _customReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<AdminController>();
      controller.getSlots();
      controller.getAllTurfs();
      controller.getTurfOwners();
    });
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Block Slots'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Select Turf Owner ───────────────────────
              _sectionTitle('Select Turf Owner'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: controller.selectedOwnerId.value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'Choose a turf owner',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: controller.turfOwners.map((owner) {
                  return DropdownMenuItem(
                    value: owner.id,
                    child: Text(owner.name),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.selectedOwnerId.value = value;
                  controller.selectedTurfId.value = null;
                  controller.selectedSlotIds.clear();
                },
              ),
              const SizedBox(height: 20),

              // ─── Select Turf ─────────────────────────────
              _sectionTitle('Select Turf'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey(controller.selectedOwnerId.value),
                initialValue: controller.selectedTurfId.value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'Choose a turf',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: controller.turfs
                    .where((t) => t.ownerId == controller.selectedOwnerId.value)
                    .map((turf) {
                  return DropdownMenuItem(
                    value: turf.id,
                    child: Text(turf.name),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.selectedTurfId.value = value;
                  controller.selectedSlotIds.clear();
                  controller.getBlockedSlots();
                },
              ),
              const SizedBox(height: 20),

              // ─── Select Date ─────────────────────────────
              _sectionTitle('Select Date'),
              const SizedBox(height: 8),
              InkWell(
                onTap: controller.selectedTurfId.value == null
                    ? null
                    : () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: controller.selectedDate.value ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 7)),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (date != null) {
                          controller.selectedDate.value = date;
                          controller.getBlockedSlots();
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: controller.selectedTurfId.value == null
                          ? Colors.grey[300]!
                          : Colors.grey[400]!,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: controller.selectedTurfId.value == null
                        ? Colors.grey[50]
                        : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          controller.selectedDate.value != null
                              ? '${controller.selectedDate.value!.day}/${controller.selectedDate.value!.month}/${controller.selectedDate.value!.year}'
                              : 'Pick a date',
                          style: TextStyle(
                            color: controller.selectedTurfId.value == null
                                ? Colors.grey[400]
                                : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Icon(Icons.calendar_today,
                          color: controller.selectedTurfId.value == null
                              ? Colors.grey[300]
                              : Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ─── Select Slots ────────────────────────────
              _sectionTitle('Select Slots to Block'),
              const SizedBox(height: 8),
              if (controller.selectedTurfId.value == null || controller.selectedDate.value == null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Center(
                    child: Text(
                      'Please select turf and date first',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                )
              else if (controller.allSlots.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Center(
                    child: Text(
                      'No slots active for this turf on this date.',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: controller.allSlots.length,
                  itemBuilder: (context, index) {
                    final Slot slot = controller.allSlots[index];
                    return Obx(() {
                      final isSelected = controller.selectedSlotIds.contains(slot.id);
                      final isBooked = slot.availabilityReason == 'booked';
                      final isBlocked = slot.availabilityReason == 'blocked';
                      final isUnavailable = isBooked || isBlocked;

                      return GestureDetector(
                        onTap: isUnavailable
                            ? null
                            : () => controller.toggleSlot(slot.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.green[600]!
                                  : isBlocked
                                      ? Colors.red[300]!
                                      : isBooked
                                          ? Colors.grey[300]!
                                          : Colors.grey[300]!,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                            color: isSelected
                                ? Colors.green.withValues(alpha: 0.08)
                                : isBlocked
                                    ? Colors.red.withValues(alpha: 0.05)
                                    : isBooked
                                        ? Colors.grey[50]
                                        : Colors.white,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  slot.displayLabel,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isUnavailable
                                        ? Colors.grey
                                        : isSelected
                                            ? Colors.green[800]
                                            : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (isBooked)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.lock, size: 10, color: Colors.grey[500]),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Booked',
                                        style: TextStyle(fontSize: 9, color: Colors.grey[600], fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  )
                                else if (isBlocked)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.block, size: 10, color: Colors.red[600]),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Blocked',
                                        style: TextStyle(fontSize: 9, color: Colors.red[600], fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                else if (isSelected)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle, size: 10, color: Colors.green[600]),
                                      const SizedBox(width: 2),
                                      Text(
                                        'Selected',
                                        style: TextStyle(fontSize: 9, color: Colors.green[600], fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    'Available',
                                    style: TextStyle(fontSize: 9, color: Colors.grey[400]),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
                  },
                ),
              const SizedBox(height: 24),

              // ─── Reason ──────────────────────────────────
              _sectionTitle('Reason'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: controller.selectedReason.value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'Select reason',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: ['Maintenance', 'Private Event', 'Holiday', 'Other']
                    .map((reason) {
                  return DropdownMenuItem(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.selectedReason.value = value;
                },
              ),
              const SizedBox(height: 16),

              // Custom reason
              TextField(
                controller: _customReasonController,
                maxLines: 2,
                onChanged: (value) =>
                    controller.customReason.value = value,
                decoration: InputDecoration(
                  labelText: 'Additional Details (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'Enter additional details',
                ),
              ),
              const SizedBox(height: 28),

              // ─── Existing Blocked Slots ──────────────────
              if (controller.blockedSlots.isNotEmpty) ...[
                _sectionTitle('Currently Blocked Slots'),
                const SizedBox(height: 12),
                ...controller.blockedSlots.map((block) {
                  final slotId = block['slot_id'];
                  final slot = controller.allSlots
                      .firstWhereOrNull((s) => s.id == slotId);
                  final turfName = block['turf']?['name'] ?? 'Turf';
                  final dateStr = block['blocked_date'] ?? '';
                  final reasonVal = block['reason'] ?? '';
                  final notesVal = block['custom_reason'];
                  final blockedByVal = block['blocked_by_user']?['name'] ?? 'Unknown';
                  final createdAtStr = block['created_at'];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.withValues(alpha: 0.15)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.block, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$turfName — ${slot?.displayLabel ?? 'Slot'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => controller.unblockSlot(block['id']),
                                tooltip: 'Unblock',
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          _detailRow('Date', dateStr),
                          _detailRow('Reason', reasonVal),
                          if (notesVal != null && notesVal.toString().isNotEmpty)
                            _detailRow('Notes', notesVal.toString()),
                          _detailRow('Blocked By', blockedByVal),
                          _detailRow('Created At', _formatDateTime(createdAtStr)),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],

              // ─── Block Button ────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearBlockForm();
                        _customReasonController.clear();
                      },
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: controller.isBlocking.value
                          ? null
                          : () async {
                              await controller.blockSlots();
                              _customReasonController.clear();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: controller.isBlocking.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Text('Block Selected Slots',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          );
        }),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  String _formatDateTime(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
