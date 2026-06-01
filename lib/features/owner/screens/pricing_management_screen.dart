import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/owner_controller.dart';

class PricingManagementScreen extends StatefulWidget {
  const PricingManagementScreen({Key? key}) : super(key: key);

  @override
  State<PricingManagementScreen> createState() => _PricingManagementScreenState();
}

class _PricingManagementScreenState extends State<PricingManagementScreen> {
  final _ownerController = Get.find<OwnerController>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ownerController.loadPricingSlots();
    });
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _ownerController.selectedDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      _ownerController.selectedDate.value = picked;
      _ownerController.loadPricingSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slot Pricing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _ownerController.loadPricingSlots(),
          ),
        ],
      ),
      body: Obx(() {
        if (_ownerController.myTurfs.isEmpty) {
          return const Center(child: Text('No turfs available to manage pricing.'));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _ownerController.selectedTurfId.value,
                    decoration: InputDecoration(
                      labelText: 'Select Turf',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _ownerController.myTurfs.map((turf) {
                      return DropdownMenuItem(value: turf.id, child: Text(turf.name));
                    }).toList(),
                    onChanged: (newTurfId) {
                      if (newTurfId != null) {
                        _ownerController.selectedTurfId.value = newTurfId;
                        _ownerController.loadPricingSlots();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20, color: Colors.teal),
                              const SizedBox(width: 12),
                              Text(
                                DateFormat('dd MMMM yyyy').format(_ownerController.selectedDate.value),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const Text(
                            'Change Date',
                            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Obx(() {
                if (_ownerController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_ownerController.slotsPricing.isEmpty) {
                  return const Center(child: Text('No slots loaded.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _ownerController.slotsPricing.length,
                  itemBuilder: (context, index) {
                    final slot = _ownerController.slotsPricing[index];
                    final slotId = slot['slot_id'] as String;
                    final label = slot['display_label'] as String;
                    final price = (slot['price'] as num).toDouble();
                    final isCustom = slot['is_custom'] as bool;

                    if (!_controllers.containsKey(slotId)) {
                      _controllers[slotId] = TextEditingController(text: price.toStringAsFixed(0));
                    } else {
                      if (double.tryParse(_controllers[slotId]!.text) != price) {
                        _controllers[slotId]!.text = price.toStringAsFixed(0);
                      }
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isCustom ? Colors.orange.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isCustom ? 'Custom' : 'Default',
                                          style: TextStyle(
                                            color: isCustom ? Colors.orange[800] : Colors.grey[700],
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (isCustom)
                                        InkWell(
                                          onTap: () {
                                            _ownerController.resetLocalSlotToDefault(slotId);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            child: Text(
                                              'Reset to Default',
                                              style: TextStyle(
                                                color: Colors.red[700],
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _controllers[slotId],
                                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                textAlign: TextAlign.right,
                                decoration: InputDecoration(
                                  prefixText: '₹ ',
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onChanged: (val) {
                                  final newP = double.tryParse(val);
                                  if (newP != null) {
                                    _ownerController.updateLocalSlotPrice(slotId, newP);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _ownerController.isLoading.value ? null : () => _ownerController.saveSlotPricing(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _ownerController.isLoading.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Save Slot Prices', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
