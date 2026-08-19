import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// Small icon + label pill used for compact metadata (address, phone,
/// status). Neutral surface styling so it reads on any background.
class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: AppTheme.borderPill,
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? AppTheme.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
