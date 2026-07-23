import 'package:flutter/material.dart';

import '../data/car_data.dart';
import '../state/selection.dart';
import '../models/car.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../utils/actions.dart';
import '../widgets/kit.dart';
import '../widgets/photo.dart';

/// The opening statement: the car, the marque, the price of entry, and the
/// four things that make it worth the crossing.
class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({super.key, required this.onGo});

  final void Function(int index) onGo;

  @override
  Widget build(BuildContext context) {
    final tier = Breakpoints.of(context);
    final margin = Breakpoints.margin(context);
    final selection = Selection.of(context);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _Hero(from: selection.landedFloor, tier: tier),
        Bounded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: margin),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Gap.xl),
                Reveal(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: Breakpoints.readable),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHead(
                          eyebrow: 'The proposition',
                          title: 'Ordered in Alexandria.\nBuilt in Hefei.',
                          large: tier.atLeastMedium,
                        ),
                        const SizedBox(height: Gap.md),
                        Text(car.positioning, style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: Gap.xl),
                _Figures(tier: tier),
                const SizedBox(height: Gap.xl),
                _Dimensions(tier: tier),
                const SizedBox(height: Gap.xxl),
                _Highlights(tier: tier),
                const SizedBox(height: Gap.xxl),
                _Assurances(tier: tier),
                const SizedBox(height: Gap.xxl),
                _Close(onGo: onGo),
                const SizedBox(height: Gap.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hero ─────────────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({required this.from, required this.tier});

  final double from;
  final Tier tier;

  @override
  Widget build(BuildContext context) {
    // The supplied photography is 860 px wide. Stretched full-bleed across a
    // 1900 px desktop that is a 2x upscale and it visibly falls apart, so wide
    // layouts present it as a framed plate at close to its native size — which
    // is also the more editorial composition. Phones stay full-bleed, where
    // 860 px comfortably exceeds the device width.
    return tier.isCompact ? _compact(context) : _wide(context);
  }

  // ── Phone: full-bleed ──────────────────────────────────────────────────────

  Widget _compact(BuildContext context) {
    final margin = Breakpoints.margin(context);

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.86,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Plate(photo: car.photos.first),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.ink.withValues(alpha: 0.80),
                  AppColors.ink.withValues(alpha: 0.10),
                  AppColors.ink.withValues(alpha: 0.90),
                  AppColors.ink,
                ],
                stops: const [0, 0.30, 0.80, 1],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              margin,
              MediaQuery.of(context).padding.top + Gap.md,
              margin,
              Gap.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Reveal(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/brand/mega-trust-light.png', height: 30),
                      const Spacer(),
                      Caps('${car.modelYear}', color: AppColors.boneMuted),
                    ],
                  ),
                ),
                const Spacer(),
                _Titles(from: from, modelSize: 88, taglineSize: 16, priceSize: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Desktop: type left, photographic plate right ───────────────────────────

  Widget _wide(BuildContext context) {
    final margin = Breakpoints.margin(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(margin, Gap.xl, margin, Gap.lg),
      child: Bounded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 5,
              child: _Titles(from: from, modelSize: 116, taglineSize: 18, priceSize: 36),
            ),
            const SizedBox(width: Gap.xl),
            Expanded(
              flex: 7,
              child: Reveal(
                delay: const Duration(milliseconds: 120),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.hairline),
                  ),
                  child: AspectRatio(
                    // Matches the source crop, so the photo is never stretched
                    // on either axis.
                    aspectRatio: 860 / 538,
                    child: Plate(photo: car.photos.first),
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

/// The marque, model, tagline and entry price. Shared by both hero layouts.
class _Titles extends StatelessWidget {
  const _Titles({
    required this.from,
    required this.modelSize,
    required this.taglineSize,
    required this.priceSize,
  });

  final double from;
  final double modelSize;
  final double taglineSize;
  final double priceSize;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Reveal(child: Marque(latin: car.brand, native: car.brandNative)),
        const SizedBox(height: Gap.md),
        Reveal(
          delay: const Duration(milliseconds: 160),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              car.model,
              style: t.displayLarge!.copyWith(fontSize: modelSize, letterSpacing: 2),
            ),
          ),
        ),
        const SizedBox(height: Gap.sm),
        Reveal(
          delay: const Duration(milliseconds: 260),
          child: Text(car.tagline, style: t.bodyLarge!.copyWith(fontSize: taglineSize)),
        ),
        const SizedBox(height: Gap.md),
        const Rule(gilt: true, width: 54, thickness: 1.5),
        const SizedBox(height: Gap.md),
        Reveal(
          delay: const Duration(milliseconds: 360),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Caps('Landed Alexandria, from'),
                    const SizedBox(height: Gap.xs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Num.egpShort(from),
                        style: AppTheme.figure.copyWith(
                          fontSize: priceSize,
                          color: AppColors.champagne,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Gap.md),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Caps('Factory new\n0 km', color: AppColors.boneMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Headline figures ─────────────────────────────────────────────────────────

class _Figures extends StatelessWidget {
  const _Figures({required this.tier});

  final Tier tier;

  @override
  Widget build(BuildContext context) {
    final stats = <(double, String, String, int, bool)>[
      (car.maxPowerHp.toDouble(), 'hp', 'System output', 0, true),
      (car.bestZeroToHundred, 'sec', '0 – 100 km/h', 1, false),
      (car.maxTotalRangeKm.toDouble(), 'km', 'Total range', 0, false),
      (car.wheelbaseMm.toDouble(), 'mm', 'Wheelbase', 0, true),
    ];

    // Four across on a wide screen, two-by-two on a phone.
    final perRow = tier.atLeastMedium ? 4 : 2;

    return Column(
      children: [
        const Rule(),
        for (var row = 0; row * perRow < stats.length; row++) ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var col = 0; col < perRow; col++) ...[
                  if (col > 0) const VerticalDivider(width: 1, color: AppColors.hairline),
                  Expanded(
                    child: Reveal(
                      delay: Duration(milliseconds: 110 * (row * perRow + col)),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          col > 0 ? Gap.md : 0,
                          Gap.md,
                          Gap.xs,
                          Gap.md,
                        ),
                        child: Builder(
                          builder: (context) {
                            final (v, unit, caption, dp, accent) = stats[row * perRow + col];
                            return Figure(
                              value: v,
                              unit: unit,
                              caption: caption,
                              decimals: dp,
                              accent: accent,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Rule(),
        ],
      ],
    );
  }
}

// ── Dimensions ───────────────────────────────────────────────────────────────

/// An architectural dimension band rather than a drawing — a line, two ticks
/// and a number reads as a technical document, not an illustration.
class _Dimensions extends StatelessWidget {
  const _Dimensions({required this.tier});

  final Tier tier;

  @override
  Widget build(BuildContext context) {
    const lines = [
      ('Length', '5,480 mm', 1.0, false),
      ('Wheelbase', '3,370 mm', 0.615, true),
      ('Width', '2,000 mm', 0.365, false),
      ('Height', '1,536 mm', 0.28, false),
    ];

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Caps('Overall dimensions'),
        const SizedBox(height: Gap.md),
        for (final (label, value, fraction, accent) in lines) ...[
          _DimensionLine(label: label, value: value, fraction: fraction, accent: accent),
          const SizedBox(height: Gap.md),
        ],
        Text(
          'Measured against the 5,480 mm overall length. The wheelbase is '
          'longer than a long-wheelbase Maybach S-Class.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );

    if (!tier.atLeastMedium) return body;

    // Wide: set the dimensions beside a photograph of the car in profile.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(flex: 5, child: body),
          const SizedBox(width: Gap.xl),
          Expanded(
            flex: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(border: Border.all(color: AppColors.hairlineSoft)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Plate(photo: car.photos[4]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DimensionLine extends StatelessWidget {
  const _DimensionLine({
    required this.label,
    required this.value,
    required this.fraction,
    this.accent = false,
  });

  final String label;
  final String value;
  final double fraction;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final tint = accent ? AppColors.champagne : AppColors.boneFaint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Caps(label, color: accent ? AppColors.champagne : null)),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: accent ? AppColors.champagne : AppColors.bone,
                  ),
            ),
          ],
        ),
        const SizedBox(height: Gap.xs),
        SizedBox(
          height: 7,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 3,
                child: Container(height: 1, color: AppColors.hairlineSoft),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fraction),
                duration: const Duration(milliseconds: 1300),
                curve: Curves.easeOutQuart,
                builder: (context, v, _) => FractionallySizedBox(
                  widthFactor: v,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 3,
                        child: Container(height: 1, color: tint),
                      ),
                      // End ticks, as on a measured drawing.
                      Positioned(left: 0, child: Container(width: 1, height: 7, color: tint)),
                      Positioned(right: 0, child: Container(width: 1, height: 7, color: tint)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Highlights ───────────────────────────────────────────────────────────────

class _Highlights extends StatelessWidget {
  const _Highlights({required this.tier});

  final Tier tier;

  @override
  Widget build(BuildContext context) {
    final heroes = car.features.where((f) => f.hero).toList();
    final columns = tier.isExpanded ? 2 : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(
          eyebrow: 'Four reasons',
          title: 'What the money actually buys',
          large: tier.atLeastMedium,
        ),
        const SizedBox(height: Gap.lg),
        if (columns == 1)
          for (final (i, f) in heroes.indexed) _HighlightRow(feature: f, index: i)
        else
          for (var row = 0; row * 2 < heroes.length; row++)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var col = 0; col < 2; col++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: col == 0 ? Gap.xl : 0),
                      child: row * 2 + col < heroes.length
                          ? _HighlightRow(
                              feature: heroes[row * 2 + col],
                              index: row * 2 + col,
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
        const Rule(),
      ],
    );
  }
}

class _HighlightRow extends StatelessWidget {
  const _HighlightRow({required this.feature, required this.index});

  final FeatureItem feature;
  final int index;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Reveal(
      delay: Duration(milliseconds: 80 * index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Rule(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Gap.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (feature.figure != null)
                  SizedBox(
                    width: 92,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature.figure!,
                          style: AppTheme.figure.copyWith(
                            fontSize: 30,
                            color: AppColors.champagne,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Caps(feature.figureUnit ?? '', size: 9),
                      ],
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feature.title, style: t.headlineMedium),
                      const SizedBox(height: Gap.xs),
                      Text(feature.description, style: t.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Assurances ───────────────────────────────────────────────────────────────

class _Assurances extends StatelessWidget {
  const _Assurances({required this.tier});

  final Tier tier;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final items = car.assurances.take(tier.atLeastMedium ? 6 : 3).toList();
    final columns = tier.isExpanded ? 3 : (tier.atLeastMedium ? 2 : 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(
          eyebrow: 'Importing with us',
          title: 'A new car, and a paper trail to prove it',
          large: tier.atLeastMedium,
        ),
        const SizedBox(height: Gap.lg),
        // The LayoutBuilder must sit outside the Wrap: a Wrap hands its
        // children unbounded width, so measuring from inside one yields
        // infinity and the cards overflow.
        LayoutBuilder(
          builder: (context, constraints) {
            final width =
                (constraints.maxWidth - Gap.sm * (columns - 1)) / columns;
            return Wrap(
              spacing: Gap.sm,
              runSpacing: Gap.sm,
              children: [
                for (final a in items)
                  SizedBox(
                    width: width,
                    child: Panel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(a.icon, size: 17, color: AppColors.champagne),
                          const SizedBox(height: Gap.sm),
                          Text(a.title, style: t.titleLarge),
                          const SizedBox(height: Gap.xxs),
                          Text(a.detail, style: t.bodySmall),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ── Close ────────────────────────────────────────────────────────────────────

class _Close extends StatelessWidget {
  const _Close({required this.onGo});

  final void Function(int index) onGo;

  @override
  Widget build(BuildContext context) {
    final wide = Breakpoints.of(context).atLeastMedium;

    final buttons = [
      GoldButton(label: 'Build yours', icon: Icons.tune_rounded, onPressed: () => onGo(3)),
      LineButton(
        label: 'Talk to us',
        icon: Icons.forum_outlined,
        onPressed: () => showContactSheet(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (wide)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Row(
                children: [
                  Expanded(child: buttons[0]),
                  const SizedBox(width: Gap.sm),
                  Expanded(child: buttons[1]),
                ],
              ),
            ),
          )
        else ...[
          buttons[0],
          const SizedBox(height: Gap.xs),
          buttons[1],
        ],
        const SizedBox(height: Gap.md),
        Center(
          child: Column(
            children: [
              Image.asset('assets/brand/mega-trust-light.png', height: 30),
              const SizedBox(height: Gap.xs),
              Text(
                '${car.dealerRole} · ${car.addressLine}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
