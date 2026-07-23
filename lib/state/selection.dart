import 'package:flutter/widgets.dart';

import '../data/car_data.dart';
import '../models/car.dart';
import '../services/rates.dart';

/// Where the exchange rates currently in use came from.
enum RateSource {
  /// The built-in figures from car_data.dart; live rates not (yet) loaded.
  estimated,

  /// Live mid-market rates fetched this session.
  live,

  /// A live rate was fetched, then the user edited a rate by hand.
  adjusted,
}

/// The buyer's current build, plus the costing assumptions used to price it.
///
/// Configure and Order are two views of this one object, so a change on either
/// screen is already reflected on the other.
class Selection extends ChangeNotifier {
  Selection()
      : _variant = car.entryVariant,
        _paint = car.paints.first,
        _interior = car.interiors.first,
        _costing = car.costing;

  Variant _variant;
  PaintOption _paint;
  InteriorOption _interior;
  ImportCosting _costing;

  RateSource _rateSource = RateSource.estimated;
  String _rateDate = '';

  RateSource get rateSource => _rateSource;
  String get rateDate => _rateDate;

  Variant get variant => _variant;
  PaintOption get paint => _paint;
  InteriorOption get interior => _interior;
  ImportCosting get costing => _costing;

  set variant(Variant value) {
    if (_variant == value) return;
    _variant = value;
    notifyListeners();
  }

  set paint(PaintOption value) {
    if (_paint == value) return;
    _paint = value;
    notifyListeners();
  }

  set interior(InteriorOption value) {
    if (_interior == value) return;
    _interior = value;
    notifyListeners();
  }

  set costing(ImportCosting value) {
    _costing = value;
    // A hand edit means the figure is no longer purely the fetched live rate.
    if (_rateSource == RateSource.live) _rateSource = RateSource.adjusted;
    notifyListeners();
  }

  void resetCosting() {
    _costing = car.costing;
    _rateSource = RateSource.estimated;
    _rateDate = '';
    notifyListeners();
  }

  /// Fetches live mid-market rates and folds them into the current costing,
  /// leaving duty, tax, clearance and margin untouched. Silently keeps the
  /// built-in defaults if the network is unavailable.
  Future<void> loadLiveRates() async {
    final rates = await RatesService.fetch();
    if (rates == null) return;
    // Don't stomp on a rate the user has already started editing.
    if (_rateSource == RateSource.adjusted) return;

    _costing = _costing.copyWith(
      egpPerRmb: rates.egpPerRmb,
      usdToEgp: rates.usdToEgp,
    );
    _rateSource = RateSource.live;
    _rateDate = rates.date;
    notifyListeners();
  }

  /// Options chosen on top of the list price, in RMB.
  int get optionsRmb => _paint.premiumRmb + _interior.premiumRmb;

  Quote get quote => _costing.quote(_variant.priceRmb, optionsRmb: optionsRmb);

  double get landed => quote.total;

  /// The cheapest possible landed price across the range, for "from" figures.
  double get landedFloor => _costing.quote(car.entryVariant.priceRmb).total;

  static Selection of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SelectionScope>();
    assert(scope != null, 'No SelectionScope found above this widget.');
    return scope!.notifier!;
  }
}

/// Rebuilds dependents whenever the build or the costing changes.
class SelectionScope extends InheritedNotifier<Selection> {
  const SelectionScope({super.key, required Selection super.notifier, required super.child});
}
