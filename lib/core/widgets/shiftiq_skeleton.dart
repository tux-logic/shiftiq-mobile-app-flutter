import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';

/// Animated shimmer wrapper that sweeps a soft highlight across skeleton bones.
class ShiftIQSkeletonShimmer extends StatefulWidget {
  final Widget child;

  const ShiftIQSkeletonShimmer({super.key, required this.child});

  @override
  State<ShiftIQSkeletonShimmer> createState() => _ShiftIQSkeletonShimmerState();
}

class _ShiftIQSkeletonShimmerState extends State<ShiftIQSkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1350),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final slide = -1.0 + (_controller.value * 3.0);
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(slide - 1.0, 0),
              end: Alignment(slide + 1.0, 0),
              colors: const [
                Color(0xFFE2E8F0),
                Color(0xFFF8FAFC),
                Color(0xFFE2E8F0),
              ],
              stops: const [0.15, 0.5, 0.85],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Basic rounded skeleton bone used to compose ShiftIQ skeleton layouts.
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

/// Skeleton list mimicking ShiftIQ's 18px-radius entity cards
/// (Work Orders, Appointments, Inventory, Telemetry, Customers, Billing).
class ShiftIQSkeletonCardList extends StatelessWidget {
  final int itemCount;
  final bool showKpiRow;
  final EdgeInsetsGeometry padding;

  const ShiftIQSkeletonCardList({
    super.key,
    this.itemCount = 4,
    this.showKpiRow = false,
    this.padding = const EdgeInsets.fromLTRB(16, 12, 16, 108),
  });

  @override
  Widget build(BuildContext context) {
    return ShiftIQSkeletonShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        children: [
          if (showKpiRow) ...[
            Row(
              children: [
                Expanded(child: _SkeletonKpiCard()),
                const SizedBox(width: 10),
                Expanded(child: _SkeletonKpiCard()),
              ],
            ),
            const SizedBox(height: 14),
          ],
          for (var i = 0; i < itemCount; i++) ...[
            const _SkeletonEntityCard(),
            if (i < itemCount - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/// Skeleton layout matching DashboardPage's KPI grid, chart card, and order rows.
class ShiftIQSkeletonDashboard extends StatelessWidget {
  const ShiftIQSkeletonDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShiftIQSkeletonShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 108),
        children: const [
          Row(
            children: [
              Expanded(child: _SkeletonKpiCard()),
              SizedBox(width: 10),
              Expanded(child: _SkeletonKpiCard()),
            ],
          ),
          SizedBox(height: 12),
          _SkeletonChartCard(),
          SizedBox(height: 12),
          _SkeletonChartCard(height: 168),
          SizedBox(height: 12),
          _SkeletonEntityCard(),
        ],
      ),
    );
  }
}

/// Skeleton layout matching BranchSelectionPage's image-banner branch cards.
class ShiftIQSkeletonBranchList extends StatelessWidget {
  final int itemCount;

  const ShiftIQSkeletonBranchList({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ShiftIQSkeletonShimmer(
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => const _SkeletonBranchCard(),
      ),
    );
  }
}

/// Skeleton layout matching ProfilePage, WorkOrderDetailPage, and VoucherDetailPage.
class ShiftIQSkeletonDetail extends StatelessWidget {
  const ShiftIQSkeletonDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return ShiftIQSkeletonShimmer(
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
                    ShiftIQSkeletonBox(width: 52, height: 52, borderRadius: 26),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShiftIQSkeletonBox(width: 160, height: 16),
                          SizedBox(height: 8),
                          ShiftIQSkeletonBox(width: 110, height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ShiftIQSkeletonBox(width: 190, height: 12),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _SkeletonEntityCard(),
          const SizedBox(height: 12),
          const _SkeletonEntityCard(),
        ],
      ),
    );
  }
}

class _SkeletonKpiCard extends StatelessWidget {
  const _SkeletonKpiCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ShiftIQColors.borderSlate),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShiftIQSkeletonBox(width: 28, height: 28, borderRadius: 8),
              SizedBox(width: 8),
              ShiftIQSkeletonBox(width: 76, height: 12),
            ],
          ),
          SizedBox(height: 12),
          ShiftIQSkeletonBox(width: 96, height: 20),
        ],
      ),
    );
  }
}

class _SkeletonChartCard extends StatelessWidget {
  final double height;

  const _SkeletonChartCard({this.height = 190});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ShiftIQColors.borderSlate),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShiftIQSkeletonBox(width: 140, height: 14),
          SizedBox(height: 8),
          ShiftIQSkeletonBox(width: 90, height: 11),
          Spacer(),
          ShiftIQSkeletonBox(width: double.infinity, height: 84, borderRadius: 12),
        ],
      ),
    );
  }
}

class _SkeletonEntityCard extends StatelessWidget {
  const _SkeletonEntityCard();

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
            children: [
              ShiftIQSkeletonBox(width: 68, height: 22, borderRadius: 8),
              Spacer(),
              ShiftIQSkeletonBox(width: 76, height: 22, borderRadius: 20),
            ],
          ),
          SizedBox(height: 12),
          ShiftIQSkeletonBox(width: 190, height: 15),
          SizedBox(height: 8),
          ShiftIQSkeletonBox(width: 140, height: 12),
          SizedBox(height: 14),
          Row(
            children: [
              ShiftIQSkeletonBox(width: 110, height: 12),
              Spacer(),
              ShiftIQSkeletonBox(width: 72, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonBranchCard extends StatelessWidget {
  const _SkeletonBranchCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ShiftIQColors.borderSlate),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShiftIQSkeletonBox(
            width: double.infinity,
            height: 124,
            borderRadius: 17,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShiftIQSkeletonBox(width: 180, height: 16),
                SizedBox(height: 8),
                ShiftIQSkeletonBox(width: 230, height: 12),
                SizedBox(height: 6),
                ShiftIQSkeletonBox(width: 130, height: 12),
                SizedBox(height: 14),
                ShiftIQSkeletonBox(
                  width: double.infinity,
                  height: 44,
                  borderRadius: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
