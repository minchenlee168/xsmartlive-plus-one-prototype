import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/bonus_provider.dart';
import '../../theme/app_theme_extension.dart';

/// 紅利點數畫面 —— 由「我的」頁點按「紅利」進入。
///
/// 版面（由上而下）對照設計稿：
///   1. 目前可使用紅利點數（大數字）+「立即使用」按鈕
///   2. 即將到期（30天內）
///   3. 紅利點數使用紀錄：全部明細 / 獲得紀錄 / 扣抵紀錄 三個過濾分頁 + 明細列表
///
/// 視覺一律走 Theme token（`context.appTheme.*` 與 colorScheme），不硬寫顏色。
class BonusScreen extends ConsumerStatefulWidget {
  const BonusScreen({super.key});

  @override
  ConsumerState<BonusScreen> createState() => _BonusScreenState();
}

enum _BonusFilter { all, earning, usage }

class _BonusScreenState extends ConsumerState<BonusScreen> {
  _BonusFilter _filter = _BonusFilter.all;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final overviewAsync = ref.watch(bonusOverviewProvider);

    return Scaffold(
      backgroundColor: appTheme.bg,
      appBar: AppBar(
        title: const Text('紅利點數'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appTheme.primaryGradient),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
      ),
      body: overviewAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Text(
            '載入失敗，請稍後再試',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        data: (overview) {
          final entries = overview.entries.where((e) {
            switch (_filter) {
              case _BonusFilter.all:
                return true;
              case _BonusFilter.earning:
                return e.isEarning;
              case _BonusFilter.usage:
                return !e.isEarning;
            }
          }).toList(growable: false);

          return ListView(
            padding: EdgeInsets.all(appTheme.spacingLg),
            children: [
              _AvailableCard(points: overview.availablePoints),
              SizedBox(height: appTheme.spacingMd),
              _ExpiringCard(points: overview.expiringPoints),
              SizedBox(height: appTheme.spacingMd),
              _HistoryCard(
                filter: _filter,
                onFilterChanged: (f) => setState(() => _filter = f),
                entries: entries,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── 共用：白色圓角卡片外殼 ────────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(appTheme.spacingXl),
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        border: Border.all(color: appTheme.divider),
        boxShadow: appTheme.elevation1,
      ),
      child: child,
    );
  }
}

// ── 目前可使用紅利點數 + 立即使用 ─────────────────────────────────────────
class _AvailableCard extends StatelessWidget {
  const _AvailableCard({required this.points});
  final double points;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '目前可使用紅利點數',
                  style: TextStyle(fontSize: 13, color: appTheme.fgMuted),
                ),
                SizedBox(height: appTheme.spacingSm),
                Text(
                  _fmt(points),
                  style: GoogleFonts.getFont(
                    appTheme.fontDisplay,
                    textStyle: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: appTheme.brandPalette.tone500,
                      height: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: appTheme.spacingMd),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('紅利點數可於結帳時折抵')),
                );
            },
            style: FilledButton.styleFrom(
              backgroundColor: appTheme.brandPalette.tone500,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: appTheme.spacingXl,
                vertical: appTheme.spacingMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(appTheme.buttonRadius),
              ),
            ),
            child: const Text(
              '立即使用',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 即將到期（30天內）─────────────────────────────────────────────────────
class _ExpiringCard extends StatelessWidget {
  const _ExpiringCard({required this.points});
  final double points;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '即將到期 (30天內)',
            style: TextStyle(fontSize: 13, color: appTheme.fgMuted),
          ),
          SizedBox(height: appTheme.spacingSm),
          Text(
            _fmt(points),
            style: GoogleFonts.getFont(
              appTheme.fontDisplay,
              textStyle: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: appTheme.fg,
                height: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 紅利點數使用紀錄 ──────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.filter,
    required this.onFilterChanged,
    required this.entries,
  });

  final _BonusFilter filter;
  final ValueChanged<_BonusFilter> onFilterChanged;
  final List<BonusEntry> entries;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return _Card(
      padding: EdgeInsets.symmetric(
        horizontal: appTheme.spacingXl,
        vertical: appTheme.spacingLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '紅利點數使用紀錄',
            style: GoogleFonts.getFont(
              appTheme.fontDisplay,
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: appTheme.fontWeightDisplay,
                color: appTheme.fg,
              ),
            ),
          ),
          SizedBox(height: appTheme.spacingMd),
          Row(
            children: [
              _FilterTab(
                label: '全部明細',
                selected: filter == _BonusFilter.all,
                onTap: () => onFilterChanged(_BonusFilter.all),
              ),
              SizedBox(width: appTheme.spacingXl),
              _FilterTab(
                label: '獲得紀錄',
                selected: filter == _BonusFilter.earning,
                onTap: () => onFilterChanged(_BonusFilter.earning),
              ),
              SizedBox(width: appTheme.spacingXl),
              _FilterTab(
                label: '扣抵紀錄',
                selected: filter == _BonusFilter.usage,
                onTap: () => onFilterChanged(_BonusFilter.usage),
              ),
            ],
          ),
          SizedBox(height: appTheme.spacingXs),
          Divider(height: 1, color: appTheme.divider),
          if (entries.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: appTheme.spacingXxl),
              child: Center(
                child: Text(
                  '尚無紀錄',
                  style: TextStyle(color: appTheme.fgMuted),
                ),
              ),
            )
          else
            for (var i = 0; i < entries.length; i++) ...[
              _HistoryRow(entry: entries[i]),
              if (i < entries.length - 1)
                Divider(height: 1, color: appTheme.divider),
            ],
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
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
    final color = selected ? appTheme.brandPalette.tone500 : appTheme.fgMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: appTheme.spacingSm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
            SizedBox(height: appTheme.spacingSm),
            Container(
              height: 2,
              width: 28,
              decoration: BoxDecoration(
                color: selected ? color : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry});
  final BonusEntry entry;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final isEarning = entry.isEarning;
    final amountColor = isEarning ? appTheme.success : appTheme.fg;
    final sign = isEarning ? '+' : '-';
    final amountText = '$sign ${_fmt(entry.amount.abs())}';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: appTheme.spacingLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左側圓形圖示：獲得為綠底↙、扣抵為灰底↗
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isEarning
                  ? appTheme.success.withValues(alpha: 0.14)
                  : appTheme.bgSubtle,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isEarning ? Icons.south_west : Icons.north_east,
              size: 18,
              color: isEarning ? appTheme.success : appTheme.fgMuted,
            ),
          ),
          SizedBox(width: appTheme.spacingMd),
          // 中段：標題 + 時間 + 有效期限
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: appTheme.fg,
                  ),
                ),
                SizedBox(height: appTheme.spacingSm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: appTheme.fgMuted),
                    SizedBox(width: appTheme.spacingXs),
                    Flexible(
                      child: Text(
                        entry.dateText,
                        style: TextStyle(
                          fontSize: 12,
                          color: appTheme.fgMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                // 有效期限放在使用時間下方，左緣對齊上方月曆 icon。
                if (entry.expiryText != null) ...[
                  SizedBox(height: appTheme.spacingXs),
                  Text(
                    entry.expiryText!,
                    style: TextStyle(
                      fontSize: 12,
                      color: appTheme.fgMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: appTheme.spacingSm),
          // 右側：金額 + 狀態
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amountText,
                style: GoogleFonts.getFont(
                  appTheme.fontDisplay,
                  textStyle: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
              ),
              SizedBox(height: appTheme.spacingSm),
              Text(
                entry.statusText,
                style: TextStyle(fontSize: 12, color: appTheme.fgMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 數字格式：固定兩位小數（312 → 312.00）────────────────────────────────
String _fmt(double v) => v.toStringAsFixed(2);
