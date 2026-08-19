import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// Compact metric tile used on dashboards: an accent icon, a large value,
/// and a caption. Presentational only — wrap it in your own Link/InkWell
/// navigation as needed (it already handles tap when [onTap] is given).
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  /// Accent color for the icon. Use the brand-harmonized `AppTheme.accent*`
  /// set rather than raw Material colors.
  final Color accent;
  final VoidCallback? onTap;
  final double width;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
    this.onTap,
    this.width = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.space8),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.10),
                        borderRadius: AppTheme.borderSm,
                      ),
                      child: Icon(icon, color: accent, size: 22),
                    ),
                    const Spacer(),
                    if (onTap != null)
                      const Icon(Icons.arrow_outward,
                          size: 16, color: AppTheme.textTertiary),
                  ],
                ),
                const SizedBox(height: AppTheme.space12),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
