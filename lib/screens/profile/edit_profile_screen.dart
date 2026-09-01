import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/profile_provider.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/platform_preview.dart';

/// 編輯個人資料 — 姓名 / 性別 / 生日 / Email。
///
/// 登入時預填會員資料並透過 [MemberProfileNotifier.updateProfile] 儲存；
/// web 預覽（未登入）改用範例資料，儲存僅提示成功（對齊 prototype 策略）。
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  int? _gender;
  String? _birthday;
  bool _busy = false;
  String? _error;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  /// 以會員資料（或 web 範例）預填一次表單。
  void _seed() {
    if (_seeded) return;
    final profile = ref.read(memberProfileProvider).valueOrNull;
    if (profile != null) {
      _nameCtrl.text = profile.name;
      _emailCtrl.text = profile.email ?? '';
      _gender = profile.gender;
      _birthday = profile.birthday;
      _seeded = true;
    } else if (isWebPreview) {
      _nameCtrl.text = '測試會員A';
      _emailCtrl.text = 'abc0123@gmail.com';
      _gender = 1;
      _birthday = '1997-08-12';
      _seeded = true;
    }
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final initial =
        DateTime.tryParse(_birthday ?? '') ?? DateTime(now.year - 25);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() {
      _birthday = '${picked.year.toString().padLeft(4, '0')}-'
          '${picked.month.toString().padLeft(2, '0')}-'
          '${picked.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = '請輸入姓名');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (!isWebPreview) {
        await ref.read(memberProfileProvider.notifier).updateProfile(
              name: _nameCtrl.text.trim(),
              email: _emailCtrl.text.trim().isEmpty
                  ? null
                  : _emailCtrl.text.trim(),
              gender: _gender,
              birthday: _birthday,
            );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('個人資料已更新'),
          duration: Duration(seconds: 2),
        ));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _seed();
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;

    return Scaffold(
      backgroundColor: appTheme.bg,
      appBar: AppBar(
        title: const Text('編輯個人資料'),
        backgroundColor: appTheme.bgElev,
        foregroundColor: appTheme.fg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            _Label(text: '姓名'),
            const SizedBox(height: 8),
            _Field(controller: _nameCtrl, hint: '請輸入姓名'),
            const SizedBox(height: 18),
            _Label(text: '電子信箱（可留空清除）'),
            const SizedBox(height: 8),
            _Field(
              controller: _emailCtrl,
              hint: 'name@example.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),
            _Label(text: '性別'),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final g in const [(1, '男性'), (2, '女性'), (3, '其他')]) ...[
                  _GenderPill(
                    label: g.$2,
                    selected: _gender == g.$1,
                    onTap: () => setState(() => _gender = g.$1),
                  ),
                  if (g.$1 != 3) const SizedBox(width: 10),
                ],
              ],
            ),
            const SizedBox(height: 18),
            _Label(text: '生日（可留空清除）'),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickBirthday,
              borderRadius: BorderRadius.circular(appTheme.radiusSm),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: appTheme.bgElev,
                  borderRadius: BorderRadius.circular(appTheme.radiusSm),
                  border: Border.all(color: appTheme.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _birthday ?? '請選擇生日',
                        style: TextStyle(
                          fontSize: 14,
                          color: _birthday != null
                              ? appTheme.fg
                              : appTheme.fgMuted,
                        ),
                      ),
                    ),
                    Icon(Icons.calendar_today_outlined,
                        size: 16, color: appTheme.fgMuted),
                  ],
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!,
                  style: TextStyle(fontSize: 12, color: appTheme.danger)),
            ],
            const SizedBox(height: 28),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: _busy ? null : _save,
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
                            fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Text(text,
        style: TextStyle(
            fontSize: 12,
            color: appTheme.fgMuted,
            fontWeight: FontWeight.w500));
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, this.hint, this.keyboardType});
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14, color: appTheme.fg),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: appTheme.muted, fontSize: 13),
        filled: true,
        fillColor: appTheme.bgElev,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(appTheme.radiusSm),
          borderSide: BorderSide(color: appTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(appTheme.radiusSm),
          borderSide: BorderSide(color: appTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(appTheme.radiusSm),
          borderSide: BorderSide(color: accent),
        ),
      ),
    );
  }
}

class _GenderPill extends StatelessWidget {
  const _GenderPill({
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
    final accent = appTheme.brandPalette.tone500;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(appTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accent : appTheme.bgElev,
          borderRadius: BorderRadius.circular(appTheme.radiusSm),
          border: Border.all(
            color: selected ? accent : appTheme.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check, size: 15, color: Colors.white),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? Colors.white : appTheme.fgMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
