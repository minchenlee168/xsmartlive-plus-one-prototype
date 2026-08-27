/// 結帳任務狀態 — 對應後端 CheckoutTaskStatusEnum。
enum CheckoutTaskStatus {
  pending,
  processing,
  succeeded,
  failed,
  unknown;

  static CheckoutTaskStatus fromString(String? value) {
    switch (value) {
      case 'pending':
        return CheckoutTaskStatus.pending;
      case 'processing':
        return CheckoutTaskStatus.processing;
      case 'succeeded':
        return CheckoutTaskStatus.succeeded;
      case 'failed':
        return CheckoutTaskStatus.failed;
      default:
        return CheckoutTaskStatus.unknown;
    }
  }

  bool get isTerminal =>
      this == CheckoutTaskStatus.succeeded || this == CheckoutTaskStatus.failed;
}

/// 結帳任務資源 — 對應後端 CheckoutTaskResource。
///
/// 由 `POST /cart/checkout/confirm` 建立，並以
/// `GET /cart/checkout/task/{requestId}` 輪詢狀態。
class CheckoutTask {
  const CheckoutTask({
    required this.requestId,
    required this.taskId,
    required this.status,
    this.purchaseId,
    this.action,
    this.redirectUrl,
    this.errorCode,
    this.errorMessage,
    this.retryCount = 0,
    this.startedAt,
    this.finishedAt,
  });

  final String requestId;
  final int taskId;
  final CheckoutTaskStatus status;
  final int? purchaseId;
  final String? action;
  final String? redirectUrl;
  final int? errorCode;
  final String? errorMessage;
  final int retryCount;
  final String? startedAt;
  final String? finishedAt;

  factory CheckoutTask.fromJson(Map<String, dynamic> json) {
    return CheckoutTask(
      requestId: json['request_id'] as String? ?? '',
      taskId: (json['task_id'] as num?)?.toInt() ?? 0,
      status: CheckoutTaskStatus.fromString(json['status'] as String?),
      purchaseId: (json['purchase_id'] as num?)?.toInt(),
      action: json['action'] as String?,
      redirectUrl: json['redirect_url'] as String?,
      errorCode: (json['error_code'] as num?)?.toInt(),
      errorMessage: json['error_message'] as String?,
      retryCount: (json['retry_count'] as num?)?.toInt() ?? 0,
      startedAt: json['started_at'] as String?,
      finishedAt: json['finished_at'] as String?,
    );
  }
}
