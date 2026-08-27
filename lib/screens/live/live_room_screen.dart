import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../l10n/app_localizations.dart';
import '../../models/live_stream.dart';
import '../../models/product.dart';
import '../../providers/live_provider.dart';
import '../../providers/product_provider.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_theme_extension.dart';

/// Live Room — corresponds to prototype `src/screens/live.jsx` `LiveRoom()`
/// in **split layout** (top 52% video + bottom 48% scrollable product list).
///
/// This is the layout shown in the prototype's screenshot (matches the
/// 直播管家觀眾App.html default for vertical mobile viewing).
///
/// Features:
///   - Bottom nav hidden (registered as top-level GoRoute outside ShellRoute)
///   - Live chat overlay (left of video) with auto-stream of mock comments
///     when `livePageProvider.comments` is empty (so the room never feels
///     dead during dev / initial backend setup)
///   - Floating heart button bottom-right of video, emits drifting hearts
///   - Product list bottom: # badge + image + name + price + 立即下單 button
///   - Sticky comment input at the very bottom
///
/// `// TODO(API): GET /lives/{id}/products` — currently uses
/// `productListProvider(ProductFilter())` as a generic product list because
/// no per-live-room product endpoint exists yet.
class LiveRoomScreen extends ConsumerStatefulWidget {
  const LiveRoomScreen({super.key, required this.streamId});

  final String streamId;

  @override
  ConsumerState<LiveRoomScreen> createState() => _LiveRoomScreenState();
}

/// Two layout variants ported from prototype `live.jsx`. `split` is the
/// default mobile-vertical layout; `immersive` is full-screen video with
/// floating overlays. User can toggle via the on-screen pill on the right.
enum _LiveLayout { split, immersive }

class _LiveRoomScreenState extends ConsumerState<LiveRoomScreen>
    with TickerProviderStateMixin {
  final _chatCtrl = TextEditingController();
  final _hearts = <_FloatingHeart>[];
  final _mockChat = <_MockComment>[];
  Timer? _mockChatTimer;
  int _heartCount = 2400;
  int _activeProductIndex = 0;
  bool _productDismissed = false;
  _LiveLayout _layout = _LiveLayout.split;

  // Mock chat script — used only when API has no comments yet.
  static const _script = [
    ('阿宏', '已下單 ✅'),
    ('小美', '尺寸表在哪裡？'),
    ('Emma', '+1 號碼 12'),
    ('Chia', '主播下次再上這款 ❤'),
    ('Linda', '太美了 💄'),
    ('Joy', '質感看起來很好'),
    ('Kelly', '請問還有現貨嗎'),
    ('Wendy', '剛搶到 🎉'),
    ('Tina', '送禮自用兩相宜'),
    ('Ann', '今天的開箱很實用'),
    ('Ruby', '有運費優惠嗎？'),
    ('Mia', '主播好專業 👏'),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    // Mock-stream chat every 1.4s to mirror prototype's auto-stream feel.
    _mockChatTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (!mounted) return;
      final entry = _script[_mockChat.length % _script.length];
      setState(() {
        _mockChat.add(_MockComment(
          id: DateTime.now().microsecondsSinceEpoch,
          user: entry.$1,
          msg: entry.$2,
        ));
        if (_mockChat.length > 30) _mockChat.removeAt(0);
      });
    });
  }

  @override
  void dispose() {
    _mockChatTimer?.cancel();
    _chatCtrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _emitHeart() {
    final rng = math.Random();
    final heart = _FloatingHeart(
      id: DateTime.now().microsecondsSinceEpoch + rng.nextInt(1000),
      drift: (rng.nextDouble() - 0.5) * 60,
      offsetX: 12.0 + rng.nextDouble() * 30,
      color: _heartColors[rng.nextInt(_heartColors.length)],
    );
    setState(() {
      _hearts.add(heart);
      _heartCount += 1;
    });
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      setState(() => _hearts.removeWhere((h) => h.id == heart.id));
    });
  }

  void _sendChat() {
    final text = _chatCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _mockChat.add(_MockComment(
        id: DateTime.now().microsecondsSinceEpoch,
        user: '我',
        msg: text,
        isSelf: true,
      ));
    });
    _chatCtrl.clear();
    // TODO(API): POST /lives/{id}/comments
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appTheme = context.appTheme;
    final pageState = ref.watch(livePageProvider).valueOrNull;
    final productListAsync =
        ref.watch(productListProvider(const ProductFilter()));
    final stream = pageState?.currentLive ??
        (pageState?.historicalLives ?? const <LiveStream>[])
            .where((s) => s.id == widget.streamId)
            .firstOrNull;

    if (stream == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(l10n.liveNoStream,
              style: const TextStyle(color: Colors.white)),
        ),
      );
    }

    final products = productListAsync.valueOrNull?.products ?? const [];
    final liveProducts = products.take(4).toList();

    final media = MediaQuery.of(context);
    final keyboard = media.viewInsets.bottom;
    final activeProduct = liveProducts.isNotEmpty
        ? liveProducts[_activeProductIndex.clamp(0, liveProducts.length - 1)]
        : null;

    if (_layout == _LiveLayout.immersive) {
      return _buildImmersive(
        l10n: l10n,
        appTheme: appTheme,
        stream: stream,
        activeProduct: activeProduct,
        media: media,
        keyboard: keyboard,
      );
    }

    return _buildSplit(
      l10n: l10n,
      appTheme: appTheme,
      stream: stream,
      products: liveProducts,
      media: media,
      keyboard: keyboard,
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // SPLIT LAYOUT — top 52% video + bottom product list + sticky input.
  // ──────────────────────────────────────────────────────────────────────
  Widget _buildSplit({
    required AppLocalizations l10n,
    required AppThemeExtension appTheme,
    required LiveStream stream,
    required List<Product> products,
    required MediaQueryData media,
    required double keyboard,
  }) {
    final videoH = media.size.height * 0.52;
    return Scaffold(
      backgroundColor: appTheme.bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              // ── TOP HALF: video + overlays ──
              SizedBox(
                height: videoH,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _VideoBg(
                      thumbnail: stream.thumbnail,
                      fallbackGradient: appTheme.primaryGradient,
                    ),
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 100,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xB3000000), Color(0x00000000)],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: media.viewPadding.top + 8,
                      left: 12,
                      right: 12,
                      child: _TopBar(stream: stream),
                    ),
                    Positioned(
                      top: media.viewPadding.top + 56,
                      left: 16,
                      child: Row(
                        children: [
                          _LivePill(color: appTheme.danger),
                          const SizedBox(width: 6),
                          _ViewerPill(viewers: stream.viewers),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 14,
                      left: 12,
                      width: media.size.width * 0.62,
                      child: _ChatOverlay(comments: _mockChat),
                    ),
                    Positioned(
                      bottom: 14,
                      right: 14,
                      child: _HeartButton(
                        count: _heartCount,
                        onTap: _emitHeart,
                      ),
                    ),
                    ..._hearts.map((h) => Positioned(
                          bottom: 60,
                          right: h.offsetX,
                          child: _AnimatedHeart(heart: h),
                        )),
                  ],
                ),
              ),
              // ── BOTTOM HALF: product list ──
              Expanded(
                child: _ProductList(
                  products: products,
                  activeIndex: _activeProductIndex,
                  onTap: (i) => setState(() {
                    _activeProductIndex = i;
                    _productDismissed = false;
                  }),
                ),
              ),
              _BottomInputBar(
                ctrl: _chatCtrl,
                hint: l10n.liveCommentHint,
                onSend: _sendChat,
                keyboard: keyboard,
              ),
            ],
          ),
          // Single layout-toggle icon, stacked 10px above the heart button.
          // Heart is 44px tall at `bottom: 14` (ends at bottom 58); toggle
          // (40px) sits at bottom 68 → clear gap above the heart.
          Positioned(
            right: 16,
            bottom: 68,
            child: _LayoutToggleButton(
              isImmersive: _layout == _LiveLayout.immersive,
              onTap: () => setState(() {
                _layout = _layout == _LiveLayout.split
                    ? _LiveLayout.immersive
                    : _LiveLayout.split;
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────
  // IMMERSIVE LAYOUT — full-screen video, floating product card,
  // glass bottom input bar, side action column.
  // ──────────────────────────────────────────────────────────────────────
  Widget _buildImmersive({
    required AppLocalizations l10n,
    required AppThemeExtension appTheme,
    required LiveStream stream,
    required Product? activeProduct,
    required MediaQueryData media,
    required double keyboard,
  }) {
    final bottomSafe = media.padding.bottom;
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen video
          _VideoBg(
            thumbnail: stream.thumbnail,
            fallbackGradient: appTheme.primaryGradient,
          ),
          // Top dark gradient
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x99000000), Color(0x00000000)],
                ),
              ),
            ),
          ),
          // Bottom dark gradient
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 320,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xD9000000), Color(0x00000000)],
                ),
              ),
            ),
          ),
          // Top bar (back + host + CS) — same widget as split layout
          Positioned(
            top: media.viewPadding.top + 8,
            left: 12,
            right: 12,
            child: _TopBar(stream: stream),
          ),
          // LIVE + viewer badge
          Positioned(
            top: media.viewPadding.top + 56,
            left: 16,
            child: Row(
              children: [
                _LivePill(color: appTheme.danger),
                const SizedBox(width: 6),
                _ViewerPill(viewers: stream.viewers),
              ],
            ),
          ),
          // Side action column — heart + gift + share + layout-toggle
          // stacked at the right edge. Toggle sits at the bottom per
          // prototype parity.
          Positioned(
            right: 12,
            bottom: 200 + bottomSafe,
            child: _SideActionColumn(
              heartCount: _heartCount,
              onHeartTap: _emitHeart,
              isImmersive: true,
              onLayoutToggle: () => setState(() {
                _layout = _LiveLayout.split;
              }),
            ),
          ),
          // Floating hearts (lifted higher in immersive)
          ..._hearts.map((h) => Positioned(
                bottom: 240 + bottomSafe,
                right: h.offsetX,
                child: _AnimatedHeart(heart: h),
              )),
          // Chat overlay — bottom-left, taller than split
          Positioned(
            bottom: 110 + bottomSafe,
            left: 12,
            width: media.size.width * 0.6,
            height: 220,
            child: _ChatOverlay(comments: _mockChat),
          ),
          // Floating product card — above input bar
          if (activeProduct != null && !_productDismissed)
            Positioned(
              left: 12,
              right: 80,
              bottom: 80 + bottomSafe + keyboard,
              child: _FloatingProductCard(
                index: _activeProductIndex + 1,
                product: activeProduct,
                onClose: () => setState(() => _productDismissed = true),
              ),
            ),
          // Bottom input bar (glass) + shopping bag CTA
          Positioned(
            left: 12,
            right: 12,
            bottom: 16 + bottomSafe + keyboard,
            child: _GlassBottomInput(
              ctrl: _chatCtrl,
              hint: l10n.liveCommentHint,
              onSend: _sendChat,
              onBag: () {
                if (_productDismissed) {
                  setState(() => _productDismissed = false);
                } else if (activeProduct != null) {
                  ref.read(cartProvider.notifier).addItem(activeProduct);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

const _heartColors = <Color>[
  Color(0xFFFF6B7A),
  Color(0xFFA88BFF),
  Color(0xFF30D158),
  Color(0xFFFFA040),
  Color(0xFF7BC890),
  Color(0xFFFF8A6B),
];

class _MockComment {
  _MockComment({
    required this.id,
    required this.user,
    required this.msg,
    this.isSelf = false,
  });
  final int id;
  final String user;
  final String msg;
  final bool isSelf;
}

class _FloatingHeart {
  _FloatingHeart({
    required this.id,
    required this.drift,
    required this.offsetX,
    required this.color,
  });
  final int id;
  final double drift;
  final double offsetX;
  final Color color;
}

// ───────────────────────────────────────────────────────────────────────────
// Video background — falls back to bundled prototype host portrait when
// the API supplies no thumbnail (matches prototype `LiveVideoBg`).
// ───────────────────────────────────────────────────────────────────────────
class _VideoBg extends StatelessWidget {
  const _VideoBg({
    required this.thumbnail,
    required this.fallbackGradient,
  });
  final String thumbnail;
  final LinearGradient fallbackGradient;

  @override
  Widget build(BuildContext context) {
    if (thumbnail.isEmpty) {
      return Image.asset(
        'assets/prototype/live_host.jpg',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          decoration: BoxDecoration(gradient: fallbackGradient),
        ),
      );
    }
    return Image.network(
      thumbnail,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Image.asset(
        'assets/prototype/live_host.jpg',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          decoration: BoxDecoration(gradient: fallbackGradient),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Top bar
// ───────────────────────────────────────────────────────────────────────────
class _TopBar extends ConsumerWidget {
  const _TopBar({required this.stream});
  final LiveStream stream;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    final hostInitial = stream.streamer.isNotEmpty
        ? stream.streamer.substring(0, 1)
        : 'C';

    return Row(
      children: [
        _GlassCircleButton(
          icon: AppIcons.back,
          onTap: () => Navigator.of(context).maybePop(),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(4, 4, 6, 4),

            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: appTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    hostInitial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stream.streamer.isNotEmpty
                            ? stream.streamer
                            : 'Coco 闆娘',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(AppIcons.eye,
                              color: Colors.white, size: 10),
                          const SizedBox(width: 3),
                          Text(
                            '${stream.viewers > 0 ? stream.viewers : 3333} 觀看',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: appTheme.brandPalette.tone500,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    '+ 追蹤',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _GlassCircleButton(
          icon: Icons.headset_mic_outlined,
          onTap: () => context.push('/support'),
        ),
      ],
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  const _GlassCircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.4),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// LIVE pill
// ───────────────────────────────────────────────────────────────────────────
class _LivePill extends StatelessWidget {
  const _LivePill({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(appTheme.radiusSm),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 6,
            height: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: 5),
          Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Chat overlay (bottom-left of video).
//
// Mirrors prototype `live.jsx` lines 244–264:
//   - `overflowY: auto` (user can scroll up to read older messages)
//   - `maxHeight: 220` (fixed viewport height, content scrolls inside)
//   - auto-scroll to newest whenever a new comment arrives
//   - top-fade mask (older messages fade out)
//
// We do NOT shrink to "last 8 messages" anymore — the full history is
// kept so users can scroll up. Auto-scroll only follows the newest if the
// user was already pinned to the bottom; if they scrolled up, we leave
// them in place.
// ───────────────────────────────────────────────────────────────────────────
class _ChatOverlay extends StatefulWidget {
  const _ChatOverlay({required this.comments});
  final List<_MockComment> comments;

  @override
  State<_ChatOverlay> createState() => _ChatOverlayState();
}

class _ChatOverlayState extends State<_ChatOverlay> {
  final _scroll = ScrollController();
  int _lastSeenCount = 0;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _maybeAutoScroll() {
    if (!_scroll.hasClients) return;
    // With `reverse: true`, offset 0 == bottom (newest). If user is
    // within ~40px of the bottom, follow new messages; otherwise stay.
    final pinnedToBottom = _scroll.offset <= 40;
    if (pinnedToBottom) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final comments = widget.comments;
    if (comments.length != _lastSeenCount) {
      _lastSeenCount = comments.length;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _maybeAutoScroll();
      });
    }
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x00000000), Color(0xFF000000)],
        stops: [0.0, 0.35],
      ).createShader(rect),
      child: SizedBox(
        height: 160,
        child: ListView.separated(
          controller: _scroll,
          reverse: true,
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemCount: comments.length,
          separatorBuilder: (_, _) => const SizedBox(height: 4),
          itemBuilder: (context, i) {
            // reverse: true → index 0 is rendered at the bottom (newest).
            final c = comments[comments.length - 1 - i];
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: c.isSelf
                      ? appTheme.brandPalette.tone500
                      : Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: c.user,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: c.isSelf
                              ? Colors.white
                              : appTheme.brandPalette.tone200,
                        ),
                      ),
                      const TextSpan(text: '  '),
                      TextSpan(text: c.msg),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Heart button (bottom-right of video) + animated heart particles
// ───────────────────────────────────────────────────────────────────────────
class _HeartButton extends StatelessWidget {
  const _HeartButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black54,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            AppIcons.heartFilled,
            color: appTheme.brandPalette.tone500,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _AnimatedHeart extends StatefulWidget {
  const _AnimatedHeart({required this.heart});
  final _FloatingHeart heart;

  @override
  State<_AnimatedHeart> createState() => _AnimatedHeartState();
}

class _AnimatedHeartState extends State<_AnimatedHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value;
        return Transform.translate(
          offset: Offset(widget.heart.drift * t, -180 * t),
          child: Opacity(
            opacity: (1 - t).clamp(0, 1),
            child: Icon(AppIcons.heartFilled,
                color: widget.heart.color, size: 28),
          ),
        );
      },
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Product list (bottom half)
// ───────────────────────────────────────────────────────────────────────────
class _ProductList extends StatelessWidget {
  const _ProductList({
    required this.products,
    required this.activeIndex,
    required this.onTap,
  });

  final List<Product> products;
  final int activeIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    if (products.isEmpty) {
      return Container(
        color: appTheme.bg,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.shoppingBag,
                  color: appTheme.fgMuted, size: 36),
              const SizedBox(height: 12),
              Text(
                '此場直播尚無商品',
                style:
                    TextStyle(color: appTheme.fgMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: appTheme.bg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
        children: [
          Row(
            children: [
              Icon(AppIcons.shoppingBag,
                  size: 18, color: appTheme.brandPalette.tone500),
              const SizedBox(width: 8),
              Text(
                '直播商品 · ${products.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: appTheme.fg,
                ),
              ),
              const Spacer(),
              Text(
                '滑動瀏覽 ›',
                style: TextStyle(
                    fontSize: 11, color: appTheme.fgMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...products.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            final active = i == activeIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => onTap(i),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: appTheme.bgElev,
                    borderRadius:
                        BorderRadius.circular(appTheme.cardRadius),
                    border: Border.all(
                      color: active
                          ? appTheme.brandPalette.tone500
                          : appTheme.divider,
                      width: active ? 2 : 1,
                    ),
                    boxShadow: appTheme.elevation1,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(appTheme.radiusSm),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: p.image.isNotEmpty
                                  ? Image.network(
                                      p.image,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _ProductFallback(index: i),
                                    )
                                  : _ProductFallback(index: i),
                            ),
                          ),
                          Positioned(
                            top: -6,
                            left: -6,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: active
                                    ? appTheme.brandPalette.tone500
                                    : appTheme.fg,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: appTheme.fg,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${p.price.toStringAsFixed(0)}',
                                  style: GoogleFonts.getFont(
                                    appTheme.fontDisplay,
                                    textStyle: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color:
                                          appTheme.brandPalette.tone500,
                                    ),
                                  ),
                                ),
                                if (p.originalPrice != null) ...[
                                  const SizedBox(width: 5),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 2),
                                    child: Text(
                                      '\$${p.originalPrice!.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: appTheme.fgMuted,
                                        decoration:
                                            TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '已售 ${p.sales}',
                              style: TextStyle(
                                fontSize: 10,
                                color: appTheme.fgMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FilledButton(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            backgroundColor:
                                appTheme.brandPalette.tone500,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  appTheme.radiusSm),
                            ),
                          ),
                          child: const Text(
                            '立即下單',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Cycles through the 10 bundled prototype product PNGs as a placeholder
// when the API hasn't yet supplied a product image. Keeps the live-room
// product list looking populated while backend wires real product imagery.
class _ProductFallback extends StatelessWidget {
  const _ProductFallback({required this.index});
  final int index;

  static const _assets = [
    'assets/prototype/products/01_serum.png',
    'assets/prototype/products/02_mask.png',
    'assets/prototype/products/03_cream.png',
    'assets/prototype/products/04_lipstick.png',
    'assets/prototype/products/05_foundation.png',
    'assets/prototype/products/06_perfume.png',
    'assets/prototype/products/07_cleanser.png',
    'assets/prototype/products/08_sunscreen.png',
    'assets/prototype/products/09_eyeshadow.png',
    'assets/prototype/products/10_toner.png',
  ];

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Image.asset(
      _assets[index % _assets.length],
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: appTheme.bgSubtle,
        alignment: Alignment.center,
        child: Icon(Icons.image_outlined, color: appTheme.fgMuted),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Bottom comment input bar
// ───────────────────────────────────────────────────────────────────────────
class _BottomInputBar extends StatelessWidget {
  const _BottomInputBar({
    required this.ctrl,
    required this.hint,
    required this.onSend,
    required this.keyboard,
  });

  final TextEditingController ctrl;
  final String hint;
  final VoidCallback onSend;
  final double keyboard;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 8, 12, bottom + 8 + keyboard),
      decoration: BoxDecoration(
        color: appTheme.bgElev,
        border: Border(top: BorderSide(color: appTheme.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: appTheme.bgSubtle,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: appTheme.divider),
              ),
              child: Row(
                children: [
                  Icon(AppIcons.comment,
                      color: appTheme.fgMuted, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      style: TextStyle(
                          color: appTheme.fg, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: TextStyle(
                          color: appTheme.fgMuted,
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: appTheme.brandPalette.tone500,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onSend,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(AppIcons.send,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// _ViewerPill — eye icon + viewer count, used in both layouts.
// ───────────────────────────────────────────────────────────────────────────
class _ViewerPill extends StatelessWidget {
  const _ViewerPill({required this.viewers});
  final int viewers;

  @override
  Widget build(BuildContext context) {
    final n = viewers > 0 ? viewers : 3333;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.eye, color: Colors.white, size: 11),
          const SizedBox(width: 3),
          Text(
            '$n',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// _LayoutToggleButton — single glass-circle icon. Tapping flips between
// split and immersive layouts. The icon shows the layout you'll switch TO
// (so users can predict the action).
// ───────────────────────────────────────────────────────────────────────────
class _LayoutToggleButton extends StatelessWidget {
  const _LayoutToggleButton({
    required this.isImmersive,
    required this.onTap,
  });

  final bool isImmersive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(
        side: BorderSide(color: Color(0x33FFFFFF)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: isImmersive ? '切回半屏式' : '切到沉浸式',
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              isImmersive ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// _SideActionColumn — heart action button (immersive layout). Gift / share
// can be added when wired to backend.
// ───────────────────────────────────────────────────────────────────────────
class _SideActionColumn extends StatelessWidget {
  const _SideActionColumn({
    required this.heartCount,
    required this.onHeartTap,
    this.isImmersive = false,
    this.onLayoutToggle,
  });

  final int heartCount;
  final VoidCallback onHeartTap;

  /// When true, the column appends a layout-toggle button at the bottom.
  final bool isImmersive;
  final VoidCallback? onLayoutToggle;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SideActionButton(
          icon: Icons.favorite,
          label: '$heartCount',
          bg: appTheme.brandPalette.tone500,
          onTap: onHeartTap,
        ),
        const SizedBox(height: 14),
        _SideActionButton(
          icon: Icons.card_giftcard,
          label: '禮物',
          bg: Colors.black.withValues(alpha: 0.5),
          onTap: () {},
        ),
        const SizedBox(height: 14),
        _SideActionButton(
          icon: Icons.share,
          label: '分享',
          bg: Colors.black.withValues(alpha: 0.5),
          onTap: () {},
        ),
        if (onLayoutToggle != null) ...[
          const SizedBox(height: 14),
          _SideActionButton(
            icon: isImmersive
                ? Icons.fullscreen_exit
                : Icons.fullscreen,
            label: '縮放',
            bg: Colors.black.withValues(alpha: 0.5),
            onTap: onLayoutToggle!,
          ),
        ],
      ],
    );
  }
}

class _SideActionButton extends StatelessWidget {
  const _SideActionButton({
    required this.icon,
    required this.label,
    required this.bg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 1),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// _FloatingProductCard — translucent card showing the active product
// hovering above the bottom input in immersive layout.
// ───────────────────────────────────────────────────────────────────────────
class _FloatingProductCard extends ConsumerWidget {
  const _FloatingProductCard({
    required this.index,
    required this.product,
    required this.onClose,
  });

  final int index;
  final Product product;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    final hasOriginal = product.originalPrice != null &&
        product.originalPrice! > product.price;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(appTheme.cardRadius),
            border:
                Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(appTheme.radiusSm),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: product.image.isNotEmpty
                      ? Image.network(
                          product.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: appTheme.bgSubtle,
                            alignment: Alignment.center,
                            child: Icon(Icons.image_outlined,
                                color: appTheme.fgMuted),
                          ),
                        )
                      : Container(
                          color: appTheme.bgSubtle,
                          alignment: Alignment.center,
                          child: Icon(Icons.image_outlined,
                              color: appTheme.fgMuted),
                        ),
                ),
              ),
              Positioned(
                top: -4,
                left: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '#$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(0)}',
                      style: GoogleFonts.getFont(
                        appTheme.fontDisplay,
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: accent,
                        ),
                      ),
                    ),
                    if (hasOriginal) ...[
                      const SizedBox(width: 5),
                      Text(
                        '\$${product.originalPrice!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.6),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: accent,
            borderRadius: BorderRadius.circular(appTheme.radiusSm),
            child: InkWell(
              borderRadius: BorderRadius.circular(appTheme.radiusSm),
              onTap: () =>
                  ref.read(cartProvider.notifier).addItem(product),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Text(
                  '立即下單',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
            ],
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// _GlassBottomInput — translucent comment bar + shopping-bag CTA used in
// the immersive layout (over the video).
// ───────────────────────────────────────────────────────────────────────────
class _GlassBottomInput extends StatelessWidget {
  const _GlassBottomInput({
    required this.ctrl,
    required this.hint,
    required this.onSend,
    required this.onBag,
  });

  final TextEditingController ctrl;
  final String hint;
  final VoidCallback onSend;
  final VoidCallback onBag;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  AppIcons.comment,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: accent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onBag,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
