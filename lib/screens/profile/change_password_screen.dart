import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/repository_providers.dart';
import '../../theme/app_theme_extension.dart';

/// 修改密碼 — single-step form.
///
/// Wires to `POST /me/password` (B5) via [AuthRepository.changePassword].
/// Validates new password / confirm match before submitting.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final oldPwd = _oldCtrl.text;
    final newPwd = _newCtrl.text;
    final confirmPwd = _confirmCtrl.text;

    if (oldPwd.isEmpty) {
      setState(() => _error = '請輸入舊密碼');
      return;
    }
    if (newPwd.length < 6) {
      setState(() => _error = '新密碼至少需要 6 個字元');
      return;
    }
    if (newPwd != confirmPwd) {
      setState(() => _error = '兩次新密碼不一致');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authRepositoryProvider).changePassword(
            oldPassword: oldPwd,
            password: newPwd,
            confirmPassword: confirmPwd,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('密碼已更新'),
          duration: Duration(seconds: 2),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString();
      final colon = raw.indexOf(':');
      final msg =
          colon != -1 ? raw.substring(colon + 1).trim() : raw;
      setState(() => _error = msg);
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
        title: const Text('修改密碼'),
        backgroundColor: appTheme.bgElev,
        foregroundColor: appTheme.fg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          children: [
            _PasswordField(
              label: '舊密碼',
              controller: _oldCtrl,
              obscure: _obscureOld,
              onToggle: () => setState(() => _obscureOld = !_obscureOld),
            ),
            const SizedBox(height: 14),
            _PasswordField(
              label: '新密碼',
              controller: _newCtrl,
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              hint: '至少 6 個字元',
            ),
            const SizedBox(height: 14),
            _PasswordField(
              label: '確認新密碼',
              controller: _confirmCtrl,
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
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
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        '確認修改',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.hint,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: TextStyle(fontSize: 14, color: appTheme.fg),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle:
                        TextStyle(fontSize: 12, color: appTheme.fgMuted),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: appTheme.fgMuted,
                  size: 20,
                ),
                onPressed: onToggle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
