import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';

import 'package:s800_showroom/data/car_data.dart';
import 'package:s800_showroom/main.dart';
import 'package:s800_showroom/models/car.dart';
import 'package:s800_showroom/state/selection.dart';

void main() {
  // Phone, tablet and desktop. The app claims to be cross-platform, so every
  // tab has to survive every tier — this is what catches overflow regressions
  // in the responsive layouts.
  const viewports = <String, Size>{
    'phone': Size(390, 844),
    'tablet': Size(834, 1112),
    'desktop': Size(1440, 900),
  };

  for (final entry in viewports.entries) {
    testWidgets('every tab lays out cleanly on ${entry.key}', (tester) async {
      tester.view
        ..physicalSize = entry.value
        ..devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const S800App());
      await tester.pump(const Duration(seconds: 2));

      expect(find.text(car.model), findsWidgets);

      for (final tab in ['GALLERY', 'SPEC', 'BUILD', 'ORDER', 'HOME']) {
        await tester.tap(find.text(tab).first);
        await tester.pump(const Duration(milliseconds: 900));
        expect(
          tester.takeException(),
          isNull,
          reason: '$tab overflowed or threw on ${entry.key}',
        );
      }
    });
  }

  test('the listing is internally consistent', () {
    expect(car.variants, isNotEmpty);
    expect(car.paints, isNotEmpty);
    expect(car.interiors, isNotEmpty);
    expect(car.photos, isNotEmpty);

    // entryVariant must genuinely be the cheapest, since it drives every
    // "from" price shown in the app.
    for (final v in car.variants) {
      expect(car.entryVariant.priceRmb, lessThanOrEqualTo(v.priceRmb));
    }

    expect(car.variants.where((v) => v.flagship).length, lessThanOrEqualTo(1));
    expect(car.bestZeroToHundred, greaterThan(0));
    expect(car.maxTotalRangeKm, greaterThanOrEqualTo(car.variants.first.electricRangeKm));

    // An EREV must carry further than it does on the battery alone; a BEV
    // must not claim to.
    for (final v in car.variants) {
      if (v.isErev) {
        expect(v.totalRangeKm, greaterThan(v.electricRangeKm));
      } else {
        expect(v.totalRangeKm, equals(v.electricRangeKm));
      }
    }
  });

  test('the landed quote sums to its own line items', () {
    const costing = ImportCosting(
      egpPerRmb: 7,
      freightUsd: 4000,
      usdToEgp: 50,
      customsDutyRate: 0.4,
      vatRate: 0.14,
      clearanceEgp: 250000,
      dealerMarginRate: 0.1,
    );
    final quote = costing.quote(700000);

    final sum = quote.lines.fold<double>(0, (a, l) => a + l.$2);
    expect(sum, closeTo(quote.total, 0.01));

    // Duty is charged on CIF, so it must exceed duty on the vehicle alone.
    expect(quote.duty, greaterThan(quote.vehicle * costing.customsDutyRate));
    expect(quote.total, greaterThan(quote.vehicle));
  });

  test('selection prices options on top of the list price', () {
    final s = Selection();
    final base = s.landed;

    final premiumPaint =
        car.paints.firstWhere((p) => p.premiumRmb > 0, orElse: () => car.paints.first);
    if (premiumPaint.premiumRmb > 0) {
      s.paint = premiumPaint;
      expect(s.landed, greaterThan(base));
    }

    s.variant = car.flagshipVariant;
    expect(s.landed, greaterThan(s.landedFloor));
    s.dispose();
  });
}
