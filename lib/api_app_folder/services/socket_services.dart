import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  final _controller = StreamController<dynamic>.broadcast();

  Stream<dynamic> get stream => _controller.stream;

  bool get isConnected => _channel != null;

  void connect(String url, {Map<String, String>? headers}) {
    if (_channel != null) return;

    _channel = WebSocketChannel.connect(
      Uri.parse(url),
      // protocols: [
      //   'auth',
      //   'token_${yourToken}',
      // ],
     // headers: headers,
    );

    _channel?.stream.listen((data) {
        try {
          final decoded = jsonDecode(data);
          _controller.add(decoded);
        } catch (_) {
          _controller.add(data);
        }
      },
      onError: (error) {
        _controller.addError(error);
        _reconnect(url, headers);
      },
      onDone: () {
        _reconnect(url, headers);
      },
    );
  }

  /// SEND DATA
  void send(dynamic data) {
    if (_channel == null) {
      debugPrint('[WS] ❌ Send failed: Socket not connected');
      return;
    }

    final payload =
    data is String ? data : jsonEncode(data);
    _channel?.sink.add(payload);
    debugPrint(
      '[WS] 📤 Sent → ${_truncate(payload)}',
    );
  }
  String _truncate(String text, {int max = 5000}) {
    if (text.length <= max) return text;
    return '${text.substring(0, max)}...(${text.length} chars)';
  }

  /// DISCONNECT
  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  /// AUTO RECONNECT
  void _reconnect(String url, Map<String, String>? headers) async {
    disconnect();
    await Future.delayed(const Duration(seconds: 3));
    connect(url, headers: headers);
  }

  /// CLEANUP
  void dispose() {
    disconnect();
    _controller.close();
  }
}