# Duration

Golang like send/receive communication channel with multi-listen capability.

# Usage

## Send

```dart
main() async {
  final channel = Channel<int>();
  channel.send(i);
}
```

## Receive

```dart
main() async {
  final channel = Channel<int>();
  print(await channel.tryReceive(i));
}
```

## Pipe

`pipe` method offers a way to pipe the contents of the given stream into the channel.

```dart
main() async {
  final channel = Channel<int>();
  await channel.pipe(Stream.fromIterable(Iterable.generate(10, (i) => i)));
  channel.close();
}
```

```dart
main() async {
  final channel = Channel<int>();
  final event = await channel.receive(i);
  if(!event.isClosed) {
    print(event.data);
  }
}
```

# Close

```dart
main() async {
  final channel = Channel<int>();
  channel.send(i);
  channel.close();
}
```

# Stream

```dart
main() async {
  final channel = Channel<int>();
  channel.asStream.listen((d) {
    print(d);
  });
}
```

# Example

```dart
import 'package:channel/channel.dart';
import 'package:pedantic/pedantic.dart';

void main() async {
  final channel = Channel<int>();

  unawaited(Future.microtask(() async {
    while (true) {
      final data = await channel.receive();
      if (!data.isClosed) {
        print('In first task: ${data.data}');
      } else {
        print('First task closed');
        break;
      }
    }
  }));

  unawaited(Future.microtask(() async {
    while (true) {
      final data = await channel.receive();
      if (!data.isClosed) {
        print('In second task: ${data.data}');
      } else {
        print('Second task closed');
        break;
      }
    }
  }));

  for (int i = 0; i < 10; i++) {
    channel.send(i);
  }

  channel.close();

  await Future.delayed(Duration(seconds: 5));
}
```
