import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// External handle so the parent screen can ask the WebView to re-render the
/// Turnstile challenge (after a 10007 backend error, or when the cached token
/// has been consumed).
class TurnstileController {
  _TurnstileCaptchaWidgetState? _state;

  void _attach(_TurnstileCaptchaWidgetState state) => _state = state;
  void _detach(_TurnstileCaptchaWidgetState state) {
    if (identical(_state, state)) _state = null;
  }

  /// Discards the current token and renders a fresh challenge. Safe to call
  /// before the WebView has finished its first load — it queues until ready.
  Future<void> reset() async => _state?._reset();
}

/// Embedded Cloudflare Turnstile widget.
///
/// Renders an inline HTML page that loads the Turnstile script with
/// [siteKey] + [action], and bridges the JavaScript token callback back to
/// Dart via a [JavaScriptChannel]. The host screen submits the token as
/// `captcha` in the mall login body — see Turnstile spec section 4.
///
/// Sizing notes:
/// - Default Turnstile widget is 300×65 px.
/// - We let the WebView size itself to its content; the parent should
///   constrain width if needed but not height.
///
/// **Do not** change the WebView UserAgent at runtime — Cloudflare treats UA
/// drift mid-session as a risk signal and will reject the token.
class TurnstileCaptchaWidget extends StatefulWidget {
  const TurnstileCaptchaWidget({
    super.key,
    required this.siteKey,
    required this.action,
    required this.baseUrl,
    required this.onToken,
    this.onError,
    this.onExpired,
    this.controller,
    this.height = 72,
  });

  final String siteKey;
  final String action;

  /// Base URL passed to [WebViewController.loadHtmlString] so the document
  /// has a real origin. Without this the document origin is `null` and
  /// Turnstile's internal `postMessage` to the parent window is rejected
  /// (targetOrigin mismatch), so the token callback never fires.
  /// Pass the backend's origin (e.g. `https://api-uat-1.xsmartlive.com`) —
  /// it must match a hostname allowed for the site key in the Cloudflare
  /// Dashboard, or "Allow any hostname" must be set.
  final String baseUrl;
  final ValueChanged<String> onToken;
  final ValueChanged<String>? onError;
  final VoidCallback? onExpired;
  final TurnstileController? controller;
  final double height;

  @override
  State<TurnstileCaptchaWidget> createState() => _TurnstileCaptchaWidgetState();
}

class _TurnstileCaptchaWidgetState extends State<TurnstileCaptchaWidget> {
  late final WebViewController _webController;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'TurnstileBridge',
        onMessageReceived: _onBridgeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _ready = true);
          },
          // Block top-level navigation away from our injected page — Turnstile
          // iframe navigation is always allowed. The main-frame load uses
          // [widget.baseUrl] as the document origin so allow that prefix too.
          onNavigationRequest: (request) {
            if (request.isMainFrame &&
                !request.url.startsWith('about:') &&
                !request.url.startsWith('data:') &&
                !request.url.startsWith(widget.baseUrl)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadHtmlString(
        _buildHtml(widget.siteKey, widget.action),
        baseUrl: widget.baseUrl,
      );
  }

  @override
  void didUpdateWidget(covariant TurnstileCaptchaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    if (oldWidget.siteKey != widget.siteKey ||
        oldWidget.action != widget.action ||
        oldWidget.baseUrl != widget.baseUrl) {
      _webController.loadHtmlString(
        _buildHtml(widget.siteKey, widget.action),
        baseUrl: widget.baseUrl,
      );
    }
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    // webview_flutter 4.x doesn't expose an explicit controller dispose, and
    // on Android the platform view release can lag behind the Flutter
    // element teardown — meanwhile Cloudflare's challenge JS keeps polling,
    // retries the failed-origin postMessage, and prints `Error: 110200`.
    // Loading about:blank synchronously tears down the JS context so all
    // in-flight Turnstile work stops the moment we leave the login screen.
    // Best-effort: swallow errors in case the controller is already gone.
    _webController
        .loadRequest(Uri.parse('about:blank'))
        .catchError((_) {});
    super.dispose();
  }

  void _onBridgeMessage(JavaScriptMessage msg) {
    final raw = msg.message;
    final sep = raw.indexOf(':');
    final tag = sep == -1 ? raw : raw.substring(0, sep);
    final value = sep == -1 ? '' : raw.substring(sep + 1);
    switch (tag) {
      case 'token':
        widget.onToken(value);
      case 'error':
        widget.onError?.call(value);
      case 'expired':
        widget.onExpired?.call();
    }
  }

  Future<void> _reset() async {
    if (!_ready) {
      // The first onPageFinished hasn't fired yet — reload the page from
      // scratch so the user gets a fresh widget once ready.
      await _webController.loadHtmlString(
        _buildHtml(widget.siteKey, widget.action),
        baseUrl: widget.baseUrl,
      );
      return;
    }
    try {
      await _webController.runJavaScript('window.resetTurnstile && resetTurnstile();');
    } catch (_) {
      // Best-effort: if the JS bridge is gone for any reason, reload the page.
      await _webController.loadHtmlString(
        _buildHtml(widget.siteKey, widget.action),
        baseUrl: widget.baseUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: WebViewWidget(controller: _webController),
    );
  }

  static String _buildHtml(String siteKey, String action) {
    final safeKey = _escapeAttr(siteKey);
    final safeAction = _escapeAttr(action);
    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<script src="https://challenges.cloudflare.com/turnstile/v0/api.js" async defer></script>
<style>
  html, body { margin: 0; padding: 0; background: transparent; height: 100%; }
  body { display: flex; align-items: center; justify-content: center; }
</style>
</head>
<body>
  <div class="cf-turnstile"
       data-sitekey="$safeKey"
       data-action="$safeAction"
       data-callback="onTurnstileToken"
       data-error-callback="onTurnstileError"
       data-expired-callback="onTurnstileExpired"
       data-theme="auto"></div>
  <script>
    function _post(tag, value) {
      try {
        if (window.TurnstileBridge && TurnstileBridge.postMessage) {
          TurnstileBridge.postMessage(tag + ':' + (value || ''));
        }
      } catch (e) {}
    }
    function onTurnstileToken(token)  { _post('token', token); }
    function onTurnstileError(code)   { _post('error', code); }
    function onTurnstileExpired()     { _post('expired', ''); }
    function resetTurnstile() {
      if (window.turnstile && turnstile.reset) {
        try { turnstile.reset(); } catch (e) {}
      }
    }
  </script>
</body>
</html>
''';
  }

  static String _escapeAttr(String raw) =>
      raw.replaceAll('&', '&amp;').replaceAll('"', '&quot;').replaceAll('<', '&lt;');
}

/// Marks debug builds — useful for logging Turnstile errors without spamming
/// production logs. Currently unused publicly but kept for future hooks.
@visibleForTesting
const kIsTurnstileDebug = kDebugMode;
