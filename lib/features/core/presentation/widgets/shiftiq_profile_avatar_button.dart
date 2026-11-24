import 'package:flutter/material.dart';
import 'package:shiftiq_mobile_app_flutter/core/di/dependency_injection.dart';
import 'package:shiftiq_mobile_app_flutter/core/storage/session_storage.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/application/usecases/get_user_profile_context.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/profile_page.dart';
import 'package:shiftiq_mobile_app_flutter/features/core/presentation/widgets/shiftiq_liquid_button.dart';

/// Reactive cache for the authenticated user's profile image URL so every
/// header avatar button across all role screens stays in sync without
/// duplicating `/api/v1/profiles/me` requests.
class ShiftIQProfileAvatarStore {
  ShiftIQProfileAvatarStore._();

  static final ValueNotifier<String?> imageUrlNotifier =
      ValueNotifier<String?>(null);

  static bool _hasFetched = false;
  static bool _isFetching = false;

  static void setImageUrl(String? url) {
    final normalized = (url != null && url.trim().isNotEmpty) ? url.trim() : null;
    if (imageUrlNotifier.value != normalized) {
      imageUrlNotifier.value = normalized;
    }
    _hasFetched = true;
  }

  static void clear() {
    imageUrlNotifier.value = null;
    _hasFetched = false;
    _isFetching = false;
  }

  static Future<void> ensureLoaded() async {
    if (_hasFetched || _isFetching) return;
    if (!getIt.isRegistered<SessionStorage>() ||
        !getIt.isRegistered<GetUserProfileContextUseCase>()) {
      return;
    }
    final session = getIt<SessionStorage>();
    if (!session.isAuthenticated) return;

    _isFetching = true;
    try {
      final ctx = await getIt<GetUserProfileContextUseCase>().execute();
      setImageUrl(ctx.resolvedProfileImageUrl);
    } catch (_) {
      // Keep fallback icon quietly if network/context lookup fails.
    } finally {
      _isFetching = false;
    }
  }
}

/// Header profile button that renders the user's profile photo when available,
/// falling back to [ShiftIQLiquidIconButton] with a person icon otherwise.
class ShiftIQProfileAvatarButton extends StatefulWidget {
  final String? tooltip;
  final bool onDarkBackground;
  final VoidCallback? onPressed;
  final double size;

  const ShiftIQProfileAvatarButton({
    super.key,
    this.tooltip,
    this.onDarkBackground = true,
    this.onPressed,
    this.size = 40,
  });

  @override
  State<ShiftIQProfileAvatarButton> createState() =>
      _ShiftIQProfileAvatarButtonState();
}

class _ShiftIQProfileAvatarButtonState
    extends State<ShiftIQProfileAvatarButton> {
  @override
  void initState() {
    super.initState();
    ShiftIQProfileAvatarStore.ensureLoaded();
  }

  void _handleTap() {
    if (widget.onPressed != null) {
      widget.onPressed!();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: ShiftIQProfileAvatarStore.imageUrlNotifier,
      builder: (context, imageUrl, _) {
        if (imageUrl == null || imageUrl.isEmpty) {
          return ShiftIQLiquidIconButton(
            icon: Icons.person_outline_rounded,
            tooltip: widget.tooltip,
            onDarkBackground: widget.onDarkBackground,
            size: widget.size,
            onPressed: _handleTap,
          );
        }

        final button = Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: widget.size,
              height: widget.size,
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withAlpha(180),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(32),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if (wasSynchronouslyLoaded) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.white.withAlpha(24),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
          return Tooltip(message: widget.tooltip!, child: button);
        }
        return button;
      },
    );
  }
}
