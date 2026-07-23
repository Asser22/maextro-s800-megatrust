import 'package:flutter/material.dart';

/// How a variant is propelled.
enum Powertrain {
  bev('Battery Electric', 'BEV'),
  erev('Range Extender', 'EREV');

  const Powertrain(this.label, this.short);

  final String label;
  final String short;
}

/// One orderable version of the car. Prices are the Chinese domestic list
/// price in RMB; the landed Alexandria figure is derived by [ImportCosting].
class Variant {
  const Variant({
    required this.name,
    required this.powertrain,
    required this.seats,
    required this.motors,
    required this.powerKw,
    required this.powerHp,
    required this.zeroToHundred,
    required this.topSpeedKmh,
    required this.batteryKwh,
    required this.electricRangeKm,
    required this.totalRangeKm,
    required this.priceRmb,
    required this.note,
    this.flagship = false,
    this.priceProvisional = false,
  });

  final String name;
  final Powertrain powertrain;
  final int seats;
  final int motors;
  final int powerKw;
  final int powerHp;
  final double zeroToHundred;
  final int topSpeedKmh;
  final double batteryKwh;
  final int electricRangeKm;

  /// Equal to [electricRangeKm] on a BEV; includes the range extender on EREV.
  final int totalRangeKm;
  final int priceRmb;
  final String note;
  final bool flagship;

  /// True when the list price for this model year has not been published and
  /// the previous year's figure is standing in. Surfaced in the UI so nobody
  /// quotes it as final.
  final bool priceProvisional;

  bool get isErev => powertrain == Powertrain.erev;
  String get layout => '$motors-motor ${motors > 1 ? 'AWD' : 'RWD'}';
  String get seatLabel => '$seats-seat';
}

/// A label/value row inside a [SpecGroup].
class SpecItem {
  const SpecItem(this.label, this.value, {this.note, this.accent = false});

  final String label;
  final String value;
  final String? note;

  /// Renders in champagne — reserve it for the two or three figures per group
  /// that actually sell the car.
  final bool accent;
}

class SpecGroup {
  const SpecGroup({required this.title, required this.items});

  final String title;
  final List<SpecItem> items;
}

/// An equipment highlight.
class FeatureItem {
  const FeatureItem({
    required this.title,
    required this.description,
    required this.category,
    this.figure,
    this.figureUnit,
    this.hero = false,
  });

  final String title;
  final String description;
  final String category;

  /// Optional headline number shown alongside, e.g. "43" speakers.
  final String? figure;
  final String? figureUnit;
  final bool hero;
}

/// An orderable exterior finish. [asset] is a photograph of the car actually
/// wearing it, so choosing a finish swaps real photography rather than
/// recolouring a single image.
class PaintOption {
  const PaintOption({
    required this.name,
    required this.swatch,
    required this.sheen,
    required this.twoTone,
    required this.asset,
    this.premiumRmb = 0,
  });

  final String name;
  final Color swatch;

  /// Highlight tone used for the swatch gradient.
  final Color sheen;
  final bool twoTone;
  final String asset;
  final int premiumRmb;
}

/// An orderable cabin, likewise backed by a real photograph.
class InteriorOption {
  const InteriorOption({
    required this.name,
    required this.material,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.asset,
    this.premiumRmb = 0,
  });

  final String name;
  final String material;
  final Color primary;
  final Color secondary;
  final Color accent;
  final String asset;
  final int premiumRmb;
}

/// A photograph. [asset] may be absent — the gallery falls back to a framed
/// plate rather than failing.
class GalleryPhoto {
  const GalleryPhoto({
    required this.asset,
    required this.caption,
    required this.category,
    this.tall = false,
  });

  final String asset;
  final String caption;
  final String category;
  final bool tall;
}

/// One step of the order-to-delivery process.
class ImportStage {
  const ImportStage({
    required this.title,
    required this.detail,
    required this.duration,
    required this.icon,
  });

  final String title;
  final String detail;

  /// Human-readable, e.g. "3–5 weeks".
  final String duration;
  final IconData icon;
}

/// A commitment made to the buyer.
class Assurance {
  const Assurance(this.title, this.detail, this.icon);

  final String title;
  final String detail;
  final IconData icon;
}

/// A car the buyer is realistically cross-shopping.
class Rival {
  const Rival({
    required this.name,
    required this.powerHp,
    required this.zeroToHundred,
    required this.wheelbaseMm,
    required this.rangeKm,
  });

  final String name;
  final int powerHp;
  final double zeroToHundred;
  final int wheelbaseMm;
  final int rangeKm;
}

/// Every input that turns a Chinese list price into an indicative
/// Alexandria on-the-road figure.
///
/// These are DEFAULTS, not quotations. Egyptian duty, tax and clearance costs
/// move, and they depend on the exact HS classification, battery capacity and
/// the agreement in force at the time of shipment. The order screen exposes
/// every one of these as an editable input for exactly that reason.
class ImportCosting {
  const ImportCosting({
    required this.egpPerRmb,
    required this.freightUsd,
    required this.usdToEgp,
    required this.customsDutyRate,
    required this.vatRate,
    required this.clearanceEgp,
    required this.dealerMarginRate,
  });

  final double egpPerRmb;
  final double freightUsd;
  final double usdToEgp;

  /// Fraction, e.g. 0.40 for 40%.
  final double customsDutyRate;
  final double vatRate;
  final double clearanceEgp;
  final double dealerMarginRate;

  ImportCosting copyWith({
    double? egpPerRmb,
    double? freightUsd,
    double? usdToEgp,
    double? customsDutyRate,
    double? vatRate,
    double? clearanceEgp,
    double? dealerMarginRate,
  }) {
    return ImportCosting(
      egpPerRmb: egpPerRmb ?? this.egpPerRmb,
      freightUsd: freightUsd ?? this.freightUsd,
      usdToEgp: usdToEgp ?? this.usdToEgp,
      customsDutyRate: customsDutyRate ?? this.customsDutyRate,
      vatRate: vatRate ?? this.vatRate,
      clearanceEgp: clearanceEgp ?? this.clearanceEgp,
      dealerMarginRate: dealerMarginRate ?? this.dealerMarginRate,
    );
  }

  /// A full landed-cost breakdown for one variant, in EGP.
  Quote quote(int priceRmb, {int optionsRmb = 0}) {
    final vehicle = (priceRmb + optionsRmb) * egpPerRmb;
    final freight = freightUsd * usdToEgp;
    final cif = vehicle + freight;
    final duty = cif * customsDutyRate;
    final vat = (cif + duty) * vatRate;
    final margin = (cif + duty + vat + clearanceEgp) * dealerMarginRate;
    return Quote(
      vehicle: vehicle,
      freight: freight,
      duty: duty,
      vat: vat,
      clearance: clearanceEgp,
      margin: margin,
    );
  }
}

/// The output of [ImportCosting.quote]. All figures in EGP.
class Quote {
  const Quote({
    required this.vehicle,
    required this.freight,
    required this.duty,
    required this.vat,
    required this.clearance,
    required this.margin,
  });

  final double vehicle;
  final double freight;
  final double duty;
  final double vat;
  final double clearance;
  final double margin;

  double get total => vehicle + freight + duty + vat + clearance + margin;

  /// Ordered line items for the breakdown table.
  List<(String, double)> get lines => [
        ('Vehicle, ex-works China', vehicle),
        ('Sea freight & marine insurance', freight),
        ('Customs duty', duty),
        ('VAT & schedule tax', vat),
        ('Clearance, plates & registration', clearance),
        ('Importer margin & preparation', margin),
      ];
}

/// The whole listing. One instance drives the app.
class CarListing {
  const CarListing({
    required this.brand,
    required this.brandNative,
    required this.model,
    required this.segment,
    required this.madeBy,
    required this.modelYear,
    required this.tagline,
    required this.positioning,
    required this.lengthMm,
    required this.widthMm,
    required this.heightMm,
    required this.wheelbaseMm,
    required this.dragCoefficient,
    required this.variants,
    required this.specGroups,
    required this.features,
    required this.paints,
    required this.interiors,
    required this.photos,
    required this.stages,
    required this.assurances,
    required this.rivals,
    required this.costing,
    required this.dealerName,
    required this.dealerRole,
    required this.city,
    required this.addressLine,
    required this.mapQuery,
    required this.phone,
    required this.phoneDisplay,
    required this.whatsapp,
    required this.whatsappDisplay,
    required this.email,
    required this.showroomNote,
    required this.reservationEgp,
    this.siteUrl,
  });

  final String brand;
  final String brandNative;
  final String model;
  final String segment;
  final String madeBy;
  final int modelYear;
  final String tagline;
  final String positioning;

  final int lengthMm;
  final int widthMm;
  final int heightMm;
  final int wheelbaseMm;
  final double dragCoefficient;

  final List<Variant> variants;
  final List<SpecGroup> specGroups;
  final List<FeatureItem> features;
  final List<PaintOption> paints;
  final List<InteriorOption> interiors;
  final List<GalleryPhoto> photos;
  final List<ImportStage> stages;
  final List<Assurance> assurances;
  final List<Rival> rivals;
  final ImportCosting costing;

  final String dealerName;
  final String dealerRole;
  final String city;
  final String addressLine;
  final String mapQuery;
  /// E.164, digits only — what `tel:` and `wa.me` need.
  final String phone;
  final String whatsapp;

  /// Human-formatted, for anything a customer reads.
  final String phoneDisplay;
  final String whatsappDisplay;

  final String email;
  final String showroomNote;
  final int reservationEgp;

  /// Public URL of the listing, included in the shared brochure.
  final String? siteUrl;

  String get fullName => '$brand $model';

  Variant get entryVariant =>
      variants.reduce((a, b) => a.priceRmb <= b.priceRmb ? a : b);

  Variant get flagshipVariant =>
      variants.firstWhere((v) => v.flagship, orElse: () => variants.last);

  /// Quickest 0–100 across the range.
  double get bestZeroToHundred =>
      variants.map((v) => v.zeroToHundred).reduce((a, b) => a < b ? a : b);

  int get maxPowerHp => variants.map((v) => v.powerHp).reduce((a, b) => a > b ? a : b);

  int get maxTotalRangeKm =>
      variants.map((v) => v.totalRangeKm).reduce((a, b) => a > b ? a : b);

  List<String> get photoCategories {
    final seen = <String>[];
    for (final p in photos) {
      if (!seen.contains(p.category)) seen.add(p.category);
    }
    return seen;
  }

  List<String> get featureCategories {
    final seen = <String>[];
    for (final f in features) {
      if (!seen.contains(f.category)) seen.add(f.category);
    }
    return seen;
  }
}
