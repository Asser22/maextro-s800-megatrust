import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/car_data.dart';
import '../state/selection.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../utils/actions.dart';
import '../widgets/kit.dart';

/// The commercial screen: what it lands at, how the figure is built, how long
/// it takes, and how to reserve a build slot.
class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _showAssumptions = false;

  @override
  Widget build(BuildContext context) {
    final s = Selection.of(context);
    final t = Theme.of(context).textTheme;
    final quote = s.quote;

    return ScreenBody(
      maxWidth: Breakpoints.readable + 220,
      children: [
        const SectionHead(
          eyebrow: 'Landed price',
          title: 'What it costs,\nline by line',
          lede: 'One figure, with every component of it shown. No fees appear '
              'later in the process.',
        ),
        const SizedBox(height: Gap.lg),

        // ── Headline ───────────────────────────────────────────────────────
        Panel(
          accent: true,
          padding: const EdgeInsets.all(Gap.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Caps(s.variant.name, color: AppColors.champagne),
              const SizedBox(height: Gap.sm),
              Text(
                Num.egp(quote.total),
                style: AppTheme.figure.copyWith(fontSize: 40, color: AppColors.bone),
              ),
              const SizedBox(height: Gap.xxs),
              Text(
                'Delivered, registered and on the road in ${car.city}.',
                style: t.bodySmall,
              ),
              const SizedBox(height: Gap.md),
              const Rule(gilt: true, width: 40, thickness: 1.5),
              const SizedBox(height: Gap.md),
              Ledger(
                topRule: false,
                children: [
                  for (final (label, amount) in quote.lines)
                    LedgerRow(label: label, value: Num.egp(amount)),
                  LedgerRow(
                    label: 'Total, on the road',
                    value: Num.egp(quote.total),
                    accent: true,
                    emphasis: true,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: Gap.sm),
        _RateBadge(source: s.rateSource, date: s.rateDate),
        const SizedBox(height: Gap.sm),
        Panel(
          filled: false,
          padding: const EdgeInsets.all(Gap.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.amber),
              const SizedBox(width: Gap.xs),
              Expanded(
                child: Text(
                  s.variant.priceProvisional
                      ? 'Indicative only, and the 2026 list price for this trim '
                          'has not been published — the 2025 figure is used here. '
                          'Egyptian duty, tax and clearance depend on classification '
                          'and the rules on the day. Your written quotation is the '
                          'binding figure.'
                      : 'Indicative only. Egyptian duty, tax and clearance depend on '
                          'classification and the rules in force on the day of clearance. '
                          'Your written quotation is the binding figure.',
                  style: t.bodySmall,
                ),
              ),
            ],
          ),
        ),

        // ── Assumptions ────────────────────────────────────────────────────
        const SizedBox(height: Gap.md),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _showAssumptions = !_showAssumptions);
          },
          child: Row(
            children: [
              Expanded(
                child: Caps(
                  _showAssumptions ? 'Hide assumptions' : 'Adjust the assumptions',
                  color: AppColors.champagne,
                ),
              ),
              AnimatedRotation(
                turns: _showAssumptions ? 0.5 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 17,
                  color: AppColors.champagne,
                ),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 320),
          sizeCurve: Curves.easeOutQuart,
          crossFadeState:
              _showAssumptions ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: _Assumptions(),
          secondChild: const SizedBox(width: double.infinity),
        ),

        // ── Timeline ───────────────────────────────────────────────────────
        const SizedBox(height: Gap.xxl),
        const SectionHead(
          eyebrow: 'Order to keys',
          title: 'How long it takes',
          lede: 'Roughly thirteen to twenty-one weeks from signature to '
              'handover, tracked at every stage.',
        ),
        const SizedBox(height: Gap.lg),
        for (final (i, stage) in car.stages.indexed)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.champagneDeep),
                      ),
                      child: Icon(stage.icon, size: 14, color: AppColors.champagne),
                    ),
                    if (i != car.stages.length - 1)
                      const Expanded(
                        child: VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: AppColors.hairline,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: Gap.sm),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i == car.stages.length - 1 ? 0 : Gap.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Text(stage.title, style: t.titleLarge)),
                            Caps(stage.duration, color: AppColors.champagneDeep, size: 9),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(stage.detail, style: t.bodySmall),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

        // ── Assurances ─────────────────────────────────────────────────────
        const SizedBox(height: Gap.xxl),
        const SectionHead(eyebrow: 'Our undertaking', title: 'What we guarantee'),
        const SizedBox(height: Gap.md),
        Ledger(
          children: [
            for (final a in car.assurances)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Gap.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(a.icon, size: 15, color: AppColors.champagne),
                    const SizedBox(width: Gap.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title, style: t.titleMedium),
                          const SizedBox(height: 2),
                          Text(a.detail, style: t.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),

        // ── Reservation ────────────────────────────────────────────────────
        const SizedBox(height: Gap.xxl),
        const _Reserve(),
      ],
    );
  }
}

// ── Editable costing assumptions ─────────────────────────────────────────────

class _Assumptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = Selection.of(context);
    final c = s.costing;

    return Padding(
      padding: const EdgeInsets.only(top: Gap.md),
      child: Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set these to the numbers your clearing agent gives you. The '
              'quotation above recalculates immediately.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: Gap.md),
            _Dial(
              label: 'EGP per RMB',
              value: c.egpPerRmb,
              min: 3,
              max: 15,
              decimals: 2,
              onChanged: (v) => s.costing = c.copyWith(egpPerRmb: v),
            ),
            _Dial(
              label: 'USD to EGP',
              value: c.usdToEgp,
              min: 20,
              max: 120,
              decimals: 2,
              onChanged: (v) => s.costing = c.copyWith(usdToEgp: v),
            ),
            _Dial(
              label: 'Freight & insurance',
              value: c.freightUsd,
              min: 1000,
              max: 12000,
              decimals: 0,
              prefix: r'$',
              onChanged: (v) => s.costing = c.copyWith(freightUsd: v),
            ),
            _Dial(
              label: 'Customs duty',
              value: c.customsDutyRate * 100,
              min: 0,
              max: 150,
              decimals: 0,
              suffix: '%',
              onChanged: (v) => s.costing = c.copyWith(customsDutyRate: v / 100),
            ),
            _Dial(
              label: 'VAT & schedule tax',
              value: c.vatRate * 100,
              min: 0,
              max: 40,
              decimals: 0,
              suffix: '%',
              onChanged: (v) => s.costing = c.copyWith(vatRate: v / 100),
            ),
            _Dial(
              label: 'Clearance & registration',
              value: c.clearanceEgp,
              min: 0,
              max: 1500000,
              decimals: 0,
              prefix: 'EGP ',
              onChanged: (v) => s.costing = c.copyWith(clearanceEgp: v),
            ),
            _Dial(
              label: 'Importer margin',
              value: c.dealerMarginRate * 100,
              min: 0,
              max: 40,
              decimals: 0,
              suffix: '%',
              onChanged: (v) => s.costing = c.copyWith(dealerMarginRate: v / 100),
            ),
            const SizedBox(height: Gap.xs),
            LineButton(
              label: 'Reset to defaults',
              dense: true,
              onPressed: s.resetCosting,
            ),
          ],
        ),
      ),
    );
  }
}

class _Dial extends StatelessWidget {
  const _Dial({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.decimals = 0,
    this.prefix = '',
    this.suffix = '',
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int decimals;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final shown = decimals > 0
        ? value.toStringAsFixed(decimals)
        : Num.group(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Caps(label)),
            Text(
              '$prefix$shown$suffix',
              style: const TextStyle(
                fontFamily: 'Sans',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.champagne,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackShape: const RectangularSliderTrackShape(),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ── Reservation form ─────────────────────────────────────────────────────────

class _Reserve extends StatefulWidget {
  const _Reserve();

  @override
  State<_Reserve> createState() => _ReserveState();
}

class _ReserveState extends State<_Reserve> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }
    HapticFeedback.mediumImpact();
    final s = Selection.of(context);
    Reach.email(
      context,
      subject: '${car.fullName} — build slot reservation',
      body: Reach.enquiryBody(
        name: _name.text.trim(),
        contact: _contact.text.trim(),
        variant: s.variant,
        paint: s.paint,
        interior: s.interior,
        landed: s.landed,
        note: _note.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHead(
          eyebrow: 'Reserve',
          title: 'Open a build slot',
          lede: 'A refundable ${Num.egp(car.reservationEgp)} reservation holds a '
              'production slot while the final specification is agreed.',
        ),
        const SizedBox(height: Gap.lg),
        Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                style: t.bodyMedium!.copyWith(color: AppColors.bone),
                cursorColor: AppColors.champagne,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) =>
                    (v == null || v.trim().length < 2) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: Gap.md),
              TextFormField(
                controller: _contact,
                keyboardType: TextInputType.emailAddress,
                style: t.bodyMedium!.copyWith(color: AppColors.bone),
                cursorColor: AppColors.champagne,
                decoration: const InputDecoration(labelText: 'Phone or email'),
                validator: (v) =>
                    (v == null || v.trim().length < 5) ? 'How should we reach you?' : null,
              ),
              const SizedBox(height: Gap.md),
              TextFormField(
                controller: _note,
                maxLines: 3,
                style: t.bodyMedium!.copyWith(color: AppColors.bone),
                cursorColor: AppColors.champagne,
                decoration: const InputDecoration(
                  labelText: 'Anything to add (optional)',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gap.lg),
        GoldButton(
          label: 'Send reservation request',
          icon: Icons.mail_outline_rounded,
          onPressed: _submit,
        ),
        const SizedBox(height: Gap.xs),
        LineButton(
          label: 'WhatsApp instead',
          icon: Icons.chat_outlined,
          onPressed: () => Reach.whatsapp(context),
        ),
        const SizedBox(height: Gap.md),
        Text(car.showroomNote, style: t.bodySmall, textAlign: TextAlign.center),
      ],
    );
  }
}

/// A slim strip showing where the exchange rate came from — live, estimated, or
/// live-then-adjusted — so the figure above is never mistaken for a firm quote.
class _RateBadge extends StatelessWidget {
  const _RateBadge({required this.source, required this.date});

  final RateSource source;
  final String date;

  @override
  Widget build(BuildContext context) {
    final (color, icon, label, detail) = switch (source) {
      RateSource.live => (
          AppColors.jade,
          Icons.trending_up_rounded,
          'Live exchange rate',
          date.isEmpty ? 'Mid-market, today' : 'Mid-market · $date',
        ),
      RateSource.adjusted => (
          AppColors.champagne,
          Icons.tune_rounded,
          'Rate adjusted by you',
          'Live rate, edited below',
        ),
      RateSource.estimated => (
          AppColors.amber,
          Icons.schedule_rounded,
          'Estimated rate',
          'Fetching the live rate…',
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 9),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.4)),
        color: color.withValues(alpha: 0.06),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: Gap.xs),
          Expanded(child: Caps(label, color: color, size: 10)),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
