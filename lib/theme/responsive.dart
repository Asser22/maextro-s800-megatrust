import 'package:flutter/widgets.dart';

import 'app_theme.dart';

/// Layout tiers. The app is one codebase across phone, tablet, desktop and
/// web, so every screen asks these questions rather than assuming a phone.
enum Tier {
  /// Phones, and any narrow window.
  compact,

  /// Small tablets, split-screen desktop windows.
  medium,

  /// Laptops and desktops.
  expanded;

  bool get isCompact => this == Tier.compact;
  bool get atLeastMedium => index >= Tier.medium.index;
  bool get isExpanded => this == Tier.expanded;
}

abstract final class Breakpoints {
  static const medium = 760.0;
  static const expanded = 1140.0;

  static Tier of(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= expanded) return Tier.expanded;
    if (w >= medium) return Tier.medium;
    return Tier.compact;
  }

  /// Horizontal page margin, growing with the viewport.
  static double margin(BuildContext context) => switch (of(context)) {
        Tier.compact => Gap.page,
        Tier.medium => 44,
        Tier.expanded => 64,
      };

  /// Widest the reading column is ever allowed to get. Long measures are
  /// unreadable, so prose stops well before the window does.
  static const readable = 720.0;

  /// Widest the overall page content gets on a large display.
  static const page = 1360.0;

  /// Columns for the photo grid at this size.
  static int galleryColumns(BuildContext context) => switch (of(context)) {
        Tier.compact => 2,
        Tier.medium => 3,
        Tier.expanded => 4,
      };
}

/// Centres its child and caps how wide it can grow.
class Bounded extends StatelessWidget {
  const Bounded({super.key, required this.child, this.maxWidth = Breakpoints.page});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        // Stretch to the full permitted width. Without this the column
        // shrink-wraps its widest child and the whole page drifts to the
        // middle instead of sitting on the page margins.
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

/// Standard page scaffold: bounded width, responsive horizontal margin, and
/// room at the bottom for the navigation bar on compact layouts.
class ScreenBody extends StatelessWidget {
  const ScreenBody({
    super.key,
    required this.children,
    this.maxWidth = Breakpoints.page,
    this.controller,
  });

  final List<Widget> children;
  final double maxWidth;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final margin = Breakpoints.margin(context);
    // On wide layouts the top navigation bar has already consumed the status
    // bar inset, so only compact pages pay for it again.
    final top = Breakpoints.of(context).isCompact
        ? MediaQuery.of(context).padding.top + Gap.lg
        : Gap.lg;

    return Bounded(
      maxWidth: maxWidth,
      child: ListView(
        controller: controller,
        padding: EdgeInsets.fromLTRB(margin, top, margin, Gap.xl),
        children: children,
      ),
    );
  }
}
