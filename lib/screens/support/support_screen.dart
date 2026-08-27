import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/responsive.dart';

/// Customer Support screen — corresponds to prototype `src/screens/support.jsx`.
///
/// Local-only chat for now; auto-reply matches keywords in the user's text
/// (出貨/shipping, 退貨/return, 尺寸/size, 真人/human) and falls back to a
/// generic acknowledgement.
///
/// `// TODO(API): GET/POST /support/messages` — when backend exposes a real
/// support endpoint, swap `_messages` for a Riverpod-backed AsyncNotifier
/// and `_send()` for a server-round-trip call.
class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [];
  bool _showQuickReplies = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _messages.add(_Msg(text: l10n.supportGreeting, isMe: false));
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _messages.add(_Msg(text: text, isMe: true));
      _ctrl.clear();
      _showQuickReplies = false;
    });
    _scrollToBottom();
    // Simulated CS reply after a short delay
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _messages.add(_Msg(text: _autoReply(text, l10n), isMe: false));
      });
      _scrollToBottom();
    });
  }

  String _autoReply(String text, AppLocalizations l10n) {
    final t = text.toLowerCase();
    if (t.contains('出貨') || t.contains('ship') || t.contains('物流')) {
      return l10n.supportAutoReplyShipping;
    }
    if (t.contains('退貨') || t.contains('退') || t.contains('return')) {
      return l10n.supportAutoReplyReturn;
    }
    if (t.contains('尺寸') || t.contains('size')) {
      return l10n.supportAutoReplySize;
    }
    if (t.contains('真人') || t.contains('human') || t.contains('agent')) {
      return l10n.supportAutoReplyHuman;
    }
    return l10n.supportAutoReplyDefault;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final topPadding = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      backgroundColor: appTheme.bg,
      body: Column(
        children: [
          // Sticky header
          Container(
            padding: EdgeInsets.only(
              top: topPadding + 8,
              left: 12,
              right: 12,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              color: appTheme.bgElev,
              border: Border(bottom: BorderSide(color: appTheme.divider)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: appTheme.fg),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                // CS avatar
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: appTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'C',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: appTheme.bgElev, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.supportTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: appTheme.fg,
                        ),
                      ),
                      Text(
                        l10n.supportStatus,
                        style: TextStyle(
                          fontSize: 11,
                          color: appTheme.fgMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.info_outline, color: appTheme.fgMuted),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return _ChatBubble(message: m);
              },
            ),
          ),
          // Quick replies (only shown until first user message)
          if (_showQuickReplies)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  l10n.supportQuickShipping,
                  l10n.supportQuickReturn,
                  l10n.supportQuickSize,
                  l10n.supportQuickHuman,
                ]
                    .map((t) => GestureDetector(
                          onTap: () => _send(t),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: appTheme.chip,
                              borderRadius: BorderRadius.circular(
                                  appTheme.chipRadius),
                            ),
                            child: Text(
                              t,
                              style: TextStyle(
                                fontSize: 12,
                                color: appTheme.chipFg,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(
              12,
              8,
              12,
              MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.of(context).padding.bottom +
                  8,
            ),
            decoration: BoxDecoration(
              color: appTheme.bgElev,
              border: Border(top: BorderSide(color: appTheme.divider)),
            ),
            child: Row(
              children: [
                Icon(Icons.add_circle_outline,
                    color: appTheme.fgMuted, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: appTheme.bgSubtle,
                      borderRadius:
                          BorderRadius.circular(appTheme.cardRadius),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      style: TextStyle(fontSize: 14, color: appTheme.fg),
                      decoration: InputDecoration(
                        hintText: l10n.supportInputHint,
                        hintStyle: TextStyle(
                            fontSize: 14, color: appTheme.fgMuted),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _send,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: appTheme.brandPalette.tone500,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _send(_ctrl.text),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(Icons.send,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Msg {
  _Msg({required this.text, required this.isMe});
  final String text;
  final bool isMe;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final _Msg message;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final isMe = message.isMe;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMe ? 18 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 18),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: appTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                'C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.cappedWidth(
                context,
                ratio: 0.7,
                cap: Responsive.chatBubbleMaxWidth,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? appTheme.brandPalette.tone500
                    : appTheme.bgElev,
                borderRadius: radius,
                border: isMe ? null : Border.all(color: appTheme.divider),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 13,
                  color: isMe ? Colors.white : appTheme.fg,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
