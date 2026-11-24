import 'package:flutter/material.dart';

/// Full-screen gesture-driven photo gallery viewer with horizontal swipe,
/// pinch-to-zoom, and swipe-up-to-dismiss with smooth fade/scale transition.
class ShiftIQPhotoGalleryViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String title;

  const ShiftIQPhotoGalleryViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.title = 'Foto',
  });

  /// Opens the full-screen gallery route starting at [initialIndex].
  static Future<void> open(
    BuildContext context, {
    required List<String> imageUrls,
    int initialIndex = 0,
    String title = 'Foto',
  }) {
    if (imageUrls.isEmpty) return Future.value();
    final safeIndex = initialIndex.clamp(0, imageUrls.length - 1);
    return Navigator.of(context, rootNavigator: true).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 220),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, _, _) => ShiftIQPhotoGalleryViewer(
          imageUrls: imageUrls,
          initialIndex: safeIndex,
          title: title,
        ),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  State<ShiftIQPhotoGalleryViewer> createState() =>
      _ShiftIQPhotoGalleryViewerState();
}

class _ShiftIQPhotoGalleryViewerState extends State<ShiftIQPhotoGalleryViewer> {
  late final PageController _pageController;
  late int _currentIndex;
  double _dragOffsetY = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onVerticalDragStart(DragStartDetails details) {
    setState(() => _isDragging = true);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final next = _dragOffsetY + details.delta.dy;
    // Allow upward swipe-to-dismiss (and subtle downward elasticity).
    setState(() => _dragOffsetY = next.clamp(-320.0, 48.0));
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final velocityY = details.velocity.pixelsPerSecond.dy;
    final shouldDismiss = _dragOffsetY < -90 || velocityY < -450;
    if (shouldDismiss) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isDragging = false;
      _dragOffsetY = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.imageUrls.length;
    final upwardProgress = (-_dragOffsetY / 220).clamp(0.0, 1.0);
    final backdropOpacity = (1.0 - upwardProgress * 0.72).clamp(0.25, 1.0);
    final scale = (1.0 - upwardProgress * 0.14).clamp(0.86, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: backdropOpacity),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: _isDragging
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              transform: Matrix4.identity()
                ..translateByDouble(0.0, _dragOffsetY, 0.0, 1.0)
                ..scaleByDouble(scale, scale, 1.0, 1.0),
              transformAlignment: Alignment.center,
              child: PageView.builder(
                controller: _pageController,
                itemCount: total,
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Center(
                      child: Image.network(
                        widget.imageUrls[index],
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: Colors.white54,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'No se pudo cargar la imagen',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: AnimatedOpacity(
                opacity: (1.0 - upwardProgress * 1.4).clamp(0.0, 1.0),
                duration: const Duration(milliseconds: 120),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Text(
                          total > 1
                              ? '${widget.title} · ${_currentIndex + 1} / $total'
                              : widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: AnimatedOpacity(
                  opacity: (1.0 - upwardProgress * 1.4).clamp(0.0, 1.0),
                  duration: const Duration(milliseconds: 120),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (total > 1) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(total, (i) {
                              final active = i == _currentIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: active ? 20 : 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: active
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 10),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.keyboard_arrow_up_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Desliza hacia arriba para cerrar',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
