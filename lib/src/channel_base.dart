import 'dart:async';
import 'dart:collection';
import 'dart:math';

class ChannelEvent<T> {
  final T? data;

  final bool isClosed;

  ChannelEvent(this.data, this.isClosed);
}

abstract class Channel<T> {
  factory Channel() = NonBlockingChannel<T>;

  FutureOr<void> send(T? value);

  Future<ChannelEvent<T?>> receive();

  Future<T?> tryReceive({T? onClose});

  Stream<ChannelEvent<T?>> asStream();

  bool get isClosed;

  void close();
}

class NonBlockingChannel<T> implements Channel<T> {
  final Queue<T?> _data = Queue<T?>();

  final _completers = Queue<Completer<ChannelEvent<T?>>>();

  bool _isClosed = false;

  @override
  void send(T? value) {
    if (isClosed) throw Exception('Channel is closed');
    _data.add(value);
    _send();
  }

  @override
  Future<ChannelEvent<T?>> receive() async {
    if (_isClosed && _data.isEmpty) {
      return ChannelEvent<T?>(null, true);
    }

    if (_data.isNotEmpty && _completers.isEmpty) {
      return ChannelEvent<T?>(_data.removeFirst(), false);
    }

    final completer = Completer<ChannelEvent<T?>>();
    _completers.add(completer);
    return completer.future;
  }

  @override
  Future<T?> tryReceive({T? onClose}) async {
    final data = await receive();
    if (!data.isClosed) return data.data;
    return onClose;
  }

  @override
  Stream<ChannelEvent<T?>> asStream() {
    final StreamController<ChannelEvent<T?>> controller =
        StreamController<ChannelEvent<T?>>();

    void loop() async {
      bool isCancelled = false;
      controller.onCancel = () {
        isCancelled = true;
      };

      while (true) {
        if (_data.isEmpty && _isClosed) {
          await controller.close();
          break;
        }

        final data = await receive();
        if (isCancelled) {
          await controller.close();
          break;
        }
        controller.add(data);
      }
    }

    loop();

    return controller.stream;
  }

  @override
  bool get isClosed => _isClosed;

  @override
  void close() {
    _isClosed = true;
    _send();

    while (_completers.isNotEmpty) {
      final Completer<ChannelEvent<T?>> completer = _completers.removeFirst();
      completer.complete(ChannelEvent<T?>(null, true));
    }
  }

  void _send() {
    if (_data.isEmpty || _completers.isEmpty) return;

    final n = min<int>(_data.length, _completers.length);
    for (int i = 0; i < n; i++) {
      final Completer<ChannelEvent<T?>> completer = _completers.removeFirst();
      final data = _data.removeFirst();
      completer.complete(ChannelEvent<T?>(data, false));
    }
  }
}
