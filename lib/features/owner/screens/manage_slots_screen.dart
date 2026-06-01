import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/owner_controller.dart';
import '../../../models/turf_model.dart';

class ManageSlotsScreen extends StatefulWidget {
  const ManageSlotsScreen({super.key});

  @override
  State<ManageSlotsScreen> createState() => _ManageSlotsScreenState();
}

class _ManageSlotsScreenState extends State<ManageSlotsScreen> {
  final _ownerController = Get.find<OwnerController>();
  late Turf _turf;

  @override
  void initState() {
    super.initState();
    _turf = Get.arguments as Turf;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ownerController.loadTurfSlots(_turf.id);
    });
  }

  void _enableAllSlots() {
    for (var slot in _ownerController.turfSlotsList) {
      if (slot['is_enabled'] == false) {
        _ownerController.toggleLocalSlot(slot['slot_id']);
      }
    }
  }

  void _disableAllSlots() {
    for (var slot in _ownerController.turfSlotsList) {
      if (slot['is_enabled'] == true) {
        _ownerController.toggleLocalSlot(slot['slot_id']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Slots: ${_turf.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _ownerController.loadTurfSlots(_turf.id),
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            // Quick Action Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.grey[50],
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _enableAllSlots,
                      icon: Icon(Icons.check_circle_outline, size: 18, color: primaryColor),
                      label: Text('Enable All', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _disableAllSlots,
                      icon: const Icon(Icons.highlight_off, size: 18, color: Colors.red),
                      label: const Text('Disable All', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Master Slots List
            Expanded(
              child: Obx(() {
                if (_ownerController.isSlotsLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_ownerController.turfSlotsList.isEmpty) {
                  return const Center(child: Text('No slots loaded.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _ownerController.turfSlotsList.length,
                  itemBuilder: (context, index) {
                    final slot = _ownerController.turfSlotsList[index];
                    final slotId = slot['slot_id'] as String;
                    final label = slot['display_label'] as String;
                    final startTime = slot['start_time'] as String;
                    final endTime = slot['end_time'] as String;
                    final isEnabled = slot['is_enabled'] as bool;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isEnabled
                                    ? primaryColor.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isEnabled ? Icons.alarm_on : Icons.alarm_off,
                                color: isEnabled ? primaryColor : Colors.grey,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isEnabled ? Colors.black87 : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$startTime - $endTime',
                                    style: TextStyle(
                                      color: isEnabled ? Colors.grey[600] : Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: isEnabled,
                              activeThumbColor: primaryColor,
                              activeTrackColor: primaryColor.withValues(alpha: 0.5),
                              onChanged: (_) => _ownerController.toggleLocalSlot(slotId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // Save Configurations Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _ownerController.isSlotsLoading.value
                      ? null
                      : () => _ownerController.saveTurfSlots(_turf.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _ownerController.isSlotsLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Save Configuration',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
