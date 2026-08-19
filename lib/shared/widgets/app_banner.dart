import 'package:flutter/material.dart';

import '../../config/theme.dart';

enum AppBannerVariant { info, success, warning, danger }

/// A tinted inline banner for status / info / error messages.
///
/// Replaces the ad-hoc "red box" and "blue box" containers that were
/// duplicated across login, dashboards, and booking screens. Colors come
/// from the semantic surface tokens in [AppTheme].
class AppBanner extends StatelessWidget {
  final String message;
  final AppBannerVariant variant;

  /// Overrides the default icon for the variant. Pass `null` via
  /// [showIcon] = false to hide it entirely.
  final IconData? icon;
  final bool showIcon;

  /// Optional trailing widget (e.g. an action button or value).
  final Widget? trailing;

  const AppBanner(
    this.message, {
    super.key,
    this.variant = AppBannerVariant.info,
    this.icon,
    this.showIcon = true,
    this.trailing,
  });

  const AppBanner.info(this.message, {super.key, this.icon, this.showIcon = true, this.trailing})
      : variant = AppBannerVariant.info;
  const AppBanner.success(this.message, {super.key, this.icon, this.showIcon = true, this.trailing})
      : variant = AppBannerVariant.success;
  const AppBanner.warning(this.message, {super.key, this.icon, this.showIcon = true, this.trailing})
      : variant = AppBannerVariant.warning;
  const AppBanner.danger(this.message, {super.key, this.icon, this.showIcon = true, this.trailing})
      : variant = AppBannerVariant.danger;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg, defaultIcon) = switch (variant) {
      AppBannerVariant.info => (
          AppTheme.infoBg,
          AppTheme.infoBorder,
          AppTheme.info,
          Icons.info_outline_rounded,
        ),
      AppBannerVariant.success => (
          AppTheme.successBg,
          AppTheme.successBorder,
          AppTheme.success,
          Icons.check_circle_outline_rounded,
        ),
      AppBannerVariant.warning => (
          AppTheme.warningBg,
          AppTheme.warningBorder,
          AppTheme.warning,
          Icons.warning_amber_rounded,
        ),
      AppBannerVariant.danger => (
          AppTheme.dangerBg,
          AppTheme.dangerBorder,
          AppTheme.danger,
          Icons.error_outline_rounded,
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space12, vertical: AppTheme.space12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppTheme.borderMd,
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showIcon) ...[
            Icon(icon ?? defaultIcon, size: 18, color: fg),
            const SizedBox(width: AppTheme.space8),
          ],
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: fg,
                    height: 1.45,
                  ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppTheme.space8),
            trailing!,
          ],
        ],
      ),
    );
  }
}
