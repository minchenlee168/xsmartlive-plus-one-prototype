import 'dart:async';

/// Broadcasts session-expiry events from [DioClient] to [AuthNotifier].
/// Using a broadcast stream decouples the interceptor from Riverpod.
class SessionService {
  final _controller = StreamController<void>.broadcast();

  Stream<void> get sessionExpiredStream => _controller.stream;

  void notifySessionExpired() {
    if (!_controller.isClosed) _controller.add(null);
  }

  void dispose() => _controller.close();
}
