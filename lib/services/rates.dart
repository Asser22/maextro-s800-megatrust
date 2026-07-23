import 'dart:convert';

import 'package:http/http.dart' as http;

/// A live foreign-exchange snapshot, reduced to the two rates this app prices
/// with: EGP per RMB (the car's list price) and EGP per USD (freight).
class LiveRates {
  const LiveRates({
    required this.egpPerRmb,
    required this.usdToEgp,
    required this.date,
  });

  final double egpPerRmb;
  final double usdToEgp;

  /// The publication date reported by the source, e.g. "2026-07-23".
  final String date;
}

/// Fetches reference exchange rates for the Order screen.
///
/// Source: the fawazahmed0 currency-api, served from the jsDelivr CDN. It is
/// free, needs no key, sends `access-control-allow-origin: *` (so it works
/// from a browser), lists 300+ currencies, and mirrors to a second CDN — which
/// is why it is a more dependable client-side source than scraping a bank page
/// the way a server-side job would.
///
/// One request for `usd.json` yields USD→EGP and USD→CNY; EGP-per-RMB is then
/// USD→EGP ÷ USD→CNY. These are official mid-market rates: a good, honest
/// default, but the rate an importer actually pays a bank is usually a little
/// worse, which is exactly why the Order screen keeps every rate editable.
abstract final class RatesService {
  static const _primary =
      'https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json';
  // Second CDN the same project publishes to. Tried only if the first fails.
  static const _fallback =
      'https://latest.currency-api.pages.dev/v1/currencies/usd.json';

  static Future<LiveRates?> fetch() async {
    for (final url in [_primary, _fallback]) {
      final rates = await _tryOne(url);
      if (rates != null) return rates;
    }
    return null;
  }

  static Future<LiveRates?> _tryOne(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final usd = body['usd'] as Map<String, dynamic>?;
      if (usd == null) return null;

      final usdToEgp = (usd['egp'] as num?)?.toDouble();
      final usdToCny = (usd['cny'] as num?)?.toDouble();
      if (usdToEgp == null || usdToCny == null || usdToCny == 0) return null;

      // Sanity bounds: reject a garbled response rather than quote a wild
      // number. EGP/USD has run roughly 30–90 in recent years.
      if (usdToEgp < 20 || usdToEgp > 200) return null;

      return LiveRates(
        egpPerRmb: usdToEgp / usdToCny,
        usdToEgp: usdToEgp,
        date: (body['date'] as String?) ?? '',
      );
    } catch (_) {
      // Any failure — offline, CORS, timeout, malformed — falls through to the
      // next source, and ultimately to the app's built-in default rates.
      return null;
    }
  }
}
