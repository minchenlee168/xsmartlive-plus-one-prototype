import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mock_data.dart';
import '../models/notification_item.dart';

class NotificationNotifier extends Notifier<List<NotificationItem>> {
  @override
  List<NotificationItem> build() => MockData.notifications;

  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, List<NotificationItem>>(
  NotificationNotifier.new,
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).where((n) => !n.isRead).length;
});
