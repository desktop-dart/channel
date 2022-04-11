import 'package:channel/channel.dart';
import 'package:pedantic/pedantic.dart';

void main() async {
  final channel = Channel<int>();

  final futures = <Future>[];
  futures.add(Future.microtask(() async {
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

  futures.add(Future.microtask(() async {
    while (true) {
      final data = await channel.tryReceive();
      if (data != null) {
        print('In second task: $data');
      } else {
        print('Second task closed');
        break;
      }
    }
  }));

  await channel.pipe(Stream.fromIterable(Iterable.generate(10, (i) => i)));
  channel.close();

  await Future.wait(futures);
}
