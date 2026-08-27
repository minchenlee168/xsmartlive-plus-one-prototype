import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/preset_theme_provider.dart';
import '../theme/preset_themes.dart';

/// Theme-keyed cart-fly FX system. Mirrors the prototype `src/fx.jsx` —
/// six preset variants (warm/minimal/vibrant/ecom/night/diva), each with its
/// own particle style, motion curve, ripple, and cart-icon receive bounce.
///
/// Usage:
///   1. Wrap the cart icon with `CartFlyAnimation.cartTargetWrapper(child:)`
///      so animations have a destination AND can play the receive bounce.
///   2. From any add-to-cart handler call
///      `CartFlyAnimation.fly(context: ctx, ref: ref, originGlobal: pos)`.
class CartFlyAnimation {
  CartFlyAnimation._();

  static final GlobalKey _targetKey =
      GlobalKey(debugLabel: 'cart-fly-target');

  /// Backwards-compatible accessor — earlier code wrapped the cart icon
  /// directly in a `KeyedSubtree(key: cartTargetKey, ...)`. New call sites
  /// should prefer `cartTargetWrapper` so the receive-bounce works too.
  static GlobalKey get cartTargetKey => _targetKey;

  /// Internal signal fired when particles arrive at the cart icon —
  /// the wrapper listens and plays a 550ms scale-bounce + glow.
  static final ValueNotifier<_ReceiveSignal?> _receiveSignal =
      ValueNotifier(null);

  /// Wraps the cart icon. Required for the FX system to find the target
  /// and to play the receive animation.
  static Widget cartTargetWrapper({required Widget child}) {
    return KeyedSubtree(
      key: _targetKey,
      child: _CartReceiveAnimator(
        signal: _receiveSignal,
        child: child,
      ),
    );
  }

  /// Trigger a fly animation. The active preset (read from
  /// `presetThemeProvider`) decides the visual style + motion curve;
  /// `null` (= remote merchant theme) falls back to the `warm` preset.
  static void fly({
    required BuildContext context,
    required WidgetRef ref,
    required Offset originGlobal,
  }) {
    final presetId = ref.read(presetThemeProvider).valueOrNull;
    final preset = _kPresets[presetId] ?? _kPresets[PresetId.warm]!;

    final cartCtx = _targetKey.currentContext;
    if (cartCtx == null) return;
    final cartBox = cartCtx.findRenderObject();
    if (cartBox is! RenderBox || !cartBox.attached) return;

    final cartCenter = cartBox.localToGlobal(Offset.zero) +
        Offset(cartBox.size.width / 2, cartBox.size.height / 2);

    final overlay = Overlay.of(context, rootOverlay: true);

    // Origin ripple — emanates from the tap point.
    late OverlayEntry rippleEntry;
    rippleEntry = OverlayEntry(
      builder: (_) => _OriginRipple(
        center: originGlobal,
        color: preset.rippleColor,
        onComplete: () => rippleEntry.remove(),
      ),
    );
    overlay.insert(rippleEntry);

    // Particles — count + visual + motion are all preset-driven.
    final rng = math.Random();
    final count = preset.particleCount;
    for (var i = 0; i < count; i++) {
      final angle = (math.pi * 2 * i) / count + (rng.nextDouble() - 0.5) * 0.3;
      final spread = count > 1 ? 18.0 + rng.nextDouble() * 22 : 0.0;
      final particleStart = originGlobal +
          Offset(math.cos(angle) * spread, math.sin(angle) * spread);
      final delay = Duration(milliseconds: i * 50 + rng.nextInt(60));
      final isLast = i == count - 1;

      late OverlayEntry particleEntry;
      particleEntry = OverlayEntry(
        builder: (_) => _Particle(
          from: particleStart,
          to: cartCenter,
          preset: preset,
          variant: i,
          total: count,
          delay: delay,
          onComplete: () {
            particleEntry.remove();
            if (isLast) {
              _receiveSignal.value =
                  _ReceiveSignal(preset.receiveGlow, DateTime.now());
            }
          },
        ),
      );
      overlay.insert(particleEntry);
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Preset table — mirrors fx.jsx FX_PRESETS exactly.
// ──────────────────────────────────────────────────────────────────────────
enum _FxStyle { softGlow, thinStroke, bokeh, badgeImpact, plasma, goldLeaf }
enum _FxMotion {
  arcSlow,
  lineSharp,
  spiralLoose,
  snapImpact,
  cometCurve,
  glideElegant,
}

@immutable
class _Preset {
  const _Preset({
    required this.accent,
    required this.accentSoft,
    required this.accentBg,
    required this.style,
    required this.motion,
    required this.rippleColor,
    required this.receiveGlow,
    required this.particleCount,
    required this.duration,
  });

  final Color accent;
  final Color accentSoft;
  final Color accentBg;
  final _FxStyle style;
  final _FxMotion motion;
  final Color rippleColor;
  final Color receiveGlow;
  final int particleCount;
  final Duration duration;
}

// Particle counts and durations from fx.jsx lines 128-150.
const _Preset _warm = _Preset(
  accent: Color(0xFFE07856),
  accentSoft: Color(0xFFFFCFB8),
  accentBg: Color(0xFFFFE8DA),
  style: _FxStyle.softGlow,
  motion: _FxMotion.arcSlow,
  rippleColor: Color(0x40E07856), // 0.25 alpha
  receiveGlow: Color(0xFFFFCFB8),
  particleCount: 4,
  duration: Duration(milliseconds: 1100),
);

const _Preset _minimal = _Preset(
  accent: Color(0xFF0A0A0A),
  accentSoft: Color(0xFFA89072),
  accentBg: Color(0xFFF5F4EE),
  style: _FxStyle.thinStroke,
  motion: _FxMotion.lineSharp,
  rippleColor: Color(0x1F0A0A0A), // 0.12 alpha
  receiveGlow: Color(0x260A0A0A), // 0.15 alpha
  particleCount: 1,
  duration: Duration(milliseconds: 500),
);

const _Preset _vibrant = _Preset(
  accent: Color(0xFFFF2E93),
  accentSoft: Color(0xFF7C5CFF),
  accentBg: Color(0x26FF2E93), // 0.15 alpha
  style: _FxStyle.bokeh,
  motion: _FxMotion.spiralLoose,
  rippleColor: Color(0x4DFF2E93), // 0.3 alpha
  receiveGlow: Color(0xFFFF8AC4),
  particleCount: 7,
  duration: Duration(milliseconds: 1200),
);

const _Preset _ecom = _Preset(
  accent: Color(0xFFEE3F4D),
  accentSoft: Color(0xFFFF7A00),
  accentBg: Color(0xFFFFE8E1),
  style: _FxStyle.badgeImpact,
  motion: _FxMotion.snapImpact,
  rippleColor: Color(0x66EE3F4D), // 0.4 alpha
  receiveGlow: Color(0xFFEE3F4D),
  particleCount: 1,
  duration: Duration(milliseconds: 420),
);

const _Preset _night = _Preset(
  accent: Color(0xFFFF3B6F),
  accentSoft: Color(0xFF9B6DFF),
  accentBg: Color(0x33FF3B6F), // 0.2 alpha
  style: _FxStyle.plasma,
  motion: _FxMotion.cometCurve,
  rippleColor: Color(0x809B6DFF), // 0.5 alpha
  receiveGlow: Color(0xFF9B6DFF),
  particleCount: 5,
  duration: Duration(milliseconds: 1000),
);

const _Preset _diva = _Preset(
  accent: Color(0xFFB8966E),
  accentSoft: Color(0xFFD4AD81),
  accentBg: Color(0xFFFDF3E3),
  style: _FxStyle.goldLeaf,
  motion: _FxMotion.glideElegant,
  rippleColor: Color(0x4DB8966E), // 0.3 alpha
  receiveGlow: Color(0xFFD4AD81),
  particleCount: 6,
  duration: Duration(milliseconds: 1300),
);

const Map<PresetId, _Preset> _kPresets = {
  PresetId.warm: _warm,
  PresetId.minimal: _minimal,
  PresetId.vibrant: _vibrant,
  PresetId.ecom: _ecom,
  PresetId.night: _night,
  PresetId.diva: _diva,
};

// ──────────────────────────────────────────────────────────────────────────
// Cart receive — wrapper that scales + glows when particles arrive.
// ──────────────────────────────────────────────────────────────────────────
@immutable
class _ReceiveSignal {
  const _ReceiveSignal(this.color, this.timestamp);
  final Color color;
  final DateTime timestamp;
}

class _CartReceiveAnimator extends StatefulWidget {
  const _CartReceiveAnimator({
    required this.signal,
    required this.child,
  });

  final ValueNotifier<_ReceiveSignal?> signal;
  final Widget child;

  @override
  State<_CartReceiveAnimator> createState() => _CartReceiveAnimatorState();
}

class _CartReceiveAnimatorState extends State<_CartReceiveAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  Color _glow = const Color(0x00000000);
  DateTime? _lastFired;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    widget.signal.addListener(_onSignal);
  }

  void _onSignal() {
    final s = widget.signal.value;
    if (s == null || s.timestamp == _lastFired) return;
    _lastFired = s.timestamp;
    setState(() => _glow = s.color);
    _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    widget.signal.removeListener(_onSignal);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      child: widget.child,
      builder: (ctx, child) {
        // Keyframes: 0%→20% scale 1→1.35 + glow rises;
        // 20%→50% scale 1.35→0.92; 50%→100% scale 0.92→1.
        final t = _ctrl.value;
        late double scale;
        if (t < 0.2) {
          scale = 1.0 + (t / 0.2) * 0.35;
        } else if (t < 0.5) {
          scale = 1.35 - ((t - 0.2) / 0.3) * 0.43;
        } else {
          scale = 0.92 + ((t - 0.5) / 0.5) * 0.08;
        }
        final glowAlpha = t < 0.2
            ? (t / 0.2)
            : t < 0.7
                ? 1.0 - (t - 0.2) / 0.5
                : 0.0;
        final glow = _glow.withValues(alpha: glowAlpha.clamp(0.0, 1.0));
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: glowAlpha > 0
                ? [
                    BoxShadow(
                      color: glow,
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Origin ripple — 40px ring expanding to 2.4× over 700ms.
// ──────────────────────────────────────────────────────────────────────────
class _OriginRipple extends StatefulWidget {
  const _OriginRipple({
    required this.center,
    required this.color,
    required this.onComplete,
  });

  final Offset center;
  final Color color;
  final VoidCallback onComplete;

  @override
  State<_OriginRipple> createState() => _OriginRippleState();
}

class _OriginRippleState extends State<_OriginRipple>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _ctrl.forward().whenComplete(widget.onComplete);
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
      builder: (ctx, _) {
        // cubic-bezier(.2,.8,.4,1) ≈ Curves.easeOutCubic
        final t = Curves.easeOutCubic.transform(_ctrl.value);
        final scale = 0.3 + t * (2.4 - 0.3);
        final opacity = (0.9 * (1.0 - t)).clamp(0.0, 1.0);
        return Positioned(
          left: widget.center.dx - 20,
          top: widget.center.dy - 20,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: widget.color, width: 2),
                    gradient: RadialGradient(
                      colors: [widget.color, widget.color.withValues(alpha: 0)],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Particle — flies from button origin to cart along motion-specific curve.
// ──────────────────────────────────────────────────────────────────────────
class _Particle extends StatefulWidget {
  const _Particle({
    required this.from,
    required this.to,
    required this.preset,
    required this.variant,
    required this.total,
    required this.delay,
    required this.onComplete,
  });

  final Offset from;
  final Offset to;
  final _Preset preset;
  final int variant;
  final int total;
  final Duration delay;
  final VoidCallback onComplete;

  @override
  State<_Particle> createState() => _ParticleState();
}

class _ParticleState extends State<_Particle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.preset.duration,
    );
    Future.delayed(widget.delay, () {
      if (!mounted) return;
      _ctrl.forward().whenComplete(widget.onComplete);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Curve P0 → P1 → P2 control point derived from prototype's mx/my values.
  // See fx.jsx lines 198-216 for the per-motion math.
  Offset _controlPoint() {
    final from = widget.from;
    final to = widget.to;
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final variant = widget.variant;
    final total = widget.total;

    late double mx, my;
    switch (widget.preset.motion) {
      case _FxMotion.arcSlow:
        mx = dx * 0.5;
        my = dy * 0.5 - 105; // -90 with avg jitter
      case _FxMotion.lineSharp:
      case _FxMotion.snapImpact:
        mx = dx * 0.5;
        my = dy * 0.5;
      case _FxMotion.spiralLoose:
        final a = (math.pi * 2 * variant) / total;
        mx = dx * 0.45 + math.cos(a) * 70;
        my = dy * 0.45 + math.sin(a) * 70;
      case _FxMotion.cometCurve:
        final a = (math.pi * 2 * variant) / total + 0.3;
        mx = math.cos(a) * 80 + dx * 0.3;
        my = math.sin(a) * 80 + dy * 0.3;
      case _FxMotion.glideElegant:
        mx = dx * 0.55 - 20;
        my = dy * 0.55 - 50;
    }
    // Bezier control point such that B(0.5) = from + (mx, my).
    return Offset(
      from.dx + 2 * mx - dx / 2,
      from.dy + 2 * my - dy / 2,
    );
  }

  static Offset _quadBezier(Offset p0, Offset p1, Offset p2, double t) {
    final u = 1 - t;
    return Offset(
      u * u * p0.dx + 2 * u * t * p1.dx + t * t * p2.dx,
      u * u * p0.dy + 2 * u * t * p1.dy + t * t * p2.dy,
    );
  }

  // Per-motion easing curve approximating the CSS cubic-beziers.
  Curve _easing() => switch (widget.preset.motion) {
        _FxMotion.arcSlow => Curves.easeInOutCubic,
        _FxMotion.lineSharp => Curves.easeInOut,
        _FxMotion.snapImpact => Curves.easeInOutBack,
        _FxMotion.spiralLoose => Curves.easeInOut,
        _FxMotion.cometCurve => Curves.easeInOut,
        _FxMotion.glideElegant => Curves.easeInOutCubic,
      };

  // Scale envelope (matches CSS keyframes per motion).
  double _scaleAt(double t) {
    switch (widget.preset.motion) {
      case _FxMotion.arcSlow:
        // 0%→20% 0.4→1, 20%→50% 1→1.05, 50%→100% 1.05→0.4
        if (t < 0.2) return 0.4 + (t / 0.2) * 0.6;
        if (t < 0.5) return 1.0 + ((t - 0.2) / 0.3) * 0.05;
        return 1.05 - ((t - 0.5) / 0.5) * 0.65;
      case _FxMotion.lineSharp:
        // 0%→25% 0.5→1, 25%→100% 1→0.6
        if (t < 0.25) return 0.5 + (t / 0.25) * 0.5;
        return 1.0 - ((t - 0.25) / 0.75) * 0.4;
      case _FxMotion.snapImpact:
        // 0%→15% 0.4→1.3 (overshoot), 15%→100% 1.3→0.5
        if (t < 0.15) return 0.4 + (t / 0.15) * 0.9;
        return 1.3 - ((t - 0.15) / 0.85) * 0.8;
      case _FxMotion.spiralLoose:
        if (t < 0.2) return 0.4 + (t / 0.2) * 0.7;
        if (t < 0.5) return 1.1 - ((t - 0.2) / 0.3) * 0.1;
        return 1.0 - ((t - 0.5) / 0.5) * 0.7;
      case _FxMotion.cometCurve:
        if (t < 0.15) return 0.5 + (t / 0.15) * 0.5;
        if (t < 0.5) return 1.0 + ((t - 0.15) / 0.35) * 0.2;
        return 1.2 - ((t - 0.5) / 0.5) * 0.8;
      case _FxMotion.glideElegant:
        // 0%→25% 0.3→1, 25%→50% 1→1.1, 50%→100% 1.1→0.4
        if (t < 0.25) return 0.3 + (t / 0.25) * 0.7;
        if (t < 0.5) return 1.0 + ((t - 0.25) / 0.25) * 0.1;
        return 1.1 - ((t - 0.5) / 0.5) * 0.7;
    }
  }

  // Rotation envelope (radians).
  double _rotationAt(double t) {
    switch (widget.preset.motion) {
      case _FxMotion.spiralLoose:
        // 0% 0deg → 50% 360 → 100% 720
        return t * 2 * math.pi * 2;
      case _FxMotion.glideElegant:
        // 0%→25% 0→45, 25%→50% 45→120, 50%→100% 120→240
        if (t < 0.25) return (t / 0.25) * (math.pi / 4);
        if (t < 0.5) {
          return (math.pi / 4) +
              ((t - 0.25) / 0.25) * (math.pi * 75 / 180);
        }
        return (math.pi * 120 / 180) +
            ((t - 0.5) / 0.5) * (math.pi * 120 / 180);
      default:
        return 0;
    }
  }

  // Opacity envelope.
  double _opacityAt(double t) {
    switch (widget.preset.motion) {
      case _FxMotion.arcSlow:
      case _FxMotion.glideElegant:
        if (t < 0.2) return t / 0.2;
        if (t < 0.85) return 1.0;
        return (1.0 - (t - 0.85) / 0.15).clamp(0.0, 1.0);
      case _FxMotion.snapImpact:
        if (t < 0.15) return t / 0.15;
        return (1.0 - (t - 0.15) / 0.85).clamp(0.0, 1.0) * 0.9 + 0.1;
      case _FxMotion.lineSharp:
        if (t < 0.25) return t / 0.25;
        return (1.0 - (t - 0.25) / 0.75).clamp(0.0, 1.0);
      case _FxMotion.spiralLoose:
        if (t < 0.2) return (t / 0.2) * 0.8;
        return (0.8 - (t - 0.2) / 0.8 * 0.8).clamp(0.0, 1.0);
      case _FxMotion.cometCurve:
        if (t < 0.15) return t / 0.15;
        return (1.0 - (t - 0.15) / 0.85).clamp(0.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (ctx, _) {
        final tRaw = _ctrl.value;
        final t = _easing().transform(tRaw);
        final pos =
            _quadBezier(widget.from, _controlPoint(), widget.to, t);
        final scale = _scaleAt(tRaw);
        final rotation = _rotationAt(tRaw);
        final opacity = _opacityAt(tRaw);
        return Positioned(
          left: pos.dx,
          top: pos.dy,
          child: IgnorePointer(
            child: Transform.translate(
              offset: const Offset(-18, -18),
              child: Opacity(
                opacity: opacity,
                child: Transform.rotate(
                  angle: rotation,
                  child: Transform.scale(
                    scale: scale,
                    child: _ParticleVisual(
                      style: widget.preset.style,
                      preset: widget.preset,
                      variant: widget.variant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
// Particle visuals — six styles mapped from fx.jsx renderParticle().
// ──────────────────────────────────────────────────────────────────────────
class _ParticleVisual extends StatelessWidget {
  const _ParticleVisual({
    required this.style,
    required this.preset,
    required this.variant,
  });

  final _FxStyle style;
  final _Preset preset;
  final int variant;

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case _FxStyle.softGlow:
        return _softGlow();
      case _FxStyle.thinStroke:
        return _thinStroke();
      case _FxStyle.bokeh:
        return _bokeh();
      case _FxStyle.badgeImpact:
        return _badgeImpact();
      case _FxStyle.plasma:
        return _plasma();
      case _FxStyle.goldLeaf:
        return _goldLeaf();
    }
  }

  // Cream/peach soft glow ball with layered radial.
  Widget _softGlow() {
    final size = 24.0 + (variant % 2) * 4;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.75,
          colors: [Colors.white, preset.accentSoft, preset.accent],
          stops: const [0.0, 0.6, 1.0],
        ),
        boxShadow: [
          BoxShadow(color: preset.accentSoft, blurRadius: 16),
          BoxShadow(color: preset.accentBg, blurRadius: 32),
        ],
      ),
    );
  }

  // Hairline ring + center dot — minimal aesthetic.
  Widget _thinStroke() {
    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: preset.accent, width: 1),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: preset.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Big blurred bokeh circle, mix of accent colors.
  Widget _bokeh() {
    const palette = <Color>[
      Color(0xFFFF2E93),
      Color(0xFF7C5CFF),
      Color(0xFFFFD700),
      Color(0xFF00C896),
    ];
    final color = palette[variant % palette.length];
    final size = 28.0 + (variant % 3) * 10;
    final blurSigma = (variant % 2) == 0 ? 1.0 : 4.0;
    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.55),
          boxShadow: [BoxShadow(color: color, blurRadius: 24)],
        ),
      ),
    );
  }

  // Crisp red badge with shock ring + check.
  Widget _badgeImpact() {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Shock ring
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: preset.accent.withValues(alpha: 0.5), width: 2),
            ),
          ),
          // Filled square badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: preset.accent,
              boxShadow: [
                BoxShadow(
                  color: preset.accent.withValues(alpha: 0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              '✓',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Plasma core + comet trail.
  Widget _plasma() {
    return SizedBox(
      width: 80,
      height: 20,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          // Comet trail
          Positioned(
            right: 8,
            top: 6,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                width: 60,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [
                      preset.accent.withValues(alpha: 0),
                      preset.accent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Core
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white, preset.accent],
                stops: const [0.0, 0.6],
              ),
              boxShadow: [
                BoxShadow(color: preset.accent, blurRadius: 20),
                BoxShadow(color: preset.accentSoft, blurRadius: 40),
                BoxShadow(color: preset.accentSoft, blurRadius: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Gold flake — 4 alternating shapes (rotated square / dot / ✦ / teardrop).
  Widget _goldLeaf() {
    switch (variant % 4) {
      case 0:
        return Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [preset.accent, preset.accentSoft],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66B8966E),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        );
      case 1:
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: preset.accent,
            boxShadow: [BoxShadow(color: preset.accentSoft, blurRadius: 8)],
          ),
        );
      case 2:
        return Text(
          '✦',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 18,
            color: preset.accent,
            height: 1.0,
            shadows: const [
              Shadow(
                color: Color(0x80B8966E),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        );
      default:
        return Transform.rotate(
          angle: -math.pi / 4,
          child: Container(
            width: 8,
            height: 16,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.zero,
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [preset.accentSoft, preset.accent],
              ),
            ),
          ),
        );
    }
  }
}
