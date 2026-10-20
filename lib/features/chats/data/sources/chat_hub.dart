import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

// -------------------------------------------------------------
// ChatHub — اتصال لحظي بهَب SignalR على سيرفر ASP.NET Core (بروتوكول JSON فوق WebSocket، بدون negotiate):
//   1) WebSocket على /hubs/chat مع  Authorization: Bearer <token>
//   2) handshake:  {"protocol":"json","version":1}␞   ← السيرفر بيرد {}␞
//   3) السيرفر بيبعت  {"type":1,"target":"ReceiveMessage","arguments":[MessageDto]}␞  لكل رسالة جديدة
//   4) ping كل 15 ثانية {"type":6}␞ (حتى ما يسكّر السيرفر الاتصال) — ولو انقطع بيرجع يتصل لحاله (2، 4، 8… لحد 30 ثانية)
// (␞ = الحرف 0x1E اللي بيفصل الرسائل ببروتوكول SignalR)
// -------------------------------------------------------------
typedef WebSocketConnector = Future<WebSocket> Function(Uri uri, Map<String, String> headers);

class ChatHub {
  final Uri uri;
  final Future<String?> Function() accessToken;
  final Duration pingInterval;
  final WebSocketConnector _connect;

  ChatHub({required this.uri, required this.accessToken, this.pingInterval = const Duration(seconds: 15), WebSocketConnector? connector})
    : _connect = connector ?? ((uri, headers) => WebSocket.connect(uri.toString(), headers: headers));

  static const _separator = '\u001e';

  final _messages = StreamController<Map<String, dynamic>>.broadcast();
  WebSocket? _socket;
  Timer? _ping;
  Timer? _retry;
  bool _active = false;
  bool _handshaken = false;
  int _attempt = 0;

  /// MessageDto لكل رسالة جديدة بتوصل
  Stream<Map<String, dynamic>> get messages => _messages.stream;

  bool get isConnected => _socket != null && _handshaken;

  void start() {
    if (_active) return;
    _active = true;
    _open();
  }

  Future<void> _open() async {
    _retry?.cancel();
    try {
      final token = await accessToken();
      final socket = await _connect(uri, {if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'}).timeout(const Duration(seconds: 10));
      if (!_active) {
        await socket.close();
        return;
      }
      _socket = socket;
      _handshaken = false;
      socket.listen(_onData, onDone: _onClosed, onError: (_) => _onClosed(), cancelOnError: true);
      socket.add('{"protocol":"json","version":1}$_separator');
      _ping?.cancel();
      _ping = Timer.periodic(pingInterval, (_) => _write('{"type":6}'));
    } catch (_) {
      _scheduleRetry();
    }
  }

  void _write(String record) {
    try {
      _socket?.add('$record$_separator');
    } catch (_) {
      _onClosed();
    }
  }

  void _onData(dynamic data) {
    final text = data is String ? data : utf8.decode(data as List<int>, allowMalformed: true);
    for (final record in text.split(_separator)) {
      if (record.trim().isEmpty) continue;
      final Object? json;
      try {
        json = jsonDecode(record);
      } catch (_) {
        continue;
      }
      if (json is! Map<String, dynamic>) continue;
      if (!_handshaken) {
        // رد الـ handshake: {} — أو {"error": "..."}
        if (json['error'] != null) {
          _socket?.close();
          return;
        }
        _handshaken = true;
        _attempt = 0;
        continue;
      }
      switch (json['type']) {
        case 1:
          if ((json['target'] as String?)?.toLowerCase() != 'receivemessage') break;
          for (final argument in (json['arguments'] as List? ?? const [])) {
            if (argument is Map<String, dynamic>) _messages.add(argument);
          }
        case 7:
          _socket?.close();
      }
    }
  }

  void _onClosed() {
    _ping?.cancel();
    _socket = null;
    _handshaken = false;
    if (_active) _scheduleRetry();
  }

  void _scheduleRetry() {
    if (!_active) return;
    _attempt++;
    final seconds = math.min(30, math.pow(2, _attempt).toInt());
    _retry?.cancel();
    _retry = Timer(Duration(seconds: seconds), _open);
  }

  Future<void> stop() async {
    _active = false;
    _retry?.cancel();
    _ping?.cancel();
    final socket = _socket;
    _socket = null;
    _handshaken = false;
    await socket?.close();
  }

  Future<void> dispose() async {
    await stop();
    await _messages.close();
  }
}
