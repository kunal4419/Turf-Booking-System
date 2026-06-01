import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/owner_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../models/turf_model.dart';
import '../../../core/routes/app_routes.dart';

class MyTurfsScreen extends StatelessWidget {
  const MyTurfsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ownerController = Get.find<OwnerController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Turfs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.find<AuthController>().logout();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (ownerController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ownerController.myTurfs.isEmpty) {
          return const Center(child: Text('No turfs found for your account.'));
        }

        return RefreshIndicator(
          onRefresh: () => ownerController.loadOwnerTurfs(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: ownerController.myTurfs.length,
            itemBuilder: (context, index) {
              final turf = ownerController.myTurfs[index];
              return _buildOwnerTurfCard(context, turf, ownerController);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOwnerTurfCard(BuildContext context, Turf turf, OwnerController ownerController) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    turf.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(turf.sportName, style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              turf.location,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Base Slot Price', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('₹${turf.pricePerSlot.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        turf.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: turf.isActive ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    ownerController.selectedTurfId.value = turf.id;
                    Get.toNamed(AppRoutes.ownerPricing);
                  },
                  icon: const Icon(Icons.currency_rupee, size: 16),
                  label: const Text('Slot Pricing'),
                  style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).primaryColor),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    ownerController.selectedTurfId.value = turf.id;
                    ownerController.clearBlockForm();
                    Get.toNamed(AppRoutes.ownerBlockSlots);
                  },
                  icon: const Icon(Icons.block, size: 16),
                  label: const Text('Block Slots'),
                  style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).primaryColor),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    Get.toNamed(AppRoutes.ownerManageSlots, arguments: turf);
                  },
                  icon: const Icon(Icons.schedule, size: 16),
                  label: const Text('Manage Slots'),
                  style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).primaryColor),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.toNamed(AppRoutes.ownerEditTurf, arguments: turf);
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Details'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
