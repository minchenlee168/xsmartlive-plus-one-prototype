import 'package:dio/dio.dart';

import '../../config/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../models/cart_api.dart';
import '../../models/win_mall_bid.dart';
import '../dio_client.dart';

class CartRepository {
  CartRepository(this._dioClient);

  final DioClient _dioClient;

  Future<CartApi?> fetchCart() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.cart);
      final body = response.data as Map<String, dynamic>;
      return _extractFirstCart(body);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// POST /api/v1/mall/store/{store}/market/mall/{market}/win — 商城卡 (type=2).
  Future<WinMallBidResponse> winMallBid({
    required int marketId,
    required WinMallBidRequest request,
  }) =>
      _winBid(ApiConstants.marketMallWin(marketId), request);

  /// POST /api/v1/mall/store/{store}/market/live/{market}/win — 直播卡 (type=1).
  /// Same shape as [winMallBid], different endpoint. Server returns
  /// `20103: 賣場類型不符` if you call the wrong one for the card type.
  Future<WinMallBidResponse> winLiveBid({
    required int marketId,
    required WinMallBidRequest request,
  }) =>
      _winBid(ApiConstants.marketLiveWin(marketId), request);

  Future<WinMallBidResponse> _winBid(
    String url,
    WinMallBidRequest request,
  ) async {
    try {
      final response = await _dioClient.dio.post(
        url,
        data: request.toJson(),
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == false) {
        throw ServerException(body['message'] as String? ?? 'Add to cart failed');
      }
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return WinMallBidResponse.fromJson(data);
      }
      return WinMallBidResponse.fromJson(body);
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// POST /api/v1/mall/store/{store}/cart/item/{cartItemId}/update
  Future<void> updateItem(int cartItemId, {required int quantity}) async {
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.cartUpdateItem(cartItemId),
        data: {'quantity': quantity},
      );
      _ensureSuccess(response.data, 'Update cart item failed');
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// POST /api/v1/mall/store/{store}/cart/item/{cartItemId}/destroy
  Future<void> removeItem(int cartItemId) async {
    try {
      final response =
          await _dioClient.dio.post(ApiConstants.cartRemoveItem(cartItemId));
      _ensureSuccess(response.data, 'Remove cart item failed');
    } on DioException catch (e) {
      throw dioErrorToAppException(e);
    }
  }

  /// Throws a [ServerException] if the response carries `success: false`.
  /// Otherwise returns silently. (Some 200-OK responses still represent
  /// failure — e.g. `success: false, code: 20103`.)
  void _ensureSuccess(dynamic body, String fallback) {
    if (body is Map<String, dynamic> && body['success'] == false) {
      throw ServerException(body['message'] as String? ?? fallback);
    }
  }

  CartApi? _extractFirstCart(Map<String, dynamic> body) {
    final data = body['data'] as List<dynamic>?;
    if (data == null || data.isEmpty) return null;
    return CartApi.fromJson(data.first as Map<String, dynamic>);
  }
}
