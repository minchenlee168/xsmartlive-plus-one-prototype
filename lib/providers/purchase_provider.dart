import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/purchase.dart';
import 'repository_providers.dart';

typedef PurchasesFilter = ({
  String? status,
  int page,
  DateTime? startTime,
  DateTime? endTime,
  int? mallType,
  String? keyword,
});

final purchasesProvider =
    FutureProvider.family<PurchaseCollection, PurchasesFilter>(
        (ref, filter) async {
  return ref.read(purchaseRepositoryProvider).fetchPurchases(
        status: filter.status,
        page: filter.page,
        startTime: filter.startTime,
        endTime: filter.endTime,
        mallType: filter.mallType,
        productName: filter.keyword,
      );
});

final purchaseDetailProvider =
    FutureProvider.family<PurchaseDetail, int>((ref, id) async {
  return ref.read(purchaseRepositoryProvider).fetchPurchaseDetail(id);
});

class PurchaseCounts {
  const PurchaseCounts({
    required this.pending,
    required this.paid,
    required this.shipped,
    required this.completed,
  });

  final int pending;
  final int paid;
  final int shipped;
  final int completed;

  int get unfinished => pending + paid + shipped;
}

int _countFromCollection(PurchaseCollection c) {
  final total = int.tryParse(c.meta?.totalNumber ?? '');
  return total ?? c.data.length;
}

final purchaseCountsProvider = FutureProvider<PurchaseCounts>((ref) async {
  final repo = ref.read(purchaseRepositoryProvider);
  final results = await Future.wait([
    repo.fetchPurchases(status: 'pending', perPage: 10),
    repo.fetchPurchases(status: 'paid', perPage: 10),
    repo.fetchPurchases(status: 'shipped', perPage: 10),
    repo.fetchPurchases(status: 'completed', perPage: 10),
  ]);
  return PurchaseCounts(
    pending: _countFromCollection(results[0]),
    paid: _countFromCollection(results[1]),
    shipped: _countFromCollection(results[2]),
    completed: _countFromCollection(results[3]),
  );
});
