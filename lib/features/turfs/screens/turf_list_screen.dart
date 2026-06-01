import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/turf_controller.dart';


class TurfListScreen extends StatelessWidget {
  const TurfListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final turfController = Get.find<TurfController>();

    // Load turfs on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      turfController.getTurfs();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Turfs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          )
        ],
      ),
      body: Obx(() {
        if (turfController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (turfController.turfs.isEmpty) {
          return const Center(child: Text('No turfs available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: turfController.turfs.length,
          itemBuilder: (context, index) {
            final turf = turfController.turfs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () {
                  turfController.selectTurf(turf.id);
                  Get.toNamed('/turf-details'); // Or use AppRoutes.turfDetails if defined
                },
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        image: turf.imageUrls.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(turf.imageUrls[0]),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: turf.imageUrls.isEmpty
                          ? const Center(
                              child: Icon(Icons.image, size: 50, color: Colors.grey),
                            )
                          : null,
                    ),
                    Padding(
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.5 (20)', // Static for now as model doesn't have it
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                turf.location,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '₹${turf.pricePerSlot}/slot',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
