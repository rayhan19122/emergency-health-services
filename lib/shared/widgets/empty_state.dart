import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// A consistent, finished empty-state block: a soft brand-tinted icon badge,
/// a title, and an optional one-line hint. Replaces the bare
/// "faint icon + single line" empty states scattered across list screens.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space24, vertical: AppTheme.space48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.space20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 40, color: AppTheme.primary.withValues(alpha: 0.55)),
            ),
            const SizedBox(height: AppTheme.space20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppTheme.textPrimary),
            ),
            if (message != null) ...[
              const SizedBox(height: AppTheme.space8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
