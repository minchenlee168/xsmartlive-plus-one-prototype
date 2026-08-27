import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/profile_provider.dart';
import '../../providers/repository_providers.dart';
import '../../theme/app_theme_extension.dart';

/// 綁定手機 — 2-step flow for accounts that have not bound a mobile yet
/// (typically social-login users):
///   1. Enter country + mobile, tap 送出驗證碼  → POST /me/bindMobile
///   2. Enter OTP, tap 確認綁定                → POST /me/verifyOtp
///
/// On success, invalidates [memberProfileProvider] so the profile reloads
/// and the "尚未綁定手機" hint disappears.
class BindMobileScreen extends ConsumerStatefulWidget {
  const BindMobileScreen({super.key});

  @override
  ConsumerState<BindMobileScreen> createState() => _BindMobileScreenState();
}

class _BindMobileScreenState extends ConsumerState<BindMobileScreen> {
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
      setState(() => _error = '請輸入手機號碼');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).bindMobile(
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
      setState(() => _error = _extractMessage(e));
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
      await ref.read(authRepositoryProvider).verifyBindMobileOtp(
            country: _country,
            mobile: mobile,
            otp: otp,
          );
      if (!mounted) return;
      ref.invalidate(memberProfileProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('手機綁定成功'),
          duration: Duration(seconds: 2),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _extractMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _extractMessage(Object e) {
    final raw = e.toString();
    final colon = raw.indexOf(':');
    return colon != -1 ? raw.substring(colon + 1).trim() : raw;
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;

    return Scaffold(
      backgroundColor: appTheme.bg,
      appBar: AppBar(
        title: const Text('綁定手機'),
        backgroundColor: appTheme.bgElev,
        foregroundColor: appTheme.fg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          children: [
            Text(
              '為了帳號安全與訂單通知，請綁定您的手機號碼。',
              style: TextStyle(
                  fontSize: 12, color: appTheme.fgMuted, height: 1.5),
            ),
            const SizedBox(height: 18),
            Text(
              '手機號碼',
              style: TextStyle(
                fontSize: 12,
                color: appTheme.fgMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: appTheme.bgElev,
                borderRadius: BorderRadius.circular(appTheme.radiusSm),
                border: Border.all(color: appTheme.divider),
              ),
              child: Row(
                children: [
                  // Country code dropdown
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _country,
                        items: _codes
                            .map((c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c,
                                    style: TextStyle(
                                        fontSize: 14, color: appTheme.fg),
                                  ),
                                ))
                            .toList(),
                        onChanged: _otpSent
                            ? null
                            : (v) {
                                if (v != null) setState(() => _country = v);
                              },
                      ),
                    ),
                  ),
                  Container(width: 1, height: 24, color: appTheme.divider),
                  Expanded(
                    child: TextField(
                      controller: _mobileCtrl,
                      enabled: !_otpSent,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(fontSize: 14, color: appTheme.fg),
                      decoration: InputDecoration(
                        hintText: '請輸入手機號碼',
                        hintStyle: TextStyle(
                            fontSize: 12, color: appTheme.fgMuted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_otpSent) ...[
              const SizedBox(height: 14),
              Text(
                '驗證碼',
                style: TextStyle(
                  fontSize: 12,
                  color: appTheme.fgMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: appTheme.bgElev,
                  borderRadius: BorderRadius.circular(appTheme.radiusSm),
                  border: Border.all(color: appTheme.divider),
                ),
                child: TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 14, color: appTheme.fg),
                  decoration: InputDecoration(
                    hintText: '請輸入 6 位數驗證碼',
                    hintStyle: TextStyle(
                        fontSize: 12, color: appTheme.fgMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: appTheme.danger, fontSize: 12),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: _busy ? null : (_otpSent ? _confirm : _sendOtp),
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
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _otpSent ? '確認綁定' : '送出驗證碼',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
            if (_otpSent) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: _busy
                    ? null
                    : () {
                        setState(() {
                          _otpSent = false;
                          _otpCtrl.clear();
                          _error = null;
                        });
                      },
                child: const Text('修改手機號碼'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
