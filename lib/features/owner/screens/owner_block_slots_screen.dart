import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/owner_controller.dart';
import '../../../models/slot_model.dart';

class OwnerBlockSlotsScreen extends StatefulWidget {
  const OwnerBlockSlotsScreen({super.key});

  @override
  State<OwnerBlockSlotsScreen> createState() => _OwnerBlockSlotsScreenState();
}

class _OwnerBlockSlotsScreenState extends State<OwnerBlockSlotsScreen> {
  final _ownerController = Get.find<OwnerController>();
  final _customReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_ownerController.selectedTurfId.value == null && _ownerController.myTurfs.isNotEmpty) {
        _ownerController.selectedTurfId.value = _ownerController.myTurfs.first.id;
      }
      _ownerController.loadBlockSlotsData();
    });
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Block Slots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _ownerController.loadBlockSlotsData(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Select Turf ─────────────────────────────
              _sectionTitle('Select Turf'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _ownerController.selectedTurfId.value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'Choose a turf',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _ownerController.myTurfs.map((turf) {
                  return DropdownMenuItem(
                    value: turf.id,
                    child: Text(turf.name),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _ownerController.selectedTurfId.value = value;
                    _ownerController.blockSelectedSlotIds.clear();
                    _ownerController.loadBlockSlotsData();
                  }
                },
              ),
              const SizedBox(height: 20),

              // ─── Select Date ─────────────────────────────
              _sectionTitle('Select Date'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _ownerController.selectedTurfId.value == null
                    ? null
                    : () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _ownerController.selectedDate.value,
                          firstDate: DateTime.now().subtract(const Duration(days: 7)),
                          lastDate: DateTime.now().add(const Duration(days: 90)),
                        );
                        if (date != null) {
                          _ownerController.selectedDate.value = date;
                          _ownerController.blockSelectedSlotIds.clear();
                          _ownerController.loadBlockSlotsData();
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _ownerController.selectedTurfId.value == null
                          ? Colors.grey[300]!
                          : Colors.grey[400]!,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: _ownerController.selectedTurfId.value == null
                        ? Colors.grey[50]
                        : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_ownerController.selectedDate.value.day}/${_ownerController.selectedDate.value.month}/${_ownerController.selectedDate.value.year}',
                          style: TextStyle(
                            color: _ownerController.selectedTurfId.value == null
                                ? Colors.grey[400]
                                : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Icon(Icons.calendar_today,
                          color: _ownerController.selectedTurfId.value == null
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
              if (_ownerController.selectedTurfId.value == null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Center(
                    child: Text(
                      'Please select turf first',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                )
              else if (_ownerController.isBlockLoading.value)
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                )
              else if (_ownerController.blockAllSlots.isEmpty)
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
                  itemCount: _ownerController.blockAllSlots.length,
                  itemBuilder: (context, index) {
                    final Slot slot = _ownerController.blockAllSlots[index];
                    return Obx(() {
                      final isSelected = _ownerController.blockSelectedSlotIds.contains(slot.id);
                      final isBooked = slot.availabilityReason == 'booked';
                      final isBlocked = slot.availabilityReason == 'blocked';
                      final isUnavailable = isBooked || isBlocked;

                      return GestureDetector(
                        onTap: isUnavailable
                            ? null
                            : () => _ownerController.toggleBlockSlot(slot.id),
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
                initialValue: _ownerController.blockReason.value,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'Select reason',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: ['Maintenance', 'Private Event', 'Holiday', 'Other'].map((reason) {
                  return DropdownMenuItem(
                    value: reason,
                    child: Text(reason),
                  );
                }).toList(),
                onChanged: (value) {
                  _ownerController.blockReason.value = value;
                },
              ),
              const SizedBox(height: 16),

              // Notes Text Field
              TextField(
                controller: _customReasonController,
                maxLines: 2,
                onChanged: (value) => _ownerController.blockCustomReason.value = value,
                decoration: InputDecoration(
                  labelText: 'Additional Details (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: 'Enter optional details/notes',
                ),
              ),
              const SizedBox(height: 24),

              // ─── Block Buttons ────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _ownerController.clearBlockForm();
                        _customReasonController.clear();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _ownerController.isProcessing.value
                          ? null
                          : () async {
                              await _ownerController.blockSlots();
                              _customReasonController.clear();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _ownerController.isProcessing.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Block Selected Slots',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ─── Currently Blocked Slots List ─────────────
              Obx(() {
                if (_ownerController.isBlockLoading.value) {
                  return const SizedBox();
                }

                if (_ownerController.blockBlockedSlots.isEmpty) {
                  return const SizedBox();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionTitle('Currently Blocked Slots'),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _ownerController.blockBlockedSlots.length,
                      itemBuilder: (context, idx) {
                        final block = _ownerController.blockBlockedSlots[idx];
                        final blockId = block['id'];
                        final turfName = block['turf']?['name'] ?? 'Turf';
                        final slotLabel = block['slot']?['display_label'] ?? 'Slot';
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
                                        '$turfName — $slotLabel',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () => _ownerController.unblockSlot(blockId),
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
                      },
                    ),
                  ],
                );
              }),
            ],
          );
        }),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
    );
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
