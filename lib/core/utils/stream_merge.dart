import 'dart:async';

/// كل أحداث [streams] بستريم واحد — وإيقاف السماع بيوقفهم كلهم (بلا مكتبات إضافية)
Stream<T> mergeStreams<T>(List<Stream<T>> streams) {
  final subs = <StreamSubscription<T>>[];
  late final StreamController<T> controller;
  controller = StreamController<T>(
    onListen: () {
      for (final s in streams) {
        subs.add(s.listen(controller.add, onError: controller.addError));
      }
    },
    onCancel: () async {
      for (final s in subs) {
        await s.cancel();
      }
      subs.clear();
    },
  );
  return controller.stream;
}
