import 'package:flutter/material.dart';

import '../theme/app_theme_extension.dart';

/// Shared pill-style category chip used by the shop page and category page.
///
/// Single source of truth for the horizontal category / sub-category rail so
/// the two rails can never visually drift again. Visuals come entirely from
/// theme tokens (`context.appTheme`) — the only literals are the chip's own
/// intrinsic constants (999 pill radius, 16/8 padding, 13pt label).
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Material(
      color: selected ? appTheme.brandPalette.tone500 : appTheme.chip,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? Theme.of(context).colorScheme.onPrimary
                    : appTheme.chipFg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
