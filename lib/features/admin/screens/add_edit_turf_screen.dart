import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/admin_controller.dart';
import '../../../controllers/sport_controller.dart';
import '../../../models/turf_model.dart';
import '../../../services/turf_service.dart';

class AddEditTurfScreen extends StatefulWidget {
  const AddEditTurfScreen({Key? key}) : super(key: key);

  @override
  State<AddEditTurfScreen> createState() => _AddEditTurfScreenState();
}

class _AddEditTurfScreenState extends State<AddEditTurfScreen> {
  final AdminController adminController = Get.find<AdminController>();
  final SportController sportController = Get.find<SportController>();

  final _formKey = GlobalKey<FormState>();

  // Edit states
  Turf? _editingTurf;
  bool get _isEditMode => _editingTurf != null;
  List<String> _originalFacilities = [];

  // Form Fields
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final rulesController = TextEditingController();

  String? selectedSportId;
  String? selectedOwnerId;

  // Facilities Checks
  bool hasParking = false;
  bool hasLights = false;
  bool hasWashroom = false;
  bool hasWater = false;

  bool _isInitLoaded = false;

  @override
  void initState() {
    super.initState();
    _editingTurf = Get.arguments as Turf?;

    // Prefill basic info
    if (_isEditMode) {
      nameController.text = _editingTurf!.name;
      locationController.text = _editingTurf!.location;
      priceController.text = _editingTurf!.pricePerSlot.toStringAsFixed(0);
      descriptionController.text = _editingTurf!.description ?? '';
      rulesController.text = _editingTurf!.rules ?? '';
      selectedSportId = _editingTurf!.sportId;
      selectedOwnerId = _editingTurf!.ownerId;
    }

    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // 1. Fetch sports & owners in parallel
    await Future.wait([
      sportController.getSports(),
      adminController.getTurfOwners(),
    ]);

    // 2. Fetch full details if in edit mode (to get facilities and rules)
    if (_isEditMode) {
      try {
        adminController.isLoading.value = true;
        final detailedTurf = await TurfService().getTurfDetails(_editingTurf!.id);
        final facilities = detailedTurf.facilities;

        setState(() {
          _originalFacilities = List<String>.from(facilities);
          hasParking = facilities.contains('Parking');
          hasLights = facilities.contains('Flood Lights') || facilities.contains('Lights');
          hasWashroom = facilities.contains('Washroom');
          hasWater = facilities.contains('Drinking Water');
        });
      } catch (e) {
        Get.snackbar('Warning', 'Failed to load full turf facilities: $e');
      } finally {
        adminController.isLoading.value = false;
      }
    }

    setState(() {
      _isInitLoaded = true;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    rulesController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedSportId == null) {
      Get.snackbar('Validation', 'Please select a Sport Type',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100]);
      return;
    }

    if (selectedOwnerId == null) {
      Get.snackbar('Validation', 'Please select a Turf Owner',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red[100]);
      return;
    }

    // Prepare facilities list
    final List<String> selectedFacilities = [];
    if (hasParking) selectedFacilities.add('Parking');
    if (hasLights) selectedFacilities.add('Flood Lights');
    if (hasWashroom) selectedFacilities.add('Washroom');
    if (hasWater) selectedFacilities.add('Drinking Water');

    bool success = false;
    final price = double.tryParse(priceController.text) ?? 0.0;

    if (_isEditMode) {
      success = await adminController.updateTurf(
        turfId: _editingTurf!.id,
        name: nameController.text.trim(),
        sportId: selectedSportId!,
        location: locationController.text.trim(),
        pricePerSlot: price,
        ownerId: selectedOwnerId!,
        description: descriptionController.text.trim(),
        rules: rulesController.text.trim(),
        imageUrls: _editingTurf!.imageUrls,
        isActive: _editingTurf!.isActive,
        selectedFacilities: selectedFacilities,
        originalFacilities: _originalFacilities,
      );
    } else {
      success = await adminController.createTurf(
        name: nameController.text.trim(),
        sportId: selectedSportId!,
        location: locationController.text.trim(),
        pricePerSlot: price,
        ownerId: selectedOwnerId!,
        description: descriptionController.text.trim(),
        rules: rulesController.text.trim(),
        imageUrls: ['https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=800'],
        selectedFacilities: selectedFacilities,
      );
    }

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        _isEditMode ? 'Turf updated successfully' : 'Turf created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Turf' : 'Add Turf'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final isLoading = adminController.isLoading.value ||
            adminController.isProcessing.value ||
            sportController.isLoading.value ||
            adminController.isLoadingOwners.value;

        if (isLoading && !_isInitLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: 'Turf Name',
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Turf Name is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Turf Owner Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: adminController.turfOwners.any((o) => o.id == selectedOwnerId)
                          ? selectedOwnerId
                          : null,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Turf Owner *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: adminController.turfOwners.map((owner) {
                        return DropdownMenuItem<String>(
                          value: owner.id,
                          child: Text(owner.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedOwnerId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Turf Owner selection is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Sport Type Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: sportController.sports.any((s) => s.id == selectedSportId)
                          ? selectedSportId
                          : null,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Sport Type *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: sportController.sports.map((sport) {
                        return DropdownMenuItem<String>(
                          value: sport.id,
                          child: Text(sport.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSportId = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Sport Type selection is required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: locationController,
                      label: 'Location',
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Location is required' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: priceController,
                      label: 'Pricing (per slot)',
                      prefixText: '₹ ',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Price per slot is required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Facilities',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),

                    CheckboxListTile(
                      title: const Text('Parking'),
                      value: hasParking,
                      onChanged: (v) => setState(() => hasParking = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('Flood Lights'),
                      value: hasLights,
                      onChanged: (v) => setState(() => hasLights = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('Washroom'),
                      value: hasWashroom,
                      onChanged: (v) => setState(() => hasWashroom = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    CheckboxListTile(
                      title: const Text('Drinking Water'),
                      value: hasWater,
                      onChanged: (v) => setState(() => hasWater = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: descriptionController,
                      label: 'Description',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: rulesController,
                      label: 'Rules',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _onSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[900],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _isEditMode ? 'Update' : 'Save',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.15),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? prefixText,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
