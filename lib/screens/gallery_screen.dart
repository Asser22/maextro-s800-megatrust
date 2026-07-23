import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/car_data.dart';
import '../models/car.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/kit.dart';
import '../widgets/photo.dart';

/// The photography, filterable by part of the car.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  String _category = 'All';

  List<GalleryPhoto> get _visible => _category == 'All'
      ? car.photos
      : car.photos.where((p) => p.category == _category).toList();

  /// Distributes photos into [count] balanced columns, counting a tall plate
  /// as 1.55 of a wide one.
  List<List<GalleryPhoto>> _distribute(int count) {
    final columns = List.generate(count, (_) => <GalleryPhoto>[]);
    final heights = List.filled(count, 0.0);

    for (final p in _visible) {
      var shortest = 0;
      for (var i = 1; i < count; i++) {
        if (heights[i] < heights[shortest]) shortest = i;
      }
      columns[shortest].add(p);
      heights[shortest] += p.tall ? 1.55 : 1.0;
    }
    return columns;
  }

  @override
  Widget build(BuildContext context) {
    final tier = Breakpoints.of(context);
    final margin = Breakpoints.margin(context);
    final categories = ['All', ...car.photoCategories];
    final columns = _distribute(Breakpoints.galleryColumns(context));
    final all = _visible;

    return Bounded(
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          margin,
          tier.isCompact ? MediaQuery.of(context).padding.top + Gap.lg : Gap.lg,
          margin,
          Gap.xl,
        ),
        children: [
          SectionHead(
            eyebrow: '${car.photos.length} plates',
            title: 'Gallery',
            lede: 'Exterior, both cabins, and the details that justify the '
                'price. Tap any frame for full screen.',
            large: tier.atLeastMedium,
          ),
          const SizedBox(height: Gap.lg),
          Wrap(
            spacing: Gap.xs,
            runSpacing: Gap.xs,
            children: [
              for (final c in categories)
                OptionChip(
                  label: c,
                  trailing: '${c == 'All' ? car.photos.length : car.photos.where((p) => p.category == c).length}',
                  selected: c == _category,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _category = c);
                  },
                ),
            ],
          ),
          const SizedBox(height: Gap.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, column) in columns.indexed) ...[
                if (i > 0) const SizedBox(width: Gap.xs),
                Expanded(child: _Column(photos: column, all: all)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({required this.photos, required this.all});

  final List<GalleryPhoto> photos;
  final List<GalleryPhoto> all;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final photo in photos)
          Padding(
            padding: const EdgeInsets.only(bottom: Gap.xs),
            child: _Frame(
              photo: photo,
              index: all.indexOf(photo),
              onTap: () => PhotoViewer.open(context, all, all.indexOf(photo)),
            ),
          ),
      ],
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.photo, required this.index, required this.onTap});

  final GalleryPhoto photo;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(border: Border.all(color: AppColors.hairlineSoft)),
            child: AspectRatio(
              aspectRatio: photo.tall ? 3 / 4.2 : 4 / 3,
              child: Plate(photo: photo),
            ),
          ),
          const SizedBox(height: Gap.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Caps(
                (index + 1).toString().padLeft(2, '0'),
                color: AppColors.champagneDeep,
                size: 9,
              ),
              const SizedBox(width: Gap.xs),
              Expanded(
                child: Text(
                  photo.caption,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(height: 1.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: Gap.xs),
        ],
      ),
    );
  }
}
