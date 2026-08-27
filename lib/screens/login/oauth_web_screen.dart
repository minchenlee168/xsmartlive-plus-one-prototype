import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Full-screen WebView that handles server-side OAuth flows (LINE, TikTok).
///
/// Flow:
///   1. Opens [initialUrl] (the provider's authorise endpoint).
///   2. User authenticates in the embedded browser.
///   3. Provider redirects to the server callback URL.
///   4. This screen intercepts any navigation whose URL starts with
///      [callbackUrlPrefix] **before** the WebView loads it.
///   5. Pops with the full intercepted URL so the caller can replay the
///      request through Dio (ensuring cookies land in the shared cookie jar).
///
/// Returns `null` if the user closes the screen without completing auth.
class OAuthWebScreen extends StatefulWidget {
  const OAuthWebScreen({
    super.key,
    required this.initialUrl,
    required this.callbackUrlPrefix,
    required this.title,
  });

  final String initialUrl;
  final String callbackUrlPrefix;
  final String title;

  /// Convenience helper — pushes the screen and returns the intercepted
  /// callback URL, or `null` if the user cancelled.
  static Future<String?> show({
    required BuildContext context,
    required String initialUrl,
    required String callbackUrlPrefix,
    required String title,
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => OAuthWebScreen(
          initialUrl: initialUrl,
          callbackUrlPrefix: callbackUrlPrefix,
          title: title,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<OAuthWebScreen> createState() => _OAuthWebScreenState();
}

class _OAuthWebScreenState extends State<OAuthWebScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  static const _bg = Color(0xFF09090B);
  static const _surface = Color(0xFF18181B);
  static const _primary = Color(0xFF7008E7);

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(_bg)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            // Intercept the server OAuth callback BEFORE the WebView loads it.
            // We replay the request through Dio so the session cookie lands
            // in the shared PersistCookieJar rather than the WebView store.
            if (request.url.startsWith(widget.callbackUrlPrefix)) {
              Navigator.of(context).pop(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(null),
          tooltip: 'Cancel',
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const ColoredBox(
              color: _bg,
              child: Center(
                child: CircularProgressIndicator(color: _primary),
              ),
            ),
        ],
      ),
    );
  }
}
