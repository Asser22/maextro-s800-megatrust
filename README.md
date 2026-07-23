# MAEXTRO S800 · Alexandria

A cross-platform Flutter sales app for importing the **Maextro S800** new from
China and selling it to order in Alexandria, Egypt.

Runs from one codebase on **iOS, Android, Web and macOS**.

---

## ⚠️ Read this first: the car is not a Xiaomi

There is **no Xiaomi S800**. Xiaomi builds the **SU7** (sedan) and **YU7** (SUV).

The S800 is the **Maextro S800** (尊界 S800) — built by **JAC Group with
Huawei** under the HIMA alliance, launched 30 May 2025, priced in China from
¥708,000 to ¥1,018,000. It is a full-size ultra-luxury sedan aimed squarely at
the Maybach S-Class.

The app is built around the Maextro. If you actually meant a different car,
say so and it can be repointed — every figure lives in one file.

---

## The one file you edit

**`lib/data/car_data.dart`** drives the entire app: prices, specification,
finishes, timeline, contact details. Lines marked `✏️` are the ones you must
set before showing this to a customer:

| What | Status |
|---|---|
| `dealerName` | ✅ Mega Trust Group |
| `email` | ✅ hello@megatrust.net |
| `addressLine`, `mapQuery` | ✅ 696 El-Hourya St, Louran, Alexandria |
| `whatsapp` | ✅ +1 (321) 503-9948 |
| `phone` | ⚠️ +20 2 1234 5678 — **verify.** `02` is the Cairo code (Alexandria is `03`) and `1234 5678` reads like a placeholder |
| `siteUrl` | ✏️ set to the final public URL; it appears in the shared brochure |
| `costing` | ✏️ the six landed-cost assumptions. **See below.** |
| `reservationEgp` | ✏️ your refundable reservation amount |
| `paints` names | ✏️ confirm against the current Maextro order sheet |

Phone numbers are stored twice: `phone`/`whatsapp` in E.164 for `tel:` and
`wa.me` links, and `phoneDisplay`/`whatsappDisplay` for anything a customer
reads. Keep both in step.

---

## The landed-cost calculator

The Order screen turns a Chinese list price into an indicative Alexandria
on-the-road figure:

```
vehicle (RMB × rate) + freight      → CIF
CIF × duty%                         → duty
(CIF + duty) × VAT%                 → tax
+ clearance + your margin           = total
```

**The defaults are estimates, not quotations.** Egyptian duty and tax on
imported vehicles depend on HS classification, powertrain, battery capacity
and the rules in force on the day of clearance — and EV/EREV treatment has
moved more than once. Get the real numbers from your clearing agent and put
them in `costing`.

All six inputs are also **editable live** inside the app ("Adjust the
assumptions" on the Order screen), so you can re-price in front of a customer
without a rebuild.

---

## Photography

Ten real S800 photographs live in `assets/car/`. They drive the hero, the
gallery, and the configurator.

**The configurator swaps real photography.** Each `PaintOption` and
`InteriorOption` in `car_data.dart` carries an `asset` — a picture of the car
actually wearing that finish — so choosing "Pearl over Bronze" cross-fades to
the pearl car rather than tinting one image.

| File | Used for |
|---|---|
| `exterior-front.webp` | Hero, and Obsidian over Champagne |
| `exterior-cutaway.webp` | Champagne over Obsidian, dimensions section |
| `exterior-pearl.webp` | Pearl over Bronze |
| `exterior-doors.webp` | Onyx over Gold |
| `exterior-rear.webp` | Gallery |
| `cabin-cognac.webp` | Cognac cabin |
| `cabin-cream-wood.webp` | Porcelain & Walnut cabin |
| `cabin-starlight.webp` | Porcelain Starlight cabin |
| `detail-console.webp`, `audio-topdown.webp` | Gallery details |

**To add more:** drop the file in `assets/car/`, add a `GalleryPhoto` entry to
`photos` in `car_data.dart`, and run `flutter run`. To add a new finish, add a
`PaintOption` pointing at its photograph.

Where to get more images you are cleared to use:

1. **Your own photographs** of the actual cars — on arrival, at the port, in
   the showroom. Best option commercially and legally, and it is what
   separates you from every other listing.
2. **The official Maextro / HIMA dealer media kit.** As an importer you can
   request the press and retail asset pack with written permission to use it.
   Ask for it when you set up the supply channel.
3. **Your supplier's photography**, with written permission.

### Resolution — the one real weakness

The supplied photographs are **860 px wide**. A desktop hero is 1600–1920 px,
so they were being upscaled roughly 2×, which is what made the hero look
pixelated.

Mitigated, not cured:

- Resampled 2× with Lanczos plus a restrained unsharp mask, which removes the
  stair-stepped edges that read as "pixelated".
- `FilterQuality.high` (bicubic) on every scaled photo; Flutter's default
  medium filtering is visibly softer when upscaling.

**None of this invents detail.** The hero is the one place it still shows. The
actual fix is 2000 px+ originals — ask your supplier for the Maextro dealer
media pack, drop them into `assets/car/` under the same filenames, and the
hero becomes genuinely sharp with no code change.

Nothing is scraped from the web here. For a commercial sales site that is a
copyright exposure for the business, and licensed dealer imagery is both safer
and higher resolution.

---

## Running it

The Flutter SDK is installed at `~/development/flutter`.

```bash
export PATH="$HOME/development/flutter/bin:$PATH"

flutter pub get
flutter run -d chrome          # web
flutter run                    # attached device
flutter build apk --release    # Android
flutter build ipa              # iOS (needs Xcode)
flutter test                   # 5 tests
flutter analyze                # clean
```

iOS and macOS builds need the full Xcode, not just Command Line Tools.

---

## Publishing the site

```bash
./tool/package_web.sh
```

Builds and writes two ready-to-upload packages to the Desktop:

| Package | Host | Config it carries |
|---|---|---|
| `S800-cloudflare` + `.zip` | Cloudflare Pages | `_headers`, `_redirects` |
| `S800-netlify` + `.zip` | Netlify | `_headers`, `_redirects`, `netlify.toml` |

Drag the **folder** (or the zip) into the host's upload area. In both, the site
sits at the **root** of the archive — a zip containing a wrapper directory
deploys to a site with no `index.html` at the top level and serves nothing.

`netlify.toml` disables Netlify's post-processing. That step tries to re-parse
and re-minify every JS asset it finds, and a 2.6 MB dart2js bundle is exactly
the input that makes it stall. Flutter's output is already minified.

The script also strips debug symbol maps and the CanvasKit engine variants a
JS build never loads — about 21 MB of dead weight per deploy.

### If `*.netlify.app` is unreachable

Some networks — Egyptian ISPs among them — cannot route to Netlify's
`*.netlify.app` serving edge, even though `netlify.com` itself loads fine.
Symptom: the URL times out rather than returning an error page, and Netlify's
own `play.netlify.app` fails the same way.

To confirm, open the link on **mobile data with WiFi off**. If it loads there,
it is the network, not the deploy.

Fixes, in order of preference:

1. **A custom domain.** Point `megatrust.net` (or a subdomain) at the host.
   Custom domains resolve to different IPs and sidestep the block entirely —
   and a business selling F-segment cars should not be sending customers a
   link with someone else's brand in it.
2. **Cloudflare Pages.** Its anycast network has a Cairo point of presence and
   is essentially always reachable in Egypt. Free, same drag-and-drop.

---

## Responsive behaviour

One codebase, three layout tiers (`lib/theme/responsive.dart`):

| Tier | Width | Layout |
|---|---|---|
| compact | < 760 | Bottom tab bar, single column, portrait hero |
| medium | 760 – 1139 | Top navigation, 3-column gallery |
| expanded | ≥ 1140 | Top navigation, cinematic hero, 4-column gallery, two-column configurator and dimensions |

`flutter test` exercises every tab at phone, tablet and desktop sizes and fails
on any overflow, which is what keeps the desktop layout honest.

---

## Design

**"Obsidian & Champagne."** Warm near-black — never blue-black, which reads as
consumer tech — lit by a single champagne metallic that appears roughly once
per screen. Type does the work: **Bodoni Moda** pinned to optical size 72 for
the hairline-serif display, **Jost** for everything else. Surfaces are
separated by hairlines rather than shadow or blur, radii are square, motion is
slow and long-eased.

Both fonts are instanced locally from the variable originals into static cuts
in `assets/fonts/` — nothing is fetched at runtime.

---

## Structure

```
lib/
├── data/car_data.dart      ← the only file you normally edit
├── models/car.dart         ← Variant, ImportCosting, Quote, …
├── state/selection.dart    ← the buyer's build, shared by Build + Order
├── theme/app_theme.dart    ← palette and type scale
├── theme/responsive.dart   ← breakpoints and page shells
├── widgets/
│   ├── kit.dart            ← Panel, Ledger, Figure, GoldButton, Rule, …
│   └── photo.dart          ← asset photos with graceful fallback
└── screens/
    ├── showcase_screen.dart
    ├── gallery_screen.dart
    ├── specs_screen.dart
    ├── configure_screen.dart
    └── order_screen.dart

assets/
├── car/                    ← the 10 real photographs
├── brand/                  ← Mega Trust logo (+ dark-ground variant)
└── fonts/                  ← Bodoni Moda + Jost, statically instanced
```

---

## Specification sources

Figures in `car_data.dart` come from public reference material:

- [Maextro S800 — Wikipedia](https://en.wikipedia.org/wiki/Maextro_S800)
- [CarNewsChina — S800 2026 refresh](https://carnewschina.com/2026/02/07/huaweis-updated-maextro-s800-luxury-sedan-features-upgraded-range-extender-with-three-motors/)
- [CnEVPost — S800 Grand Design](https://cnevpost.com/2026/06/25/maextro-launches-s800-grand-design/)

**Confirm every figure against the official Maextro order sheet for the exact
model year and build you are importing before you quote a customer.** The 2026
refresh changed the EREV battery (65 → 63.3 kWh) and the LiDAR.

---

## Not built yet

- **Arabic / RTL.** Worth doing for Alexandria walk-in customers. Flutter
  handles RTL well; it needs an Arabic face and the strings extracted.
- **Payment or deposit capture.** The reservation form composes an email; it
  does not take money.
- **A backend.** Everything is local. No server, no analytics, and no customer
  data leaves the device except through the mail or WhatsApp app the buyer
  chooses.
