import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/owner_controller.dart';
import '../../../controllers/sport_controller.dart';
import '../../../models/turf_model.dart';
import '../../../services/turf_service.dart';
import '../../../controllers/auth_controller.dart';

class OwnerEditTurfScreen extends StatefulWidget {
  const OwnerEditTurfScreen({Key? key}) : super(key: key);

  @override
  State<OwnerEditTurfScreen> createState() => _OwnerEditTurfScreenState();
}

class _OwnerEditTurfScreenState extends State<OwnerEditTurfScreen> {
  final OwnerController ownerController = Get.find<OwnerController>();
  final SportController sportController = Get.put(SportController());

  final _formKey = GlobalKey<FormState>();

  late Turf _editingTurf;
  List<String> _originalFacilities = [];

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();
  final rulesController = TextEditingController();

  String? selectedSportId;

  bool hasParking = false;
  bool hasLights = false;
  bool hasWashroom = false;
  bool hasWater = false;

  bool _isInitLoaded = false;
  bool _isAuthorized = true;

  @override
  void initState() {
    super.initState();
    final turfArg = Get.arguments;
    if (turfArg is Turf) {
      _editingTurf = turfArg;
      final currentUserId = Get.find<AuthController>().user.value?.id;
      if (_editingTurf.ownerId != currentUserId) {
        _isAuthorized = false;
      } else {
        nameController.text = _editingTurf.name;
        locationController.text = _editingTurf.location;
        priceController.text = _editingTurf.pricePerSlot.toStringAsFixed(0);
        descriptionController.text = _editingTurf.description ?? '';
        rulesController.text = _editingTurf.rules ?? '';
        selectedSportId = _editingTurf.sportId;
      }
    } else {
      _isAuthorized = false;
    }

    if (_isAuthorized) {
      _loadInitialData();
    }
  }

  Future<void> _loadInitialData() async {
    await sportController.getSports();

    try {
      ownerController.isLoading.value = true;
      final detailedTurf = await TurfService().getTurfDetails(_editingTurf.id);
      final facilities = detailedTurf.facilities;

      setState(() {
        _originalFacilities = List<String>.from(facilities);
        hasParking = facilities.contains('Parking');
        hasLights = facilities.contains('Flood Lights') || facilities.contains('Lights');
        hasWashroom = facilities.contains('Washroom');
        hasWater = facilities.contains('Drinking Water');
      });
    } catch (e) {
      Get.snackbar('Warning', 'Failed to load turf facilities: $e');
    } finally {
      ownerController.isLoading.value = false;
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

    final List<String> selectedFacilities = [];
    if (hasParking) selectedFacilities.add('Parking');
    if (hasLights) selectedFacilities.add('Flood Lights');
    if (hasWashroom) selectedFacilities.add('Washroom');
    if (hasWater) selectedFacilities.add('Drinking Water');

    final price = double.tryParse(priceController.text) ?? 0.0;

    final success = await ownerController.updateOwnerTurf(
      turfId: _editingTurf.id,
      name: nameController.text.trim(),
      sportId: selectedSportId!,
      location: locationController.text.trim(),
      pricePerSlot: price,
      description: descriptionController.text.trim(),
      rules: rulesController.text.trim(),
      imageUrls: _editingTurf.imageUrls,
      selectedFacilities: selectedFacilities,
      originalFacilities: _originalFacilities,
    );

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'Turf updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
        colorText: Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthorized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Turf')),
        body: const Center(child: Text('You are not authorized to edit this turf.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Turf'),
        backgroundColor: Colors.teal[800],
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final isLoading = ownerController.isLoading.value ||
            ownerController.isProcessing.value ||
            sportController.isLoading.value;

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

                    DropdownButtonFormField<String>(
                      initialValue: sportController.sports.any((s) => s.id == selectedSportId)
                          ? selectedSportId
                          : null,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Sport Type *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    ),
                    CheckboxListTile(
                      title: const Text('Flood Lights'),
                      value: hasLights,
                      onChanged: (v) => setState(() => hasLights = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('Washroom'),
                      value: hasWashroom,
                      onChanged: (v) => setState(() => hasWashroom = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('Drinking Water'),
                      value: hasWater,
                      onChanged: (v) => setState(() => hasWater = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 24),

                    _buildTextField(
                      controller: descriptionController,
                      label: 'Description',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: rulesController,
                      label: 'Rules',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: ownerController.isProcessing.value ? null : _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: ownerController.isProcessing.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            if (ownerController.isProcessing.value || ownerController.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.1),
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
    String? prefixText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
