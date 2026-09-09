import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/notification_item.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme_extension.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationProvider);
    final unread = notifications.where((n) => !n.isRead).toList();

    final appTheme = context.appTheme;
    return Scaffold(
      backgroundColor: appTheme.bg,
      body: Column(
        children: [
          // Header
          Container(
            color: appTheme.bgElev,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top + 56,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    appTheme.spacingLg,
                    appTheme.spacingLg,
                    appTheme.spacingLg,
                    appTheme.spacingXs,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('通知中心',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: appTheme.fg)),
                      TextButton(
                        onPressed: () => ref
                            .read(notificationProvider.notifier)
                            .markAllAsRead(),
                        style: TextButton.styleFrom(
                          foregroundColor: appTheme.brandPalette.tone500,
                        ),
                        child: const Text('全部已讀'),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: appTheme.spacingLg),
                  child: Text('${unread.length} 則未讀通知',
                      style: TextStyle(
                          fontSize: 12, color: appTheme.fgMuted)),
                ),
                SizedBox(height: appTheme.spacingXs),
                TabBar(
                  controller: _tabCtrl,
                  labelColor: appTheme.brandPalette.tone500,
                  unselectedLabelColor: appTheme.fgMuted,
                  indicatorColor: appTheme.brandPalette.tone500,
                  tabs: [
                    Tab(text: '全部 (${notifications.length})'),
                    Tab(text: '未讀 (${unread.length})'),
                  ],
                ),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _NotificationList(notifications: notifications),
                _NotificationList(notifications: unread),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationList extends ConsumerWidget {
  const _NotificationList({required this.notifications});
  final List<NotificationItem> notifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_none,
                size: 48, color: appTheme.muted),
            SizedBox(height: appTheme.spacingMd),
            Text('暫無通知', style: TextStyle(color: appTheme.fgMuted)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(appTheme.spacingLg),
      itemCount: notifications.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: appTheme.spacingXs),
      itemBuilder: (context, i) => _NotificationTile(
        item: notifications[i],
        onTap: () => ref
            .read(notificationProvider.notifier)
            .markAsRead(notifications[i].id),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});
  final NotificationItem item;
  final VoidCallback onTap;

  static const _typeConfig = {
    NotificationType.live: (Icons.live_tv, Colors.red),
    NotificationType.cart: (Icons.shopping_cart, Colors.purple),
    NotificationType.favorite: (Icons.favorite, Colors.pink),
    NotificationType.promotion: (Icons.local_offer, Colors.orange),
  };

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final scheme = Theme.of(context).colorScheme;
    final (icon, semColor) = _typeConfig[item.type] ??
        (Icons.notifications, Colors.blue);

    final unreadAccent = appTheme.brandPalette.tone500;

    return Card(
      elevation: 0,
      color: item.isRead
          ? scheme.surface
          : unreadAccent.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        side: BorderSide(
          color: item.isRead
              ? scheme.outlineVariant
              : unreadAccent.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(appTheme.cardRadius),
        child: Padding(
          padding: EdgeInsets.all(appTheme.spacingLg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(appTheme.spacingSm),
                decoration: BoxDecoration(
                  color: semColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: semColor, size: 20),
              ),
              SizedBox(width: appTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: appTheme.fg)),
                        ),
                        if (!item.isRead)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: unreadAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('新',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    SizedBox(height: appTheme.spacingXs),
                    Text(item.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14, color: appTheme.fg)),
                    SizedBox(height: appTheme.spacingXs),
                    Text(item.time,
                        style: TextStyle(
                            fontSize: 12, color: appTheme.fgMuted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
