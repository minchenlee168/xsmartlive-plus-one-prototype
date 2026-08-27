class WinMallBidRequest {
  const WinMallBidRequest({
    required this.productCardVariantId,
    required this.quantity,
    this.requestId,
  });

  final String? requestId;
  final int productCardVariantId;
  final int quantity;

  Map<String, dynamic> toJson() => {
        if (requestId != null && requestId!.isNotEmpty) 'request_id': requestId,
        'product_card_variant_id': productCardVariantId,
        'quantity': quantity,
      };
}

class WinMallBidResponse {
  const WinMallBidResponse({
    required this.requestId,
    required this.status,
  });

  final String requestId;
  final String status;

  factory WinMallBidResponse.fromJson(Map<String, dynamic> json) {
    return WinMallBidResponse(
      requestId: json['request_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}
