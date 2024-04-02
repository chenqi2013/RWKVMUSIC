import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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

  static Future<String> getdllPath() async {
    var currentPath = Directory.current.absolute.path;
    String path = p.join(currentPath, 'lib/fastmodel/');
    if (Platform.isMacOS) {
      path = p.join(path, 'faster_rwkvd.dylib');
    } else if (Platform.isWindows) {
      path = p.join(path, 'faster_rwkvd.dll');
    } else if (Platform.isAndroid || Platform.isIOS) {
      path = 'assets/fastmodel/libfaster_rwkvd.so';
    }
    debugPrint('path===$path');
    return path;
  }

  static Future<String> getBinPath() async {
    String path;
    if (Platform.isAndroid || Platform.isIOS) {
      path = 'assets/fastmodel/RWKV-5-ABC-82M-v1-20230901-ctx1024-ncnn.bin';
    } else {
      String currentPath = Directory.current.absolute.path;
      path = p.join(currentPath,
          'lib/fastmodel/RWKV-5-ABC-82M-v1-20230901-ctx1024-ncnn.bin');
    }
    debugPrint('getBinPath===$path');
    return path;
  }

  static Future<String> loadDllFromAssets(String dllFileName) async {
    try {
      Directory tempDir = await getApplicationCacheDirectory();
      String tempDirPath = tempDir.path;
      // 构建DLL文件的路径
      String dllFilePath = '$tempDirPath/$dllFileName';
      // 将DLL文件写入临时目录
      File dllFile = File(dllFilePath);
      if (await dllFile.exists()) {
      } else {
        // 加载assets下DLL文件的内容
        ByteData data = await rootBundle.load('assets/fastmodel/$dllFileName');
        await dllFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
      }
      // 加载DLL文件
      // DynamicLibrary dll = DynamicLibrary.open(dllFilePath);
      return dllFilePath;
    } catch (e) {
      print('Error loading DLL file: $e');
      return ''; // 返回空值或者其他默认值
    }
  }

  static Future<String> frameworkpath() async {
    Directory tempDir = await getApplicationCacheDirectory();
    String tempDirPath = tempDir.path;
    return '$tempDirPath/libfaster_rwkvd.dylib';
  }

  static Future<void> unzipfile(String path) async {
    // Read the Zip file from disk.
    Directory tempDir = await getApplicationCacheDirectory();
    String tempDirPath = tempDir.path;
    final bytes = File(path).readAsBytesSync();

    // Decode the Zip file
    final archive = ZipDecoder().decodeBytes(bytes);
    // Extract the contents of the Zip archive to disk.
    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File('$tempDirPath/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory('$tempDirPath/$filename').create(recursive: true);
      }
    }
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
      debugPrint(responseData);
    }, onDone: () {
      // 数据流接收完成
      debugPrint('请求完成');
      httpClient.close();
    }, onError: (error) {
      // 处理错误
      debugPrint('请求发生错误: $error');
    });
  }
}
