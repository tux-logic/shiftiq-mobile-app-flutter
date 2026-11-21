import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shiftiq_mobile_app_flutter/core/services/nominatim_geocoding_service.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/minimalist_map_config.dart';

/// Visual vector map pin picker with address search (Nominatim) and
/// expandable full-map modal for capturing branch coordinates without manual lat/lng input.
class BranchLocationPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final ValueChanged<LatLng> onLocationPicked;
  final ValueChanged<String>? onAddressResolved;
  final NominatimGeocodingService? geocodingService;

  const BranchLocationPicker({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationPicked,
    this.onAddressResolved,
    this.geocodingService,
  });

  @override
  State<BranchLocationPicker> createState() => _BranchLocationPickerState();
}

class _BranchLocationPickerState extends State<BranchLocationPicker> {
  final TextEditingController _searchController = TextEditingController();
  late final NominatimGeocodingService _geocodingService;

  MapLibreMapController? _mapController;
  Circle? _pickedCircle;
  LatLng? _pickedPoint;
  bool _styleLoaded = false;
  bool _isSearching = false;
  List<GeocodingPlace> _searchResults = const [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _geocodingService =
        widget.geocodingService ?? NominatimGeocodingService();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _pickedPoint = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _syncPickedCircle() async {
    final controller = _mapController;
    final point = _pickedPoint;
    if (controller == null || !_styleLoaded || point == null) return;

    final options = MinimalistMapConfig.pinCircleOptions(
      point,
      isSelected: true,
    );
    if (_pickedCircle == null) {
      _pickedCircle = await controller.addCircle(options);
    } else {
      await controller.updateCircle(_pickedCircle!, options);
    }
  }

  Future<void> _applyPickedPoint(
    LatLng point, {
    bool moveCamera = false,
    String? resolvedAddress,
  }) async {
    setState(() {
      _pickedPoint = point;
      _searchResults = const [];
    });
    widget.onLocationPicked(point);
    await _syncPickedCircle();
    if (moveCamera && _mapController != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(point, 15.5),
      );
    }
    if (resolvedAddress != null && resolvedAddress.isNotEmpty) {
      widget.onAddressResolved?.call(resolvedAddress);
    } else if (widget.onAddressResolved != null) {
      final addr = await _geocodingService.reverseGeocode(
        point.latitude,
        point.longitude,
      );
      if (addr != null && mounted) {
        widget.onAddressResolved?.call(addr);
      }
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() {
        _searchResults = const [];
        _isSearching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _runSearch(value);
    });
  }

  Future<void> _runSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) return;
    setState(() => _isSearching = true);
    final results = await _geocodingService.searchAddress(trimmed);
    if (!mounted) return;
    setState(() {
      _isSearching = false;
      _searchResults = results;
    });
  }

  Future<void> _openExpandedPicker() async {
    final result = await showDialog<_ExpandedPickResult>(
      context: context,
      builder: (_) => _ExpandedLocationPickerDialog(
        initialPoint: _pickedPoint,
        geocodingService: _geocodingService,
      ),
    );
    if (result != null && mounted) {
      await _applyPickedPoint(
        result.point,
        moveCamera: true,
        resolvedAddress: result.address,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _pickedPoint ?? const LatLng(-12.0865, -76.9905);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Ubicación en el mapa',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: ShiftIQColors.graphiteText,
              ),
            ),
            if (_pickedPoint != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ShiftIQColors.preventiveGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 13,
                      color: ShiftIQColors.preventiveGreen,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Pin fijado',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ShiftIQColors.preventiveGreen,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          textInputAction: TextInputAction.search,
          onChanged: _onSearchChanged,
          onSubmitted: _runSearch,
          style: const TextStyle(fontSize: 13.5),
          decoration: InputDecoration(
            hintText: 'Buscar calle, avenida o distrito...',
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 19,
              color: Color(0xFF64748B),
            ),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ShiftIQColors.primaryBlue,
                      ),
                    ),
                  )
                : (_searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = const []);
                        },
                      )
                    : null),
            isDense: true,
            filled: true,
            fillColor: ShiftIQColors.warmNeutral,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ShiftIQColors.borderSlate),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ShiftIQColors.borderSlate),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: ShiftIQColors.primaryBlue,
                width: 1.4,
              ),
            ),
          ),
        ),
        if (_searchResults.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ShiftIQColors.borderSlate),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _searchResults.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final place = _searchResults[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.place_outlined,
                    size: 18,
                    color: ShiftIQColors.primaryBlue,
                  ),
                  title: Text(
                    place.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                  onTap: () {
                    _searchController.text = place.displayName;
                    _applyPickedPoint(
                      LatLng(place.latitude, place.longitude),
                      moveCamera: true,
                      resolvedAddress: place.displayName,
                    );
                  },
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 185,
            decoration: BoxDecoration(
              border: Border.all(color: ShiftIQColors.borderSlate),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              children: [
                MapLibreMap(
                  styleString: MinimalistMapConfig.styleUrl,
                  initialCameraPosition: CameraPosition(
                    target: center,
                    zoom: _pickedPoint != null ? 15.0 : 12.5,
                  ),
                  compassEnabled: false,
                  rotateGesturesEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onStyleLoadedCallback: () {
                    _styleLoaded = true;
                    _syncPickedCircle();
                  },
                  onMapClick: (_, point) {
                    _applyPickedPoint(point);
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(10),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: _openExpandedPicker,
                      child: const Padding(
                        padding: EdgeInsets.all(7),
                        child: Icon(
                          Icons.open_in_full_rounded,
                          size: 18,
                          color: ShiftIQColors.graphiteText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Busca la dirección arriba o toca directamente el mapa para fijar la ubicación.',
          style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
        ),
      ],
    );
  }
}

class _ExpandedPickResult {
  final LatLng point;
  final String? address;

  const _ExpandedPickResult({required this.point, this.address});
}

class _ExpandedLocationPickerDialog extends StatefulWidget {
  final LatLng? initialPoint;
  final NominatimGeocodingService geocodingService;

  const _ExpandedLocationPickerDialog({
    required this.initialPoint,
    required this.geocodingService,
  });

  @override
  State<_ExpandedLocationPickerDialog> createState() =>
      _ExpandedLocationPickerDialogState();
}

class _ExpandedLocationPickerDialogState
    extends State<_ExpandedLocationPickerDialog> {
  MapLibreMapController? _controller;
  Circle? _circle;
  LatLng? _point;
  String? _resolvedAddress;
  bool _styleLoaded = false;

  @override
  void initState() {
    super.initState();
    _point = widget.initialPoint;
  }

  Future<void> _syncCircle() async {
    final controller = _controller;
    final point = _point;
    if (controller == null || !_styleLoaded || point == null) return;
    final options =
        MinimalistMapConfig.pinCircleOptions(point, isSelected: true);
    if (_circle == null) {
      _circle = await controller.addCircle(options);
    } else {
      await controller.updateCircle(_circle!, options);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _point ?? const LatLng(-12.0865, -76.9905);

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Seleccionar ubicación'),
          backgroundColor: const Color(0xFF0F172A),
          foregroundColor: Colors.white,
          actions: [
            if (_point != null)
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  _ExpandedPickResult(
                    point: _point!,
                    address: _resolvedAddress,
                  ),
                ),
                child: const Text(
                  'Confirmar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            MapLibreMap(
              styleString: MinimalistMapConfig.styleUrl,
              initialCameraPosition: CameraPosition(
                target: center,
                zoom: _point != null ? 15.5 : 13.0,
              ),
              compassEnabled: false,
              rotateGesturesEnabled: false,
              onMapCreated: (c) => _controller = c,
              onStyleLoadedCallback: () {
                _styleLoaded = true;
                _syncCircle();
              },
              onMapClick: (_, pt) async {
                setState(() => _point = pt);
                await _syncCircle();
                final addr = await widget.geocodingService
                    .reverseGeocode(pt.latitude, pt.longitude);
                if (mounted && addr != null) {
                  setState(() => _resolvedAddress = addr);
                }
              },
            ),
            if (_resolvedAddress != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: ShiftIQColors.borderSlate),
                  ),
                  child: Text(
                    _resolvedAddress!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ShiftIQColors.graphiteText,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
