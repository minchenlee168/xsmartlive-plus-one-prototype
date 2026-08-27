import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/profile_provider.dart';
import '../../providers/repository_providers.dart';
import '../../theme/app_theme_extension.dart';

/// 更改手機號碼 — 2-step flow:
///   1. Enter new country code + mobile, tap 送出驗證碼
///      → calls `AuthRepository.requestChangeMobile()` (POST
///      `/me/changeMobile/request`).
///   2. Enter OTP, tap 確認
///      → calls `AuthRepository.confirmChangeMobile()` (POST
///      `/me/changeMobile/confirm`). On success, pops with a snackbar
///      and invalidates `memberProfileProvider` so the profile reloads.
class ChangeMobileScreen extends ConsumerStatefulWidget {
  const ChangeMobileScreen({super.key});

  @override
  ConsumerState<ChangeMobileScreen> createState() =>
      _ChangeMobileScreenState();
}

class _ChangeMobileScreenState extends ConsumerState<ChangeMobileScreen> {
  final _mobileCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  static const _codes = ['+886', '+1', '+81', '+82', '+86', '+852', '+65'];
  String _country = '+886';
  bool _otpSent = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final mobile = _mobileCtrl.text.trim();
    if (mobile.isEmpty) {
      setState(() => _error = '請輸入新手機號碼');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).requestChangeMobile(
            country: _country,
            mobile: mobile,
          );
      if (!mounted) return;
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('驗證碼已發送'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final mobile = _mobileCtrl.text.trim();
    final otp = _otpCtrl.text.trim();
    if (otp.isEmpty) {
      setState(() => _error = '請輸入驗證碼');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).confirmChangeMobile(
            country: _country,
            mobile: mobile,
            otp: otp,
          );
      if (!mounted) return;
      // Reload profile to reflect the new mobile.
      ref.invalidate(memberProfileProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('手機號碼已更新'),
          duration: Duration(seconds: 2),
        ),
      );
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
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return Scaffold(
      backgroundColor: appTheme.bg,
      appBar: AppBar(
        backgroundColor: appTheme.bgElev,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: Text(
          '更改手機號碼',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: appTheme.fg,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: appTheme.fg),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          Text('新手機號碼',
              style: TextStyle(
                  fontSize: 12,
                  color: appTheme.fgMuted,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: appTheme.bgElev,
                  borderRadius:
                      BorderRadius.circular(appTheme.radiusSm),
                  border: Border.all(color: appTheme.divider),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _country,
                    dropdownColor: appTheme.bgElev,
                    style: TextStyle(color: appTheme.fg, fontSize: 14),
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: appTheme.muted, size: 16),
                    items: _codes
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: _busy || _otpSent
                        ? null
                        : (v) => setState(() => _country = v!),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _mobileCtrl,
                  enabled: !_busy && !_otpSent,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: appTheme.fg, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: '請輸入新手機號碼',
                    hintStyle: TextStyle(
                        color: appTheme.muted, fontSize: 13),
                    filled: true,
                    fillColor: appTheme.bgElev,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 13),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(appTheme.radiusSm),
                      borderSide:
                          BorderSide(color: appTheme.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(appTheme.radiusSm),
                      borderSide:
                          BorderSide(color: appTheme.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(appTheme.radiusSm),
                      borderSide: BorderSide(color: accent),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_otpSent) ...[
            const SizedBox(height: 16),
            Text('驗證碼',
                style: TextStyle(
                    fontSize: 12,
                    color: appTheme.fgMuted,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _otpCtrl,
              enabled: !_busy,
              keyboardType: TextInputType.number,
              style: TextStyle(color: appTheme.fg, fontSize: 14),
              decoration: InputDecoration(
                hintText: '輸入 OTP 驗證碼',
                hintStyle: TextStyle(color: appTheme.muted, fontSize: 13),
                filled: true,
                fillColor: appTheme.bgElev,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 13),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(appTheme.radiusSm),
                  borderSide: BorderSide(color: appTheme.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(appTheme.radiusSm),
                  borderSide: BorderSide(color: appTheme.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(appTheme.radiusSm),
                  borderSide: BorderSide(color: accent),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _busy ? null : _sendOtp,
              style: TextButton.styleFrom(
                foregroundColor: accent,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('重新發送驗證碼',
                  style: TextStyle(fontSize: 12)),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(
                  fontSize: 12, color: appTheme.danger),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Material(
              color: _busy ? appTheme.muted : accent,
              borderRadius:
                  BorderRadius.circular(appTheme.cardRadius),
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(appTheme.cardRadius),
                onTap: _busy
                    ? null
                    : (_otpSent ? _confirm : _sendOtp),
                child: Center(
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _otpSent ? '確認更新' : '送出驗證碼',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
