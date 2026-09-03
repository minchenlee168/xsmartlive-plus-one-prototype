import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// AppBar 用的返回鍵：有上一頁就返回，否則導向 [fallbackLocation]。
///
/// 用途：避免直接開啟網址／硬重新整理／經 `context.go` 進入的頁面，
/// 因為 `Navigator.canPop()` 為 false 而讓 AppBar 自動返回鍵消失。
class BackLeadingButton extends StatelessWidget {
  const BackLeadingButton({
    super.key,
    this.fallbackLocation = '/home',
    this.color,
    this.icon = Icons.arrow_back,
  });

  final String fallbackLocation;
  final Color? color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      color: color,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
        } else {
          context.go(fallbackLocation);
        }
      },
    );
  }
}
