import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme_extension.dart';

/// 第三方帳號 — 綁定 / 解除綁定各社群登入來源。
///
/// prototype：綁定狀態僅在前端切換（真實流程走各家 OAuth）。
class ThirdPartyScreen extends ConsumerStatefulWidget {
  const ThirdPartyScreen({super.key});

  @override
  ConsumerState<ThirdPartyScreen> createState() => _ThirdPartyScreenState();
}

class _ThirdPartyScreenState extends ConsumerState<ThirdPartyScreen> {
  /// 支援綁定的第三方來源（對照設計稿）。
  static const _providers = <String>[
    'Facebook',
    'Facebook Messenger',
    'Google',
    'LINE',
    'TikTok',
    'Instagram',
  ];

  /// 目前已綁定的來源（前端狀態）。
  final Set<String> _bound = {};

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Scaffold(
      backgroundColor: appTheme.bg,
      appBar: AppBar(
        title: const Text('第三方帳號'),
        backgroundColor: appTheme.bgElev,
        foregroundColor: appTheme.fg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: _providers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final name = _providers[i];
            final bound = _bound.contains(name);
            return _ProviderCard(
              name: name,
              bound: bound,
              onToggle: () => setState(() {
                if (bound) {
                  _bound.remove(name);
                } else {
                  _bound.add(name);
                }
              }),
            );
          },
        ),
      ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.name,
    required this.bound,
    required this.onToggle,
  });

  final String name;
  final bool bound;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        border: Border.all(color: appTheme.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: appTheme.fg,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bound ? '已綁定' : '未綁定',
                  style: TextStyle(
                    fontSize: 12,
                    color: bound ? appTheme.success : appTheme.fgMuted,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onToggle,
            style: TextButton.styleFrom(
              foregroundColor: bound ? appTheme.fgMuted : accent,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              bound ? '解除綁定' : '綁定',
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
