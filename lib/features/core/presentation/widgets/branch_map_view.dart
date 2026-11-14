import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';

/// Interactive OpenStreetMap view rendering geolocated workshop branches and a floating preview card.
class BranchMapView extends StatefulWidget {
  final List<Branch> branches;
  final Branch? selectedBranch;
  final ValueChanged<Branch> onEnterBranch;

  const BranchMapView({
    super.key,
    required this.branches,
    this.selectedBranch,
    required this.onEnterBranch,
  });

  @override
  State<BranchMapView> createState() => _BranchMapViewState();
}

class _BranchMapViewState extends State<BranchMapView> {
  final MapController _mapController = MapController();
  Branch? _focusedBranch;

  List<Branch> get _geolocatedBranches =>
      widget.branches.where((b) => b.hasCoordinates).toList();

  @override
  void initState() {
    super.initState();
    final geolocated = _geolocatedBranches;
    if (geolocated.isNotEmpty) {
      _focusedBranch = widget.selectedBranch != null &&
              widget.selectedBranch!.hasCoordinates
          ? widget.selectedBranch
          : geolocated.first;
    }
  }

  void _focusBranch(Branch branch) {
    setState(() => _focusedBranch = branch);
    if (branch.hasCoordinates) {
      _mapController.move(
        LatLng(branch.latitude!, branch.longitude!),
        14.2,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final geolocated = _geolocatedBranches;
    final loc = AppLocalizations.of(context);

    if (geolocated.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.map_outlined,
                size: 56,
                color: Color(0xFF94A3B8),
              ),
              SizedBox(height: 14),
              Text(
                'No branches with map coordinates',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: ShiftIQColors.graphiteText,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Branches with latitude and longitude will appear as interactive pins here.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    final initialCenter = LatLng(
      _focusedBranch?.latitude ?? geolocated.first.latitude!,
      _focusedBranch?.longitude ?? geolocated.first.longitude!,
    );

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.tuxlogic.shiftiq.mobile',
            ),
            MarkerLayer(
              markers: geolocated.map((branch) {
                final isFocused = _focusedBranch?.id == branch.id;
                return Marker(
                  point: LatLng(branch.latitude!, branch.longitude!),
                  width: 110,
                  height: 44,
                  child: GestureDetector(
                    onTap: () => _focusBranch(branch),
                    child: AnimatedScale(
                      scale: isFocused ? 1.08 : 0.94,
                      duration: const Duration(milliseconds: 180),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isFocused
                                ? ShiftIQColors.primaryBlue
                                : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  branch.code.isNotEmpty
                                      ? branch.code
                                      : branch.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // Floating branch preview card
        if (_focusedBranch != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Container(
                key: ValueKey<String>(_focusedBranch!.id),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.14),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_focusedBranch!.coverImageUrl != null &&
                        _focusedBranch!.coverImageUrl!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _focusedBranch!.coverImageUrl!,
                          height: 92,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _focusedBranch!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ShiftIQColors.graphiteText,
                            ),
                          ),
                        ),
                        if (_focusedBranch!.code.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: ShiftIQColors.primaryBlue.withAlpha(18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _focusedBranch!.code,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ShiftIQColors.primaryBlue,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _focusedBranch!.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    if (_focusedBranch!.phone != null &&
                        _focusedBranch!.phone!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _focusedBranch!.phone!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: FilledButton.icon(
                        onPressed: () => widget.onEnterBranch(_focusedBranch!),
                        style: FilledButton.styleFrom(
                          backgroundColor: ShiftIQColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: Text(
                          loc.translate('enter_this_branch'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
