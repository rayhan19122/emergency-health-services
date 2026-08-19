import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../providers/auth_provider.dart';
import 'app_nav_bar.dart';

/// Slide-in navigation for narrow viewports. Mirrors the destinations shown
/// in the horizontal bar on wide screens, plus profile / auth actions.
class AppNavDrawer extends StatelessWidget {
  const AppNavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentPath = GoRouterState.of(context).uri.path;
    final destinations = navDestinationsFor(auth, currentPath);

    void navigate(String path) {
      Navigator.of(context).pop(); // close the drawer first
      if (path != currentPath) context.go(path);
    }

    return Drawer(
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTheme.space20, AppTheme.space20, AppTheme.space16, AppTheme.space12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.primary, AppTheme.accent],
                        ),
                        borderRadius: AppTheme.borderMd,
                      ),
                      child: const Icon(Icons.local_hospital_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space12, vertical: AppTheme.space12),
                children: [
                  for (final d in destinations)
                    _DrawerItem(
                      icon: d.icon,
                      label: d.label,
                      active: d.active,
                      onTap: () => navigate(d.path),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppTheme.space12),
              child: auth.isAuthenticated
                  ? Column(
                      children: [
                        _DrawerItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Profile',
                          active: currentPath == '/profile',
                          onTap: () {
                            Navigator.of(context).pop();
                            if (currentPath != '/profile') context.push('/profile');
                          },
                        ),
                        _DrawerItem(
                          icon: Icons.logout_rounded,
                          label: 'Sign Out',
                          active: false,
                          onTap: () {
                            Navigator.of(context).pop();
                            auth.signOut();
                          },
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go('/login');
                        },
                        icon: const Icon(Icons.login_rounded, size: 18),
                        label: const Text('Sign In'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.primary : AppTheme.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: active ? AppTheme.primary.withValues(alpha: 0.10) : Colors.transparent,
        borderRadius: AppTheme.borderMd,
        child: InkWell(
          borderRadius: AppTheme.borderMd,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space16, vertical: AppTheme.space12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: AppTheme.space12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? AppTheme.primary : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
