import 'package:flutter/material.dart';

import 'app_nav_bar.dart';
import 'app_nav_drawer.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppNavBar(),
      // Right-side drawer holds navigation on narrow viewports; the menu
      // button in AppNavBar opens it. Harmless on wide screens (no opener).
      endDrawer: const AppNavDrawer(),
      body: child,
    );
  }
}
