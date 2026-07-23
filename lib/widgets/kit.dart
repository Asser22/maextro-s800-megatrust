import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Small tracked-out capitals — the workhorse label of the whole app.
class Caps extends StatelessWidget {
  const Caps(this.text, {super.key, this.color, this.size});

  final String text;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTheme.caps.copyWith(color: color, fontSize: size),
    );
  }
}

/// A hairline. [gilt] draws it in brushed champagne, which marks the one
/// element on a screen that matters most.
class Rule extends StatelessWidget {
  const Rule({super.key, this.gilt = false, this.width, this.thickness = 1});

  final bool gilt;
  final double? width;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: thickness,
      decoration: BoxDecoration(
        color: gilt ? null : AppColors.hairline,
        gradient: gilt ? AppColors.gilt : null,
      ),
    );
  }
}

/// Eyebrow, serif headline, optional lede. Every section opens with one.
class SectionHead extends StatelessWidget {
  const SectionHead({
    super.key,
    required this.eyebrow,
    required this.title,
    this.lede,
    this.large = false,
  });

  final String eyebrow;
  final String title;
  final String? lede;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Rule(gilt: true, width: 26, thickness: 1.5),
            const SizedBox(width: Gap.sm),
            Flexible(child: Caps(eyebrow, color: AppColors.champagne)),
          ],
        ),
        const SizedBox(height: Gap.md),
        Text(title, style: large ? t.displayMedium : t.displaySmall),
        if (lede != null) ...[
          const SizedBox(height: Gap.sm),
          Text(lede!, style: t.bodyLarge),
        ],
      ],
    );
  }
}

/// A flat panel bounded by a hairline. No blur, no shadow, no rounding — the
/// deliberate opposite of a glassmorphic card.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Gap.md),
    this.onTap,
    this.accent = false,
    this.filled = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Champagne border. At most one panel per screen should use it.
  final bool accent;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      decoration: BoxDecoration(
        color: filled ? AppColors.surface : Colors.transparent,
        border: Border.all(
          color: accent ? AppColors.champagneDeep : AppColors.hairline,
        ),
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return panel;
    return GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: panel);
  }
}

/// Formats numbers the way the rest of the app expects them.
abstract final class Num {
  static String group(num value) {
    final digits = value.round().abs().toString();
    final out = StringBuffer(value < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return out.toString();
  }

  static String egp(num value) => 'EGP ${group(value)}';

  static String rmb(num value) => '¥${group(value)}';

  /// Compact form for headline prices, e.g. "EGP 8.42 M".
  static String egpShort(num value) {
    if (value >= 1000000) return 'EGP ${(value / 1000000).toStringAsFixed(2)} M';
    if (value >= 1000) return 'EGP ${(value / 1000).toStringAsFixed(0)} K';
    return egp(value);
  }

  static String decimal(double v, int places) => v.toStringAsFixed(places);
}

/// A number that counts up the first time it is built.
class Tally extends StatelessWidget {
  const Tally({
    super.key,
    required this.value,
    this.decimals = 0,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.grouped = true,
    this.animate = true,
  });

  final double value;
  final int decimals;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final bool grouped;
  final bool animate;

  static String format(double v, int decimals, bool grouped) {
    if (decimals > 0) {
      final fixed = v.toStringAsFixed(decimals);
      if (!grouped) return fixed;
      final parts = fixed.split('.');
      return '${Num.group(double.parse(parts[0]))}.${parts[1]}';
    }
    return grouped ? Num.group(v) : v.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final resolved = style ?? AppTheme.figure;
    if (!animate) {
      return Text('$prefix${format(value, decimals, grouped)}$suffix', style: resolved);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutQuart,
      builder: (context, v, _) => Text(
        '$prefix${format(v, decimals, grouped)}$suffix',
        style: resolved,
      ),
    );
  }
}

/// A specification figure: value, unit, caption. The app's data primitive.
class Figure extends StatelessWidget {
  const Figure({
    super.key,
    required this.value,
    required this.unit,
    required this.caption,
    this.decimals = 0,
    this.animate = true,
    this.grouped = true,
    this.accent = false,
    this.compact = false,
  });

  final double value;
  final String unit;
  final String caption;
  final int decimals;
  final bool animate;
  final bool grouped;
  final bool accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final style = AppTheme.figure.copyWith(
      fontSize: compact ? 24 : 34,
      color: accent ? AppColors.champagne : AppColors.bone,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Tally(
                value: value,
                decimals: decimals,
                style: style,
                grouped: grouped,
                animate: animate,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontFamily: 'Sans',
                  fontSize: compact ? 10 : 11.5,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.4,
                  color: AppColors.boneMuted,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: Gap.xs),
        Caps(caption, size: compact ? 9 : 10),
      ],
    );
  }
}

/// Primary action: champagne fill, ink text, square corners.
class GoldButton extends StatelessWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.dense = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: dense ? 13 : 17, horizontal: Gap.md),
        decoration: BoxDecoration(
          gradient: enabled ? AppColors.gilt : null,
          color: enabled ? null : AppColors.hairline,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: enabled ? AppColors.ink : AppColors.boneFaint),
              const SizedBox(width: Gap.xs),
            ],
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Sans',
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.4,
                color: enabled ? AppColors.ink : AppColors.boneFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Secondary action: hairline outline, bone text.
class LineButton extends StatelessWidget {
  const LineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.dense = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool dense;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(vertical: dense ? 13 : 17, horizontal: Gap.md),
        decoration: BoxDecoration(border: Border.all(color: AppColors.hairline)),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: AppColors.boneMuted),
              const SizedBox(width: Gap.xs),
            ],
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Sans',
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.4,
                color: AppColors.bone,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A selectable option. Square, hairline, champagne when chosen.
class OptionChip extends StatelessWidget {
  const OptionChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
    this.trailing,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.champagne.withValues(alpha: 0.10) : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.champagne : AppColors.hairline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Sans',
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.8,
                color: selected ? AppColors.champagneLight : AppColors.boneMuted,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: Gap.xs),
              Text(
                trailing!,
                style: TextStyle(
                  fontFamily: 'Sans',
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                  color: selected
                      ? AppColors.champagne.withValues(alpha: 0.8)
                      : AppColors.boneFaint,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Thin proportional bar. Used for comparisons, never for progress.
class Meter extends StatelessWidget {
  const Meter({
    super.key,
    required this.fraction,
    this.color = AppColors.champagne,
    this.height = 2,
    this.delay = Duration.zero,
  });

  final double fraction;
  final Color color;
  final double height;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(height: height, color: AppColors.hairline),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: fraction.clamp(0.0, 1.0)),
          duration: const Duration(milliseconds: 1100) + delay,
          curve: Curves.easeOutQuart,
          builder: (context, v, _) => FractionallySizedBox(
            widthFactor: v,
            child: Container(height: height, color: color),
          ),
        ),
      ],
    );
  }
}

/// Fades and lifts its child in once. Slow and long-eased — luxury motion is
/// never springy.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.child, this.delay = Duration.zero, this.rise = 18});

  final Widget child;
  final Duration delay;
  final double rise;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  static const _travel = Duration(milliseconds: 900);

  late final AnimationController _c;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    // The stagger lives in the curve as a leading Interval, so there is never
    // a pending timer that can outlive this State.
    final total = widget.delay + _travel;
    _c = AnimationController(vsync: this, duration: total);
    _curve = CurvedAnimation(
      parent: _c,
      curve: Interval(
        widget.delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: Curves.easeOutQuart,
      ),
    );
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, widget.rise * (1 - _curve.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// The brand lockup: Latin name over the native characters, hairline between.
class Marque extends StatelessWidget {
  const Marque({super.key, required this.latin, required this.native, this.scale = 1});

  final String latin;
  final String native;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          latin.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Sans',
            fontSize: 12 * scale,
            fontWeight: FontWeight.w400,
            letterSpacing: 8 * scale,
            color: AppColors.champagne,
          ),
        ),
        SizedBox(height: 5 * scale),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Rule(width: 18 * scale),
            SizedBox(width: 7 * scale),
            Text(
              native,
              style: TextStyle(
                fontFamily: 'Sans',
                fontSize: 11 * scale,
                fontWeight: FontWeight.w300,
                letterSpacing: 3 * scale,
                color: AppColors.boneFaint,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A label/value row separated from its neighbours by a hairline. The spec
/// sheet, the price breakdown and the paperwork list are all built from this.
class LedgerRow extends StatelessWidget {
  const LedgerRow({
    super.key,
    required this.label,
    required this.value,
    this.note,
    this.accent = false,
    this.emphasis = false,
    this.onTap,
  });

  final String label;
  final String value;
  final String? note;
  final bool accent;

  /// Larger type, for a total line.
  final bool emphasis;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return GestureDetector(
      behavior: onTap == null ? HitTestBehavior.deferToChild : HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Gap.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Text(
                label,
                style: emphasis
                    ? t.titleLarge
                    : t.bodyMedium!.copyWith(color: AppColors.boneMuted),
              ),
            ),
            const SizedBox(width: Gap.sm),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    textAlign: TextAlign.right,
                    style: emphasis
                        ? AppTheme.figure.copyWith(
                            fontSize: 20,
                            color: accent ? AppColors.champagne : AppColors.bone,
                          )
                        : t.titleMedium!.copyWith(
                            color: accent ? AppColors.champagne : AppColors.bone,
                          ),
                  ),
                  if (note != null) ...[
                    const SizedBox(height: 2),
                    Text(note!, textAlign: TextAlign.right, style: t.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vertical rhythm helper: children separated by hairlines.
class Ledger extends StatelessWidget {
  const Ledger({super.key, required this.children, this.topRule = true});

  final List<Widget> children;
  final bool topRule;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (topRule) const Rule(),
        for (final child in children) ...[child, const Rule()],
      ],
    );
  }
}

/// Soft directional wash. Provides depth without a gradient mesh cliché.
class Atmosphere extends StatelessWidget {
  const Atmosphere({
    super.key,
    this.color = AppColors.champagne,
    this.alignment = const Alignment(-0.6, -0.8),
    this.radius = 1.1,
    this.opacity = 0.055,
  });

  final Color color;
  final Alignment alignment;
  final double radius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: alignment,
            radius: radius,
            colors: [color.withValues(alpha: opacity), Colors.transparent],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Fine diagonal grain, drawn once and tiled by the painter. Keeps large flat
/// areas of near-black from banding on OLED panels.
class Grain extends StatelessWidget {
  const Grain({super.key, this.opacity = 0.02});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _GrainPainter(opacity), size: Size.infinite),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter(this.opacity);

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.bone.withValues(alpha: opacity)
      ..strokeWidth = 0.6;
    // A fixed seed keeps the texture stable between frames.
    final rng = math.Random(7);
    final count = (size.width * size.height / 900).clamp(0, 2600).toInt();
    for (var i = 0; i < count; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      canvas.drawLine(Offset(dx, dy), Offset(dx + 0.7, dy + 0.7), paint);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter old) => old.opacity != opacity;
}
