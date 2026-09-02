import 'package:flutter/material.dart';

import '../../theme/app_theme_extension.dart';
import 'combo_data.dart';

/// 呈現模式：[sheet] 為商品卡加入購物車的彈窗；[page] 為商品內頁的組合挑選。
enum ComboMode { sheet, page }

/// 已挑選的一筆（同商品同規格會合併累加數量）。
class ComboPick {
  ComboPick({required this.item, required this.spec, required this.qty});
  final ComboItem item;
  final String spec;
  int qty;
}

/// 任選組合挑選器：商品池（規格 + 數量 + 挑選）、已選摘要、進度、加入購物車。
/// 彈窗（#36）與內頁（#37）共用同一份挑選邏輯，僅版面不同。
class ComboPicker extends StatefulWidget {
  const ComboPicker({super.key, required this.config, required this.mode});

  final ComboConfig config;
  final ComboMode mode;

  @override
  State<ComboPicker> createState() => _ComboPickerState();
}

class _ComboPickerState extends State<ComboPicker> {
  int _sets = 1;
  final Map<String, String> _specSel = {};
  final Map<String, int> _qtySel = {};
  final List<ComboPick> _picks = [];

  ComboConfig get _cfg => widget.config;

  String _spec(ComboItem it) =>
      _specSel[it.id] ?? (it.specs.isNotEmpty ? it.specs.first : '');
  int _qty(ComboItem it) => _qtySel[it.id] ?? 1;

  int get _totalPicked => _picks.fold(0, (s, p) => s + p.qty);
  int get _remaining => _cfg.pickCount - _totalPicked;
  int _committedFor(ComboItem it) =>
      _picks.where((p) => p.item.id == it.id).fold(0, (s, p) => s + p.qty);

  void _pick(ComboItem it) {
    final spec = _spec(it);
    final want = _qty(it);
    final byLimit = it.limit - _committedFor(it);
    final add = [want, byLimit, _remaining].reduce((a, b) => a < b ? a : b);
    if (add <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(byLimit <= 0
                ? '「${it.name}」已達限購 ${it.limit} 個'
                : '已達需挑選件數')));
      return;
    }
    setState(() {
      final existing = _picks
          .where((p) => p.item.id == it.id && p.spec == spec)
          .cast<ComboPick?>()
          .firstWhere((_) => true, orElse: () => null);
      if (existing != null) {
        existing.qty += add;
      } else {
        _picks.add(ComboPick(item: it, spec: spec, qty: add));
      }
    });
  }

  void _removePick(int i) => setState(() => _picks.removeAt(i));

  void _addToCart() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text('已加入購物車：${_cfg.name} ×$_sets 組')));
    if (widget.mode == ComboMode.sheet) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final complete = _remaining == 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 標題列 ──
        if (widget.mode == ComboMode.page)
          _pageHeader(appTheme, accent)
        else
          _sheetHeader(appTheme, accent),
        // ── 已選摘要 ──
        if (_picks.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                for (var i = 0; i < _picks.length; i++)
                  _summaryRow(appTheme, _picks[i], i),
              ],
            ),
          ),
        // ── 商品池 ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: LayoutBuilder(
            builder: (context, c) {
              if (widget.mode == ComboMode.sheet) {
                return Column(
                  children: [
                    for (final it in _cfg.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _itemCard(appTheme, accent, it, dense: true),
                      ),
                  ],
                );
              }
              const spacing = 12.0;
              final cols = (c.maxWidth / 190).floor().clamp(2, 4);
              final w = (c.maxWidth - spacing * (cols - 1)) / cols;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final it in _cfg.items)
                    SizedBox(
                        width: w,
                        child: _itemCard(appTheme, accent, it, dense: false)),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // ── 進度 + 加入購物車 ──
        Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12 + MediaQuery.of(context).viewPadding.bottom,
          ),
          decoration: BoxDecoration(
            color: appTheme.bgElev,
            border: Border(top: BorderSide(color: appTheme.divider)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                complete
                    ? '已挑選 $_totalPicked 件，可加入購物車'
                    : '請挑選並加入規格，已挑選 $_totalPicked 件，剩餘 $_remaining 件',
                style: TextStyle(
                    fontSize: 12,
                    color: complete ? appTheme.success : accent),
              ),
              const SizedBox(height: 4),
              Text(
                _picks.isEmpty
                    ? '尚未挑選任何內容'
                    : '已選內容 $_totalPicked/${_cfg.pickCount}',
                style: TextStyle(fontSize: 12, color: appTheme.fgMuted),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 46,
                child: FilledButton(
                  onPressed: complete ? _addToCart : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    disabledBackgroundColor: accent.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(appTheme.buttonRadius),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text('加入購物車',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 標題：彈窗（#36）──
  Widget _sheetHeader(AppThemeExtension appTheme, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('請選擇 ${_cfg.pickCount} 件商品',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: appTheme.fg)),
              ),
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.close, size: 20, color: appTheme.fgMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _thumb(appTheme, 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_cfg.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: appTheme.fg)),
                    const SizedBox(height: 4),
                    Text('NT\$${_cfg.price}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: accent)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('數量',
                  style: TextStyle(fontSize: 13, color: appTheme.fg)),
              const SizedBox(width: 16),
              _stepper(
                appTheme,
                value: _sets,
                onMinus: _sets > 1 ? () => setState(() => _sets--) : null,
                onPlus: () => setState(() => _sets++),
              ),
              const SizedBox(width: 8),
              Text('組', style: TextStyle(fontSize: 13, color: appTheme.fg)),
            ],
          ),
          const SizedBox(height: 14),
          Text('選擇商品',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: appTheme.fg)),
        ],
      ),
    );
  }

  // ── 標題：內頁（#37）──
  Widget _pageHeader(AppThemeExtension appTheme, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: accent.withValues(alpha: 0.08),
      child: Row(
        children: [
          Expanded(
            child: Text('商品組合（請選擇 ${_cfg.pickCount} 件商品）',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: appTheme.fg)),
          ),
          Text('已選 $_totalPicked / ${_cfg.pickCount}',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: accent)),
        ],
      ),
    );
  }

  Widget _summaryRow(AppThemeExtension appTheme, ComboPick p, int i) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: appTheme.bgSubtle,
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.item.name,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: appTheme.fg)),
                const SizedBox(height: 2),
                Text('${p.spec} ×${p.qty}',
                    style:
                        TextStyle(fontSize: 12, color: appTheme.fgMuted)),
              ],
            ),
          ),
          InkWell(
            onTap: () => _removePick(i),
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(Icons.close, size: 18, color: appTheme.fgMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(AppThemeExtension appTheme, Color accent, ComboItem it,
      {required bool dense}) {
    final specField = _specDropdown(appTheme, it);
    final qtyStepper = _stepper(
      appTheme,
      value: _qty(it),
      onMinus: _qty(it) > 1
          ? () => setState(() => _qtySel[it.id] = _qty(it) - 1)
          : null,
      onPlus: _qty(it) < it.limit
          ? () => setState(() => _qtySel[it.id] = _qty(it) + 1)
          : null,
    );
    final pickBtn = FilledButton(
      onPressed: () => _pick(it),
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: const Size(0, 34),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(appTheme.buttonRadius)),
      ),
      child: const Text('挑選',
          style: TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
    );

    if (dense) {
      // 彈窗（#36）：橫向列
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: appTheme.bgSubtle,
          borderRadius: BorderRadius.circular(appTheme.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _thumb(appTheme, 48),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(it.name,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: appTheme.fg)),
                      const SizedBox(height: 2),
                      Text('限購 ${it.limit} 個',
                          style: TextStyle(
                              fontSize: 11, color: appTheme.danger)),
                    ],
                  ),
                ),
                pickBtn,
              ],
            ),
            const SizedBox(height: 10),
            Row(children: [
              SizedBox(width: 40, child: Text('規格',
                  style: TextStyle(fontSize: 12, color: appTheme.fgMuted))),
              Expanded(child: specField),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              SizedBox(width: 40, child: Text('數量',
                  style: TextStyle(fontSize: 12, color: appTheme.fgMuted))),
              qtyStepper,
            ]),
          ],
        ),
      );
    }

    // 內頁（#37）：直式卡
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        border: Border.all(color: appTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: _thumb(appTheme, null),
          ),
          const SizedBox(height: 8),
          Text(it.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: appTheme.fg)),
          const SizedBox(height: 2),
          Text('限購 ${it.limit} 個',
              style: TextStyle(fontSize: 11, color: appTheme.danger)),
          const SizedBox(height: 8),
          Row(children: [
            SizedBox(width: 32, child: Text('規格',
                style: TextStyle(fontSize: 12, color: appTheme.fgMuted))),
            Expanded(child: specField),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            SizedBox(width: 32, child: Text('數量',
                style: TextStyle(fontSize: 12, color: appTheme.fgMuted))),
            qtyStepper,
          ]),
          const SizedBox(height: 8),
          SizedBox(height: 34, child: pickBtn),
        ],
      ),
    );
  }

  Widget _specDropdown(AppThemeExtension appTheme, ComboItem it) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
        border: Border.all(color: appTheme.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          isDense: true,
          value: _spec(it),
          icon: Icon(Icons.keyboard_arrow_down,
              size: 18, color: appTheme.fgMuted),
          style: TextStyle(fontSize: 13, color: appTheme.fg),
          dropdownColor: appTheme.bgElev,
          items: [
            for (final s in it.specs)
              DropdownMenuItem(value: s, child: Text(s)),
          ],
          onChanged: (v) =>
              setState(() => _specSel[it.id] = v ?? _spec(it)),
        ),
      ),
    );
  }

  Widget _stepper(AppThemeExtension appTheme,
      {required int value,
      required VoidCallback? onMinus,
      required VoidCallback? onPlus}) {
    Widget btn(IconData icon, VoidCallback? onTap) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(appTheme.radiusSm),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: appTheme.bgElev,
              borderRadius: BorderRadius.circular(appTheme.radiusSm),
              border: Border.all(color: appTheme.divider),
            ),
            alignment: Alignment.center,
            child: Icon(icon,
                size: 15,
                color: onTap == null ? appTheme.muted : appTheme.fg),
          ),
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        btn(Icons.remove, onMinus),
        Container(
          constraints: const BoxConstraints(minWidth: 36),
          alignment: Alignment.center,
          child: Text('$value',
              style: TextStyle(fontSize: 13, color: appTheme.fg)),
        ),
        btn(Icons.add, onPlus),
      ],
    );
  }

  /// 圖片佔位（prototype）。size 為 null 時填滿父層。
  Widget _thumb(AppThemeExtension appTheme, double? size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: appTheme.bgSubtle,
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined,
          size: size == null ? 30 : 20, color: appTheme.fgMuted),
    );
  }
}

/// 顯示任選組合挑選彈窗（#36）。
Future<void> showComboSheet(BuildContext context, ComboConfig config) {
  final appTheme = context.appTheme;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: appTheme.bgElev,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollCtrl) => SingleChildScrollView(
        controller: scrollCtrl,
        child: ComboPicker(config: config, mode: ComboMode.sheet),
      ),
    ),
  );
}
