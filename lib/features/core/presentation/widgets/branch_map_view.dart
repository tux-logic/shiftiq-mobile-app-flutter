import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/core/widgets/shiftiq_empty_state.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/minimalist_map_config.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_liquid_button.dart';

/// Interactive MapLibre + OpenFreeMap Positron vector map with animated,
/// reactive branch pins, inline branch summary badges, and a compact preview card.
class BranchMapView extends StatefulWidget {
  final List<Branch> branches;
  final Branch? selectedBranch;
  final ValueChanged<Branch> onEnterBranch;
  final VoidCallback? onCreateBranch;

  const BranchMapView({
    super.key,
    required this.branches,
    this.selectedBranch,
    required this.onEnterBranch,
    this.onCreateBranch,
  });

  @override
  State<BranchMapView> createState() => _BranchMapViewState();
}

class _BranchMapViewState extends State<BranchMapView>
    with SingleTickerProviderStateMixin {
  MapLibreMapController? _mapController;
  late final AnimationController _pulseController;
  Branch? _focusedBranch;
  bool _showCard = true;
  bool _styleLoaded = false;
  bool _updatingPositions = false;
  Map<String, math.Point<double>> _pinScreenPoints = {};

  List<Branch> get _geolocatedBranches =>
      widget.branches.where((b) => b.hasCoordinates).toList();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    final geolocated = _geolocatedBranches;
    if (geolocated.isNotEmpty) {
      _focusedBranch = widget.selectedBranch != null &&
              widget.selectedBranch!.hasCoordinates
          ? widget.selectedBranch
          : geolocated.first;
    }
  }

  @override
  void didUpdateWidget(covariant BranchMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.branches != widget.branches) {
      final geolocated = _geolocatedBranches;
      if (_focusedBranch == null && geolocated.isNotEmpty) {
        _focusedBranch = geolocated.first;
      }
      _updatePinScreenPositions();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _updatePinScreenPositions() async {
    final controller = _mapController;
    final geolocated = _geolocatedBranches;
    if (controller == null || !_styleLoaded || geolocated.isEmpty) return;
    if (_updatingPositions) return;

    _updatingPositions = true;
    try {
      final points = await controller.toScreenLocationBatch(
        geolocated.map((b) => LatLng(b.latitude!, b.longitude!)),
      );
      if (!mounted) return;

      final next = <String, math.Point<double>>{};
      for (var i = 0; i < geolocated.length && i < points.length; i++) {
        next[geolocated[i].id] = math.Point<double>(
          points[i].x.toDouble(),
          points[i].y.toDouble(),
        );
      }
      setState(() => _pinScreenPoints = next);
    } catch (_) {
      // Ignore transient projection calls before map layout settles.
    } finally {
      _updatingPositions = false;
    }
  }

  Future<void> _focusBranch(Branch branch) async {
    setState(() {
      _focusedBranch = branch;
      _showCard = true;
    });
    if (branch.hasCoordinates && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(branch.latitude!, branch.longitude!),
          14.0,
        ),
      );
      await _updatePinScreenPositions();
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
              ShiftIQEmptyStateIcon(),
              SizedBox(height: 12),
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
      clipBehavior: Clip.none,
      children: [
        // 1. Minimalist vector map
        MapLibreMap(
          styleString: MinimalistMapConfig.styleUrl,
          initialCameraPosition: CameraPosition(
            target: initialCenter,
            zoom: 13.2,
          ),
          trackCameraPosition: true,
          compassEnabled: false,
          myLocationEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onStyleLoadedCallback: () {
            _styleLoaded = true;
            _updatePinScreenPositions();
          },
          onCameraMove: (_) => _updatePinScreenPositions(),
          onCameraIdle: _updatePinScreenPositions,
          onMapClick: (_, _) {
            if (_showCard) setState(() => _showCard = false);
          },
        ),

        // 2. Animated & reactive branch pins with inline summary badges
        ...geolocated.map((branch) {
          final point = _pinScreenPoints[branch.id];
          if (point == null) return const SizedBox.shrink();

          final isFocused = _focusedBranch?.id == branch.id;
          const pinWidth = 152.0;
          const pinHeight = 76.0;

          return Positioned(
            left: point.x - (pinWidth / 2),
            top: point.y - pinHeight + 8,
            width: pinWidth,
            height: pinHeight,
            child: _AnimatedBranchPin(
              branch: branch,
              isFocused: isFocused,
              pulseAnimation: _pulseController,
              onTap: () => _focusBranch(branch),
            ),
          );
        }),

        // 3. Discrete top-right Liquid Glass map controls
        Positioned(
          top: 12,
          right: 12,
          child: Column(
            children: [
              ShiftIQLiquidIconButton(
                icon: Icons.center_focus_strong_rounded,
                tooltip: 'Center map',
                onPressed: () {
                  final target = _focusedBranch ?? geolocated.first;
                  _focusBranch(target);
                },
              ),
              if (widget.onCreateBranch != null) ...[
                const SizedBox(height: 8),
                ShiftIQLiquidIconButton(
                  key: const Key('btn_add_branch'),
                  icon: Icons.add_rounded,
                  tooltip: loc.translate('new_branch'),
                  isPrimary: true,
                  onPressed: widget.onCreateBranch!,
                ),
              ],
            ],
          ),
        ),

        // 4. Compact ShiftIQ floating summary card (tap to enter, tap map to hide)
        if (_showCard && _focusedBranch != null)
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              child: _CompactBranchSummaryCard(
                key: ValueKey<String>(_focusedBranch!.id),
                branch: _focusedBranch!,
                enterLabel: loc.translate('enter_this_branch'),
                onEnter: () => widget.onEnterBranch(_focusedBranch!),
              ),
            ),
          ),
      ],
    );
  }
}

class _AnimatedBranchPin extends StatelessWidget {
  final Branch branch;
  final bool isFocused;
  final Animation<double> pulseAnimation;
  final VoidCallback onTap;

  const _AnimatedBranchPin({
    required this.branch,
    required this.isFocused,
    required this.pulseAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final badgeLabel = branch.code.isNotEmpty ? branch.code : branch.name;
    final statusColor = branch.active
        ? ShiftIQColors.preventiveGreen
        : ShiftIQColors.severityCrimson;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: AnimatedScale(
        scale: isFocused ? 1.08 : 0.96,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Inline branch summary pill
            Container(
              constraints: const BoxConstraints(maxWidth: 146),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                gradient: isFocused
                    ? const LinearGradient(
                        colors: [Color(0xFF0F172A), ShiftIQColors.primaryBlue],
                      )
                    : null,
                color: isFocused ? null : Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFocused
                      ? ShiftIQColors.accentSkyBlue
                      : const Color(0xFFCBD5E1),
                  width: isFocused ? 1.4 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.16),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      badgeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isFocused
                            ? Colors.white
                            : ShiftIQColors.graphiteText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            // Animated pulsing halo + reactive location icon
            SizedBox(
              width: 38,
              height: 38,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isFocused)
                    AnimatedBuilder(
                      animation: pulseAnimation,
                      builder: (context, _) {
                        final t = pulseAnimation.value;
                        return Transform.scale(
                          scale: 0.75 + (t * 0.85),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ShiftIQColors.secondaryTeal.withValues(
                                alpha: (1 - t) * 0.45,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isFocused
                          ? ShiftIQColors.primaryBlue
                          : const Color(0xFF0F172A),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactBranchSummaryCard extends StatelessWidget {
  final Branch branch;
  final String enterLabel;
  final VoidCallback onEnter;

  const _CompactBranchSummaryCard({
    super.key,
    required this.branch,
    required this.enterLabel,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        branch.coverImageUrl != null && branch.coverImageUrl!.isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 6,
      shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.16),
      child: InkWell(
        onTap: onEnter,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    branch.coverImageUrl!,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        _BranchBadgeThumb(code: branch.code),
                  ),
                )
              else
                _BranchBadgeThumb(code: branch.code),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            branch.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: ShiftIQColors.graphiteText,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: branch.active
                                ? ShiftIQColors.preventiveGreen.withAlpha(24)
                                : ShiftIQColors.severityCrimson.withAlpha(24),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            branch.active ? 'ACTIVE' : 'INACTIVE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: branch.active
                                  ? ShiftIQColors.preventiveGreen
                                  : ShiftIQColors.severityCrimson,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      branch.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ShiftIQLiquidButton(
                key: Key('btn_enter_branch_${branch.code}'),
                icon: Icons.arrow_forward_rounded,
                height: 40,
                borderRadius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                onPressed: onEnter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BranchBadgeThumb extends StatelessWidget {
  final String code;

  const _BranchBadgeThumb({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), ShiftIQColors.primaryBlue],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.store_mall_directory_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
