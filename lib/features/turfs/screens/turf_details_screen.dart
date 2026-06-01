import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/turf_controller.dart';
import '../../../controllers/booking_controller.dart';
import '../../../core/routes/app_routes.dart';

class TurfDetailsScreen extends StatelessWidget {
  const TurfDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final turfController = Get.find<TurfController>();
    final bookingController = Get.find<BookingController>();

    return Scaffold(
      body: Obx(() {
        if (turfController.isLoading.value &&
            turfController.selectedTurf.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final turf = turfController.selectedTurf.value;
        if (turf == null) {
          return const Center(child: Text('No turf selected'));
        }

        return CustomScrollView(
          slivers: [
            // ── Hero image ───────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 250.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: turf.imageUrls.isNotEmpty
                    ? PageView.builder(
                        itemCount: turf.imageUrls.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            turf.imageUrls[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _imagePlaceholder(context),
                          );
                        },
                      )
                    : _imagePlaceholder(context),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Name + sport chip ──────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            turf.name,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            turf.sportName,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ── Location ──────────────────────────────────────
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.grey, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            turf.location,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Description ───────────────────────────────────
                    if (turf.description != null &&
                        turf.description!.isNotEmpty) ...[
                      const Text('Description',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        turf.description!,
                        style: TextStyle(
                            color: Colors.grey[800], height: 1.5),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Facilities ────────────────────────────────────
                    if (turf.facilities.isNotEmpty) ...[
                      const Text('Facilities',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: turf.facilities
                            .map((f) => Chip(
                                  label: Text(f,
                                      style: const TextStyle(fontSize: 13)),
                                  backgroundColor:
                                      Colors.grey[100],
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // ── Rules ─────────────────────────────────────────
                    if (turf.rules != null && turf.rules!.isNotEmpty) ...[
                      const Text('Rules',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...turf.rules!
                          .split('\n')
                          .where((r) => r.trim().isNotEmpty)
                          .map((rule) => _buildRuleItem(rule)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),

      // ── Book Now bar ──────────────────────────────────────────────────
      bottomSheet: Obx(() {
        final turf = turfController.selectedTurf.value;
        if (turf == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price per slot',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(
                    '₹${turf.pricePerSlot.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    bookingController.setSelectedTurf(
                        turf.id, turf.pricePerSlot);
                    Get.toNamed(AppRoutes.slotSelection);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Book Now',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      color: Colors.green.withValues(alpha: 0.15),
      child: const Center(
        child: Icon(Icons.stadium, size: 60, color: Colors.white70),
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 6, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text,
                  style: TextStyle(color: Colors.grey[800], height: 1.4))),
        ],
      ),
    );
  }
}
