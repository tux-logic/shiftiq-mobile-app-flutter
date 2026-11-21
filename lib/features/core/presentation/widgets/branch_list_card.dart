import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/localization/app_localizations.dart';
import 'package:shiftiq_mobile_app_flutter/core/theme.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/domain/core_domain.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_liquid_button.dart';

/// Image-first ShiftIQ branch card supporting cover photos with a navy-gradient fallback.
class BranchListCard extends StatelessWidget {
  final Branch branch;
  final bool isFocused;
  final bool isCurrentSession;
  final VoidCallback onTap;
  final VoidCallback onEnter;
  final VoidCallback? onEdit;

  const BranchListCard({
    super.key,
    required this.branch,
    required this.isFocused,
    required this.isCurrentSession,
    required this.onTap,
    required this.onEnter,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final borderColor = isCurrentSession
        ? ShiftIQColors.primaryBlue
        : const Color(0xFFE2E8F0);

    return Material(
      key: Key('branch_card_${branch.code}'),
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: isCurrentSession ? 3 : 1,
      shadowColor: const Color(0xFF0F172A).withValues(alpha: 0.10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: borderColor,
              width: isCurrentSession ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BranchCoverBanner(
                branch: branch,
                isCurrentSession: isCurrentSession,
                onEdit: onEdit,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      branch.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: ShiftIQColors.graphiteText,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _MetadataRow(
                      icon: Icons.place_outlined,
                      text: branch.address,
                      maxLines: 2,
                    ),
                    if (branch.phone != null && branch.phone!.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      _MetadataRow(
                        icon: Icons.phone_outlined,
                        text: branch.phone!,
                      ),
                    ],
                    const SizedBox(height: 14),
                    ShiftIQLiquidButton(
                      key: Key('btn_enter_branch_${branch.code}'),
                      icon: Icons.arrow_forward_rounded,
                      label: loc.translate('enter_this_branch'),
                      expand: true,
                      height: 44,
                      borderRadius: 12,
                      onPressed: onEnter,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BranchCoverBanner extends StatelessWidget {
  final Branch branch;
  final bool isCurrentSession;
  final VoidCallback? onEdit;

  const _BranchCoverBanner({
    required this.branch,
    required this.isCurrentSession,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        branch.coverImageUrl != null && branch.coverImageUrl!.isNotEmpty;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
      child: SizedBox(
        height: 124,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.network(
                branch.coverImageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const _NavyBannerFallback();
                },
                errorBuilder: (_, _, _) => const _NavyBannerFallback(),
              )
            else
              const _NavyBannerFallback(),

            // Subtle dark gradient scrim for crisp badge contrast
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0F172A).withValues(alpha: 0.28),
                    const Color(0xFF0F172A).withValues(alpha: 0.65),
                  ],
                ),
              ),
            ),

            // Top badges: Code + Active status
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  if (branch.code.isNotEmpty)
                    _BannerPill(
                      label: branch.code,
                      background: const Color(0xFF0F172A).withValues(alpha: 0.72),
                      foreground: Colors.white,
                      borderColor: Colors.white.withValues(alpha: 0.25),
                    ),
                  const Spacer(),
                  _BranchStatusPill(active: branch.active),
                ],
              ),
            ),

            // Bottom badges: Current session / Map availability + optional Edit button
            if (isCurrentSession || branch.hasCoordinates || onEdit != null)
              Positioned(
                bottom: 10,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    if (isCurrentSession) ...[
                      _BannerPill(
                        label: 'CURRENT',
                        icon: Icons.check_circle_rounded,
                        background: ShiftIQColors.secondaryTeal,
                        foreground: Colors.white,
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (branch.hasCoordinates)
                      _BannerPill(
                        label: 'On Map',
                        icon: Icons.location_on_rounded,
                        background: Colors.white.withValues(alpha: 0.92),
                        foreground: ShiftIQColors.primaryBlue,
                      ),
                    const Spacer(),
                    if (onEdit != null)
                      ShiftIQLiquidIconButton(
                        key: Key('btn_edit_branch_${branch.code}'),
                        icon: Icons.photo_camera_outlined,
                        size: 34,
                        iconSize: 16,
                        onDarkBackground: true,
                        onPressed: onEdit!,
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

class _NavyBannerFallback extends StatelessWidget {
  const _NavyBannerFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), ShiftIQColors.primaryBlue],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            bottom: -18,
            child: Icon(
              Icons.store_mall_directory_rounded,
              size: 112,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final Color? borderColor;

  const _BannerPill({
    required this.label,
    this.icon,
    required this.background,
    required this.foreground,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: foreground,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final int maxLines;

  const _MetadataRow({
    required this.icon,
    required this.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 15, color: const Color(0xFF64748B)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _BranchStatusPill extends StatelessWidget {
  final bool active;

  const _BranchStatusPill({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active
        ? ShiftIQColors.preventiveGreen
        : ShiftIQColors.severityCrimson;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.5,
            height: 6.5,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            active ? 'ACTIVE' : 'INACTIVE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
