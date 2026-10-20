import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

// -------------------------------------------------------------
// SignalRHub — اتصال لحظي بهَب SignalR على سيرفر ASP.NET Core (بروتوكول JSON فوق WebSocket، بدون negotiate):
//   1) WebSocket على العنوان مع  ?access_token=<token>  (ملف السيرفر: WebSockets ما بيبعت ترويسة Authorization)
//   2) handshake:  {"protocol":"json","version":1}␞   ← السيرفر بيرد {}␞
//   3) السيرفر بيبعت  {"type":1,"target":"<الحدث>","arguments":[...]}␞
//   4) ping كل 15 ثانية {"type":6}␞ — ولو انقطع بيرجع يتصل لحاله (2، 4، 8… لحد 30 ثانية) وبيطلب التوكن من جديد كل مرة
// الاتصال بيشتغل أول ما حدا يسمع لحدث ([on]) وبيسكّر لما آخر واحد يوقف
// (␞ = الحرف 0x1E اللي بيفصل الرسائل ببروتوكول SignalR)
// -------------------------------------------------------------
typedef HubConnector = Future<WebSocket> Function(Uri uri);

class SignalRHub {
  final Uri uri;

  /// بيتنادى مع كل اتصال (وإعادة اتصال) — لازم يرجّع توكن صالح (مجدَّد لو انتهى)
  final Future<String?> Function() accessToken;
  final Duration pingInterval;
  final HubConnector _connect;

  SignalRHub({required this.uri, required this.accessToken, this.pingInterval = const Duration(seconds: 15), HubConnector? connector})
    : _connect = connector ?? ((uri) => WebSocket.connect(uri.toString()));

  static const _separator = '\u001e';

  final _events = StreamController<(String, List<Object?>)>.broadcast();
  WebSocket? _socket;
  Timer? _ping;
  Timer? _retry;
  bool _active = false;
  bool _handshaken = false;
  int _attempt = 0;
  int _listeners = 0;

  bool get isConnected => _socket != null && _handshaken;

  /// arguments كل مرة السيرفر بيبعت الحدث [target] (الاتصال بيشتغل مع أول مستمع)
  Stream<List<Object?>> on(String target) {
    StreamSubscription<(String, List<Object?>)>? source;
    late final StreamController<List<Object?>> controller;
    controller = StreamController<List<Object?>>(
      onListen: () {
        _listeners++;
        source = _events.stream.where((e) => e.$1.toLowerCase() == target.toLowerCase()).listen((e) => controller.add(e.$2));
        _start();
      },
      onCancel: () async {
        await source?.cancel();
        _listeners--;
        if (_listeners <= 0) {
          _listeners = 0;
          await _stop();
        }
      },
    );
    return controller.stream;
  }

  /// استدعاء على السيرفر بدون انتظار رد — false لو الاتصال مش جاهز
  bool send(String target, List<Object?> arguments) {
    if (!isConnected) return false;
    return _write(jsonEncode({'type': 1, 'target': target, 'arguments': arguments}));
  }

  /// إعادة الاتصال فوراً (السيرفر بيشترك بمجموعات المستخدم لحظة الاتصال بس — بعد ما يتغيّر عضويته)
  Future<void> restart() async {
    if (!_active) return;
    _retry?.cancel();
    _ping?.cancel();
    final socket = _socket;
    _socket = null;
    _handshaken = false;
    _attempt = 0;
    await socket?.close();
    unawaited(_open());
  }

  void _start() {
    if (_active) return;
    _active = true;
    _open();
  }

  Future<void> _open() async {
    _retry?.cancel();
    try {
      final token = await accessToken();
      final target = token == null || token.isEmpty ? uri : uri.replace(queryParameters: {...uri.queryParameters, 'access_token': token});
      final socket = await _connect(target).timeout(const Duration(seconds: 20));
      if (!_active || _socket != null) {
        await socket.close();
        return;
      }
      _socket = socket;
      _handshaken = false;
      socket.listen((data) => _onData(socket, data), onDone: () => _onClosed(socket), onError: (_) => _onClosed(socket), cancelOnError: true);
      socket.add('{"protocol":"json","version":1}$_separator');
      _ping?.cancel();
      _ping = Timer.periodic(pingInterval, (_) => _write('{"type":6}'));
    } catch (_) {
      _scheduleRetry();
    }
  }

  bool _write(String record) {
    try {
      _socket?.add('$record$_separator');
      return _socket != null;
    } catch (_) {
      final socket = _socket;
      if (socket != null) _onClosed(socket);
      return false;
    }
  }

  void _onData(WebSocket socket, dynamic data) {
    if (!identical(socket, _socket)) return;
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
          socket.close();
          return;
        }
        _handshaken = true;
        _attempt = 0;
        continue;
      }
      switch (json['type']) {
        case 1:
          final target = json['target'];
          if (target is String) _events.add((target, List<Object?>.from(json['arguments'] as List? ?? const [])));
        case 7:
          socket.close();
      }
    }
  }

  void _onClosed(WebSocket socket) {
    if (!identical(socket, _socket)) return;
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

  Future<void> _stop() async {
    _active = false;
    _retry?.cancel();
    _ping?.cancel();
    final socket = _socket;
    _socket = null;
    _handshaken = false;
    _attempt = 0;
    await socket?.close();
  }
}
