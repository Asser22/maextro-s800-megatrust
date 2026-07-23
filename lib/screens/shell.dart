import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/car_data.dart';
import '../state/selection.dart';
import '../theme/app_theme.dart';
import '../theme/responsive.dart';
import '../utils/actions.dart';
import '../widgets/kit.dart';
import 'configure_screen.dart';
import 'gallery_screen.dart';
import 'order_screen.dart';
import 'showcase_screen.dart';
import 'specs_screen.dart';

/// Tab host.
///
/// Compact layouts get a bottom bar; anything wider gets a proper top
/// navigation bar with the marque and a call-to-action, because a phone-style
/// bottom bar on a desktop browser is the single clearest tell that a site is
/// a shrunken mobile app.
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final _selection = Selection();
  int _index = 0;

  static const _tabs = ['Home', 'Gallery', 'Spec', 'Build', 'Order'];

  @override
  void initState() {
    super.initState();
    // Pull live exchange rates once, in the background. The UI is fully usable
    // on the built-in defaults meanwhile, and this quietly upgrades them.
    _selection.loadLiveRates();
  }

  @override
  void dispose() {
    _selection.dispose();
    super.dispose();
  }

  void _go(int i) {
    if (i == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final tier = Breakpoints.of(context);
    final wide = tier.atLeastMedium;

    return SelectionScope(
      notifier: _selection,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: Stack(
          children: [
            const Positioned.fill(child: Atmosphere()),
            const Positioned.fill(child: Grain()),
            Column(
              children: [
                if (wide) _TopBar(index: _index, tabs: _tabs, onGo: _go),
                Expanded(
                  child: IndexedStack(
                    index: _index,
                    children: [
                      ShowcaseScreen(onGo: _go),
                      const GalleryScreen(),
                      const SpecsScreen(),
                      ConfigureScreen(onGo: _go),
                      const OrderScreen(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: wide ? null : _BottomBar(index: _index, tabs: _tabs, onGo: _go),
      ),
    );
  }
}

// ── Wide: top navigation ─────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.index, required this.tabs, required this.onGo});

  final int index;
  final List<String> tabs;
  final void Function(int) onGo;

  @override
  Widget build(BuildContext context) {
    final margin = Breakpoints.margin(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.obsidian,
        border: Border(bottom: BorderSide(color: AppColors.hairline)),
      ),
      padding: EdgeInsets.fromLTRB(
        margin,
        MediaQuery.of(context).padding.top + Gap.sm,
        margin,
        Gap.sm,
      ),
      child: Bounded(
        // Measure the real space available rather than trusting the breakpoint:
        // the bar has to survive a half-width desktop window too.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final showMarque = w >= 900;
            final showEnquire = w >= 700;
            final navGap = w >= 820 ? Gap.md : Gap.sm;

            return Row(
              children: [
                Flexible(
                  child: GestureDetector(
                    onTap: () => onGo(0),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/brand/mega-trust-light.png',
                            height: 30,
                            filterQuality: FilterQuality.medium,
                          ),
                          if (showMarque) ...[
                            const SizedBox(width: Gap.sm),
                            Container(width: 1, height: 24, color: AppColors.hairline),
                            const SizedBox(width: Gap.sm),
                            Marque(latin: car.brand, native: car.brandNative, scale: 0.8),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                for (final (i, label) in tabs.indexed)
                  Padding(
                    padding: EdgeInsets.only(left: navGap),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onGo(i),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label.toUpperCase(),
                              style: TextStyle(
                                fontFamily: 'Sans',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.8,
                                color: i == index ? AppColors.champagne : AppColors.boneMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutQuart,
                              height: 1.5,
                              width: i == index ? 20 : 0,
                              decoration: const BoxDecoration(gradient: AppColors.gilt),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (showEnquire) ...[
                  const SizedBox(width: Gap.md),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Reach.whatsapp(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Gap.sm, vertical: 9),
                        decoration:
                            BoxDecoration(border: Border.all(color: AppColors.champagneDeep)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.chat_outlined, size: 13, color: AppColors.champagne),
                            const SizedBox(width: 6),
                            Caps('Enquire', color: AppColors.champagne, size: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Compact: bottom navigation ───────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.tabs, required this.onGo});

  final int index;
  final List<String> tabs;
  final void Function(int) onGo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.obsidian,
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom * 0.7),
      child: Row(
        children: [
          for (final (i, label) in tabs.indexed)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onGo(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutQuart,
                      height: 1.5,
                      width: i == index ? 30 : 0,
                      decoration: const BoxDecoration(gradient: AppColors.gilt),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Sans',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                        color: i == index ? AppColors.champagne : AppColors.boneFaint,
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
