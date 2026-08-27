import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fires [onView] exactly once, after this route's first frame.
///
/// Wrap a screen in the router to emit its screen-view analytics **without
/// touching the screen widget itself**. Because go_router re-mounts a route
/// each time it is navigated to (the shell tabs here are plain `ShellRoute`
/// pages, not `StatefulShellRoute`), re-entering a screen re-fires — which is
/// the desired "entered this screen again" semantics.
class ScreenViewLogger extends ConsumerStatefulWidget {
  const ScreenViewLogger({
    super.key,
    required this.onView,
    required this.child,
  });

  /// Invoked once with a live [WidgetRef] so the callback can read the
  /// analytics service (and any other provider it needs, e.g. cart totals).
  final void Function(WidgetRef ref) onView;

  final Widget child;

  @override
  ConsumerState<ScreenViewLogger> createState() => _ScreenViewLoggerState();
}

class _ScreenViewLoggerState extends ConsumerState<ScreenViewLogger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onView(ref);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
