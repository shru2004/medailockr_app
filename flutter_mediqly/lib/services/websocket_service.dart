// ─── WebSocket Service ──────────────────────────────────────────────────────
// Mirrors the connectWebSocket() function from backendService.ts exactly.
// Connects to ws://localhost:4000/ws with exponential-backoff auto-reconnect.

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../core/constants/api_endpoints.dart';

typedef WsEventCallback = void Function(Map<String, dynamic> event);

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  bool _reconnecting = false;
  bool _disposed = false;
  int _retryCount = 0;
  static const int _maxRetries = 5;

  WsEventCallback? _onEvent;

  void connect(WsEventCallback onEvent) {
    _onEvent = onEvent;
    _retryCount = 0;
    _connect();
  }

  void _connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(ApiEndpoints.wsUrl));
      _sub = _channel!.stream.listen(
        (data) {
          // successful message → reset retry counter
          _retryCount = 0;
          try {
            final parsed = json.decode(data as String) as Map<String, dynamic>;
            _onEvent?.call(parsed);
          } catch (_) {
            // ignore malformed frames
          }
        },
        onDone: _scheduleReconnect,
        onError: (_) => _scheduleReconnect(),
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_reconnecting || _disposed) return;
    if (_retryCount >= _maxRetries) {
      // Backend unavailable after max retries — stop retrying silently.
      return;
    }
    _reconnecting = true;
    _retryCount++;
    // Exponential back-off: 3s, 6s, 12s, 24s, 48s
    final delay = Duration(seconds: 3 * (1 << (_retryCount - 1)));
    Future.delayed(delay, () {
      if (_disposed) return;
      _reconnecting = false;
      _connect();
    });
  }

  /// Reset retry counter and attempt a fresh connection (e.g. user taps retry).
  void reconnect() {
    _retryCount = 0;
    _scheduleReconnect();
  }

  void send(Map<String, dynamic> data) {
    _channel?.sink.add(json.encode(data));
  }

  void dispose() {
    _disposed = true;
    _sub?.cancel();
    _channel?.sink.close();
  }
}
