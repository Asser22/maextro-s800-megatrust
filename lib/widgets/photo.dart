import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/car.dart';
import '../theme/app_theme.dart';
import 'kit.dart';

/// An asset photograph that degrades to a framed plate when the file is not
/// present, so the app is presentable before the photography is licensed.
class Plate extends StatelessWidget {
  const Plate({super.key, required this.photo, this.fit = BoxFit.cover});

  final GalleryPhoto photo;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      photo.asset,
      fit: fit,
      // Images are scaled up on a large hero; Flutter's default medium
      // filtering leaves visible stair-stepping there. High is bicubic.
      filterQuality: FilterQuality.high,
      errorBuilder: (context, _, __) => const _EmptyPlate(),
      frameBuilder: (context, child, frame, wasSynchronous) {
        if (wasSynchronous || frame != null) return child;
        return const ColoredBox(color: AppColors.surface);
      },
    );
  }
}

class _EmptyPlate extends StatelessWidget {
  const _EmptyPlate();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surfaceRaised, AppColors.obsidian],
        ),
      ),
      child: Center(
        child: Icon(Icons.camera_outdoor_outlined, size: 22, color: AppColors.boneFaint),
      ),
    );
  }
}

/// Full-bleed, swipeable, pinch-zoomable viewer.
class PhotoViewer extends StatefulWidget {
  const PhotoViewer({super.key, required this.photos, required this.initialIndex});

  final List<GalleryPhoto> photos;
  final int initialIndex;

  static Future<void> open(BuildContext context, List<GalleryPhoto> photos, int index) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: AppColors.ink,
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, __, ___) => PhotoViewer(photos: photos, initialIndex: index),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutQuart),
          child: child,
        ),
      ),
    );
  }

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late final PageController _pages = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photos[_index];
    final t = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            itemCount: widget.photos.length,
            onPageChanged: (i) {
              HapticFeedback.selectionClick();
              setState(() => _index = i);
            },
            itemBuilder: (context, i) => _Zoomable(photo: widget.photos[i]),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + Gap.sm,
            left: Gap.page,
            right: Gap.page,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(Gap.xs),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.hairline)),
                    child: const Icon(Icons.close_rounded, size: 17, color: AppColors.bone),
                  ),
                ),
                const Spacer(),
                Caps(
                  '${(_index + 1).toString().padLeft(2, '0')} / '
                  '${widget.photos.length.toString().padLeft(2, '0')}',
                  color: AppColors.boneMuted,
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                Gap.page,
                Gap.xl,
                Gap.page,
                Gap.md + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.ink.withValues(alpha: 0.92)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Caps(photo.category, color: AppColors.champagne),
                  const SizedBox(height: Gap.xs),
                  Text(photo.caption, style: t.headlineMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Zoomable extends StatefulWidget {
  const _Zoomable({required this.photo});

  final GalleryPhoto photo;

  @override
  State<_Zoomable> createState() => _ZoomableState();
}

class _ZoomableState extends State<_Zoomable> with SingleTickerProviderStateMixin {
  final _view = TransformationController();

  /// Built in initState, not lazily: closing the viewer without ever zooming
  /// would otherwise construct the controller inside dispose().
  late final AnimationController _anim;
  Animation<Matrix4>? _tween;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 320))
      ..addListener(() {
        final tween = _tween;
        if (tween != null) _view.value = tween.value;
      });
  }

  @override
  void dispose() {
    _anim.dispose();
    _view.dispose();
    super.dispose();
  }

  void _toggle(TapDownDetails details) {
    final zoomed = _view.value.getMaxScaleOnAxis() > 1.2;
    final target = zoomed
        ? Matrix4.identity()
        : (Matrix4.identity()
          ..translateByDouble(
              -details.localPosition.dx * 1.4, -details.localPosition.dy * 1.4, 0, 1)
          ..scaleByDouble(2.4, 2.4, 2.4, 1));

    _tween = Matrix4Tween(begin: _view.value, end: target)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutQuart));
    _anim.forward(from: 0);
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _toggle,
      onDoubleTap: () {},
      child: InteractiveViewer(
        transformationController: _view,
        minScale: 1,
        maxScale: 5,
        child: Center(child: Plate(photo: widget.photo, fit: BoxFit.contain)),
      ),
    );
  }
}
