import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/owner_controller.dart';
import '../../../models/slot_model.dart';

class DirectBookingScreen extends StatefulWidget {
  const DirectBookingScreen({super.key});

  @override
  State<DirectBookingScreen> createState() => _DirectBookingScreenState();
}

class _DirectBookingScreenState extends State<DirectBookingScreen> {
  final OwnerController _ctrl = Get.find<OwnerController>();

  // Local UI state
  Slot? _selectedSlot;
  bool _isWalkin = false;
  final _walkinNameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _customerSearchQuery;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_ctrl.myTurfs.isNotEmpty && _ctrl.directTurfId.value == null) {
        _ctrl.directTurfId.value = _ctrl.myTurfs.first.id;
      }
      if (_ctrl.customers.isEmpty) _ctrl.loadCustomers();
      _loadSlots();
    });
  }

  @override
  void dispose() {
    _walkinNameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _loadSlots() {
    if (_ctrl.directTurfId.value != null) {
      _ctrl.loadDirectBookingSlots(_ctrl.directTurfId.value!, _ctrl.directDate.value);
    }
    setState(() {
      _selectedSlot = null;
    });
  }

  String _prettyDate(DateTime d) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month]} ${d.year}';
  }

  // Show a bottom sheet when owner taps a booked slot
  void _showBookedBySheet(Slot slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.red.shade700, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              slot.displayLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              'This slot is already booked',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Booked by',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          slot.bookedByName ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showConfirmBookingSheet(Slot slot) {
    setState(() {
      _selectedSlot = slot;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            final primaryColor = theme.primaryColor;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selected slot summary row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.access_time, color: primaryColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slot.displayLabel,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '₹${slot.price.toStringAsFixed(0)} • ${_prettyDate(_ctrl.directDate.value)}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        // Close sheet
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() {
                              _selectedSlot = null;
                            });
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Customer type toggle
                    const Text(
                      'Customer',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _typeChip(
                            label: 'Registered',
                            icon: Icons.person,
                            selected: !_isWalkin,
                            onTap: () => setSheetState(() => _isWalkin = false),
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _typeChip(
                            label: 'Walk-in',
                            icon: Icons.directions_walk,
                            selected: _isWalkin,
                            onTap: () => setSheetState(() => _isWalkin = true),
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Customer input section
                    if (!_isWalkin)
                      _buildCustomerDropdown(primaryColor, setSheetState)
                    else
                      _buildWalkinField(),

                    const SizedBox(height: 14),

                    // Notes field (optional)
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Notes (optional)',
                        prefixIcon: const Icon(Icons.notes_outlined, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        isDense: true,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Confirm button
                    Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _ctrl.isDirectLoading.value
                            ? null
                            : () async {
                                final isRegistered = !_isWalkin;
                                final rawId = _ctrl.selectedCustomer.value?['id'];
                                final customerId = isRegistered && rawId != null ? rawId.toString() : null;
                                final customerName = _isWalkin ? _walkinNameCtrl.text.trim() : null;

                                if (isRegistered && customerId == null) {
                                  Get.snackbar('Required', 'Please select a registered customer',
                                      snackPosition: SnackPosition.BOTTOM);
                                  return;
                                }
                                if (_isWalkin && (customerName == null || customerName.isEmpty)) {
                                  Get.snackbar('Required', 'Please enter the walk-in customer name',
                                      snackPosition: SnackPosition.BOTTOM);
                                  return;
                                }

                                final success = await _ctrl.createDirectBooking(
                                  slotId: slot.id,
                                  slotDisplay: slot.displayLabel,
                                  price: slot.price,
                                  customerId: customerId,
                                  customerName: customerName,
                                  notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
                                );

                                if (success) {
                                  // Reset local state on success
                                  setState(() {
                                    _selectedSlot = null;
                                    _walkinNameCtrl.clear();
                                    _notesCtrl.clear();
                                    _ctrl.selectedCustomer.value = null;
                                  });
                                  // Close bottom sheet
                                  Navigator.pop(context);
                                }
                              },
                        icon: _ctrl.isDirectLoading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          _ctrl.isDirectLoading.value ? 'Booking...' : 'Confirm Direct Booking',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      // Clean up selected slot if sheet is dismissed by tapping outside
      setState(() {
        _selectedSlot = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          'Direct Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Obx(() {
        if (_ctrl.myTurfs.isEmpty) {
          return const Center(
            child: Text('No turfs found. Add a turf first.'),
          );
        }

        return Column(
          children: [
            // ── Turf + Date selectors ──
            _buildSelectors(primaryColor),

            // ── Slot Grid ──
            Expanded(
              child: _ctrl.isDirectLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : _ctrl.directSlots.isEmpty
                      ? _buildEmpty()
                      : _buildSlotGrid(primaryColor),
            ),

            // Confirm panel is now fully managed within _showConfirmBookingSheet
          ],
        );
      }),
    );
  }

  // ── Turf dropdown + date strip ──────────────────────────────────────────────

  Widget _buildSelectors(Color primaryColor) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Turf dropdown
          Obx(() => DropdownButtonFormField<String>(
            value: _ctrl.directTurfId.value,
            decoration: InputDecoration(
              labelText: 'Select Turf',
              prefixIcon: const Icon(Icons.stadium_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              isDense: true,
            ),
            items: _ctrl.myTurfs.map((turf) {
              return DropdownMenuItem(value: turf.id, child: Text(turf.name));
            }).toList(),
            onChanged: (id) {
              if (id != null) {
                _ctrl.directTurfId.value = id;
                _loadSlots();
              }
            },
          )),

          const SizedBox(height: 12),

          // Date strip label
          Obx(() => Text(
            _prettyDate(_ctrl.directDate.value),
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          )),
          const SizedBox(height: 8),

          // Horizontal date strip (14 days)
          SizedBox(
            height: 72,
            child: Obx(() {
              final selectedIndex = _ctrl.directSelectedDateIndex.value;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected = selectedIndex == index;
                  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

                  return GestureDetector(
                    onTap: () {
                      _ctrl.directSelectedDateIndex.value = index;
                      _ctrl.directDate.value = date;
                      _loadSlots();
                    },
                    child: Container(
                      width: 56,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white,
                        border: Border.all(
                          color: isSelected ? primaryColor : Colors.grey[300]!,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            days[date.weekday - 1],
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
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

          const SizedBox(height: 12),
          const Divider(height: 1),
        ],
      ),
    );
  }

  // ── Slot grid ───────────────────────────────────────────────────────────────

  Widget _buildSlotGrid(Color primaryColor) {
    return RefreshIndicator(
      onRefresh: () => _ctrl.loadDirectBookingSlots(
          _ctrl.directTurfId.value!, _ctrl.directDate.value),
      color: primaryColor,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.05,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _ctrl.directSlots.length,
        itemBuilder: (context, index) {
          final slot = _ctrl.directSlots[index] as Slot;
          final isSelected = _selectedSlot?.id == slot.id;
          final reason = slot.availabilityReason.toLowerCase();

          Color bgColor;
          Color borderColor;
          Color textColor;
          String statusLabel;

          if (isSelected) {
            bgColor = primaryColor;
            borderColor = primaryColor;
            textColor = Colors.white;
            statusLabel = 'Selected';
          } else if (reason == 'booked') {
            bgColor = Colors.red.shade50;
            borderColor = Colors.red.shade200;
            textColor = Colors.red.shade800;
            statusLabel = 'Booked';
          } else if (reason == 'blocked') {
            bgColor = Colors.grey.shade100;
            borderColor = Colors.grey.shade300;
            textColor = Colors.grey.shade600;
            statusLabel = 'Blocked';
          } else {
            bgColor = Colors.white;
            borderColor = primaryColor.withValues(alpha: 0.5);
            textColor = primaryColor;
            statusLabel = 'Available';
          }

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              if (reason == 'booked') {
                _showBookedBySheet(slot);
              } else if (reason == 'available') {
                _showConfirmBookingSheet(slot);
              }
              // Blocked: no action
            },
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    slot.displayLabel,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${slot.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[700],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white24
                          : reason == 'booked'
                              ? Colors.red.shade100
                              : reason == 'blocked'
                                  ? Colors.grey.shade200
                                  : primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel,
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
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'No slots available for this date',
            style: TextStyle(fontSize: 15, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDropdown(Color primaryColor, StateSetter setSheetState) {
    return Obx(() {
      final customers = _ctrl.customers;
      if (customers.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No registered customers found',
                  style: TextStyle(fontSize: 13, color: Colors.orange.shade700),
                ),
              ),
            ],
          ),
        );
      }

      final filtered = _customerSearchQuery == null || _customerSearchQuery!.isEmpty
          ? customers
          : customers.where((c) {
              final name = (c['name'] ?? '').toString().toLowerCase();
              final email = (c['email'] ?? '').toString().toLowerCase();
              return name.contains(_customerSearchQuery!.toLowerCase()) ||
                  email.contains(_customerSearchQuery!.toLowerCase());
            }).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              labelText: 'Search customer by name / email',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              isDense: true,
            ),
            onChanged: (v) => setSheetState(() => _customerSearchQuery = v),
          ),
          const SizedBox(height: 8),
          if ((_customerSearchQuery ?? '').isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No customers match your search',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: Colors.grey.shade100),
                        itemBuilder: (context, i) {
                          final c = filtered[i];
                          final isSelected = _ctrl.selectedCustomer.value?['id'] == c['id'];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: primaryColor.withValues(alpha: 0.12),
                              child: Text(
                                (c['name'] ?? '?')[0].toUpperCase(),
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            title: Text(
                              c['name'] ?? 'Unknown',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              c['email'] ?? '',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle, color: primaryColor, size: 20)
                                : null,
                            onTap: () {
                              _ctrl.selectedCustomer.value = c;
                              setSheetState(() => _customerSearchQuery = c['name'] ?? '');
                            },
                          );
                        },
                      ),
                    ),
            )
          else if (_ctrl.selectedCustomer.value != null)
            _buildSelectedCustomerChip(primaryColor, setSheetState),
        ],
      );
    });
  }

  Widget _buildSelectedCustomerChip(Color primaryColor, StateSetter setSheetState) {
    final c = _ctrl.selectedCustomer.value!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: primaryColor.withValues(alpha: 0.15),
            child: Text(
              (c['name'] ?? '?')[0].toUpperCase(),
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c['name'] ?? 'Unknown',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                Text(
                  c['email'] ?? '',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 16, color: Colors.grey[500]),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              _ctrl.selectedCustomer.value = null;
              setSheetState(() => _customerSearchQuery = null);
            },
          ),
        ],
      ),
    );
  }

  Widget _typeChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? color : Colors.grey[500]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalkinField() {
    return TextField(
      controller: _walkinNameCtrl,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Walk-in Customer Name *',
        hintText: 'e.g. Rahul Sharma',
        prefixIcon: const Icon(Icons.directions_walk, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
    );
  }
}
