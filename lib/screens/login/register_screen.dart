import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/flavor_config.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/repository_providers.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/responsive.dart';

/// White-label register screen.
///
/// All visual styling is sourced from `Theme.of(context)` and
/// `context.appTheme.*` — no hardcoded colors, fonts, radii, or spacings.
/// Adapts to `ThemeMode.light/dark/system` automatically.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _nameCtrl       = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _otpCtrl        = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _confirmCtrl    = TextEditingController();

  String _code          = '+886';
  bool _obscurePass     = true;
  bool _obscureConfirm  = true;
  bool _agreed          = false;
  bool _showTermsErr    = false;
  bool _otpSending      = false;
  int  _otpCountdown    = 0;
  Timer? _countdownTimer;

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

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  // ── OTP countdown ────────────────────────────────────────────────────────
  void _startCountdown() {
    setState(() => _otpCountdown = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _otpCountdown--;
        if (_otpCountdown <= 0) t.cancel();
      });
    });
  }

  Future<void> _sendOtp() async {
    final l10n = AppLocalizations.of(context)!;
    if (_phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validationPhoneFirst)),
      );
      return;
    }
    setState(() => _otpSending = true);
    try {
      await ref.read(authRepositoryProvider).sendRegisterOtp(
            country: _country,
            mobile: '$_code${_phoneCtrl.text}',
          );
      if (!mounted) return;
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog(_extractMessage(e));
    } finally {
      if (mounted) setState(() => _otpSending = false);
    }
  }

  // ── Submit ───────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _showTermsErr = !_agreed);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreed) return;

    final success = await ref.read(authNotifierProvider.notifier).register(
          name:            _nameCtrl.text,
          country:         _country,
          mobile:          '$_code${_phoneCtrl.text}',
          otp:             _otpCtrl.text,
          password:        _passwordCtrl.text,
          confirmPassword: _confirmCtrl.text,
        );
    if (!mounted) return;

    if (!success) {
      final err = ref.read(authNotifierProvider).error;
      _showErrorDialog(err != null
          ? _extractMessage(err)
          : l10n.registrationFailedTitle);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.registrationSuccess)),
    );
    context.pop();
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

  void _showErrorDialog(String message) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final theme = Theme.of(dialogCtx);
        final cs = theme.colorScheme;
        return AlertDialog(
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(dialogCtx.appTheme.dialogRadius),
          ),
          title: Text(
            l10n.registrationFailedTitle,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w600),
          ),
          content: Text(
            message,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                l10n.confirm,
                style: TextStyle(color: cs.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final appTheme = context.appTheme;
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              size: 18, color: cs.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          FlavorConfig.instance.appName,
          style: theme.textTheme.titleMedium?.copyWith(
            color: cs.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () {
              // TODO(auth): wire to help link (backend-owned URL)
            },
            icon: Icon(Icons.help_outline,
                size: 16, color: cs.onSurfaceVariant),
            label: Text(l10n.registerNeedHelp),
            style: TextButton.styleFrom(foregroundColor: cs.onSurfaceVariant),
          ),
          SizedBox(width: appTheme.spacingSm),
        ],
      ),
      body: Stack(
        children: [
          // ── Page-level auth gradient decoration ───────────────────────
          // Diagonal blob covering the right side of the page, filled with
          // a vertical LinearGradient (start → end). Colors from
          // `context.appTheme.authPageGradient` (default cyan → magenta).
          Positioned.fill(child: _AuthGradientBackdrop(appTheme.authPageGradient)),

          // ── Scrollable content ────────────────────────────────────────
          SafeArea(
            top: false,
            child: Responsive.centeredBox(
              context,
              maxWidth: Responsive.authMaxWidth,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: appTheme.spacingXl,
                  vertical: appTheme.spacingSm,
                ),
                child: _authCard(context, l10n, isLoading),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Auth card with purple gradient corner decoration ─────────────────────
  Widget _authCard(
      BuildContext ctx, AppLocalizations l10n, bool isLoading) {
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      l10n.registerTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: appTheme.spacingXl),

                    // Name
                    _colLabel(ctx, l10n.labelName),
                    SizedBox(height: appTheme.spacingXs + 2),
                    _field(
                      ctx: ctx,
                      ctrl: _nameCtrl,
                      hint: l10n.hintName,
                      suffix: Icon(Icons.person_outline,
                          size: 16, color: cs.onSurfaceVariant),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l10n.validationRequired
                          : null,
                    ),
                    SizedBox(height: appTheme.spacingLg),

                    // Country + Phone
                    _rowLabel(ctx, l10n.labelCountryCode, l10n.labelPhoneNumber),
                    SizedBox(height: appTheme.spacingXs + 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _codeDropdown(ctx),
                        SizedBox(width: appTheme.spacingSm),
                        Expanded(
                          child: _field(
                            ctx: ctx,
                            ctrl: _phoneCtrl,
                            hint: l10n.hintPhoneNumber,
                            keyboard: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            suffix: Icon(Icons.phone_outlined,
                                size: 16, color: cs.onSurfaceVariant),
                            validator: (v) => (v == null || v.isEmpty)
                                ? l10n.validationRequired
                                : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: appTheme.spacingSm),

                    // Send OTP (right-aligned, per Figma)
                    Align(
                      alignment: Alignment.centerRight,
                      child: _sendOtpButton(ctx, l10n),
                    ),
                    SizedBox(height: appTheme.spacingMd),

                    // OTP input
                    _field(
                      ctx: ctx,
                      ctrl: _otpCtrl,
                      hint: l10n.hintVerificationCode,
                      keyboard: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (v) => (v == null || v.isEmpty)
                          ? l10n.validationRequired
                          : null,
                    ),
                    SizedBox(height: appTheme.spacingLg),

                    // Password
                    _colLabel(ctx, l10n.labelSetPassword),
                    SizedBox(height: appTheme.spacingXs + 2),
                    _field(
                      ctx: ctx,
                      ctrl: _passwordCtrl,
                      hint: l10n.hintSetPassword,
                      obscure: _obscurePass,
                      suffix: _eyeButton(ctx,
                          obscured: _obscurePass,
                          onTap: () =>
                              setState(() => _obscurePass = !_obscurePass)),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return l10n.validationRequired;
                        }
                        if (v.length < 8 || v.length > 20) {
                          return l10n.validationPasswordLength;
                        }
                        if (!v.contains(RegExp(r'[A-Z]'))) {
                          return l10n.validationPasswordUppercase;
                        }
                        if (!v.contains(RegExp(r'[a-z]'))) {
                          return l10n.validationPasswordLowercase;
                        }
                        if (!v.contains(RegExp(
                            r"""[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;'`~/]"""))) {
                          return l10n.validationPasswordSpecial;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: appTheme.spacingLg),

                    // Confirm password
                    _colLabel(ctx, l10n.labelConfirmPassword),
                    SizedBox(height: appTheme.spacingXs + 2),
                    _field(
                      ctx: ctx,
                      ctrl: _confirmCtrl,
                      hint: l10n.hintConfirmPassword,
                      obscure: _obscureConfirm,
                      suffix: _eyeButton(ctx,
                          obscured: _obscureConfirm,
                          onTap: () => setState(
                              () => _obscureConfirm = !_obscureConfirm)),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return l10n.validationRequired;
                        }
                        if (v != _passwordCtrl.text) {
                          return l10n.validationPasswordMismatch;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: appTheme.spacingLg),

                    // Terms checkbox
                    _termsRow(ctx, l10n),
                    if (_showTermsErr) ...[
                      SizedBox(height: appTheme.spacingXs + 2),
                      Text(
                        l10n.termsError,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.error),
                      ),
                    ],
                    SizedBox(height: appTheme.spacingXxl),

                    // Block button
                    _registerButton(ctx, l10n, isLoading),
                    SizedBox(height: appTheme.spacingXl),

                    // Already have account
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant),
                          children: [
                            TextSpan(text: l10n.alreadyHaveAccount),
                            TextSpan(
                              text: l10n.loginNow,
                              style: TextStyle(
                                color: cs.primary,
                                decoration: TextDecoration.underline,
                                decorationColor: cs.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () => context.pop(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }


  // ── Widgets ──────────────────────────────────────────────────────────────

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

  Widget _rowLabel(BuildContext ctx, String left, String right) {
    return Row(
      children: [
        Text(left, style: _labelStyle(ctx)),
        SizedBox(width: ctx.appTheme.spacingXxxl * 2 + ctx.appTheme.spacingXs),
        Text(right, style: _labelStyle(ctx)),
      ],
    );
  }

  Widget _codeDropdown(BuildContext ctx) {
    final theme = Theme.of(ctx);
    final cs = theme.colorScheme;
    final appTheme = ctx.appTheme;
    return Container(
      height: 44,
      padding: EdgeInsets.symmetric(horizontal: appTheme.spacingSm),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(appTheme.buttonRadius),
        border: Border.all(color: cs.outline),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _code,
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

  Widget _sendOtpButton(BuildContext ctx, AppLocalizations l10n) {
    final theme = Theme.of(ctx);
    final cs = theme.colorScheme;
    final appTheme = ctx.appTheme;
    final canSend = _otpCountdown == 0 && !_otpSending;
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: canSend ? _sendOtp : null,
        style: OutlinedButton.styleFrom(
          foregroundColor:
              canSend ? cs.onSurface : cs.onSurfaceVariant,
          side: BorderSide(
              color: canSend ? cs.outline : cs.outlineVariant),
          backgroundColor: cs.surface,
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(appTheme.buttonRadius)),
          padding: EdgeInsets.symmetric(
              horizontal: appTheme.spacingMd,
              vertical: appTheme.spacingXs),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: _otpSending
            ? SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.onSurfaceVariant,
                ),
              )
            : Text(
                _otpCountdown > 0
                    ? '$_otpCountdown s'
                    : l10n.sendCode,
                style: theme.textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w500),
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

  Widget _termsRow(BuildContext ctx, AppLocalizations l10n) {
    final theme = Theme.of(ctx);
    final cs = theme.colorScheme;
    final appTheme = ctx.appTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: Checkbox(
            value: _agreed,
            onChanged: (v) => setState(() {
              _agreed = v ?? false;
              if (_agreed) _showTermsErr = false;
            }),
            side: BorderSide(color: cs.outline),
            fillColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected)
                  ? cs.primary
                  : Colors.transparent,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        SizedBox(width: appTheme.spacingSm),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
              children: [
                TextSpan(text: l10n.termsAgreePrefix),
                _linkSpan(ctx, l10n.termsLink),
                TextSpan(text: l10n.termsAnd),
                _linkSpan(ctx, l10n.privacyLink),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TextSpan _linkSpan(BuildContext ctx, String text) {
    final theme = Theme.of(ctx);
    final cs = theme.colorScheme;
    return TextSpan(
      text: text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: cs.primary,
        decoration: TextDecoration.underline,
        decorationColor: cs.primary,
      ),
      recognizer: TapGestureRecognizer()..onTap = () {},
    );
  }

  Widget _registerButton(
      BuildContext ctx, AppLocalizations l10n, bool loading) {
    final theme = Theme.of(ctx);
    final cs = theme.colorScheme;
    final appTheme = ctx.appTheme;
    final enabled = !loading && _agreed;

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
          onTap: loading ? null : _submit,
          child: Center(
            child: loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.onPrimary,
                    ),
                  )
                : Text(
                    l10n.registerButton,
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
}

// ── Auth page backdrop ──────────────────────────────────────────────────────
/// Diagonal gradient shape mirroring the Figma Vector on the auth pages.
/// The shape is clipped with a gentle S-curve on its left edge and filled
/// with a vertical `LinearGradient` going from the first color to the last
/// color in `authPageGradient`. Designed to sit BEHIND the auth card so its
/// intensity isn't washed out by the card's opaque surface.
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                start.withValues(alpha: 0.85),
                end.withValues(alpha: 0.90),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Clip path for `_AuthGradientBackdrop` — hugs the right edge and curves
/// diagonally across the page, approximating the Figma Vector's silhouette.
class _AuthBackdropClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      // Start just below top-right corner, on the top edge
      ..moveTo(w * 0.35, 0)
      // S-curve down-left to ~35% height on left-ish area
      ..cubicTo(
        w * 0.60, h * 0.18,
        w * 0.10, h * 0.32,
        w * 0.40, h * 0.55,
      )
      // S-curve down-right to bottom area
      ..cubicTo(
        w * 0.70, h * 0.75,
        w * 0.15, h * 0.85,
        w * 0.55, h,
      )
      // Close along bottom → right → top
      ..lineTo(w, h)
      ..lineTo(w, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant _AuthBackdropClipper oldClipper) => false;
}

