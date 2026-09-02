import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme_extension.dart';
import 'combo_data.dart';
import 'combo_picker.dart';

/// 任選組合商品內頁（#37）：組合標題、已選摘要、商品池挑選、加入購物車。
class ComboDetailScreen extends StatelessWidget {
  const ComboDetailScreen({super.key, required this.config});

  final ComboConfig config;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      backgroundColor: appTheme.bg,
      appBar: AppBar(
        title: Text(config.name),
        backgroundColor: appTheme.bgElev,
        foregroundColor: appTheme.fg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart_outlined, color: appTheme.fg),
            onPressed: () => context.go('/cart'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ComboPicker(config: config, mode: ComboMode.page),
      ),
    );
  }
}
