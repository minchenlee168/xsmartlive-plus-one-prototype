import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../theme/app_theme_extension.dart';

enum AddressFormType { home, pickup }

/// 開啟新增地址表單（底部彈出，全高、可捲動、自動避開鍵盤）。
Future<void> showAddressFormSheet(
  BuildContext context, {
  required AddressFormType type,
}) {
  final appTheme = context.appTheme;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: appTheme.bgElev,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(appTheme.sheetRadius),
      ),
    ),
    builder: (_) => _AddressFormSheet(type: type),
  );
}

class _AddressFormSheet extends ConsumerStatefulWidget {
  const _AddressFormSheet({required this.type});
  final AddressFormType type;

  @override
  ConsumerState<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends ConsumerState<_AddressFormSheet> {
  // 共同欄位
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  static const _codes = ['+886', '+852', '+86', '+81', '+82', '+65', '+1'];
  String _phoneCode = '+886';
  int? _countryId;
  bool _isDefault = false;

  // 宅配欄位
  final _cityCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();

  // 超商欄位
  String _brand = '7-11';
  final _storeCodeCtrl = TextEditingController();
  final _storeNameCtrl = TextEditingController();
  final _storeAddrCtrl = TextEditingController();

  bool _busy = false;
  String? _error;

  bool get _isHome => widget.type == AddressFormType.home;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _addressCtrl.dispose();
    _postalCtrl.dispose();
    _storeCodeCtrl.dispose();
    _storeNameCtrl.dispose();
    _storeAddrCtrl.dispose();
    super.dispose();
  }

  String? _validate() {
    if (_nameCtrl.text.trim().isEmpty) return '請輸入收件人姓名';
    if (_phoneCtrl.text.trim().isEmpty) return '請輸入聯絡電話';
    if (_countryId == null) return '請選擇國家／地區';
    if (_isHome) {
      if (_cityCtrl.text.trim().isEmpty) return '請輸入縣市';
      if (_districtCtrl.text.trim().isEmpty) return '請輸入鄉鎮區';
      if (_addressCtrl.text.trim().isEmpty) return '請輸入詳細地址';
    } else {
      if (_storeCodeCtrl.text.trim().isEmpty) return '請輸入門市代號';
      if (_storeNameCtrl.text.trim().isEmpty) return '請輸入門市名稱';
      if (_storeAddrCtrl.text.trim().isEmpty) return '請輸入門市地址';
    }
    return null;
  }

  Future<void> _submit() async {
    final err = _validate();
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (_isHome) {
        await ref.read(homeDeliveryAddressesProvider.notifier).create(
              recipientName: _nameCtrl.text.trim(),
              recipientPhoneCountryCode: _phoneCode,
              recipientPhone: _phoneCtrl.text.trim(),
              countryId: _countryId!,
              city: _cityCtrl.text.trim(),
              district: _districtCtrl.text.trim(),
              addressLine: _addressCtrl.text.trim(),
              postalCode: _postalCtrl.text.trim().isEmpty
                  ? null
                  : _postalCtrl.text.trim(),
              isDefault: _isDefault,
            );
      } else {
        await ref.read(storePickupAddressesProvider.notifier).create(
              recipientName: _nameCtrl.text.trim(),
              recipientPhoneCountryCode: _phoneCode,
              recipientPhone: _phoneCtrl.text.trim(),
              countryId: _countryId!,
              pickupProvider: _brand,
              pickupStoreCode: _storeCodeCtrl.text.trim(),
              pickupStoreName: _storeNameCtrl.text.trim(),
              pickupStoreAddress: _storeAddrCtrl.text.trim(),
              isDefault: _isDefault,
            );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('地址已新增'), duration: Duration(seconds: 2)),
      );
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString();
      final colon = raw.indexOf(':');
      setState(() =>
          _error = colon != -1 ? raw.substring(colon + 1).trim() : raw);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxH = MediaQuery.of(context).size.height * 0.9;
    final countriesAsync = ref.watch(
      _isHome ? homeDeliveryCountriesProvider : storePickupCountriesProvider,
    );
    final countries = countriesAsync.valueOrNull ?? const <AddressCountry>[];

    // 國家清單載入後預設第一筆（通常為台灣）。
    if (_countryId == null && countries.isNotEmpty) {
      _countryId = countries.first.countryId;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖曳握把 + 標題
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: appTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Row(
                children: [
                  Text(
                    _isHome ? '新增宅配地址' : '新增超商取貨門市',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: appTheme.fg,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close, color: appTheme.fgMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                children: [
                  _LabeledField(
                    label: '收件人姓名',
                    controller: _nameCtrl,
                    hint: '請輸入收件人姓名',
                  ),
                  const SizedBox(height: 14),
                  // 國碼 + 電話
                  _Label('聯絡電話'),
                  const SizedBox(height: 6),
                  Container(
                    decoration: _boxDeco(appTheme),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12, right: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _phoneCode,
                              items: _codes
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: appTheme.fg)),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _phoneCode = v);
                              },
                            ),
                          ),
                        ),
                        Container(
                            width: 1, height: 24, color: appTheme.divider),
                        Expanded(
                          child: TextField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            style:
                                TextStyle(fontSize: 14, color: appTheme.fg),
                            decoration: _innerDeco(appTheme, '請輸入電話'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // 國家／地區
                  _Label('國家／地區'),
                  const SizedBox(height: 6),
                  Container(
                    decoration: _boxDeco(appTheme),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _countryId,
                        hint: Text('請選擇',
                            style: TextStyle(
                                fontSize: 14, color: appTheme.fgMuted)),
                        items: countries
                            .map((c) => DropdownMenuItem(
                                  value: c.countryId,
                                  child: Text(c.countryName,
                                      style: TextStyle(
                                          fontSize: 14, color: appTheme.fg)),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _countryId = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // 類型專屬欄位
                  if (_isHome) ..._homeFields(appTheme) else ..._pickupFields(appTheme),
                  const SizedBox(height: 16),
                  // 設為預設
                  Row(
                    children: [
                      Text('設為預設地址',
                          style:
                              TextStyle(fontSize: 14, color: appTheme.fg)),
                      const Spacer(),
                      Switch(
                        value: _isDefault,
                        activeThumbColor: accent,
                        onChanged: (v) => setState(() => _isDefault = v),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!,
                        style:
                            TextStyle(color: appTheme.danger, fontSize: 12)),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(appTheme.buttonRadius),
                        ),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('儲存',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _homeFields(AppThemeExtension appTheme) => [
        _LabeledField(label: '縣市', controller: _cityCtrl, hint: '例：高雄市'),
        const SizedBox(height: 14),
        _LabeledField(
            label: '鄉鎮區', controller: _districtCtrl, hint: '例：前鎮區'),
        const SizedBox(height: 14),
        _LabeledField(
            label: '詳細地址', controller: _addressCtrl, hint: '例：中山二路 10 號'),
        const SizedBox(height: 14),
        _LabeledField(
            label: '郵遞區號（選填）',
            controller: _postalCtrl,
            hint: '例：806',
            keyboardType: TextInputType.number),
      ];

  List<Widget> _pickupFields(AppThemeExtension appTheme) => [
        _Label('取貨品牌'),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final b in const ['7-11', '全家'])
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(b),
                  selected: _brand == b,
                  onSelected: (_) => setState(() => _brand = b),
                  selectedColor:
                      appTheme.brandPalette.tone500.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        _brand == b ? FontWeight.w700 : FontWeight.w500,
                    color: _brand == b
                        ? appTheme.brandPalette.tone500
                        : appTheme.fg,
                  ),
                  backgroundColor: appTheme.bgSubtle,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(appTheme.chipRadius),
                    side: BorderSide(
                      color: _brand == b
                          ? appTheme.brandPalette.tone500
                          : appTheme.divider,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        _LabeledField(
            label: '門市代號', controller: _storeCodeCtrl, hint: '例：100002'),
        const SizedBox(height: 14),
        _LabeledField(
            label: '門市名稱', controller: _storeNameCtrl, hint: '例：前鎮門市'),
        const SizedBox(height: 14),
        _LabeledField(
            label: '門市地址',
            controller: _storeAddrCtrl,
            hint: '例：高雄市前鎮區中山二路 2 號'),
      ];

  static BoxDecoration _boxDeco(AppThemeExtension t) => BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.circular(t.radiusSm),
        border: Border.all(color: t.divider),
      );

  static InputDecoration _innerDeco(AppThemeExtension t, String hint) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: t.fgMuted),
        border: InputBorder.none,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
}

// ── 共用欄位元件 ─────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: appTheme.fgMuted,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: appTheme.bg,
            borderRadius: BorderRadius.circular(appTheme.radiusSm),
            border: Border.all(color: appTheme.divider),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 14, color: appTheme.fg),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 12, color: appTheme.fgMuted),
              border: InputBorder.none,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
