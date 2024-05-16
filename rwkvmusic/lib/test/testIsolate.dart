import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as p;

void main() async {
  // 创建 ReceivePort，以接收来自子线程的消息
  final receivePort = ReceivePort();
  print('objectobjectobjectobject');
  // 创建一个新的 Isolate
  await Isolate.spawn(readFile, receivePort.sendPort);

  // 监听来自子线线程的数据
  receivePort.listen((data) {
    print('Received data: $data');
    receivePort.close(); // 操作完成后，关闭 ReceivePort
  });
}

// 运行在子线程的函数，用于读取文件
void readFile(SendPort sendPort) async {
  // 在这里替换为你的文件路径
  final currentPath = Directory.current.absolute.path;
  var path = p.join(currentPath, 'lib/test55.dart');
  final file = File('C:/Users/bay13/RWKVMUSIC/rwkvmusic/lib/test55.dart');
  String contents = await file.readAsString();
  // 使用 SendPort 发送数据回主线程
  // "C:\Users\bay13\RWKVMUSIC\rwkvmusic\lib\test55.dart"
  sendPort.send(contents);
}
