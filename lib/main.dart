import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/shell.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlay);
  runApp(const S800App());
}

class S800App extends StatelessWidget {
  const S800App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Becomes the browser tab title and the Android task-switcher label.
      title: 'Maextro S800 · Alexandria',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const Shell(),
      builder: (context, child) {
        // The layout adapts per screen (see theme/responsive.dart) rather than
        // being pinned to a phone-width column, so desktop and web get a real
        // desktop layout. Only text scale is clamped here.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(minScaleFactor: 0.85, maxScaleFactor: 1.25),
          ),
          child: ColoredBox(
            color: AppColors.ink,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
