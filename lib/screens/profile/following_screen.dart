import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme_extension.dart';
import '../../widgets/back_leading_button.dart';

/// 我的追蹤 —— 列出會員追蹤的直播主。與「我的最愛（收藏商品）」區隔：
/// 這裡追蹤的是「直播主 / 直播場次」，不是商品。
///
/// 直播間有「+ 追蹤」按鈕，本頁即是查看已追蹤主播的入口。內容為 prototype
/// 範例資料；追蹤狀態以純前端狀態切換，樣式沿用 Theme token。
class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _Streamer {
  const _Streamer({
    required this.id,
    required this.name,
    required this.tagline,
    required this.followers,
    required this.isLive,
  });
  final int id;
  final String name;
  final String tagline;

  /// 已格式化的粉絲數，例如「12.5 萬」。
  final String followers;
  final bool isLive;
}

const List<_Streamer> _sampleStreamers = [
  _Streamer(
    id: 1,
    name: '美妝達人小芸',
    tagline: '每日 20:00 美妝開箱・專櫃快閃',
    followers: '12.5 萬',
    isLive: true,
  ),
  _Streamer(
    id: 2,
    name: 'Kelly 美妝快閃',
    tagline: '開架 ✕ 專櫃彩妝・限時下殺',
    followers: '5.6 萬',
    isLive: true,
  ),
  _Streamer(
    id: 3,
    name: '廚娘小桂的直播廚房',
    tagline: '生鮮冷凍・職人料理包',
    followers: '8.2 萬',
    isLive: false,
  ),
  _Streamer(
    id: 4,
    name: 'Mia 保養專場',
    tagline: '醫美級保養・成分控推薦',
    followers: '3.1 萬',
    isLive: false,
  ),
  _Streamer(
    id: 5,
    name: '鮮選市集直播',
    tagline: '產地海鮮直送・當日現撈',
    followers: '9.9 萬',
    isLive: true,
  ),
  _Streamer(
    id: 6,
    name: '媽咪好物推薦',
    tagline: '嬰幼兒用品・親子好物開團',
    followers: '2.4 萬',
    isLive: false,
  ),
];

class _FollowingScreenState extends State<FollowingScreen> {
  /// 被取消追蹤的 id（純前端狀態）。
  final Set<int> _unfollowed = {};

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final followingCount =
        _sampleStreamers.where((s) => !_unfollowed.contains(s.id)).length;

    return Scaffold(
      backgroundColor: appTheme.bg,
      appBar: AppBar(
        leading: const BackLeadingButton(
          fallbackLocation: '/profile',
          color: Colors.white,
        ),
        title: const Text('我的追蹤'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appTheme.primaryGradient),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: appTheme.bgElev,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Text(
              '追蹤中的直播主 · $followingCount',
              style: TextStyle(fontSize: 13, color: appTheme.fgMuted),
            ),
          ),
          Divider(height: 1, color: appTheme.divider),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _sampleStreamers.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: appTheme.divider, indent: 76),
              itemBuilder: (context, i) {
                final s = _sampleStreamers[i];
                return _StreamerRow(
                  streamer: s,
                  following: !_unfollowed.contains(s.id),
                  onToggleFollow: () => setState(() {
                    if (_unfollowed.contains(s.id)) {
                      _unfollowed.remove(s.id);
                    } else {
                      _unfollowed.add(s.id);
                    }
                  }),
                  onTap: () {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(s.isLive
                              ? '前往 ${s.name} 的直播間（prototype）'
                              : '${s.name} 目前休息中'),
                        ),
                      );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamerRow extends StatelessWidget {
  const _StreamerRow({
    required this.streamer,
    required this.following,
    required this.onToggleFollow,
    required this.onTap,
  });

  final _Streamer streamer;
  final bool following;
  final VoidCallback onToggleFollow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final initial = streamer.name.isNotEmpty ? streamer.name[0] : '?';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 頭像 + 直播中光環
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: appTheme.primaryGradient,
                    border: streamer.isLive
                        ? Border.all(color: appTheme.danger, width: 2)
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: GoogleFonts.getFont(
                      appTheme.fontDisplay,
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                if (streamer.isLive)
                  Positioned(
                    bottom: -4,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: appTheme.danger,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: appTheme.bgElev, width: 1),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // 名稱 + 狀態 + 簡介 + 粉絲數
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          streamer.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: appTheme.fg,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        streamer.isLive ? '直播中' : '休息中',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: streamer.isLive
                              ? appTheme.danger
                              : appTheme.fgMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    streamer.tagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: appTheme.fgMuted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${streamer.followers} 粉絲',
                    style: TextStyle(fontSize: 11, color: appTheme.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // 追蹤 / 已追蹤 切換
            _FollowButton(following: following, onTap: onToggleFollow),
          ],
        ),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.following, required this.onTap});
  final bool following;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final accent = appTheme.brandPalette.tone500;

    if (following) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: appTheme.fgMuted,
          side: BorderSide(color: appTheme.divider),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(appTheme.buttonRadius),
          ),
        ),
        child: const Text('已追蹤', style: TextStyle(fontSize: 12)),
      );
    }
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(appTheme.buttonRadius),
        ),
      ),
      child: const Text('追蹤',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}
