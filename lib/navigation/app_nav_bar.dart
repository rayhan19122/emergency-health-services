import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/auth_provider.dart';

/// A single top-level navigation destination.
///
/// Shared between the wide-screen horizontal bar and the narrow-screen
/// drawer so the two never drift apart.
class NavDestination {
  final String label;
  final IconData icon;
  final String path;
  final bool active;

  const NavDestination(this.label, this.icon, this.path, {required this.active});
}

/// Builds the destination list for the current auth state and route.
List<NavDestination> navDestinationsFor(AuthProvider auth, String currentPath) {
  final isAdmin = auth.isOrgAdmin || auth.isSuperAdmin;
  return [
    if (!isAdmin) ...[
      NavDestination('Beds', Icons.bed_outlined, '/beds',
          active: currentPath.startsWith('/beds')),
      NavDestination('Ambulance', Icons.emergency_outlined, '/ambulance',
          active: currentPath.startsWith('/ambulance')),
      NavDestination('Blood', Icons.bloodtype_outlined, '/blood',
          active: currentPath.startsWith('/blood')),
      NavDestination('Tests', Icons.science_outlined, '/tests',
          active: currentPath.startsWith('/tests')),
      if (auth.isAuthenticated)
        NavDestination('My Bookings', Icons.list_alt_outlined, '/my-bookings',
            active: currentPath == '/my-bookings'),
    ],
    if (auth.isAuthenticated && auth.isOrgAdmin)
      NavDestination('Admin', Icons.admin_panel_settings_outlined, '/admin/dashboard',
          active: currentPath.startsWith('/admin')),
    if (auth.isAuthenticated && auth.isSuperAdmin)
      NavDestination('Platform', Icons.settings_outlined, '/super-admin/dashboard',
          active: currentPath.startsWith('/super-admin')),
  ];
}

/// The brand mark + title shown at the top-left. Tapping it goes home.
class AppBrandMark extends StatelessWidget {
  final String title;
  final String rootPath;

  const AppBrandMark({super.key, required this.title, required this.rootPath});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(rootPath),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primary, AppTheme.accent],
                ),
                borderRadius: AppTheme.borderMd,
              ),
              child: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Flexible(child: Text(title, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}

class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentPath = GoRouterState.of(context).uri.path;
    final isAdmin = auth.isOrgAdmin || auth.isSuperAdmin;
    final rootPath = auth.isSuperAdmin
        ? '/super-admin/dashboard'
        : auth.isOrgAdmin
        ? '/admin/dashboard'
        : '/';

    // Collapse the destination links into the drawer on narrow viewports.
    final isWide = MediaQuery.sizeOf(context).width >= AppTheme.navCollapseBreakpoint;

    String title = 'Emergency Healthcare';
    if (isAdmin) {
      if (auth.isSuperAdmin) {
        title = 'Platform Admin';
      } else if (auth.organizationName != null) {
        title = auth.organizationName!;
      }
    }

    final destinations = navDestinationsFor(auth, currentPath);

    return AppBar(
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      leading: currentPath == rootPath
          ? null
          : BackButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                  return;
                }
                context.replace(_fallbackPath(currentPath, auth, rootPath));
              },
            ),
      title: AppBrandMark(title: title, rootPath: rootPath),
      actions: isWide
          ? _wideActions(context, auth, currentPath, destinations)
          : _narrowActions(context, auth),
    );
  }

  /// Full horizontal navigation for desktop / wide tablet.
  List<Widget> _wideActions(
    BuildContext context,
    AuthProvider auth,
    String currentPath,
    List<NavDestination> destinations,
  ) {
    return [
      for (final d in destinations)
        _NavButton(
          label: d.label,
          icon: d.icon,
          isActive: d.active,
          onTap: () => context.go(d.path),
        ),
      const SizedBox(width: 8),
      if (auth.isAuthenticated) ...[
        IconButton(
          icon: const Icon(Icons.person_outline_rounded, color: AppTheme.textSecondary),
          tooltip: 'Profile',
          onPressed: () {
            if (currentPath != '/profile') context.push('/profile');
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary),
          tooltip: 'Sign Out',
          onPressed: () => auth.signOut(),
        ),
      ] else
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: FilledButton(
            onPressed: () => context.go('/login'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text('Sign In'),
          ),
        ),
      const SizedBox(width: 16),
    ];
  }

  /// Compact navigation for mobile / narrow tablet: a single menu button
  /// that opens the drawer holding every destination.
  List<Widget> _narrowActions(BuildContext context, AuthProvider auth) {
    return [
      Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppTheme.textPrimary),
          tooltip: 'Menu',
          onPressed: () => Scaffold.of(context).openEndDrawer(),
        ),
      ),
      const SizedBox(width: 4),
    ];
  }

  String _fallbackPath(String currentPath, AuthProvider auth, String rootPath) {
    if (currentPath.startsWith('/beds/book/')) return '/beds';
    if (currentPath.startsWith('/ambulance/book/')) return '/ambulance';
    if (currentPath.startsWith('/blood/request/')) return '/blood';
    if (currentPath.startsWith('/tests/')) return '/tests';
    if (currentPath.startsWith('/admin/tests/') &&
        currentPath.endsWith('/queue')) {
      return '/admin/tests';
    }
    if (currentPath.startsWith('/booking/')) {
      if (auth.isSuperAdmin) return '/super-admin/requests';
      if (auth.isOrgAdmin) return '/admin/dashboard';
      return '/my-bookings';
    }
    return rootPath;
  }
}

/// Nav item with animated hover background and an active-state
/// underline that slides in.
class _NavButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isActive
        ? AppTheme.primary
        : _hovered
        ? AppTheme.textPrimary
        : AppTheme.textSecondary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTheme.fast,
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered && !widget.isActive
                ? AppTheme.background
                : widget.isActive
                ? AppTheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: AppTheme.borderMd,
            border: widget.isActive
                ? Border.all(color: AppTheme.primary.withValues(alpha: 0.22))
                : null,
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: color),
              const SizedBox(width: 7),
              AnimatedDefaultTextStyle(
                duration: AppTheme.fast,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: color,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
