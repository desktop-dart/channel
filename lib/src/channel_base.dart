import 'dart:async';
import 'nonblocking.dart';

export 'nonblocking.dart';

/// An event on the channel. Could be a data event, in which case [isClosed] is
/// false.
class ChannelEvent<T> {
  final T? data;

  final bool isClosed;

  ChannelEvent(this.data, this.isClosed);
}

/// Golang like channel to send/buffer/receive data
abstract class Channel<T> {
  factory Channel() = NonBlockingChannel<T>;

  factory Channel.from(Iterable<T> values) = NonBlockingChannel<T>.from;

  factory Channel.fromStream(Stream<T> stream) =
      NonBlockingChannel<T>.fromStream;

  /// Sends one [value] to the channel
  FutureOr<void> send(T value);

  /// Sends all [values] to the channel
  FutureOr<void> sendAll(Iterable<T> values);

  /// Reads one value from the channel. Returns immediately if a value is
  /// available in the channel. If the channel is empty, a future is returned
  /// that resolves with the value when a new value is available.
  Future<ChannelEvent<T>> receive();

  /// Reads one value from the channel. Returns null or [onClose] if the channel
  /// has no value and it is closed.
  Future<T?> tryReceive({T? onClose});

  /// Reads the channel as [Stream].
  Stream<ChannelEvent<T?>> asStream();

  /// Is the channel closed?
  bool get isClosed;

  /// Closes the channel so that no more values can be sent to it.
  void close();

  /// Pipes the content of [stream] into the channel
  Future<void> pipe(Stream<T> stream);
}
