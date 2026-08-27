import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/live_stream.dart';
import '../models/social_post_market.dart';
import 'repository_providers.dart';

class LivePageNotifier extends AsyncNotifier<LivePageState> {
  @override
  Future<LivePageState> build() async {
    final repo = ref.read(liveRepositoryProvider);
    final results = await Future.wait([
      repo.fetchCurrentLive(),
      repo.fetchHistoricalLives(),
    ]);
    final currentLive = results[0] as LiveStream?;
    final history = results[1] as List<LiveStream>;
    final comments = currentLive != null
        ? await repo.fetchComments(currentLive.id)
        : <LiveComment>[];
    return LivePageState(
      currentLive: currentLive,
      historicalLives: history,
      comments: comments,
    );
  }

  Future<void> sendComment(String message) async {
    final current = state.valueOrNull;
    if (current == null) return;
    // Optimistic update — append locally.
    final newComment = LiveComment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: '我',
      message: message,
      time: _now(),
    );
    state = AsyncData(current.copyWith(
      comments: [...current.comments, newComment],
    ));
  }

  String _now() {
    final t = DateTime.now();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}

class LivePageState {
  const LivePageState({
    this.currentLive,
    this.historicalLives = const [],
    this.comments = const [],
  });

  final LiveStream? currentLive;
  final List<LiveStream> historicalLives;
  final List<LiveComment> comments;

  LivePageState copyWith({
    LiveStream? currentLive,
    List<LiveStream>? historicalLives,
    List<LiveComment>? comments,
  }) {
    return LivePageState(
      currentLive: currentLive ?? this.currentLive,
      historicalLives: historicalLives ?? this.historicalLives,
      comments: comments ?? this.comments,
    );
  }
}

final livePageProvider =
    AsyncNotifierProvider<LivePageNotifier, LivePageState>(
  LivePageNotifier.new,
);

/// 社團貼文賣場 (B11) — empty list when backend returns nothing.
final groupPostMarketsProvider =
    FutureProvider<List<SocialPostMarket>>((ref) {
  return ref.read(marketRepositoryProvider).fetchGroupPostMarkets();
});

/// 粉絲團貼文賣場 (B11).
final fanPagePostMarketsProvider =
    FutureProvider<List<SocialPostMarket>>((ref) {
  return ref.read(marketRepositoryProvider).fetchFanPagePostMarkets();
});
