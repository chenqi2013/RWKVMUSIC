import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class CommonUtils {
  static String? extractTextValue(String jsonData) {
    // 正则表达式匹配 "text" 字段的值
    RegExp regExp = RegExp(r'"text":\s*"(.*?)"');

    // 查找匹配项
    RegExpMatch? match = regExp.firstMatch(jsonData);

    // 返回匹配的值（如果存在）
    return match!.group(1);
  }

  static String escapeString(String input) {
    input = input.replaceAll("\r\n", "\n");
    input = input.replaceAll("\\|\\s+", "|");
    input = input.replaceAll("\\|\n", "|");
    return input
        .replaceAll("\\", "\\\\")
        .replaceAll("\"", "\\\"")
        .replaceAll("\\'", "\\\\'")
        .replaceAll("\n", "\\n")
        .replaceAll("\r", "\\r")
        .replaceAll("\r", "\\r")
        // .replaceAll("|\t\n", ""); //| \n
        .replaceAll(r"| \n ", ""); //| \n---->修复换行数据bug
    // .replaceAll("| \n ", ""); //| \n
  }

  static String getdllPath() {
    final currentPath = Directory.current.absolute.path;
    // "C:\Users\bay13\RWKVMUSIC\rwkvmusic\assets\fastmodel\faster_rwkvd.dll"
    var path = p.join(currentPath, 'lib/fastmodel/');
    if (Platform.isMacOS) {
      path = p.join(path, 'faster_rwkvd.dylib');
    } else if (Platform.isWindows) {
      path = p.join(path, 'faster_rwkvd.dll');
    } else {
      path = p.join(path, 'faster_rwkvd.so');
    }
    print('path===$path');
    return path;
  }

  static String getBinPath() {
    final currentPath = Directory.current.absolute.path;
    var path = p.join(currentPath,
        'lib/fastmodel/RWKV-5-ABC-82M-v1-20230901-ctx1024-ncnn.bin');
    print('getBinPath===$path');
    return path;
  }

  static void establishSSEConnection() async {
    var dic = {
      'temperature': 0.5,
      'presence_penalty': 0,
      'top_p': 1,
      'max_tokens': 10,
      'model': 'gpt-4-gizmo-g-qdhTcI4hP',
      'stream': true,
      'messages': [
        {'role': 'user', 'content': 'hello', 'raw': false}
      ]
    };
    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient
        .postUrl(Uri.parse('http://13.113.191.60/openapi/v1/chat/completions'));
    request.headers.contentType = ContentType
        .json; //这个要设置，否则报错{"error":{"message":"当前分组 reverse-times 下对于模型  计费模式 [按次计费] 无可用渠道 (request id: 20240122102439864867952mIY4Ma3k)","type":"shell_api_error"}}
    request.write(jsonEncode(dic));
    // request.headers.add('Accept', 'text/event-stream');
    HttpClientResponse response = await request.close();
    response.listen((List<int> chunk) {
      // 处理数据流的每个块
      String responseData = utf8.decode(chunk);
      print(responseData);
    }, onDone: () {
      // 数据流接收完成
      print('请求完成');
      httpClient.close();
    }, onError: (error) {
      // 处理错误
      print('请求发生错误: $error');
    });
  }
}
