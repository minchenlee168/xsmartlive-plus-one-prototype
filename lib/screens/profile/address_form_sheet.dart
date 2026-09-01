import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../theme/app_theme_extension.dart';

enum AddressFormType { home, pickup }

/// 開啟新增 / 編輯地址表單（底部彈出，全高、可捲動、自動避開鍵盤）。
/// 傳入 [editHome] / [editPickup] 即進入「編輯」模式並帶入既有資料。
Future<void> showAddressFormSheet(
  BuildContext context, {
  required AddressFormType type,
  HomeDeliveryAddress? editHome,
  StorePickupAddress? editPickup,
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
    builder: (_) => _AddressFormSheet(
      type: type,
      editHome: editHome,
      editPickup: editPickup,
    ),
  );
}

class _AddressFormSheet extends ConsumerStatefulWidget {
  const _AddressFormSheet({
    required this.type,
    this.editHome,
    this.editPickup,
  });
  final AddressFormType type;
  final HomeDeliveryAddress? editHome;
  final StorePickupAddress? editPickup;

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
  bool get _isEdit => widget.editHome != null || widget.editPickup != null;

  @override
  void initState() {
    super.initState();
    final h = widget.editHome;
    final p = widget.editPickup;
    if (h != null) {
      _nameCtrl.text = h.recipientName;
      _phoneCtrl.text = h.recipientPhone;
      if (_codes.contains(h.recipientPhoneCountryCode)) {
        _phoneCode = h.recipientPhoneCountryCode;
      }
      _cityCtrl.text = h.city;
      _districtCtrl.text = h.district;
      _addressCtrl.text = h.addressLine;
      _postalCtrl.text = h.postalCode;
      _isDefault = h.isDefault;
      _countryId = h.countryId;
    } else if (p != null) {
      _nameCtrl.text = p.recipientName;
      _phoneCtrl.text = p.recipientPhone;
      if (_codes.contains(p.recipientPhoneCountryCode)) {
        _phoneCode = p.recipientPhoneCountryCode;
      }
      if (p.pickupProvider.isNotEmpty) _brand = p.pickupProvider;
      _storeCodeCtrl.text = p.pickupStoreCode;
      _storeNameCtrl.text = p.pickupStoreName;
      _storeAddrCtrl.text = p.pickupStoreAddress;
      _isDefault = p.isDefault;
      _countryId = p.countryId;
    }
  }

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
    if (_isHome) {
      if (_cityCtrl.text.trim().isEmpty) return '請輸入縣市';
      if (_districtCtrl.text.trim().isEmpty) return '請輸入鄉鎮區';
      if (_addressCtrl.text.trim().isEmpty) return '請輸入詳細地址';
    } else {
      if (_storeNameCtrl.text.trim().isEmpty) return '請選擇取貨門市';
    }
    return null;
  }

  Future<void> _submit() async {
    final err = _validate();
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    // 編輯模式：後端尚未提供更新地址 API，prototype 以提示回饋（web 預覽的
    // 地址亦為範例資料、不可變）。真機接上 update API 後改走 update。
    if (_isEdit) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('地址已更新'), duration: Duration(seconds: 2)),
        );
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
              countryId: _countryId ?? 1,
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
              countryId: _countryId ?? 1,
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
                    _isHome
                        ? (_isEdit ? '編輯宅配地址' : '新增宅配地址')
                        : (_isEdit ? '編輯超商取貨門市' : '新增超商取貨門市'),
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
                    required: true,
                  ),
                  const SizedBox(height: 14),
                  // 國碼 + 電話
                  _Label('聯絡電話', required: true),
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

  List<Widget> _homeFields(AppThemeExtension appTheme) {
    final city = _cityCtrl.text;
    final districts = _twCityDistricts[city] ?? const <String>[];
    final districtValue =
        districts.contains(_districtCtrl.text) ? _districtCtrl.text : null;
    return [
      _Label('縣市'),
      const SizedBox(height: 6),
      _dropdownBox(
        appTheme: appTheme,
        value: city.isEmpty ? null : city,
        hint: '請選擇縣市',
        items: _twCityDistricts.keys.toList(),
        onChanged: (v) => setState(() {
          _cityCtrl.text = v ?? '';
          _districtCtrl.clear(); // 換縣市時清掉舊的鄉鎮區
        }),
      ),
      const SizedBox(height: 14),
      _Label('鄉鎮區'),
      const SizedBox(height: 6),
      _dropdownBox(
        appTheme: appTheme,
        value: districtValue,
        hint: city.isEmpty ? '請先選擇縣市' : '請選擇鄉鎮區',
        items: districts,
        onChanged: districts.isEmpty
            ? null
            : (v) => setState(() => _districtCtrl.text = v ?? ''),
      ),
      const SizedBox(height: 14),
      _LabeledField(
          label: '詳細地址', controller: _addressCtrl, hint: '例：中山二路 10 號'),
    ];
  }

  Widget _dropdownBox({
    required AppThemeExtension appTheme,
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Container(
      decoration: _boxDeco(appTheme),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint,
              style: TextStyle(fontSize: 14, color: appTheme.fgMuted)),
          onChanged: onChanged,
          style: TextStyle(fontSize: 14, color: appTheme.fg),
          dropdownColor: appTheme.bgElev,
          icon: Icon(Icons.keyboard_arrow_down, color: appTheme.fgMuted),
          items: [
            for (final it in items)
              DropdownMenuItem(value: it, child: Text(it)),
          ],
        ),
      ),
    );
  }

  /// 點選超商品牌 → 開啟電子地圖選門市 → 自動帶入門市代號 / 名稱 / 地址。
  Future<void> _openStoreMap(String brand) async {
    setState(() => _brand = brand);
    final store = await showModalBottomSheet<_PickedStore>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appTheme.bgElev,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.appTheme.sheetRadius),
        ),
      ),
      builder: (_) => _StoreMapPicker(brand: brand),
    );
    if (store == null || !mounted) return;
    setState(() {
      _storeCodeCtrl.text = store.code;
      _storeNameCtrl.text = store.name;
      _storeAddrCtrl.text = store.address;
      _error = null;
    });
  }

  List<Widget> _pickupFields(AppThemeExtension appTheme) {
    final selected = _storeNameCtrl.text.trim().isNotEmpty;
    return [
      _Label('選擇超商'),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: _BrandButton(
              brand: '7-11',
              label: '7-ELEVEN',
              color: appTheme.brandPalette.tone500,
              selected: _brand == '7-11',
              onTap: () => _openStoreMap('7-11'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _BrandButton(
              brand: '全家',
              label: '全家 FamilyMart',
              color: appTheme.brandPalette.tone500,
              selected: _brand == '全家',
              onTap: () => _openStoreMap('全家'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      // 選到門市後直接帶入（唯讀顯示，不需填寫）；未選則提示。
      if (selected)
        _SelectedStoreCard(
          brand: _brand,
          name: _storeNameCtrl.text,
          address: _storeAddrCtrl.text,
          onChange: () => _openStoreMap(_brand),
        )
      else
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: appTheme.bgSubtle,
            borderRadius: BorderRadius.circular(appTheme.radiusSm),
            border: Border.all(color: appTheme.divider),
          ),
          child: Row(
            children: [
              Icon(Icons.map_outlined, size: 18, color: appTheme.fgMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '請點選上方超商，於電子地圖選擇取貨門市',
                  style: TextStyle(fontSize: 13, color: appTheme.fgMuted),
                ),
              ),
            ],
          ),
        ),
    ];
  }

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
  const _Label(this.text, {this.required = false});
  final String text;
  final bool required;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final style = TextStyle(
      fontSize: 12,
      color: appTheme.fgMuted,
      fontWeight: FontWeight.w600,
    );
    if (!required) return Text(text, style: style);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text),
          TextSpan(
            text: ' *',
            style: TextStyle(color: appTheme.danger),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.hint,
    this.required = false,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label, required: required),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: appTheme.bg,
            borderRadius: BorderRadius.circular(appTheme.radiusSm),
            border: Border.all(color: appTheme.divider),
          ),
          child: TextField(
            controller: controller,
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

// ── 超商取貨：品牌選擇 + 電子地圖選門市 ─────────────────────────────────────
// 品牌按鈕會顯示 assets/icons/stores/ 下的 logo；未放置授權圖檔時 fallback
// 為主題色店面圖示（見 assets/icons/stores/README.md）。

/// 超商品牌對應的 logo 圖檔路徑。
String _brandAsset(String brand) => brand == '全家'
    ? 'assets/icons/stores/familymart.png'
    : 'assets/icons/stores/seven_eleven.png';

class _PickedStore {
  const _PickedStore({
    required this.code,
    required this.name,
    required this.address,
  });
  final String code;
  final String name;
  final String address;
}

const Map<String, List<_PickedStore>> _brandStores = {
  '7-11': [
    _PickedStore(
        code: '123456', name: '鑫工門市', address: '台北市大安區復興南路一段 200 號'),
    _PickedStore(
        code: '123457', name: '忠孝門市', address: '台北市大安區忠孝東路四段 45 號'),
    _PickedStore(
        code: '123458', name: '信義門市', address: '台北市信義區松高路 11 號'),
  ],
  '全家': [
    _PickedStore(
        code: '654321', name: '平鎮上海店', address: '新北市板橋區文化路二段 50 號'),
    _PickedStore(
        code: '654322', name: '大安文化店', address: '台北市大安區文化路一段 88 號'),
    _PickedStore(
        code: '654323', name: '信義松德店', address: '台北市信義區松德路 300 號'),
  ],
};

class _BrandButton extends StatelessWidget {
  const _BrandButton({
    required this.brand,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String brand;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(appTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : appTheme.bgElev,
          borderRadius: BorderRadius.circular(appTheme.radiusSm),
          border: Border.all(
            color: selected ? color : appTheme.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              // 顯示超商 logo（assets/icons/stores/）；未放置圖檔時 fallback
              // 為主題色店面圖示。
              child: Image.asset(
                _brandAsset(brand),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Container(
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.storefront, size: 18, color: color),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? color : appTheme.fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedStoreCard extends StatelessWidget {
  const _SelectedStoreCard({
    required this.brand,
    required this.name,
    required this.address,
    required this.onChange,
  });

  final String brand;
  final String name;
  final String address;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final color = appTheme.brandPalette.tone500;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
        border: Border.all(color: color),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.place, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$brand · $name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: appTheme.fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: TextStyle(fontSize: 12, color: appTheme.fgMuted),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            style: TextButton.styleFrom(
              foregroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('重新選擇', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _StoreMapPicker extends StatelessWidget {
  const _StoreMapPicker({required this.brand});
  final String brand;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final color = appTheme.brandPalette.tone500;
    final stores = _brandStores[brand] ?? const <_PickedStore>[];
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  Icon(Icons.storefront, size: 20, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$brand 取貨門市',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: appTheme.fg,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 22, color: appTheme.fgMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // 電子地圖（prototype 佔位）—— 真機接超商電子地圖 WebView / SDK。
            Container(
              height: 150,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              decoration: BoxDecoration(
                color: appTheme.bgSubtle,
                borderRadius: BorderRadius.circular(appTheme.radiusSm),
                border: Border.all(color: appTheme.divider),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 40, color: color),
                  const SizedBox(height: 8),
                  Text(
                    '電子地圖',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: appTheme.fg,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '點選下方門市即完成選擇',
                    style: TextStyle(fontSize: 12, color: appTheme.fgMuted),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: stores.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: appTheme.divider),
                itemBuilder: (context, i) {
                  final s = stores[i];
                  return InkWell(
                    onTap: () => Navigator.of(context).pop(s),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.place_outlined, size: 18, color: color),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: appTheme.fg,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  s.address,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: appTheme.fgMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              size: 18, color: appTheme.fgMuted),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 台灣縣市 → 鄉鎮區（宅配地址下拉用；prototype 涵蓋主要縣市）──────────────
const Map<String, List<String>> _twCityDistricts = {
  '台北市': [
    '中正區', '大同區', '中山區', '松山區', '大安區', '萬華區',
    '信義區', '士林區', '北投區', '內湖區', '南港區', '文山區',
  ],
  '新北市': [
    '板橋區', '三重區', '中和區', '永和區', '新莊區', '新店區',
    '土城區', '蘆洲區', '樹林區', '汐止區', '三峽區', '鶯歌區',
    '淡水區', '林口區', '五股區', '泰山區',
  ],
  '桃園市': [
    '桃園區', '中壢區', '平鎮區', '八德區', '楊梅區', '蘆竹區',
    '龜山區', '大溪區', '大園區', '龍潭區', '觀音區', '新屋區',
  ],
  '台中市': [
    '中區', '東區', '南區', '西區', '北區', '北屯區', '西屯區',
    '南屯區', '太平區', '大里區', '霧峰區', '烏日區', '豐原區', '后里區',
  ],
  '台南市': [
    '中西區', '東區', '南區', '北區', '安平區', '安南區',
    '永康區', '歸仁區', '新化區', '善化區', '仁德區',
  ],
  '高雄市': [
    '楠梓區', '左營區', '鼓山區', '三民區', '苓雅區', '新興區',
    '前金區', '鹽埕區', '前鎮區', '旗津區', '小港區', '鳳山區',
    '大寮區', '鳥松區', '仁武區',
  ],
  '基隆市': [
    '中正區', '七堵區', '暖暖區', '仁愛區', '中山區', '安樂區', '信義區',
  ],
  '新竹市': ['東區', '北區', '香山區'],
};
