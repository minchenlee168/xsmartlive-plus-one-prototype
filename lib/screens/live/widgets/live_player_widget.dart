import 'package:flutter/material.dart';

import '../../../models/live_stream.dart';

class LivePlayerWidget extends StatelessWidget {
  const LivePlayerWidget({
    super.key,
    required this.live,
    this.commentCount = 0,
    this.showOverlay = true,
    this.onFullscreen,
    this.height,
  });

  final LiveStream live;
  final int commentCount;
  final bool showOverlay;
  final VoidCallback? onFullscreen;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final stack = Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black87),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.live_tv, size: 48, color: scheme.onPrimary),
                const SizedBox(height: 8),
                Text(
                  live.title,
                  style: TextStyle(color: scheme.onPrimary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Top: LIVE badge
          if (live.isLive)
            Positioned(
              top: 12,
              left: 12,
              child: AnimatedOpacity(
                opacity: showOverlay ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 250),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('🔴 LIVE',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ),
            ),
          // Bottom: stats + share
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: AnimatedOpacity(
              opacity: showOverlay ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _OverlayChip(
                            icon: Icons.remove_red_eye,
                            label: '${live.viewers}'),
                        const SizedBox(width: 8),
                        _OverlayChip(
                            icon: Icons.favorite, label: '${live.likes}'),
                        const SizedBox(width: 8),
                        _OverlayChip(
                            icon: Icons.chat_bubble_outline,
                            label: '$commentCount'),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.share,
                        color: Colors.white, size: 20),
                  ),
                  if (onFullscreen != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onFullscreen,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.fullscreen,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );

    if (height != null) {
      return SizedBox(width: double.infinity, height: height, child: stack);
    }
    return AspectRatio(aspectRatio: 16 / 9, child: stack);
  }
}

class _OverlayChip extends StatelessWidget {
  const _OverlayChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style:
                  const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
