import 'package:channel/channel.dart';

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
    if(i % 3 == 0) {
      await Future.delayed(Duration(microseconds: 1));
    }
  }
  print('all values sent');

  channel.close();

  await Future.wait(futures);
}
