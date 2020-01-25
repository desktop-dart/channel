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
