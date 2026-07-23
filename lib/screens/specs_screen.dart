import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/car_data.dart';
import '../models/car.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../utils/actions.dart';
import '../widgets/kit.dart';

/// The full specification, the equipment list, and how it measures up against
/// the cars a buyer at this level is actually choosing between.
class SpecsScreen extends StatefulWidget {
  const SpecsScreen({super.key});

  @override
  State<SpecsScreen> createState() => _SpecsScreenState();
}

class _SpecsScreenState extends State<SpecsScreen> {
  final _search = TextEditingController();
  String _query = '';
  String _featureCategory = 'All';
  late final Set<String> _open = {car.specGroups.first.title};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<SpecGroup> get _groups {
    if (_query.isEmpty) return car.specGroups;
    final q = _query.toLowerCase();
    return car.specGroups
        .map((g) => SpecGroup(
              title: g.title,
              items: g.items
                  .where((i) =>
                      i.label.toLowerCase().contains(q) ||
                      i.value.toLowerCase().contains(q))
                  .toList(),
            ))
        .where((g) => g.items.isNotEmpty)
        .toList();
  }

  int get _count =>
      car.specGroups.fold<int>(0, (sum, g) => sum + g.items.length);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final groups = _groups;

    return ScreenBody(
      maxWidth: Breakpoints.readable + 220,
      children: [
        SectionHead(
          eyebrow: '$_count figures',
          title: 'Specification',
          lede: '${car.modelYear} model year. Performance and range are '
              'manufacturer-claimed on the CLTC cycle, and every figure is '
              'confirmed against the order sheet before a quotation is issued.',
        ),
        const SizedBox(height: Gap.lg),
        TextField(
          controller: _search,
          onChanged: (v) => setState(() => _query = v),
          style: t.bodyMedium!.copyWith(color: AppColors.bone),
          cursorColor: AppColors.champagne,
          decoration: InputDecoration(
            hintText: 'Search the specification',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(right: Gap.xs),
              child: Icon(Icons.search_rounded, size: 16, color: AppColors.boneFaint),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: _query.isEmpty
                ? null
                : GestureDetector(
                    onTap: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                    child: const Icon(Icons.close_rounded, size: 15, color: AppColors.boneFaint),
                  ),
          ),
        ),
        const SizedBox(height: Gap.lg),

        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Gap.xl),
            child: Center(child: Text('Nothing matches "$_query".', style: t.bodyMedium)),
          )
        else
          for (final g in groups)
            _Group(
              group: g,
              expanded: _query.isNotEmpty || _open.contains(g.title),
              onToggle: () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (!_open.remove(g.title)) _open.add(g.title);
                });
              },
            ),

        const SizedBox(height: Gap.md),
        LineButton(
          label: 'Copy full specification',
          icon: Icons.content_copy_rounded,
          onPressed: () => Reach.copySpecification(context),
        ),

        const SizedBox(height: Gap.xxl),
        _Range(),

        const SizedBox(height: Gap.xxl),
        _Equipment(
          selected: _featureCategory,
          onSelect: (c) {
            HapticFeedback.selectionClick();
            setState(() => _featureCategory = c);
          },
        ),

        const SizedBox(height: Gap.xxl),
        _Comparison(),
      ],
    );
  }
}

// ── Spec group ───────────────────────────────────────────────────────────────

class _Group extends StatelessWidget {
  const _Group({required this.group, required this.expanded, required this.onToggle});

  final SpecGroup group;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Rule(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Gap.md),
            child: Row(
              children: [
                Expanded(
                  child: Text(group.title, style: Theme.of(context).textTheme.headlineMedium),
                ),
                Caps('${group.items.length}', size: 9),
                const SizedBox(width: Gap.sm),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutQuart,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.champagne,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 320),
          sizeCurve: Curves.easeOutQuart,
          firstCurve: Curves.easeOut,
          crossFadeState: expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(bottom: Gap.sm),
            child: Column(
              children: [
                for (final item in group.items)
                  LedgerRow(
                    label: item.label,
                    value: item.value,
                    note: item.note,
                    accent: item.accent,
                  ),
              ],
            ),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

// ── The orderable range ──────────────────────────────────────────────────────

class _Range extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(
          eyebrow: '${car.variants.length} versions',
          title: 'The range',
          lede: 'Chinese list prices shown. Landed Alexandria figures are on '
              'the Build and Order screens.',
        ),
        const SizedBox(height: Gap.lg),
        for (final v in car.variants)
          Padding(
            padding: const EdgeInsets.only(bottom: Gap.xs),
            child: Panel(
              accent: v.flagship,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(v.name, style: t.titleLarge)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Num.rmb(v.priceRmb),
                            style: t.titleMedium!.copyWith(color: AppColors.champagne),
                          ),
                          if (v.priceProvisional)
                            Caps('provisional', color: AppColors.amber, size: 8.5),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: Gap.xs),
                  Wrap(
                    spacing: Gap.sm,
                    runSpacing: 2,
                    children: [
                      Caps(v.powertrain.short, size: 9),
                      Caps('${v.powerHp} hp', size: 9),
                      Caps('${v.zeroToHundred}s', size: 9),
                      Caps('${Num.group(v.totalRangeKm)} km', size: 9),
                      Caps(v.seatLabel, size: 9),
                    ],
                  ),
                  const SizedBox(height: Gap.xs),
                  Text(v.note, style: t.bodySmall),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Equipment ────────────────────────────────────────────────────────────────

class _Equipment extends StatelessWidget {
  const _Equipment({required this.selected, required this.onSelect});

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final categories = ['All', ...car.featureCategories];
    final visible = selected == 'All'
        ? car.features
        : car.features.where((f) => f.category == selected).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(
          eyebrow: '${car.features.length} highlights',
          title: 'Equipment',
        ),
        const SizedBox(height: Gap.md),
        Wrap(
          spacing: Gap.xs,
          runSpacing: Gap.xs,
          children: [
            for (final c in categories)
              OptionChip(label: c, selected: c == selected, onTap: () => onSelect(c)),
          ],
        ),
        const SizedBox(height: Gap.lg),
        for (final f in visible) ...[
          const Rule(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Gap.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(f.title, style: t.titleLarge)),
                    if (f.figure != null)
                      Text(
                        f.figure!,
                        style: AppTheme.figure.copyWith(
                          fontSize: 20,
                          color: AppColors.champagne,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Gap.xxs),
                Text(f.description, style: t.bodySmall),
              ],
            ),
          ),
        ],
        const Rule(),
      ],
    );
  }
}

// ── Comparison ───────────────────────────────────────────────────────────────

class _Comparison extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final flagship = car.flagshipVariant;
    final metrics = <(String, String, List<(String, double, bool)>, int)>[
      (
        'System output',
        ' hp',
        [
          (car.model, car.maxPowerHp.toDouble(), true),
          for (final r in car.rivals) (r.name, r.powerHp.toDouble(), false),
        ],
        0
      ),
      (
        'Wheelbase',
        ' mm',
        [
          (car.model, car.wheelbaseMm.toDouble(), true),
          for (final r in car.rivals) (r.name, r.wheelbaseMm.toDouble(), false),
        ],
        0
      ),
      (
        '0 – 100 km/h',
        ' s',
        [
          (car.model, flagship.zeroToHundred, true),
          for (final r in car.rivals) (r.name, r.zeroToHundred, false),
        ],
        1
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHead(
          eyebrow: 'Cross-shopped against',
          title: 'Where it stands',
          lede: 'Rival figures are manufacturer-claimed for comparable '
              'long-wheelbase flagships.',
        ),
        const SizedBox(height: Gap.lg),
        for (final (title, unit, rows, dp) in metrics) ...[
          Caps(title, color: AppColors.champagne),
          const SizedBox(height: Gap.sm),
          for (final (i, row) in rows.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: Gap.sm),
              child: Row(
                children: [
                  SizedBox(
                    width: 118,
                    child: Text(
                      row.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Sans',
                        fontSize: 12,
                        fontWeight: row.$3 ? FontWeight.w500 : FontWeight.w300,
                        color: row.$3 ? AppColors.bone : AppColors.boneMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Meter(
                      fraction: row.$2 / rows.map((r) => r.$2).reduce((a, b) => a > b ? a : b),
                      color: row.$3 ? AppColors.champagne : AppColors.hairline,
                      height: row.$3 ? 3 : 2,
                      delay: Duration(milliseconds: 90 * i),
                    ),
                  ),
                  SizedBox(
                    width: 68,
                    child: Text(
                      '${row.$2.toStringAsFixed(dp)}$unit',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: row.$3 ? AppColors.champagne : AppColors.boneMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: Gap.md),
        ],
      ],
    );
  }
}
