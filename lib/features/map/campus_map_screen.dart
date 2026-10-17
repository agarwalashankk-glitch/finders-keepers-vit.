import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/campus_locations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/item_model.dart';
import '../../../models/item_status.dart';
import '../../../providers/item_providers.dart';
import '../../../widgets/loading_indicator.dart';
import 'widgets/map_item_preview_sheet.dart';

class CampusMapScreen extends ConsumerStatefulWidget {
  const CampusMapScreen({super.key});

  @override
  ConsumerState<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends ConsumerState<CampusMapScreen> {
  final MapController _mapController = MapController();
  ItemReportType? _mapTypeFilter;

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(filteredItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map (Approximate)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Center Campus',
            onPressed: () {
              _mapController.move(
                LatLng(
                  CampusLocations.vitCenterLat,
                  CampusLocations.vitCenterLng,
                ),
                16.5,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          itemsAsync.when(
            data: (items) {
              // Apply map filter (Lost vs Found)
              final displayedItems = _mapTypeFilter == null
                  ? items
                  : items.where((i) => i.reportType == _mapTypeFilter).toList();

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(
                    CampusLocations.vitCenterLat,
                    CampusLocations.vitCenterLng,
                  ),
                  initialZoom: 16.5,
                  minZoom: 14.0,
                  maxZoom: 18.5,
                ),
                children: [
                  // OpenStreetMap Tile Layer
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.codechefvit.finderskeepers',
                  ),

                  // Approximate privacy zone blur circles
                  CircleLayer(
                    circles: displayedItems.map((item) {
                      final isLost = item.reportType == ItemReportType.lost;
                      return CircleMarker(
                        point: LatLng(
                          item.approximateLocation.approxLatitude,
                          item.approximateLocation.approxLongitude,
                        ),
                        radius: item.approximateLocation.approxRadiusMeters,
                        useRadiusInMeter: true,
                        color: (isLost ? AppColors.lostColor : AppColors.foundColor)
                            .withOpacity(0.18),
                        borderColor: (isLost ? AppColors.lostColor : AppColors.foundColor)
                            .withOpacity(0.4),
                        borderStrokeWidth: 1.5,
                      );
                    }).toList(),
                  ),

                  // Item Markers
                  MarkerLayer(
                    markers: displayedItems.map((item) {
                      final isLost = item.reportType == ItemReportType.lost;
                      return Marker(
                        point: LatLng(
                          item.approximateLocation.approxLatitude,
                          item.approximateLocation.approxLongitude,
                        ),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => _showItemPreview(context, item),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isLost ? AppColors.lostColor : AppColors.foundColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              isLost ? Icons.search : Icons.inventory_2_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
            loading: () => const LoadingIndicator(message: 'Loading map markers...'),
            error: (err, _) => Center(child: Text('Map error: $err')),
          ),

          // Map Filter Pills Header
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Approximate Campus Zones',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  _buildFilterPill('All', _mapTypeFilter == null, () {
                    setState(() => _mapTypeFilter = null);
                  }),
                  const SizedBox(width: 6),
                  _buildFilterPill('Lost', _mapTypeFilter == ItemReportType.lost, () {
                    setState(() => _mapTypeFilter = ItemReportType.lost);
                  }, activeColor: AppColors.lostColor),
                  const SizedBox(width: 6),
                  _buildFilterPill('Found', _mapTypeFilter == ItemReportType.found, () {
                    setState(() => _mapTypeFilter = ItemReportType.found);
                  }, activeColor: AppColors.foundColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    Color activeColor = AppColors.primary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showItemPreview(BuildContext context, ItemModel item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MapItemPreviewSheet(item: item),
    );
  }
}
