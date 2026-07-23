import 'package:flutter/material.dart';
import '../models/car.dart';

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║  MAEXTRO S800  ·  尊界 S800                                              ║
// ║                                                                          ║
// ║  Built by JAC Group with Huawei, under the HIMA alliance. Launched       ║
// ║  30 May 2025. This is the car the app sells — NOT a Xiaomi product;      ║
// ║  Xiaomi's cars are the SU7 and YU7, and no Xiaomi S800 exists.           ║
// ║                                                                          ║
// ║  SPECIFICATIONS below are sourced from public reference material         ║
// ║  (see README). Before you quote a customer, confirm the figures for      ║
// ║  the exact model year and build you are importing against the official   ║
// ║  Maextro order sheet — the 2026 refresh changed the battery and LiDAR.   ║
// ║                                                                          ║
// ║  ✏️  = set this to your own commercial numbers before going live.        ║
// ╚══════════════════════════════════════════════════════════════════════════╝

final CarListing car = CarListing(
  // ── Identity ──────────────────────────────────────────────────────────────
  brand: 'MAEXTRO',
  brandNative: '尊界',
  model: 'S800',
  segment: 'Full-size ultra-luxury sedan · F-segment',
  madeBy: 'JAC Group with Huawei · HIMA alliance',
  modelYear: 2026,
  tagline: 'The flagship China built to answer Maybach.',
  positioning:
      'Five-and-a-half metres of hand-finished sedan on a 3,370 mm wheelbase, '
      'carrying Huawei\'s most advanced drivetrain, sensor suite and cabin '
      'electronics. It is the first Chinese car engineered without a price '
      'ceiling, and it is the car we bring into Alexandria to order — factory '
      'new, zero kilometres, in the exact specification you choose.',

  // ── Body ──────────────────────────────────────────────────────────────────
  lengthMm: 5480,
  widthMm: 2000,
  // 1,542 mm per the CarNewsChina database for both the 2025 and 2026 model
  // years. Wikipedia's 1,536 mm is the outlier and is not used.
  heightMm: 1542,
  wheelbaseMm: 3370,
  dragCoefficient: 0.206,

  // ── Orderable range ───────────────────────────────────────────────────────
  // 2026 model year, using the manufacturer's own trim names (星光 Starlight,
  // 星辉 Xinghui, 星耀 Xingyao). Prices are the 2026 Chinese list prices.
  // Performance and range are CLTC / manufacturer-claimed.
  variants: const [
    Variant(
      name: 'Starlight Premium',
      powertrain: Powertrain.bev,
      seats: 5,
      motors: 2,
      powerKw: 390,
      powerHp: 523,
      zeroToHundred: 4.3,
      topSpeedKmh: 210,
      batteryKwh: 97,
      electricRangeKm: 670,
      totalRangeKm: 670,
      priceRmb: 728000,
      note: 'The purest version, and the quickest in the range. 97 kWh CATL '
          'Qilin pack with 5C charging, and 670 km CLTC.',
    ),
    Variant(
      name: 'Xinghui Premium',
      powertrain: Powertrain.erev,
      seats: 5,
      motors: 2,
      powerKw: 390,
      powerHp: 523,
      zeroToHundred: 4.9,
      topSpeedKmh: 200,
      batteryKwh: 63.3,
      electricRangeKm: 311,
      totalRangeKm: 1333,
      priceRmb: 728000,
      note: 'The sensible choice for Egypt today: 311 km on battery alone, '
          '1,333 km in total, and no dependence on public charging.',
    ),
    Variant(
      name: 'Xingyao Premium',
      powertrain: Powertrain.erev,
      seats: 5,
      motors: 3,
      powerKw: 635,
      powerHp: 852,
      zeroToHundred: 4.6,
      topSpeedKmh: 200,
      batteryKwh: 63.3,
      electricRangeKm: 271,
      totalRangeKm: 1200,
      priceRmb: 808000,
      note: 'Adds the second rear motor: 852 hp, 718 Nm, and torque vectoring '
          'across the rear axle.',
    ),
    Variant(
      name: 'Starlight Executive',
      powertrain: Powertrain.bev,
      seats: 4,
      motors: 2,
      powerKw: 390,
      powerHp: 523,
      zeroToHundred: 4.5,
      topSpeedKmh: 210,
      batteryKwh: 97,
      electricRangeKm: 650,
      totalRangeKm: 650,
      priceRmb: 838000,
      note: 'Four individual seats and the full rear console, on the 97 kWh '
          'battery. 650 km CLTC.',
    ),
    Variant(
      name: 'Xinghui Executive',
      powertrain: Powertrain.erev,
      seats: 4,
      motors: 2,
      powerKw: 390,
      powerHp: 523,
      zeroToHundred: 4.9,
      topSpeedKmh: 200,
      batteryKwh: 63.3,
      electricRangeKm: 311,
      totalRangeKm: 1333,
      priceRmb: 838000,
      note: 'The four-seat lounge with the range extender. The longest legs of '
          'any version, at 1,333 km.',
    ),
    Variant(
      name: 'Xingyao Executive',
      powertrain: Powertrain.erev,
      seats: 4,
      motors: 3,
      powerKw: 635,
      powerHp: 852,
      zeroToHundred: 4.7,
      topSpeedKmh: 200,
      batteryKwh: 63.3,
      electricRangeKm: 258,
      totalRangeKm: 1155,
      // ⚠️ 2026 list price not yet published. This is the 2025 figure; the
      // Order screen labels it as provisional. Confirm before quoting.
      priceRmb: 1018000,
      priceProvisional: true,
      note: 'The full-house chauffeur specification — tri-motor, four seats, '
          'and every rear-cabin option fitted.',
      flagship: true,
    ),
  ],

  // ── Specification ─────────────────────────────────────────────────────────
  specGroups: const [
    SpecGroup(
      title: 'Body & Dimensions',
      items: [
        SpecItem('Length', '5,480 mm', accent: true),
        SpecItem('Width', '2,000 mm'),
        SpecItem('Height', '1,542 mm'),
        SpecItem('Wheelbase', '3,370 mm', accent: true, note: 'Longer than a Maybach S-Class'),
        SpecItem('Kerb weight', 'from 2,604 kg', note: 'Up to 2,920 kg, tri-motor'),
        SpecItem('Drag coefficient', 'Cd 0.206', note: 'With low-drag wheels; 0.219 standard'),
        SpecItem('Boot capacity', '445 L'),
        SpecItem('Doors', 'Powered, 77° opening angle', accent: true),
        SpecItem('Seating', '4 or 5, rear split by multifunction armrest'),
      ],
    ),
    SpecGroup(
      title: 'Powertrain',
      items: [
        SpecItem('Platform', 'Tuling Longxing, 800 V architecture', accent: true),
        SpecItem('Front motor', '160 kW (215 hp)'),
        SpecItem('Rear motors', '237.5 kW (318 hp) each'),
        SpecItem('System output', '390 – 635 kW (523 – 852 hp)', accent: true),
        SpecItem('Peak torque', '718 Nm', note: 'Tri-motor'),
        SpecItem('Drive', 'Dual- or tri-motor all-wheel drive'),
        SpecItem('Range extender', '1.5 L M8000PHD turbo four', note: 'EREV only'),
        SpecItem('Extender output', '115 kW engine · 80 kW generator', note: 'EREV only'),
        SpecItem('0 – 100 km/h', 'from 4.3 s', accent: true, note: 'Starlight Premium, BEV'),
        SpecItem('Top speed', '210 km/h BEV · 200 km/h EREV'),
      ],
    ),
    SpecGroup(
      title: 'Battery & Charging',
      items: [
        SpecItem('BEV pack', '97 kWh CATL Qilin NMC', accent: true),
        SpecItem('EREV pack', '63.3 kWh CATL Freevoy NMC', note: '65 kWh before the 2026 refresh'),
        SpecItem('BEV range', '650 – 670 km CLTC'),
        SpecItem('EREV electric range', '258 – 311 km CLTC', note: 'Varies by trim'),
        SpecItem('EREV total range', 'up to 1,333 km CLTC', accent: true),
        SpecItem('BEV fast charge', '5C · 10–80% in 12 minutes'),
        SpecItem('EREV fast charge', '6C · 10–80% in 10.5 minutes', accent: true),
      ],
    ),
    SpecGroup(
      title: 'Chassis & Control',
      items: [
        SpecItem('Suspension', 'Active, with body-attitude control'),
        SpecItem('Rear-wheel steering', 'up to 12°', accent: true),
        SpecItem('Turning radius', '5.05 m standard'),
        SpecItem('Minimum turning radius', '3.80 m in special mode', accent: true),
        SpecItem('Crab walk', 'up to 16° of lateral offset'),
        SpecItem('Body control', 'Huawei Xmotion, integrated chassis domain'),
        SpecItem('Collision response', 'Automatic body adjustment on detection'),
      ],
    ),
    SpecGroup(
      title: 'Driver Assistance',
      items: [
        SpecItem('System', 'Huawei ADS 4, Level 3–ready', accent: true),
        SpecItem('Sensor count', '32 sensors', accent: true),
        SpecItem('LiDAR', '2 × 192-line'),
        SpecItem('Radar', '3 forward · 2 rear mmWave'),
        SpecItem('Cameras', '7 high-definition · 4 surround-view'),
        SpecItem('Ultrasonic', '12 sensors'),
        SpecItem('Lighting', 'Adaptive, with lane-highlight projection'),
      ],
    ),
    SpecGroup(
      title: 'Cabin & Technology',
      items: [
        SpecItem('Dashboard', 'Continuous panel, three integrated screens'),
        SpecItem('Head-up display', '76 inch', accent: true),
        SpecItem('Audio', '43 speakers · 2,920 W', accent: true),
        SpecItem('Audio format', 'HUAWEI Sound Ultimate 7.5.10'),
        SpecItem('Rear seats', 'Zero-gravity, 148.5° recline', accent: true),
        SpecItem('Rear control', 'Detachable touchscreen remote'),
        SpecItem('Connectivity', 'Huawei Xinghe, with satellite communication'),
        SpecItem('Headlights', 'Starry Splendour, 1,296 LEDs'),
        SpecItem('Tail lights', 'Nebula Canvas'),
      ],
    ),
  ],

  // ── Equipment worth a photograph ──────────────────────────────────────────
  features: const [
    FeatureItem(
      title: 'Rear Zero-Gravity Lounge',
      description:
          'The rear seats recline to 148.5° — the angle at which the spine '
          'carries no load — with powered leg rests, heat, ventilation and '
          'massage. Controlled from a detachable touchscreen that lifts out of '
          'the armrest.',
      category: 'Rear Cabin',
      figure: '148.5',
      figureUnit: 'degrees',
      hero: true,
    ),
    FeatureItem(
      title: 'HUAWEI Sound Ultimate',
      description:
          'Forty-three speakers, 2,920 watts, in a 7.5.10 layout with ceiling '
          'height channels and headrest drivers. It is the most elaborate audio '
          'system fitted to any production sedan.',
      category: 'Rear Cabin',
      figure: '43',
      figureUnit: 'speakers',
      hero: true,
    ),
    FeatureItem(
      title: '76-Inch Head-Up Display',
      description:
          'Navigation, assistance state and hazard warnings projected across a '
          'virtual 76-inch plane on the road ahead. The driver never looks down.',
      category: 'Technology',
      figure: '76',
      figureUnit: 'inches',
      hero: true,
    ),
    FeatureItem(
      title: 'Huawei ADS 4',
      description:
          'Thirty-two sensors including two 192-line LiDAR units, feeding a '
          'Level 3–ready assistance stack. Point-to-point highway and urban '
          'guidance, and memory parking.',
      category: 'Technology',
      figure: '32',
      figureUnit: 'sensors',
      hero: true,
    ),
    FeatureItem(
      title: 'Rear-Wheel Steering & Crab Walk',
      description:
          'Twelve degrees of rear steer pulls a 5.48 m sedan into a 3.8 m '
          'turning radius. It will also crab sideways at 16° to slot into a gap '
          'no other car this size would attempt.',
      category: 'Engineering',
      figure: '3.8',
      figureUnit: 'metre radius',
    ),
    FeatureItem(
      title: '800 V Tuling Longxing Platform',
      description:
          'An 800-volt architecture with 5C and 6C cells. Ten to eighty percent '
          'in as little as 10.5 minutes — faster than most cars at any price.',
      category: 'Engineering',
      figure: '10.5',
      figureUnit: 'minutes',
    ),
    FeatureItem(
      title: 'Starry Splendour Lighting',
      description:
          '1,296 individually addressable LEDs per headlight, capable of '
          'projecting the lane ahead onto the road surface, with fibre-optic '
          '"star-picking" door handles and Nebula Canvas tail lights.',
      category: 'Design',
      figure: '1,296',
      figureUnit: 'LEDs',
    ),
    FeatureItem(
      title: 'Powered 77° Doors',
      description:
          'All four doors open and close under power to 77°, with obstacle '
          'detection. They can be operated from the key, the screen, or the '
          'seat you are already sitting in.',
      category: 'Design',
      figure: '77',
      figureUnit: 'degrees',
    ),
    FeatureItem(
      title: 'Chilled Cabinet & Stemware',
      description:
          'A refrigerated compartment between the rear seats, sized and lined '
          'for glassware, alongside heated and cooled cupholders and wireless '
          'charging pads.',
      category: 'Rear Cabin',
    ),
    FeatureItem(
      title: 'Retracting Projector Screen',
      description:
          'A projector and motorised screen built into the rear cabin, plus '
          'folding tables with lit makeup mirrors and a fingerprint-secured safe.',
      category: 'Rear Cabin',
    ),
    FeatureItem(
      title: 'Satellite Communication',
      description:
          'Huawei Xinghe connectivity keeps the car reachable beyond cellular '
          'coverage — relevant on the desert road, not just as a specification '
          'line.',
      category: 'Technology',
    ),
    FeatureItem(
      title: 'Cd 0.206',
      description:
          'A drag coefficient of 0.206 on the low-drag wheels, achieved on a '
          'two-metre-wide car. It is what makes the range figures possible.',
      category: 'Engineering',
      figure: '0.206',
      figureUnit: 'Cd',
    ),
  ],

  // ── Finishes ─────────────────────────────────────────────────────────────
  // The S800 is sold as a two-tone car, and each option below points at a
  // photograph of the car actually wearing it — so the configurator swaps real
  // imagery instead of tinting one picture.
  paints: const [
    PaintOption(
      name: 'Obsidian over Champagne',
      swatch: Color(0xFF14120F),
      sheen: Color(0xFFC9AE7C),
      twoTone: true,
      asset: 'assets/car/exterior-front.webp',
    ),
    PaintOption(
      name: 'Champagne over Obsidian',
      swatch: Color(0xFFC9AE7C),
      sheen: Color(0xFF14120F),
      twoTone: true,
      asset: 'assets/car/exterior-cutaway.webp',
    ),
    PaintOption(
      name: 'Pearl over Bronze',
      swatch: Color(0xFFEDE7DD),
      sheen: Color(0xFF5A4536),
      twoTone: true,
      asset: 'assets/car/exterior-pearl.webp',
    ),
    PaintOption(
      name: 'Onyx over Gold',
      swatch: Color(0xFF1A1815),
      sheen: Color(0xFFD3B888),
      twoTone: true,
      asset: 'assets/car/exterior-doors.webp',
      premiumRmb: 30000,
    ),
  ],

  interiors: const [
    InteriorOption(
      name: 'Cognac',
      material: 'Quilted semi-aniline hide · open-pore walnut',
      primary: Color(0xFF8A5A32),
      secondary: Color(0xFF5C3A20),
      accent: Color(0xFFE6D3A8),
      asset: 'assets/car/cabin-cognac.webp',
    ),
    InteriorOption(
      name: 'Porcelain & Walnut',
      material: 'Quilted semi-aniline hide · figured walnut',
      primary: Color(0xFFE4DCCB),
      secondary: Color(0xFF7A4B2A),
      accent: Color(0xFFC6A664),
      asset: 'assets/car/cabin-cream-wood.webp',
    ),
    InteriorOption(
      name: 'Porcelain Starlight',
      material: 'Quilted semi-aniline hide · starlight headliner',
      primary: Color(0xFFEDE6D8),
      secondary: Color(0xFF3A2A1E),
      accent: Color(0xFFC6A664),
      asset: 'assets/car/cabin-starlight.webp',
      premiumRmb: 20000,
    ),
  ],

  // ── Photography ───────────────────────────────────────────────────────────
  photos: const [
    GalleryPhoto(
      asset: 'assets/car/exterior-front.webp',
      caption: 'Front three-quarter · Obsidian over Champagne',
      category: 'Exterior',
    ),
    GalleryPhoto(
      asset: 'assets/car/exterior-rear.webp',
      caption: 'Rear three-quarter, Nebula Canvas tail lights',
      category: 'Exterior',
    ),
    GalleryPhoto(
      asset: 'assets/car/exterior-pearl.webp',
      caption: 'Pearl over Bronze, and the rear cabin at night',
      category: 'Exterior',
      tall: true,
    ),
    GalleryPhoto(
      asset: 'assets/car/exterior-doors.webp',
      caption: 'All four powered doors at 77°',
      category: 'Exterior',
    ),
    GalleryPhoto(
      asset: 'assets/car/exterior-cutaway.webp',
      caption: 'Profile cutaway — 3,370 mm of wheelbase',
      category: 'Exterior',
    ),
    GalleryPhoto(
      asset: 'assets/car/cabin-cognac.webp',
      caption: 'Cognac rear lounge, five-seat layout',
      category: 'Rear Cabin',
    ),
    GalleryPhoto(
      asset: 'assets/car/cabin-cream-wood.webp',
      caption: 'Porcelain hide over figured walnut',
      category: 'Rear Cabin',
    ),
    GalleryPhoto(
      asset: 'assets/car/cabin-starlight.webp',
      caption: 'Zero-gravity recline under the starlight headliner',
      category: 'Rear Cabin',
      tall: true,
    ),
    GalleryPhoto(
      asset: 'assets/car/detail-console.webp',
      caption: 'Chilled cabinet, stemware and the folding table',
      category: 'Detail',
    ),
    GalleryPhoto(
      asset: 'assets/car/audio-topdown.webp',
      caption: 'All 43 speakers of HUAWEI Sound Ultimate',
      category: 'Detail',
    ),
  ],

  // ── Order to delivery ✏️ set your real lead times ─────────────────────────
  stages: const [
    ImportStage(
      title: 'Specification & reservation',
      detail:
          'We agree the variant, paint and cabin with you in Alexandria, confirm '
          'the landed price in writing, and place the factory order against a '
          'refundable reservation.',
      duration: 'Same week',
      icon: Icons.edit_note_rounded,
    ),
    ImportStage(
      title: 'Build slot & production',
      detail:
          'The order enters the Maextro line in Feixi, Hefei. You receive the '
          'build number and production photographs as it is assembled.',
      duration: '4 – 7 weeks',
      icon: Icons.precision_manufacturing_rounded,
    ),
    ImportStage(
      title: 'Inland transit & loading',
      detail:
          'Factory to port, pre-shipment inspection, and loading. Full marine '
          'insurance is placed before the vessel sails.',
      duration: '1 – 2 weeks',
      icon: Icons.inventory_2_rounded,
    ),
    ImportStage(
      title: 'Sea freight to Alexandria',
      detail:
          'China to Alexandria Port. You get the bill of lading and live vessel '
          'tracking for the whole crossing.',
      duration: '5 – 7 weeks',
      icon: Icons.directions_boat_rounded,
    ),
    ImportStage(
      title: 'Customs & clearance',
      detail:
          'Duty, tax and clearance handled end to end by our agent, including '
          'homologation paperwork, plates and registration in your name.',
      duration: '2 – 4 weeks',
      icon: Icons.gavel_rounded,
    ),
    ImportStage(
      title: 'Preparation & handover',
      detail:
          'Full pre-delivery inspection, paint correction and protection, '
          'software configured to Arabic, and handover at our Alexandria showroom.',
      duration: '1 week',
      icon: Icons.key_rounded,
    ),
  ],

  // ── What the buyer is promised ✏️ only keep what you can actually honour ──
  assurances: const [
    Assurance(
      'Factory new, zero kilometres',
      'Delivered sealed from the production line. Not a demonstrator, not a '
          'used export, not a re-registered car.',
      Icons.verified_rounded,
    ),
    Assurance(
      'Landed price fixed in writing',
      'The figure we quote is the figure you pay. Duty, freight, clearance and '
          'registration are all inside it.',
      Icons.receipt_long_rounded,
    ),
    Assurance(
      'Customs handled end to end',
      'Our clearing agent manages the whole file at Alexandria Port. You are '
          'never asked to attend customs yourself.',
      Icons.description_rounded,
    ),
    Assurance(
      'Parts & service arranged locally',
      'A stocked parts channel and a trained workshop partner in Alexandria '
          'before your car lands, not after.',
      Icons.build_rounded,
    ),
    Assurance(
      'Manufacturer warranty documented',
      'Warranty terms confirmed in writing at order, with the service book and '
          'digital records registered to you.',
      Icons.workspace_premium_rounded,
    ),
    Assurance(
      'Full traceability',
      'Build number, VIN, bill of lading, customs declaration and inspection '
          'report — every document handed over with the keys.',
      Icons.qr_code_2_rounded,
    ),
  ],

  // ── Cross-shopped against ─────────────────────────────────────────────────
  rivals: const [
    Rival(name: 'Maybach S 680', powerHp: 612, zeroToHundred: 4.5, wheelbaseMm: 3396, rangeKm: 0),
    Rival(name: 'BMW i7 M70', powerHp: 660, zeroToHundred: 3.7, wheelbaseMm: 3215, rangeKm: 560),
    Rival(name: 'Bentley Flying Spur', powerHp: 771, zeroToHundred: 3.8, wheelbaseMm: 3194, rangeKm: 0),
  ],

  // ── Landed-cost defaults ✏️✏️✏️ THESE ARE ESTIMATES — SET YOUR OWN ────────
  // Egyptian duty and tax on imported vehicles depend on HS classification,
  // powertrain, battery capacity and the agreements in force on the day of
  // clearance. Get these six numbers from your clearing agent and put them
  // here. Every one of them is also editable live on the Order screen.
  costing: const ImportCosting(
    egpPerRmb: 6.90,
    freightUsd: 3800,
    usdToEgp: 48.50,
    customsDutyRate: 0.40,
    vatRate: 0.14,
    clearanceEgp: 250000,
    dealerMarginRate: 0.12,
  ),

  // ── The business ✏️ ───────────────────────────────────────────────────────
  dealerName: 'Mega Trust Group',
  dealerRole: 'Direct importer · China to Alexandria',
  city: 'Alexandria, Egypt',
  addressLine: '696 El-Hourya St, Louran, Alexandria',
  mapQuery: '696 El-Hourya Street, Louran, Alexandria, Egypt',

  // Landline for calls, international mobile for WhatsApp.
  // ⚠️ "+20 2 1234 5678" is a Cairo (02) number and the digits read like a
  // placeholder. Alexandria landlines are +20 3. Double-check this before it
  // goes in front of a customer — a dead number on a luxury listing is fatal.
  phone: '+20212345678',
  phoneDisplay: '+20 2 1234 5678',
  whatsapp: '+13215039948',
  whatsappDisplay: '+1 (321) 503-9948',
  email: 'hello@megatrust.net',
  siteUrl: 'https://s800-alexandria.netlify.app', // ✏️ set to your final URL
  showroomNote:
      'Viewings and specification meetings are by appointment. We will walk you '
      'through the full order sheet, the landed cost line by line, and the '
      'delivery schedule before anything is signed.',
  reservationEgp: 250000, // ✏️ refundable reservation to open a build slot
);
