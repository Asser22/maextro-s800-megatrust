import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/car_data.dart';
import '../models/car.dart';
import '../theme/app_theme.dart';
import '../widgets/kit.dart';

/// Every outbound action: call, WhatsApp, email, map, share, copy.
abstract final class Reach {
  static Future<void> _open(BuildContext context, Uri uri, String failure) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) _toast(messenger, failure);
    } on PlatformException {
      _toast(messenger, failure);
    } on MissingPluginException {
      _toast(messenger, failure);
    }
  }

  static void _toast(ScaffoldMessengerState messenger, String message) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<void> call(BuildContext context) => _open(
        context,
        Uri(scheme: 'tel', path: car.phone),
        'No dialler available on this device.',
      );

  static Future<void> whatsapp(BuildContext context, {String? message}) {
    final number = car.whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
    final text = Uri.encodeComponent(
      message ??
          'Hello ${car.dealerName} — I am interested in importing the '
              '${car.fullName}. Could you send me the current landed price?',
    );
    return _open(
      context,
      Uri.parse('https://wa.me/$number?text=$text'),
      'Could not open WhatsApp.',
    );
  }

  static Future<void> email(BuildContext context, {String? subject, String? body}) {
    final s = subject ?? '${car.fullName} — import enquiry';
    final b = body ??
        'Hello,\n\nI would like to know more about importing the '
            '${car.fullName}.\n\n';

    // Built by hand, NOT with Uri(queryParameters:). That constructor encodes
    // application/x-www-form-urlencoded, which turns every space into a "+" —
    // mail clients then show the raw plus signs in the message body.
    // encodeComponent uses %20 and leaves the text readable.
    final uri = Uri.parse(
      'mailto:${car.email}'
      '?subject=${Uri.encodeComponent(s)}'
      '&body=${Uri.encodeComponent(b)}',
    );
    return _open(context, uri, 'No mail app configured.');
  }

  static Future<void> maps(BuildContext context) => _open(
        context,
        Uri.parse('https://maps.apple.com/?q=${Uri.encodeComponent(car.mapQuery)}'),
        'Could not open Maps.',
      );

  static Future<void> share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      brochureText(),
      subject: '${car.fullName} · ${car.city}',
      sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  static void copy(BuildContext context, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    HapticFeedback.selectionClick();
    _toast(ScaffoldMessenger.of(context), '$label copied.');
  }

  static void copySpecification(BuildContext context) {
    final out = StringBuffer(brochureText())
      ..writeln()
      ..writeln('FULL SPECIFICATION');
    for (final group in car.specGroups) {
      out
        ..writeln()
        ..writeln(group.title.toUpperCase());
      for (final item in group.items) {
        out.writeln('  ${item.label}: ${item.value}');
      }
    }
    Clipboard.setData(ClipboardData(text: out.toString()));
    HapticFeedback.mediumImpact();
    _toast(ScaffoldMessenger.of(context), 'Full specification copied.');
  }

  /// The plain-text brochure used for sharing and as a mail body.
  ///
  /// Written to survive WhatsApp: no markdown, short lines, and every way to
  /// reach the showroom at the bottom, because this is the message a customer
  /// forwards to someone else.
  static String brochureText() {
    final quote = car.costing.quote(car.entryVariant.priceRmb);
    return '''
${car.fullName} · ${car.brandNative}
${car.segment}
Built by ${car.madeBy}

Factory new, ${car.modelYear} model year, imported to order from China
to ${car.city}. Zero kilometres, never registered.

From ${Num.egp(quote.total)} landed — customs duty, taxes,
clearance and Egyptian registration all included.

• Up to ${car.maxPowerHp} hp · 0–100 km/h from ${car.bestZeroToHundred} s
• Up to ${Num.group(car.maxTotalRangeKm)} km total range (range-extender)
• ${Num.group(car.wheelbaseMm)} mm wheelbase · ${Num.group(car.lengthMm)} mm long
• Rear lounge seats reclining to 148.5°
• 43 speakers · 2,920 W HUAWEI Sound Ultimate
• Huawei ADS 4 · 32 sensors · 76-inch head-up display

${car.variants.length} versions, four exterior finishes and
${car.interiors.length} cabins available to order.
${car.siteUrl == null ? '' : '\nSee the full specification and build yours:\n${car.siteUrl}\n'}
—
${car.dealerName}
${car.dealerRole}
${car.addressLine}

WhatsApp  ${car.whatsappDisplay}
Phone     ${car.phoneDisplay}
Email     ${car.email}

Landed prices are indicative and confirmed in writing at order.''';
  }

  /// Composes the enquiry the reservation form sends.
  static String enquiryBody({
    required String name,
    required String contact,
    required Variant variant,
    required PaintOption paint,
    required InteriorOption interior,
    required double landed,
    String note = '',
  }) {
    return '''
Hello ${car.dealerName},

I would like to reserve a build slot for the ${car.fullName}.

Name:       $name
Contact:    $contact

Variant:    ${variant.name}
Powertrain: ${variant.powertrain.label} - ${variant.layout}
Exterior:   ${paint.name}
Cabin:      ${interior.name} - ${interior.material}

Indicative landed price shown in the app: ${Num.egp(landed)}
${note.isEmpty ? '' : '\n$note\n'}
Please confirm the current landed price, the build slot and the delivery
schedule in writing.

Thank you.''';
  }
}

/// Bottom sheet listing every way to reach the importer.
Future<void> showContactSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const _ContactSheet(),
  );
}

class _ContactSheet extends StatelessWidget {
  const _ContactSheet();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.obsidian,
        border: Border(top: BorderSide(color: AppColors.champagneDeep)),
      ),
      padding: EdgeInsets.fromLTRB(
        Gap.page,
        Gap.md,
        Gap.page,
        Gap.md + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 34, height: 2, color: AppColors.hairline)),
          const SizedBox(height: Gap.md),
          Text(car.dealerName, style: t.headlineMedium),
          const SizedBox(height: Gap.xxs),
          Text('${car.dealerRole} · ${car.city}', style: t.bodySmall),
          const SizedBox(height: Gap.md),
          Ledger(
            children: [
              _Line(
                label: 'WhatsApp',
                value: car.whatsappDisplay,
                onTap: () => Reach.whatsapp(context),
              ),
              _Line(
                label: 'Call',
                value: car.phoneDisplay,
                onTap: () => Reach.call(context),
              ),
              _Line(label: 'Email', value: car.email, onTap: () => Reach.email(context)),
              _Line(
                label: 'Showroom',
                value: car.addressLine,
                onTap: () => Reach.maps(context),
              ),
              _Line(
                label: 'Share',
                value: 'Send the brochure to someone',
                onTap: () => Reach.share(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Gap.sm),
        child: Row(
          children: [
            SizedBox(width: 92, child: Caps(label, color: AppColors.champagne)),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Icon(Icons.north_east_rounded, size: 13, color: AppColors.boneFaint),
          ],
        ),
      ),
    );
  }
}
