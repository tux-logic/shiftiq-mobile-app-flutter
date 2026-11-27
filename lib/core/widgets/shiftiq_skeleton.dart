import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Standard ShiftIQ wrapper around [Skeletonizer] that automatically turns
/// real production widgets into synchronized shimmer skeleton bones.
class ShiftIQSkeletonizer extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const ShiftIQSkeletonizer({
    super.key,
    required this.enabled,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      enableSwitchAnimation: true,
      effect: const ShimmerEffect(
        baseColor: Color(0xFFE2E8F0),
        highlightColor: Color(0xFFF8FAFC),
        duration: Duration(milliseconds: 1350),
      ),
      containersColor: Colors.white,
      child: child,
    );
  }
}

/// Basic rounded skeleton bone used where a dedicated placeholder is needed.
class ShiftIQSkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShiftIQSkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Fallback skeleton layout for screens without an initial real-widget payload
/// (e.g. cold detail views).
class ShiftIQSkeletonDetail extends StatelessWidget {
  const ShiftIQSkeletonDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return ShiftIQSkeletonizer(
      enabled: true,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: ShiftIQColors.borderSlate),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(radius: 26),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nombre del Registro ShiftIQ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text('Subtítulo de estado'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Detalle adicional del registro en sede'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _DetailSectionStub(),
          const SizedBox(height: 12),
          const _DetailSectionStub(),
        ],
      ),
    );
  }
}

/// Skeleton list fallback used as default placeholder in [ShiftIQPullToRefresh].
class ShiftIQSkeletonCardList extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry padding;

  const ShiftIQSkeletonCardList({
    super.key,
    this.itemCount = 4,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 108),
  });

  @override
  Widget build(BuildContext context) {
    return ShiftIQSkeletonizer(
      enabled: true,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, _) => const _DetailSectionStub(),
      ),
    );
  }
}

class _DetailSectionStub extends StatelessWidget {
  const _DetailSectionStub();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ShiftIQColors.borderSlate),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('REF-00102'),
              Text('ESTADO'),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Título principal del elemento',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text('Descripción secundaria y metadatos de sede'),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Detalle inferior'),
              Text('S/ 240.00'),
            ],
          ),
        ],
      ),
    );
  }
}
