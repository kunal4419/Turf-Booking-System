import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/turf_controller.dart';
import '../../../controllers/sport_controller.dart';

class HomeContentScreen extends StatelessWidget {
  const HomeContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final turfController = Get.find<TurfController>();
    final sportController = Get.find<SportController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      sportController.getSports();
      turfController.getTurfs();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Turf System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              Get.toNamed('/notifications');
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                onChanged: (value) {
                  turfController.searchTurfs(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search Turfs',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),

            // Sports Filter (All + Sports categories) — pill-chip style
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'Filter by Sport',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: Obx(() {
                final sports = sportController.sports;
                final selectedId = sportController.selectedSportId.value;
                final isAllSelected = selectedId == null || selectedId.isEmpty;

                return ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    // "All Turfs" chip
                    _buildFilterChip(
                      label: 'All Turfs',
                      isSelected: isAllSelected,
                      onTap: () {
                        sportController.clearSelection();
                        turfController.getTurfs();
                      },
                    ),
                    const SizedBox(width: 8),
                    // Sport chips
                    ...sports.map((sport) {
                      final selected = selectedId == sport.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildFilterChip(
                          label: sport.name,
                          isSelected: selected,
                          onTap: () {
                            if (selected) {
                              sportController.clearSelection();
                              turfController.getTurfs();
                            } else {
                              sportController.selectSport(sport.id);
                              turfController.getTurfs(sportId: sport.id);
                            }
                          },
                        ),
                      );
                    }),
                  ],
                );
              }),
            ),
            const SizedBox(height: 20),

            // All Turfs
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'All Turfs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (turfController.isLoading.value && turfController.filteredTurfs.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (turfController.filteredTurfs.isEmpty) {
                 return const Center(child: Text('No turfs found'));
              }

              return ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: turfController.filteredTurfs.length,
                itemBuilder: (context, index) {
                  final turf = turfController.filteredTurfs[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        turfController.selectTurf(turf.id);
                        Get.toNamed('/turf-details');
                      },
                      child: _buildTurfCard(
                        turf.name,
                        turf.location,
                        '₹${turf.pricePerSlot}',
                        isFullWidth: true,
                        imageUrl: turf.imageUrls.isNotEmpty ? turf.imageUrls[0] : null,
                      ),
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Pill-style filter chip matching the booking requests filter look.
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[700] : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.green[700]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTurfCard(String name, String location, String price, {bool isFullWidth = false, String? imageUrl}) {
    return Container(
      width: isFullWidth ? double.infinity : 200,
      margin: EdgeInsets.only(right: isFullWidth ? 0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: isFullWidth ? 150 : 120,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? const Center(
                    child: Icon(Icons.image, size: 40, color: Colors.grey),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Price: $price/slot',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
