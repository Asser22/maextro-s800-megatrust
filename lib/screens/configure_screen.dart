import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/car_data.dart';
import '../models/car.dart';
import '../state/selection.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../widgets/kit.dart';

/// Choose the build. The landed Alexandria figure updates as the buyer moves.
class ConfigureScreen extends StatelessWidget {
  const ConfigureScreen({super.key, required this.onGo});

  final void Function(int index) onGo;

  @override
  Widget build(BuildContext context) {
    final s = Selection.of(context);
    final tier = Breakpoints.of(context);
    final margin = Breakpoints.margin(context);
    final wide = tier.isExpanded;

    final controls = <Widget>[
      _Step(number: '01', title: 'Powertrain & cabin'),
      const SizedBox(height: Gap.md),
      for (final v in car.variants)
        _VariantRow(
          variant: v,
          selected: v == s.variant,
          onTap: () {
            HapticFeedback.selectionClick();
            s.variant = v;
          },
        ),
      const SizedBox(height: Gap.xl),
      _Step(number: '02', title: 'Exterior finish'),
      const SizedBox(height: Gap.md),
      Wrap(
        spacing: Gap.sm,
        runSpacing: Gap.sm,
        children: [
          for (final p in car.paints)
            _PaintTile(
              paint: p,
              selected: p == s.paint,
              onTap: () {
                HapticFeedback.selectionClick();
                s.paint = p;
              },
            ),
        ],
      ),
      const SizedBox(height: Gap.xl),
      _Step(number: '03', title: 'Cabin'),
      const SizedBox(height: Gap.md),
      for (final i in car.interiors)
        _InteriorRow(
          interior: i,
          selected: i == s.interior,
          onTap: () {
            HapticFeedback.selectionClick();
            s.interior = i;
          },
        ),
      const SizedBox(height: Gap.xl),
      _Summary(),
    ];

    return Column(
      children: [
        Expanded(
          child: Bounded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                margin,
                tier.isCompact ? MediaQuery.of(context).padding.top + Gap.lg : Gap.lg,
                margin,
                Gap.lg,
              ),
              children: [
                SectionHead(
                  eyebrow: 'Specify',
                  title: 'Build yours',
                  lede: 'Every combination below is orderable, and each one '
                      'shows the car actually wearing it.',
                  large: tier.atLeastMedium,
                ),
                const SizedBox(height: Gap.lg),
                if (!wide) ...[
                  const _Preview(),
                  const SizedBox(height: Gap.xl),
                  ...controls,
                ] else
                  // Wide: the car stays pinned beside the controls, so the
                  // effect of every choice is visible without scrolling.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(flex: 6, child: _Preview()),
                      const SizedBox(width: Gap.xl),
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: controls,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        _PriceBar(onGo: onGo),
      ],
    );
  }
}

/// AnimatedSwitcher's default layout stacks children loosely, which lets a
/// BoxFit.cover image size to its own intrinsic dimensions instead of filling
/// the frame. Expanding the stack restores the crop.
Widget _expandingSwitcher(Widget? current, List<Widget> previous) {
  return Stack(
    fit: StackFit.expand,
    alignment: Alignment.center,
    children: [...previous, if (current != null) current],
  );
}

/// Shows the exterior the buyer picked, then the cabin they picked beneath it.
/// Both are real photographs of that specification, not a tinted render.
class _Preview extends StatelessWidget {
  const _Preview();

  @override
  Widget build(BuildContext context) {
    final s = Selection.of(context);
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(border: Border.all(color: AppColors.hairlineSoft)),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Cross-fades between finishes rather than cutting.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 480),
                  switchInCurve: Curves.easeOutQuart,
                  layoutBuilder: _expandingSwitcher,
                  child: Image.asset(
                    s.paint.asset,
                    key: ValueKey(s.paint.asset),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    // Top-biased: one of the press shots stacks the car above
                    // a cabin frame, and the car is the subject here.
                    alignment: Alignment.topCenter,
                  ),
                ),
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.ink.withValues(alpha: 0.9)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: Gap.sm,
                  right: Gap.sm,
                  bottom: Gap.sm,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Caps(s.paint.name, color: AppColors.champagne),
                            const SizedBox(height: 2),
                            Text(s.variant.name, style: t.bodySmall),
                          ],
                        ),
                      ),
                      _Swatch(paint: s.paint, size: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Gap.xs),
        DecoratedBox(
          decoration: BoxDecoration(border: Border.all(color: AppColors.hairlineSoft)),
          child: AspectRatio(
            aspectRatio: 16 / 8,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 480),
                  switchInCurve: Curves.easeOutQuart,
                  layoutBuilder: _expandingSwitcher,
                  child: Image.asset(
                    s.interior.asset,
                    key: ValueKey(s.interior.asset),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.ink.withValues(alpha: 0.85)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: Gap.sm,
                  bottom: Gap.sm,
                  right: Gap.sm,
                  child: Row(
                    children: [
                      Expanded(
                        child: Caps('${s.interior.name} cabin', color: AppColors.champagne),
                      ),
                      Caps(s.variant.seatLabel, size: 9),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.title});

  final String number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Caps(number, color: AppColors.champagneDeep),
        const SizedBox(width: Gap.sm),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ],
    );
  }
}

class _VariantRow extends StatelessWidget {
  const _VariantRow({required this.variant, required this.selected, required this.onTap});

  final Variant variant;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xs),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutQuart,
          padding: const EdgeInsets.all(Gap.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.champagne.withValues(alpha: 0.06) : AppColors.surface,
            border: Border.all(
              color: selected ? AppColors.champagne : AppColors.hairline,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selection mark: a filled square, not a checkbox.
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(top: 5, right: Gap.sm),
                decoration: BoxDecoration(
                  color: selected ? AppColors.champagne : Colors.transparent,
                  border: Border.all(
                    color: selected ? AppColors.champagne : AppColors.boneFaint,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(variant.name, style: t.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      '${variant.powerHp} hp · ${variant.zeroToHundred}s · '
                      '${Num.group(variant.totalRangeKm)} km · ${variant.powertrain.short}',
                      style: t.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Gap.xs),
              Text(
                Num.rmb(variant.priceRmb),
                style: t.bodySmall!.copyWith(
                  color: selected ? AppColors.champagne : AppColors.boneFaint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.paint, this.size = 46});

  final PaintOption paint;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.hairline),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: paint.twoTone
              ? [paint.swatch, paint.swatch, paint.sheen, paint.sheen]
              : [paint.sheen, paint.swatch],
          stops: paint.twoTone ? const [0, 0.5, 0.5, 1] : null,
        ),
      ),
    );
  }
}

class _PaintTile extends StatelessWidget {
  const _PaintTile({required this.paint, required this.selected, required this.onTap});

  final PaintOption paint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 96,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              padding: EdgeInsets.all(selected ? 3 : 0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected ? AppColors.champagne : Colors.transparent,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: _Swatch(paint: paint),
              ),
            ),
            const SizedBox(height: Gap.xs),
            Text(
              paint.name,
              maxLines: 2,
              style: TextStyle(
                fontFamily: 'Sans',
                fontSize: 10.5,
                height: 1.35,
                fontWeight: FontWeight.w400,
                color: selected ? AppColors.bone : AppColors.boneMuted,
              ),
            ),
            if (paint.premiumRmb > 0)
              Text(
                '+${Num.rmb(paint.premiumRmb)}',
                style: const TextStyle(
                  fontFamily: 'Sans',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w300,
                  color: AppColors.champagneDeep,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InteriorRow extends StatelessWidget {
  const _InteriorRow({required this.interior, required this.selected, required this.onTap});

  final InteriorOption interior;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.xs),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          padding: const EdgeInsets.all(Gap.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.champagne.withValues(alpha: 0.06) : AppColors.surface,
            border: Border.all(color: selected ? AppColors.champagne : AppColors.hairline),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.hairline),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [interior.primary, interior.secondary],
                  ),
                ),
                child: Center(
                  child: Container(width: 18, height: 1, color: interior.accent),
                ),
              ),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(interior.name, style: t.titleMedium),
                    Text(interior.material, style: t.bodySmall),
                  ],
                ),
              ),
              if (interior.premiumRmb > 0)
                Text(
                  '+${Num.rmb(interior.premiumRmb)}',
                  style: t.bodySmall!.copyWith(color: AppColors.champagneDeep),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = Selection.of(context);

    return Panel(
      accent: true,
      padding: const EdgeInsets.all(Gap.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Caps('Your specification', color: AppColors.champagne),
          const SizedBox(height: Gap.sm),
          Ledger(
            children: [
              LedgerRow(label: 'Variant', value: s.variant.name),
              LedgerRow(label: 'Powertrain', value: s.variant.powertrain.label),
              LedgerRow(label: 'Layout', value: s.variant.layout),
              LedgerRow(label: 'Exterior', value: s.paint.name),
              LedgerRow(label: 'Cabin', value: s.interior.name),
              LedgerRow(
                label: 'China list price',
                value: Num.rmb(s.variant.priceRmb + s.optionsRmb),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sticky footer carrying the live landed price.
class _PriceBar extends StatelessWidget {
  const _PriceBar({required this.onGo});

  final void Function(int index) onGo;

  @override
  Widget build(BuildContext context) {
    final s = Selection.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.obsidian,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      padding: const EdgeInsets.fromLTRB(Gap.page, Gap.sm, Gap.page, Gap.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Caps('Indicative landed price'),
                const SizedBox(height: 3),
                Text(
                  Num.egp(s.landed),
                  style: AppTheme.figure.copyWith(fontSize: 22, color: AppColors.champagne),
                ),
              ],
            ),
          ),
          const SizedBox(width: Gap.sm),
          SizedBox(
            width: 132,
            child: GoldButton(
              label: 'Review',
              dense: true,
              onPressed: () => onGo(4),
            ),
          ),
        ],
      ),
    );
  }
}
