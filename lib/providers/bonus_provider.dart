import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bonus.dart';
import '../utils/platform_preview.dart';
import 'repository_providers.dart';

/// 紅利點數畫面用的顯示型別 —— 把後端的 [BonusBalance] / [BonusHistory]
/// 攤平成畫面直接渲染的欄位。之所以另立 view-model 而非直接吃 model：
///   • 後端 history 沒有「有效期限 / 已入帳·已使用」這類展示文字，需在此補上。
///   • 預覽（web 未登入）打不到需要授權的 `/bonus/*`，改回傳與設計稿一致的
///     範例資料，讓 prototype 畫面永遠有內容可看（與 README 描述的
///     「購物車以純前端模擬」同一種預覽策略）。
enum BonusEntryKind { earning, usage }

class BonusEntry {
  const BonusEntry({
    required this.kind,
    required this.title,
    required this.dateText,
    required this.expiryText,
    required this.amount,
    required this.statusText,
  });

  final BonusEntryKind kind;
  final String title;

  /// 發生時間，已格式化為 `yyyy.MM.dd HH:mm`。
  final String dateText;

  /// 「有效期限至 …」整串文字；無到期概念時為 null。
  final String? expiryText;

  /// 帶正負號的點數變動（獲得為正、扣抵為負）。
  final double amount;

  /// 狀態文字，例如「已入帳」「已使用」。
  final String statusText;

  bool get isEarning => kind == BonusEntryKind.earning;
}

class BonusOverview {
  const BonusOverview({
    required this.availablePoints,
    required this.expiringPoints,
    required this.entries,
  });

  final double availablePoints;
  final double expiringPoints;
  final List<BonusEntry> entries;
}

/// 紅利點數總覽（餘額 + 即將到期 + 使用紀錄）。
///
/// 先嘗試真實 API；任何失敗（含 web 預覽未登入的 401）或空資料，
/// 都回退到設計稿範例資料，確保畫面永遠可預覽。
final bonusOverviewProvider = FutureProvider<BonusOverview>((ref) async {
  // Web 預覽（無登入 / 打不到 /bonus）直接用範例資料，避免在 release build
  // 因請求 pending 而卡在載入。
  if (isWebPreview) return _sampleOverview;
  try {
    final repo = ref.watch(bonusRepositoryProvider);
    final balance = await repo.fetchBalance();
    final history = await repo.fetchHistory(pageSize: 50);
    if (history.isEmpty) return _sampleOverview;
    return BonusOverview(
      availablePoints: balance.pointBalance.toDouble(),
      expiringPoints: double.tryParse(balance.expiringPoints) ?? 0,
      entries: history.map(_mapEntry).toList(growable: false),
    );
  } catch (_) {
    return _sampleOverview;
  }
});

BonusEntry _mapEntry(BonusHistory h) => BonusEntry(
      kind: h.isEarning ? BonusEntryKind.earning : BonusEntryKind.usage,
      title: (h.note != null && h.note!.isNotEmpty)
          ? h.note!
          : (h.isEarning ? '紅利點數贈送' : '訂單折抵'),
      dateText: _formatDateTime(h.createdAt),
      expiryText: null,
      amount: h.pointAmount.toDouble(),
      statusText: h.isEarning ? '已入帳' : '已使用',
    );

/// ISO 8601 / `yyyy-MM-dd HH:mm:ss` → `yyyy.MM.dd HH:mm`。
String _formatDateTime(String raw) {
  final dt = DateTime.tryParse(raw);
  if (dt == null) return raw;
  final local = dt.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}.${two(local.month)}.${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}

/// 設計稿範例資料（未登入 / 預覽時使用）。
const BonusOverview _sampleOverview = BonusOverview(
  availablePoints: 312.00,
  expiringPoints: 20.00,
  entries: [
    BonusEntry(
      kind: BonusEntryKind.earning,
      title: '雙 11 限時活動贈送',
      dateText: '2025.11.11 21:00',
      expiryText: '有效期限至 2026.05.11 23:59',
      amount: 12.00,
      statusText: '已入帳',
    ),
    BonusEntry(
      kind: BonusEntryKind.usage,
      title: '訂單編號10002132132 折抵',
      dateText: '2026.01.20 23:00',
      expiryText: '有效期限至 2026.07.20 23:59',
      amount: -200.00,
      statusText: '已使用',
    ),
    BonusEntry(
      kind: BonusEntryKind.earning,
      title: '會員生日',
      dateText: '2026.03.01 20:00',
      expiryText: '有效期限至 2026.03.31 24:00',
      amount: 300.00,
      statusText: '已入帳',
    ),
  ],
);
