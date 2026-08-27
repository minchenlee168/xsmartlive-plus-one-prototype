import 'package:flutter/material.dart';

/// Phase 1 tablet adaptation helpers.
///
/// Strategy: phone stays exactly as-is; tablet gets centered content with a
/// `maxWidth` cap so screens don't stretch across iPad / Android tablet
/// widths. iOS iPad without iPad-specific UI work effectively becomes "x2
/// scaled iPhone" — left/right padding fills with the screen background.
///
/// Breakpoint: `MediaQuery.shortestSide >= 600` follows Material 3's tablet
/// threshold. Using `shortestSide` (not `width`) means a phone in landscape
/// is still treated as phone, and an iPad in Split View at <600pt is
/// correctly downgraded to phone behavior.
class Responsive {
  static const double tabletBreakpoint = 600;

  /// Width caps per content type (see `docs/specs/tablet_layout_phase1.md`).
  static const double contentMaxWidth = 720;
  static const double formMaxWidth = 600;
  static const double authMaxWidth = 480;
  static const double drawerMaxWidth = 400;
  static const double chatBubbleMaxWidth = 480;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= tabletBreakpoint;

  /// Wraps [child] in a centered, width-capped box on tablet; returns
  /// [child] unchanged on phone (no extra widget tree → zero phone impact).
  static Widget centeredBox(
    BuildContext context, {
    required Widget child,
    double maxWidth = contentMaxWidth,
  }) {
    if (!isTablet(context)) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  /// Returns the lesser of `screenWidth * ratio` and [cap]. Used for drawers
  /// and chat bubbles that already use percentage widths on phone but need
  /// an absolute cap on tablet so they don't span the entire screen.
  static double cappedWidth(
    BuildContext context, {
    required double ratio,
    required double cap,
  }) {
    final w = MediaQuery.of(context).size.width;
    final v = w * ratio;
    return v < cap ? v : cap;
  }

  /// Product grid column count by viewport width.
  ///
  /// Without this, fixed `crossAxisCount: 2` on tablet makes each cell
  /// ~334pt wide. Combined with the card's `childAspectRatio: 0.58`, each
  /// cell becomes ~576pt tall — the card's image area stretches and the
  /// content (title / price / sold) sits in the upper half with visible
  /// dead space below. Scaling cols with width keeps cell width near
  /// phone-equivalent (~180–200pt) so the existing aspect ratio still
  /// looks right.
  static int productGridColumns(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 900) return 4;
    if (w >= 600) return 3;
    return 2;
  }
}
