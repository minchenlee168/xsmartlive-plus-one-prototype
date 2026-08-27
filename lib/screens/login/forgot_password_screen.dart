import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/flavor_config.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/repository_providers.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/responsive.dart';

/// White-label forgot password screen.
///
/// All visual styling is sourced from `Theme.of(context)` and
/// `context.appTheme.*` — no hardcoded colors, fonts, radii, or spacings.
/// Adapts to `ThemeMode.light/dark/system` automatically.
enum _Step { phone, otp, newPassword, success }

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _phoneFormKey    = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _phoneCtrl     = TextEditingController();
  final _passwordCtrl  = TextEditingController();
  final _confirmCtrl   = TextEditingController();

  // 6-box OTP — one controller + one focus node per digit
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpNodes =
      List.generate(6, (_) => FocusNode());

  _Step _step          = _Step.phone;
  String _code         = '+886';
  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _loading        = false;
  String? _errorMsg;

  int _otpCountdown    = 0;
  Timer? _countdownTimer;

  String _passwordToken = '';

  @override
  void initState() {
    super.initState();
    for (final n in _otpNodes) {
      n.addListener(_handleFocusChange);
    }
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  static const _codes = ['+886', '+1', '+81', '+82', '+86', '+852', '+65'];

  static const _countryMap = {
    '+886': 'tw',
    '+1':   'us',
    '+81':  'jp',
    '+82':  'kr',
    '+86':  'cn',
    '+852': 'hk',
    '+65':  'sg',
  };

  String get _country => _countryMap[_code] ?? 'tw';
  String get _fullMobile => '$_code${_phoneCtrl.text}';
  String get _otpValue => _otpCtrls.map((c) => c.text).join();

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final n in _otpNodes) {
      n.dispose();
    }
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Mask the middle of the phone number (e.g., `0912345678` → `0912***678`).
  /// Falls back to the original when the number is too short.
  String get _maskedMobile {
    final raw = _phoneCtrl.text;
    if (raw.length < 7) return _fullMobile;
    final head = raw.substring(0, 4);
    final tail = raw.substring(raw.length - 3);
    return '$head***$tail';
  }

  String _extractMessage(Object err) {
    final raw = err.toString();
    final colon = raw.indexOf(':');
    if (colon != -1) {
      final msg = raw.substring(colon + 1).trim();
      if (msg.isNotEmpty) return msg;
    }
    return raw;
  }

  void _startCountdown() {
    setState(() => _otpCountdown = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_otpCountdown > 0) {
          _otpCountdown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  void _clearOtp() {
    for (final c in _otpCtrls) {
      c.clear();
    }
    if (_otpNodes.isNotEmpty) _otpNodes.first.requestFocus();
  }

  // ── Step handlers ─────────────────────────────────────────────────────────

  Future<void> _sendOtp({bool resend = false}) async {
    if (!resend && !(_phoneFormKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _errorMsg = null; });
    try {
      await ref.read(authRepositoryProvider).forgotPassword(
            country: _country,
            mobile: _fullMobile,
          );
      _startCountdown();
      if (!resend) {
        _clearOtp();
        setState(() => _step = _Step.otp);
      }
    } catch (e) {
      setState(() => _errorMsg = _extractMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpValue.length < 6) {
      setState(() => _errorMsg =
          AppLocalizations.of(context)!.validationOtpRequired);
      return;
    }
    setState(() { _loading = true; _errorMsg = null; });
    try {
      _passwordToken =
          await ref.read(authRepositoryProvider).verifyPasswordOtp(
                country: _country,
                mobile: _fullMobile,
                otp: _otpValue,
              );
      setState(() => _step = _Step.newPassword);
    } catch (e) {
      setState(() => _errorMsg = _extractMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _errorMsg = null; });
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            country: _country,
            mobile: _fullMobile,
            passwordToken: _passwordToken,
            password: _passwordCtrl.text,
            confirmPassword: _confirmCtrl.text,
          );
      if (!mounted) return;
      setState(() => _step = _Step.success);
    } catch (e) {
      setState(() => _errorMsg = _extractMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goBack() {
    if (_step == _Step.phone || _step == _Step.success) {
      context.pop();
      return;
    }
    setState(() {
      _errorMsg = null;
      _step = switch (_step) {
        _Step.otp         => _Step.phone,
        _Step.newPassword => _Step.otp,
        _ => _Step.phone,
      };
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final appTheme = context.appTheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      // Let the gradient backdrop render behind the AppBar so the shape
      // covers the full screen height (matching Figma's 393×840 frame,
      // where the vector starts at y≈0 and sits behind the nav bar).
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: _step == _Step.success
            ? null
            : IconButton(
                icon: Icon(Icons.arrow_back_ios_new,
                    size: 18, color: cs.onSurface),
                onPressed: _goBack,
              ),
        title: Text(
          FlavorConfig.instance.appName,
          style: theme.textTheme.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        // StackFit.expand forces the Stack to fill the Scaffold body
        // regardless of non-positioned children's size. Without this the
        // Stack sizes to the scroll view's intrinsic height (≈ card height)
        // so Positioned.fill only covers that band — leaving the page
        // below the card without a backdrop.
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: _AuthGradientBackdrop(appTheme.authPageGradient),
          ),
          SafeArea(
            child: Responsive.centeredBox(
              context,
              maxWidth: Responsive.authMaxWidth,
              child: SingleChildScrollView(
                // AppBar is transparent + extendBodyBehindAppBar=true, so the
                // scroll view starts at y=0 of the body. Add kToolbarHeight to
                // avoid the card hiding behind the AppBar.
                padding: EdgeInsets.only(
                  top: kToolbarHeight + appTheme.spacingSm,
                  bottom: appTheme.spacingSm,
                  left: appTheme.spacingXl,
                  right: appTheme.spacingXl,
                ),
                child: _authCard(context, l10n),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _authCard(BuildContext ctx, AppLocalizations l10n) {
    final theme = Theme.of(ctx);
    final cs = theme.colorScheme;
    final appTheme = ctx.appTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        boxShadow: appTheme.elevation2,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        child: Padding(
          padding: EdgeInsets.all(appTheme.spacingXl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _titleFor(_step, l10n),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: appTheme.spacingMd),
              Text(
                _descriptionFor(_step, l10n),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              SizedBox(height: appTheme.spacingXl),
              _stepBody(ctx, l10n),
              if (_errorMsg != null) ...[
                SizedBox(height: appTheme.spacingMd),
                _errorBanner(ctx, _errorMsg!),
              ],
              SizedBox(height: appTheme.spacingXl),
              _actionButton(ctx, l10n),
            ],
          ),
        ),
      ),
    );
  }

  String _titleFor(_Step step, AppLocalizations l10n) => switch (step) {
        _Step.phone       => l10n.forgotPasswordTitle,
        _Step.otp         => l10n.otpVerifyTitle,
        _Step.newPassword => l10n.newPasswordTitle,
        _Step.success     => l10n.resetSuccessTitle,
      };

  String _descriptionFor(_Step step, AppLocalizations l10n) => switch (step) {
        _Step.phone       => l10n.forgotPasswordDescription,
        _Step.otp         => l10n.otpVerifyDescription(_maskedMobile),
        _Step.newPassword => l10n.newPasswordDescription,
        _Step.success     => l10n.resetSuccessDescription,
      };

  Widget _stepBody(BuildContext ctx, AppLocalizations l10n) =>
      switch (_step) {
        _Step.phone       => _phoneStep(ctx, l10n),
        _Step.otp         => _otpStep(ctx, l10n),
        _Step.newPassword => _newPasswordStep(ctx, l10n),
        _Step.success     => const SizedBox.shrink(),
      };

  // ── Step bodies ───────────────────────────────────────────────────────────

  Widget _phoneStep(BuildContext ctx, AppLocalizations l10n) {
    final appTheme = ctx.appTheme;
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _colLabel(ctx, l10n.labelCountryCode),
          SizedBox(height: appTheme.spacingXs + 2),
          _codeDropdown(ctx),
          SizedBox(height: appTheme.spacingLg),
          _colLabel(ctx, l10n.labelPhoneNumber),
          SizedBox(height: appTheme.spacingXs + 2),
          _field(
            ctx: ctx,
            ctrl: _phoneCtrl,
            hint: l10n.hintPhoneNumber,
            keyboard: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) => (v == null || v.trim().isEmpty)
                ? l10n.validationPhoneRequired
                : null,
          ),
        ],
      ),
    );
  }

  Widget _otpStep(BuildContext ctx, AppLocalizations l10n) {
    final theme = Theme.of(ctx);
    final cs = theme.colorScheme;
    final appTheme = ctx.appTheme;
    final canResend = _otpCountdown == 0 && !_loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _otpBoxes(ctx),
        SizedBox(height: appTheme.spacingMd),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: theme.textTheme.bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
            children: [
              TextSpan(text: '${l10n.otpResendPrompt} '),
              TextSpan(
                text: _otpCountdown > 0
                    ? l10n.resendOtpCountdown(_otpCountdown)
                    : l10n.resendOtp,
                style: TextStyle(
                  color: canResend ? cs.primary : cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  decoration: canResend
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  decorationColor: cs.primary,
                ),
                recognizer: canResend
                    ? (TapGestureRecognizer()
                      ..onTap = () => _sendOtp(resend: true))
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _otpBoxes(BuildContext ctx) {
    return Row(
      children: [
        for (int i = 0; i < 6; i++) ...[
          Expanded(child: _otpBox(ctx, i)),
          if (i < 5) SizedBox(width: ctx.appTheme.spacingSm),
        ],
      ],
    );
  }

  Widget _otpBox(BuildContext ctx, int i) {
    final theme = Theme.of(ctx);
    final cs = theme.colorScheme;
    final appTheme = ctx.appTheme;
    final hasFocus = _otpNodes[i].hasFocus;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(appTheme.buttonRadius),
        border: Border.all(
          color: hasFocus ? cs.primary : cs.outline,
          width: hasFocus ? 1.5 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: _otpCtrls[i],
        focusNode: _otpNodes[i],
        autofocus: i == 0,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: theme.textTheme.titleLarge?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (v) {
          if (v.isNotEmpty && i < 5) {
            _otpNodes[i + 1].requestFocus();
          } else if (v.isEmpty && i > 0) {
            _otpNodes[i - 1].requestFocus();
          }
          setState(() {});
        },
      ),
    );
  }

  Widget _newPasswordStep(BuildContext ctx, AppLocalizations l10n) {
    final appTheme = ctx.appTheme;
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(
            ctx: ctx,
            ctrl: _passwordCtrl,
            hint: l10n.hintNewPassword,
            obscure: _obscurePass,
            suffix: _eyeButton(ctx,
                obscured: _obscurePass,
                onTap: () =>
                    setState(() => _obscurePass = !_obscurePass)),
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.validationNewPasswordRequired;
              if (v.length < 8) return l10n.validationPasswordMinLength;
              return null;
            },
          ),
          SizedBox(height: appTheme.spacingLg),
          _field(
            ctx: ctx,
            ctrl: _confirmCtrl,
            hint: l10n.hintConfirmPassword,
            obscure: _obscureConfirm,
            suffix: _eyeButton(ctx,
                obscured: _obscureConfirm,
                onTap: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm)),
            validator: (v) {
              if (v == null || v.isEmpty) return l10n.validationConfirmPasswordRequired;
              if (v != _passwordCtrl.text) return l10n.validationPasswordMismatch;
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ── Action button ─────────────────────────────────────────────────────────

  Widget _actionButton(BuildContext ctx, AppLocalizations l10n) {
    final (label, onTap) = switch (_step) {
      _Step.phone       => (l10n.sendOtpButton, _sendOtp),
      _Step.otp         => (l10n.verifyButton, _verifyOtp),
      _Step.newPassword => (l10n.resetPasswordButton, _resetPassword),
      _Step.success     => (l10n.goToLogin, _goToLogin),
    };
    return _blockButton(ctx, label: label, onTap: onTap);
  }

  void _goToLogin() => context.go('/login');

  Widget _blockButton(
    BuildContext ctx, {
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(ctx);
    final cs = theme.colorScheme;
    final appTheme = ctx.appTheme;
    final enabled = !_loading;

    return Container(
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(appTheme.buttonRadius),
        gradient: enabled ? appTheme.primaryGradient : null,
        color: enabled ? null : cs.surfaceContainerHighest,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(appTheme.buttonRadius),
          onTap: enabled ? onTap : null,
          child: Center(
            child: _loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.onPrimary,
                    ),
                  )
                : Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: enabled ? cs.onPrimary : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ── Shared widgets ────────────────────────────────────────────────────────

  TextStyle _labelStyle(BuildContext ctx) {
    final theme = Theme.of(ctx);
    return theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ) ??
        TextStyle(color: theme.colorScheme.onSurfaceVariant);
  }

  Widget _colLabel(BuildContext ctx, String text) =>
      Text(text, style: _labelStyle(ctx));

  Widget _codeDropdown(BuildContext ctx) {
    final theme = Theme.of(ctx);
    final cs = theme.colorScheme;
    final appTheme = ctx.appTheme;
    return Container(
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: appTheme.spacingMd),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(appTheme.buttonRadius),
        border: Border.all(color: cs.outline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _code,
          isExpanded: true,
          dropdownColor: cs.surface,
          style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
          icon: Icon(Icons.keyboard_arrow_down,
              color: cs.onSurfaceVariant, size: 16),
          items: _codes
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _code = v!),
        ),
      ),
    );
  }

  Widget _eyeButton(BuildContext ctx,
      {required bool obscured, required VoidCallback onTap}) {
    final cs = Theme.of(ctx).colorScheme;
    return IconButton(
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 16,
        color: cs.onSurfaceVariant,
      ),
      onPressed: onTap,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  Widget _field({
    required BuildContext ctx,
    required TextEditingController ctrl,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(ctx);
    final cs = theme.colorScheme;
    final appTheme = ctx.appTheme;
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.textTheme.bodyMedium
            ?.copyWith(color: cs.onSurfaceVariant),
        suffixIcon: suffix,
        filled: true,
        fillColor: cs.surface,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: appTheme.spacingMd,
          vertical: appTheme.spacingMd + 1,
        ),
        border:             _border(cs.outline, appTheme.buttonRadius),
        enabledBorder:      _border(cs.outline, appTheme.buttonRadius),
        focusedBorder:      _border(cs.primary, appTheme.buttonRadius),
        errorBorder:        _border(cs.error, appTheme.buttonRadius),
        focusedErrorBorder: _border(cs.error, appTheme.buttonRadius),
        errorStyle: theme.textTheme.bodySmall?.copyWith(color: cs.error),
      ),
      validator: validator,
    );
  }

  OutlineInputBorder _border(Color color, double radius) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: color),
      );

  Widget _errorBanner(BuildContext ctx, String message) {
    final theme = Theme.of(ctx);
    final cs = theme.colorScheme;
    final appTheme = ctx.appTheme;
    return Container(
      padding: EdgeInsets.all(appTheme.spacingMd),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(appTheme.buttonRadius),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodySmall?.copyWith(color: cs.onErrorContainer),
      ),
    );
  }
}

// ── Auth page backdrop ──────────────────────────────────────────────────────
/// Diagonal gradient shape mirroring the Figma Vector on the auth pages.
/// Clipped with a gentle S-curve on its left edge, filled with a vertical
/// `LinearGradient`. Sits BEHIND the auth card so its intensity isn't washed
/// out by the card's opaque surface.
class _AuthGradientBackdrop extends StatelessWidget {
  const _AuthGradientBackdrop(this.palette);

  final List<Color> palette;

  @override
  Widget build(BuildContext context) {
    final start = palette.first;
    final end = palette.length > 1 ? palette.last : start;
    return IgnorePointer(
      child: ClipPath(
        clipper: _AuthBackdropClipper(),
        // Container (not DecoratedBox) so the gradient fills the tight
        // constraints from Positioned.fill. DecoratedBox without a child
        // has zero size and silently collapses.
        child: Container(
          decoration: BoxDecoration(
            // Figma SVG linear gradient:
            //   x1=317.586 y1=0.49  → x2=-63.80 y2=675.67
            // i.e. top-right → bottom-left diagonal.
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [start, end],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBackdropClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Direct transcription of the Figma Vector SVG path.
    //
    // Figma frame is 393px wide; the Vector is positioned at x=105 with
    // width=349 and height=839. SVG local coords map to page fractions:
    //   page_x_fraction = (105 + svg_x) / 393
    //   page_y_fraction = svg_y / 839
    //
    // The shape extends past the right edge (x > 1.0) — those portions are
    // clipped to the viewport automatically.
    final w = size.width;
    final h = size.height;
    final path = Path()
      // M348.563 0  →  top-right of shape
      ..moveTo(w * 1.152, 0)
      // H154.078    →  top edge: line to top-left of shape
      ..lineTo(w * 0.658, 0)
      // Reverse-traverse the SVG's left boundary back DOWN to bottom.
      //
      // SVG "C-35.961 79.3281 47.5249 29.0845 154.078 0" (going 6→7)
      //     reversed 7→6 uses swapped controls.
      ..cubicTo(
        w * 0.388, h * 0.035,   // svg c2 (47.5249, 29.0845)
        w * 0.176, h * 0.094,   // svg c1 (-35.961, 79.3281)
        w * 0.307, h * 0.215,   // end at upper-bulge (15.7094, 180.119)
      )
      // SVG "C122.227 236.607 52.9632 252.791 15.7094 180.119" (5→6) reversed
      ..cubicTo(
        w * 0.402, h * 0.301,   // (52.9632, 252.791)
        w * 0.577, h * 0.282,   // (122.227, 236.607)
        w * 0.808, h * 0.382,   // middle narrow (212.766, 320.494)
      )
      // SVG "C-70.6016 623.502 399.616 493.603 212.766 320.494" (4→5) reversed
      ..cubicTo(
        w * 1.282, h * 0.588,   // (399.616, 493.603)
        w * 0.088, h * 0.743,   // (-70.6016, 623.502)
        w * 0.560, h * 0.994,   // bottom-left (115.282, 834.085)
      )
      // SVG "C326.175 813.501 131.479 852.438 115.282 834.085" (3→4) reversed
      ..cubicTo(
        w * 0.601, h * 1.016,   // (131.479, 852.438)
        w * 1.095, h * 0.969,   // (326.175, 813.501)
        w * 1.152, h * 0.994,   // (348.563, 834.085)
      )
      // Right edge back up to top-right
      ..lineTo(w * 1.152, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _AuthBackdropClipper oldClipper) => false;
}
