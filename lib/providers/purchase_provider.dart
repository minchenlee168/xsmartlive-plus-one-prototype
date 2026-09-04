import '../utils/platform_preview.dart';
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
  // Web 預覽打不到需授權的訂單 API（無 session），改用範例訂單，並在此
  // 依狀態 / 關鍵字（訂單編號）/ 日期區間過濾，讓下拉篩選與搜尋可實際運作。
  if (isWebPreview) return _sampleOrderCollection(filter);
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
  if (isWebPreview) return _sampleOrderDetail(id);
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
  if (isWebPreview) {
    return PurchaseCounts(
      pending: sampleOrderCount('pending'),
      paid: sampleOrderCount('paid'),
      shipped: sampleOrderCount('shipped'),
      completed: sampleOrderCount('completed'),
    );
  }
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

// ── 訂單狀態選項 + 範例資料（web 預覽 / 未登入 fallback）─────────────────
/// 對照設計稿的 10 種狀態；`code == null` = 全部。真機的狀態代碼以後端為準，
/// 退貨中 / 已退貨 / 已換貨 / 已取消等為 prototype 範例用途。
const List<({String? code, String label})> kOrderStatusOptions = [
  (code: null, label: '全部'),
  (code: 'paid', label: '待出貨'),
  (code: 'preparing', label: '備貨中'),
  (code: 'shipped', label: '已出貨'),
  (code: 'delivered', label: '已送達'),
  (code: 'completed', label: '已完成'),
  (code: 'returning', label: '退貨中'),
  (code: 'returned', label: '已退貨'),
  (code: 'exchanged', label: '已換貨'),
  (code: 'cancelled', label: '已取消'),
];

/// 範例訂單狀態的顯示文字。
String orderStatusLabel(String? code) {
  for (final o in kOrderStatusOptions) {
    if (o.code == code) return o.label;
  }
  return code ?? '';
}

/// prototype：拆成多個包裹、含多個貨態的訂單 id。這類訂單的顯示狀態為「處理中」。
const Set<int> kMultiFulfillmentOrderIds = {100006};

/// 20 筆範例訂單，分布於各狀態（待出貨 5 / 備貨中 2 / 已出貨 1 / 已送達 3 /
/// 已完成 3 / 退貨中 1 / 已退貨 1 / 已換貨 1 / 已取消 3）。日期落在近 3 個月，
/// 預設查詢區間即可看到。
const List<Purchase> kSampleOrders = [
  // 待出貨 x5
  Purchase(id: 100020, createdAt: '2026-08-30T20:14:00', itemCount: 2, amount: 1690, paymentMethod: '信用卡', shippingMethod: '超商取貨', status: 'paid'),
  Purchase(id: 100019, createdAt: '2026-08-28T13:02:00', itemCount: 1, amount: 890, paymentMethod: 'LINE Pay', shippingMethod: '宅配', status: 'paid'),
  Purchase(id: 100018, createdAt: '2026-08-26T09:47:00', itemCount: 3, amount: 3280, paymentMethod: '信用卡', shippingMethod: '宅配', status: 'paid'),
  Purchase(id: 100017, createdAt: '2026-08-24T21:30:00', itemCount: 2, amount: 1180, paymentMethod: 'Apple Pay', shippingMethod: '超商取貨', status: 'paid'),
  Purchase(id: 100016, createdAt: '2026-08-22T17:08:00', itemCount: 1, amount: 760, paymentMethod: 'LINE Pay', shippingMethod: '宅配', status: 'paid'),
  // 備貨中 x2
  Purchase(id: 100015, createdAt: '2026-08-18T15:20:00', itemCount: 4, amount: 4560, paymentMethod: '信用卡', shippingMethod: '宅配', status: 'preparing'),
  Purchase(id: 100014, createdAt: '2026-08-15T11:05:00', itemCount: 1, amount: 599, paymentMethod: '貨到付款', shippingMethod: '超商取貨', status: 'preparing'),
  // 已出貨 x1（多包裹範例訂單）
  Purchase(id: 100006, createdAt: '2026-08-10T18:41:00', itemCount: 2, amount: 2050, paymentMethod: '信用卡', shippingMethod: '宅配', status: 'shipped'),
  // 已送達 x3
  Purchase(id: 100013, createdAt: '2026-08-05T10:12:00', itemCount: 3, amount: 1780, paymentMethod: 'LINE Pay', shippingMethod: '超商取貨', status: 'delivered'),
  Purchase(id: 100012, createdAt: '2026-08-01T14:33:00', itemCount: 1, amount: 990, paymentMethod: '信用卡', shippingMethod: '宅配', status: 'delivered'),
  Purchase(id: 100011, createdAt: '2026-07-28T19:22:00', itemCount: 2, amount: 1360, paymentMethod: 'Apple Pay', shippingMethod: '宅配', status: 'delivered'),
  // 已完成 x3
  Purchase(id: 100010, createdAt: '2026-07-22T20:00:00', itemCount: 5, amount: 5320, paymentMethod: '信用卡', shippingMethod: '宅配', status: 'completed'),
  Purchase(id: 100009, createdAt: '2026-07-15T09:15:00', itemCount: 2, amount: 1440, paymentMethod: 'Apple Pay', shippingMethod: '超商取貨', status: 'completed'),
  Purchase(id: 100008, createdAt: '2026-07-08T16:50:00', itemCount: 1, amount: 760, paymentMethod: 'LINE Pay', shippingMethod: '宅配', status: 'completed'),
  // 退貨中 x1
  Purchase(id: 100007, createdAt: '2026-07-02T12:30:00', itemCount: 1, amount: 1280, paymentMethod: '信用卡', shippingMethod: '宅配', status: 'returning'),
  // 已退貨 x1
  Purchase(id: 100005, createdAt: '2026-06-26T11:40:00', itemCount: 2, amount: 2180, paymentMethod: 'LINE Pay', shippingMethod: '超商取貨', status: 'returned'),
  // 已換貨 x1
  Purchase(id: 100004, createdAt: '2026-06-20T15:05:00', itemCount: 1, amount: 990, paymentMethod: '信用卡', shippingMethod: '宅配', status: 'exchanged'),
  // 已取消 x3
  Purchase(id: 100003, createdAt: '2026-06-14T20:18:00', itemCount: 3, amount: 3050, paymentMethod: '信用卡', shippingMethod: '宅配', status: 'cancelled'),
  Purchase(id: 100002, createdAt: '2026-06-10T09:33:00', itemCount: 2, amount: 1440, paymentMethod: 'Apple Pay', shippingMethod: '超商取貨', status: 'cancelled'),
  Purchase(id: 100001, createdAt: '2026-06-05T16:50:00', itemCount: 1, amount: 680, paymentMethod: 'LINE Pay', shippingMethod: '宅配', status: 'cancelled'),
];

int sampleOrderCount(String? status) => status == null
    ? kSampleOrders.length
    : kSampleOrders.where((o) => o.status == status).length;

PurchaseCollection _sampleOrderCollection(PurchasesFilter filter) {
  final list = kSampleOrders.where((o) {
    if (filter.status != null && o.status != filter.status) return false;
    final kw = filter.keyword;
    if (kw != null && kw.trim().isNotEmpty &&
        !o.id.toString().contains(kw.trim())) {
      return false;
    }
    final dt = DateTime.tryParse(o.createdAt);
    if (dt != null) {
      if (filter.startTime != null && dt.isBefore(filter.startTime!)) {
        return false;
      }
      if (filter.endTime != null && dt.isAfter(filter.endTime!)) return false;
    }
    return true;
  }).toList(growable: false);
  return PurchaseCollection(
    data: list,
    meta: PurchasePagination(
      currentPage: '1',
      pageSize: '${list.length}',
      totalPages: '1',
      totalNumber: '${list.length}',
    ),
  );
}

/// 依 fulfillment 狀態碼（0 待出貨 / 1 已出貨 / 3 已送達）組出範例包裹，
/// 並把各階段時間戳補到「已達成」為止。
PurchaseFulfillment _sampleFulfillment(
  int orderId,
  int seq,
  int fStatus,
  String createdAt,
  int qty,
) {
  return PurchaseFulfillment(
    // 產生類似物流包裹單號的數字（顯示為 P{id}），各包裹唯一。
    id: 2024300000 + (orderId % 100000) * 10 + seq,
    status: fStatus,
    statusLabel: switch (fStatus) {
      1 => '已出貨',
      2 => '配送中',
      3 => '已送達',
      _ => '待出貨',
    },
    itemQuantity: '$qty',
    paidAt: createdAt,
    shippedAt: fStatus >= 1 ? createdAt : null,
    deliveredAt: fStatus >= 3 ? createdAt : null,
    completedAt: null,
  );
}

PurchaseDetail _sampleOrderDetail(int id) {
  final order = kSampleOrders.firstWhere(
    (o) => o.id == id,
    orElse: () => kSampleOrders.first,
  );

  // 示範：訂單 100006 拆成兩個包裹 —— 包裹 1 已送達、包裹 2 已出貨。
  if (order.id == 100006) {
    return PurchaseDetail(
      id: id,
      items: [
        PurchaseDetailItem(
          id: id * 10 + 1,
          productName: '範例商品 ${order.id}',
          variantName: '標準規格',
          unitPrice: 1025,
          quantity: 2,
          fulfillments: [
            _sampleFulfillment(id, 1, 3, order.createdAt, 1), // 包裹1 已送達
            _sampleFulfillment(id, 2, 1, order.createdAt, 1), // 包裹2 已出貨
          ],
        ),
      ],
    );
  }

  final status = order.status;
  final fStatus = switch (status) {
    'shipped' => 1,
    'delivered' => 3,
    'completed' => 3,
    _ => 0,
  };
  return PurchaseDetail(
    id: id,
    items: [
      PurchaseDetailItem(
        id: id * 10 + 1,
        productName: '範例商品 ${order.id}',
        variantName: '標準規格',
        unitPrice: order.amount,
        quantity: order.itemCount,
        fulfillments: [
          _sampleFulfillment(id, 1, fStatus, order.createdAt, order.itemCount),
        ],
      ),
    ],
  );
}
