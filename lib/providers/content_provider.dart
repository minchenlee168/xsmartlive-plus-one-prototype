import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/banner.dart';
import '../models/search_keyword.dart';
import '../models/store_collection.dart';
import '../models/store_marquee.dart';
import '../models/stream_board_item.dart';
import 'repository_providers.dart';

final bannerListProvider = FutureProvider<List<StoreBanner>>((ref) {
  return ref.read(contentRepositoryProvider).fetchStoreBanners();
});

final streamBoardListProvider = FutureProvider<List<StreamBoardItem>>((ref) {
  return ref.read(contentRepositoryProvider).fetchStreamBoards();
});

final storeMarqueeListProvider = FutureProvider<List<StoreMarquee>>((ref) {
  return ref.read(contentRepositoryProvider).fetchStoreMarquees();
});

final keywordListProvider = FutureProvider<List<SearchKeyword>>((ref) {
  return ref.read(contentRepositoryProvider).fetchKeywords();
});

/// Active 主題館 (store collections) — B8.
final storeCollectionsProvider =
    FutureProvider<List<StoreCollection>>((ref) {
  return ref.read(contentRepositoryProvider).fetchStoreCollections();
});

/// Items inside a specific 主題館 — B8 detail.
final storeCollectionItemsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((ref, id) {
  return ref.read(contentRepositoryProvider).fetchStoreCollectionItems(id);
});
