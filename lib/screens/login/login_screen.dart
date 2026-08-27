import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/api_constants.dart';
import '../../config/flavor_config.dart';
import '../../config/social_auth_config.dart';
import '../../core/errors/app_exception.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/repository_providers.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/responsive.dart';
import 'oauth_web_screen.dart';
import 'turnstile_captcha_widget.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _phoneCtrl  = TextEditingController();
  final _passwdCtrl = TextEditingController();
  final _captCtrl   = TextEditingController();

  String _code = '+886';
  bool _obscure         = true;
  bool _agreed          = false;
  Uint8List? _captchaBytes;
  bool _captchaLoading  = false;

  // Turnstile state — only used when [turnstileConfigProvider] reports the
  // backend has flipped TURNSTILE_ENABLED. The controller lets us reset the
  // widget after a 10007 backend rejection so the user can retry.
  final TurnstileController _turnstileController = TurnstileController();
  String? _turnstileToken;
  bool _imageCaptchaRequested = false;

  static const _codes = ['+886', '+1', '+81', '+82', '+86', '+852', '+65'];

  // ── Persistence ───────────────────────────────────────────────────────────
  static const _keyCode   = 'login_code';
  static const _keyPhone  = 'login_phone';
  static const _keyPasswd = 'login_passwd';
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  @override
  void initState() {
    super.initState();
    _loadSaved();
    _phoneCtrl.addListener(_savePhone);
    _passwdCtrl.addListener(_savePasswd);
    // Image captcha is fetched lazily the first time the legacy image row is
    // rendered — Turnstile mode skips it entirely. See [_buildCaptchaBlock].
  }

  void _ensureImageCaptchaRequested() {
    if (_imageCaptchaRequested) return;
    _imageCaptchaRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCaptcha());
  }

  Future<void> _fetchCaptcha() async {
    if (!mounted) return;
    setState(() => _captchaLoading = true);
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.post(
        ApiConstants.captcha,
        data: {'type': '2'},
      );
      final raw = response.data['data']['image'] as String;
      final base64Str = raw.contains(',') ? raw.split(',').last : raw;
      if (!mounted) return;
      setState(() => _captchaBytes = base64Decode(base64Str));
    } catch (_) {
      // Keep existing image on error; user can tap refresh to retry.
    } finally {
      if (mounted) setState(() => _captchaLoading = false);
    }
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode  = prefs.getString(_keyCode);
    final savedPhone = prefs.getString(_keyPhone);
    final savedPasswd = await _secure.read(key: _keyPasswd);
    if (!mounted) return;
    setState(() {
      if (savedCode != null && _codes.contains(savedCode)) _code = savedCode;
    });
    _phoneCtrl.text = savedPhone ?? '987654321';
    _passwdCtrl.text = savedPasswd ?? r'$Abc123456';
  }

  Future<void> _savePhone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPhone, _phoneCtrl.text);
  }

  Future<void> _saveCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCode, code);
  }

  Future<void> _savePasswd() async {
    await _secure.write(key: _keyPasswd, value: _passwdCtrl.text);
  }

  @override
  void dispose() {
    _phoneCtrl.removeListener(_savePhone);
    _passwdCtrl.removeListener(_savePasswd);
    _phoneCtrl.dispose();
    _passwdCtrl.dispose();
    _captCtrl.dispose();
    super.dispose();
  }

  // ── Social OAuth handlers ─────────────────────────────────────────────────

  String _generateState() {
    final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    return base64Url.encode(bytes);
  }

  Future<void> _facebookLogin() async {
    await ref.read(authNotifierProvider.notifier).facebookLogin();
    if (!mounted) return;
    final err = ref.read(authNotifierProvider).error;
    if (err != null) _showErrorDialog(_extractMessage(err));
  }

  Future<void> _googleLogin() async {
    await ref.read(authNotifierProvider.notifier).googleLogin();
    if (!mounted) return;
    final err = ref.read(authNotifierProvider).error;
    if (err != null) _showErrorDialog(_extractMessage(err));
  }

  Future<void> _lineLogin() async {
    final state = _generateState();
    final callbackUrl = await OAuthWebScreen.show(
      context: context,
      initialUrl: SocialAuthConfig.lineAuthUrl(state: state),
      callbackUrlPrefix: SocialAuthConfig.lineCallbackUrl,
      title: 'LINE Login',
    );
    if (callbackUrl == null || !mounted) return;
    await ref
        .read(authNotifierProvider.notifier)
        .completeServerCallback(callbackUrl);
    if (!mounted) return;
    final err = ref.read(authNotifierProvider).error;
    if (err != null) _showErrorDialog(_extractMessage(err));
  }

  Future<void> _tikTokLogin() async {
    final state = _generateState();
    final callbackUrl = await OAuthWebScreen.show(
      context: context,
      initialUrl: SocialAuthConfig.tikTokAuthUrl(state: state),
      callbackUrlPrefix: SocialAuthConfig.tikTokCallbackUrl,
      title: 'TikTok Login',
    );
    if (callbackUrl == null || !mounted) return;
    await ref
        .read(authNotifierProvider.notifier)
        .completeServerCallback(callbackUrl);
    if (!mounted) return;
    final err = ref.read(authNotifierProvider).error;
    if (err != null) _showErrorDialog(_extractMessage(err));
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final flavor = FlavorConfig.instance;
    final useTurnstile =
        flavor.turnstileEnabled && flavor.turnstileSiteKey.isNotEmpty;

    if (useTurnstile && (_turnstileToken == null || _turnstileToken!.isEmpty)) {
      final l10n = AppLocalizations.of(context)!;
      _showErrorDialog(l10n.captchaPending);
      return;
    }

    if (!_agreed) {
      final confirmed = await _showTermsConfirmDialog();
      if (confirmed != true) return;
      if (!mounted) return;
      setState(() => _agreed = true);
    }

    final captchaValue = useTurnstile ? _turnstileToken! : _captCtrl.text;

    await ref.read(authNotifierProvider.notifier).login(
          mobile:   '$_code${_phoneCtrl.text}',
          password: _passwdCtrl.text,
          captcha:  captchaValue,
        );
    if (!mounted) return;

    final err = ref.read(authNotifierProvider).error;
    if (err != null) {
      // Cloudflare token / image answer rejected — discard the stale value
      // and re-render the challenge so the next retry has a fresh one.
      if (err is CaptchaInvalidException) {
        if (useTurnstile) {
          setState(() => _turnstileToken = null);
          await _turnstileController.reset();
        } else {
          _captCtrl.clear();
          await _fetchCaptcha();
        }
      }
      _showErrorDialog(_extractMessage(err));
    }
  }

  Future<bool?> _showTermsConfirmDialog() {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final cs = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appTheme.bgElev,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(
          l10n.termsDialogTitle,
          style: TextStyle(
            color: appTheme.fg,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          l10n.termsDialogContent,
          style: TextStyle(color: appTheme.fgMuted, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.termsDialogCancel,
              style: TextStyle(color: appTheme.fgMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.termsDialogConfirm,
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
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
    final appTheme = context.appTheme;
    final cs = Theme.of(context).colorScheme;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: appTheme.bgElev,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        title: Text(l10n.loginFailedTitle,
            style: TextStyle(
                color: appTheme.fg,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
        content: Text(message,
            style: TextStyle(color: appTheme.fgMuted, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.confirm,
                style: TextStyle(color: cs.primary)),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return Scaffold(
      backgroundColor: appTheme.bg,
      body: SafeArea(
        child: Responsive.centeredBox(
          context,
          maxWidth: Responsive.authMaxWidth,
          child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),

                // ── Title ─────────────────────────────────────────────────
                Text(
                  l10n.loginTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: appTheme.fg,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  FlavorConfig.instance.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: appTheme.fgMuted, fontSize: 13),
                ),
                const SizedBox(height: 28),

                // ── Country code + Phone ───────────────────────────────────
                _rowLabel(l10n.labelCountryCode, l10n.labelPhoneNumber),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _codeDropdown(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _field(
                        ctrl: _phoneCtrl,
                        hint: l10n.hintPhoneNumber,
                        keyboard: TextInputType.phone,
                        suffix: Icon(Icons.phone_outlined,
                            size: 16, color: appTheme.muted),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? l10n.validationRequired : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ── Password ───────────────────────────────────────────────
                _colLabel(l10n.labelPassword),
                const SizedBox(height: 6),
                _field(
                  ctrl: _passwdCtrl,
                  hint: l10n.hintPassword,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 16,
                      color: appTheme.muted,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? l10n.validationRequired : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(l10n.forgotPasswordLink,
                        style: const TextStyle(fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Captcha ────────────────────────────────────────────────
                _colLabel(l10n.labelCaptcha),
                const SizedBox(height: 6),
                _buildCaptchaBlock(l10n),
                const SizedBox(height: 18),

                // ── Terms ──────────────────────────────────────────────────
                _termsRow(l10n),
                const SizedBox(height: 22),

                // ── Login button ───────────────────────────────────────────
                _loginButton(l10n, isLoading),
                const SizedBox(height: 22),

                // ── Divider ────────────────────────────────────────────────
                _orDivider(l10n),
                const SizedBox(height: 18),

                // ── Social buttons ─────────────────────────────────────────
                _socialBtn(label: 'Facebook', icon: Image.asset('assets/facebook.png', width: 20, height: 20), onTap: isLoading ? null : _facebookLogin),
                const SizedBox(height: 10),
                _socialBtn(label: 'Google',   icon: Image.asset('assets/google.png', width: 20, height: 20),   onTap: isLoading ? null : _googleLogin),
                const SizedBox(height: 10),
                _socialBtn(label: 'LINE',     icon: Image.asset('assets/line.png', width: 20, height: 20),     onTap: isLoading ? null : _lineLogin),
                const SizedBox(height: 10),
                _socialBtn(label: 'Tiktok',   icon: Image.asset('assets/tiktok.png', width: 20, height: 20),   onTap: isLoading ? null : _tikTokLogin),
                const SizedBox(height: 24),

                // ── Register link ──────────────────────────────────────────
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: appTheme.fgMuted, fontSize: 13),
                      children: [
                        TextSpan(text: l10n.noAccountText),
                        TextSpan(
                          text: l10n.registerLink,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: Theme.of(context).colorScheme.primary,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => context.push('/register'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  TextStyle get _labelStyle => TextStyle(
      color: context.appTheme.fgMuted, fontSize: 12, fontWeight: FontWeight.w500);

  Widget _rowLabel(String left, String right) {
    return Row(
      children: [
        Text(left,  style: _labelStyle),
        const SizedBox(width: 90),
        Text(right, style: _labelStyle),
      ],
    );
  }

  Widget _colLabel(String text) => Text(text, style: _labelStyle);

  Widget _codeDropdown() {
    final appTheme = context.appTheme;
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: appTheme.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _code,
          dropdownColor: appTheme.bgElev,
          style: TextStyle(color: appTheme.fg, fontSize: 14),
          icon: Icon(Icons.keyboard_arrow_down,
              color: appTheme.muted, size: 16),
          items: _codes
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) {
            setState(() => _code = v!);
            _saveCode(v!);
          },
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String hint,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    final appTheme = context.appTheme;
    final cs = Theme.of(context).colorScheme;
    return TextFormField(
      controller:   ctrl,
      obscureText:  obscure,
      keyboardType: keyboard,
      style: TextStyle(color: appTheme.fg, fontSize: 14),
      decoration: InputDecoration(
        hintText:    hint,
        hintStyle:   TextStyle(color: appTheme.muted, fontSize: 13),
        suffixIcon:  suffix,
        filled:      true,
        fillColor:   appTheme.bgElev,
        isDense:     true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        border:             _border(appTheme.divider),
        enabledBorder:      _border(appTheme.divider),
        focusedBorder:      _border(cs.primary),
        errorBorder:        _border(appTheme.danger),
        focusedErrorBorder: _border(appTheme.danger),
        errorStyle: TextStyle(color: appTheme.danger, fontSize: 11),
      ),
      validator: validator,
    );
  }

  OutlineInputBorder _border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: c),
      );

  Widget _buildCaptchaBlock(AppLocalizations l10n) {
    final flavor = FlavorConfig.instance;
    if (flavor.turnstileEnabled && flavor.turnstileSiteKey.isNotEmpty) {
      return TurnstileCaptchaWidget(
        siteKey: flavor.turnstileSiteKey,
        action: flavor.turnstileAction,
        baseUrl: flavor.baseUrl,
        controller: _turnstileController,
        onToken: (t) => setState(() => _turnstileToken = t),
        onExpired: () => setState(() => _turnstileToken = null),
        onError: (_) => setState(() => _turnstileToken = null),
      );
    }
    return _buildImageCaptchaRow(l10n);
  }

  Widget _buildImageCaptchaRow(AppLocalizations l10n) {
    _ensureImageCaptchaRequested();
    final appTheme = context.appTheme;
    return Row(
      children: [
        _captchaImage(),
        IconButton(
          icon: Icon(Icons.refresh_rounded,
              color: appTheme.fgMuted, size: 20),
          onPressed: _captchaLoading ? null : _fetchCaptcha,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          constraints: const BoxConstraints(),
        ),
        Expanded(
          child: _field(
            ctrl: _captCtrl,
            hint: l10n.hintCaptcha,
            validator: (v) =>
                (v == null || v.isEmpty) ? l10n.validationRequired : null,
          ),
        ),
      ],
    );
  }

  Widget _captchaImage() {
    final appTheme = context.appTheme;
    return Container(
      width: 112,
      height: 44,
      decoration: BoxDecoration(
        color: appTheme.bgSubtle,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: _captchaLoading
            ? Center(
                child: SizedBox(
                  width: 18, height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: appTheme.muted),
                ),
              )
            : _captchaBytes != null
                ? Image.memory(_captchaBytes!, fit: BoxFit.fill,
                    width: 112, height: 44)
                : Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        color: appTheme.muted, size: 20)),
      ),
    );
  }

  Widget _termsRow(AppLocalizations l10n) {
    final appTheme = context.appTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 18, height: 18,
          child: Checkbox(
            value: _agreed,
            onChanged: (v) => setState(() => _agreed = v ?? false),
            side: BorderSide(color: appTheme.divider),
            fillColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.selected)
                  ? cs.primary
                  : Colors.transparent,
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: appTheme.fgMuted, fontSize: 12),
              children: [
                TextSpan(text: l10n.termsAgreePrefix),
                _linkSpan(l10n.termsLink),
                TextSpan(text: l10n.termsAnd),
                _linkSpan(l10n.privacyLink),
              ],
            ),
          ),
        ),
      ],
    );
  }

  TextSpan _linkSpan(String text) {
    final cs = Theme.of(context).colorScheme;
    return TextSpan(
      text: text,
      style: TextStyle(
        color: cs.primary,
        decoration: TextDecoration.underline,
        decorationColor: cs.primary,
        fontSize: 12,
      ),
      recognizer: TapGestureRecognizer()..onTap = () {},
    );
  }

  Widget _loginButton(AppLocalizations l10n, bool loading) {
    final appTheme = context.appTheme;
    return Container(
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: appTheme.primaryGradient,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: loading ? null : _submit,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(l10n.loginButton,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _orDivider(AppLocalizations l10n) {
    final appTheme = context.appTheme;
    return Row(
      children: [
        Expanded(child: Divider(color: appTheme.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(l10n.orLoginWith,
              style: TextStyle(color: appTheme.muted, fontSize: 12)),
        ),
        Expanded(child: Divider(color: appTheme.divider)),
      ],
    );
  }

  Widget _socialBtn({
    required String label,
    required Widget icon,
    VoidCallback? onTap,
  }) {
    final appTheme = context.appTheme;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: appTheme.fg,
        backgroundColor: appTheme.bgElev,
        side: BorderSide(color: appTheme.divider),
        minimumSize: const Size.fromHeight(46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: appTheme.fg, fontSize: 14)),
        ],
      ),
    );
  }
}
