import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:labaik/core/network/signalr_hub.dart';

// -------------------------------------------------------------
// SignalRHub على سيرفر WebSocket محلي: التوكن بـ ?access_token=، الـ handshake، الأحداث، الـ ping،
// الاستدعاء من التطبيق (UpdateLocation)، إعادة الاتصال، والإغلاق لما آخر مستمع يوقف
// -------------------------------------------------------------
void main() {
  test('connects with access_token, receives events, pings, invokes, restarts and closes with the last listener', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final tokens = <String?>[];
    final invocations = <Map<String, dynamic>>[];
    var pings = 0;
    server.listen((request) async {
      tokens.add(request.uri.queryParameters['access_token']);
      final socket = await WebSocketTransformer.upgrade(request);
      socket.listen((data) {
        for (final record in (data as String).split('\u001e').where((r) => r.isNotEmpty)) {
          final json = jsonDecode(record) as Map<String, dynamic>;
          if (json['protocol'] == 'json') {
            socket.add('{}\u001e{"type":1,"target":"MessageReceived","arguments":[{"id":"m1","groupId":"g1","body":"السلام عليكم"}]}\u001e');
          } else if (json['type'] == 6) {
            pings++;
          } else if (json['type'] == 1) {
            invocations.add(json);
          }
        }
      });
    });

    var token = 'tok1';
    final hub = SignalRHub(uri: Uri.parse('ws://127.0.0.1:${server.port}/hubs/events'), accessToken: () async => token, pingInterval: const Duration(milliseconds: 50));
    final events = <List<Object?>>[];
    final sub = hub.on('MessageReceived').listen(events.add);
    // حدث تاني ما إلنا علاقة فيه ما بيوصل
    final other = <List<Object?>>[];
    final otherSub = hub.on('NotificationReceived').listen(other.add);

    await _until(() => events.isNotEmpty);
    expect((events.single.single as Map)['body'], 'السلام عليكم');
    expect(other, isEmpty);
    expect(tokens.single, 'tok1');
    expect(hub.isConnected, isTrue);

    expect(hub.send('UpdateLocation', [21.42, 39.82, null]), isTrue);
    await _until(() => invocations.isNotEmpty);
    expect(invocations.single['target'], 'UpdateLocation');
    expect(invocations.single['arguments'], [21.42, 39.82, null]);
    await _until(() => pings > 0);

    // إعادة الاتصال (مجموعة جديدة): اتصال جديد بالتوكن الحالي
    token = 'tok2';
    await hub.restart();
    await _until(() => tokens.length == 2 && hub.isConnected);
    expect(tokens.last, 'tok2');

    // آخر مستمع وقف → الاتصال بيسكّر
    await sub.cancel();
    expect(hub.isConnected, isTrue);
    await otherSub.cancel();
    expect(hub.isConnected, isFalse);
    expect(hub.send('UpdateLocation', [1, 2, null]), isFalse);
    await server.close(force: true);
  });
}

Future<void> _until(bool Function() done) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!done()) {
    if (DateTime.now().isAfter(deadline)) throw TimeoutException('condition not met');
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
