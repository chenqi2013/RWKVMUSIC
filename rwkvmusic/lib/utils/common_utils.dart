import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:app_installer/app_installer.dart';
import 'package:archive/archive.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:isolated_download_manager/isolated_download_manager.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/values/values.dart';

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

    // 获取当前可执行文件的路径
    String executablePath = Platform.resolvedExecutable;
    // 获取安装目录
    String installDir = p.dirname(executablePath); // 获取目录路径

    if (Platform.isMacOS) {
      path = p.join(path, 'faster_rwkvd.dylib');
    } else if (Platform.isWindows) {
      path = p.join(path, 'faster_rwkvd.dll');
      path = p.join(installDir, 'lib/fastmodel/faster_rwkvd.dll');
    } else if (Platform.isAndroid || Platform.isIOS) {
      path = 'assets/fastmodel/libfaster_rwkvd.so';
    }
    debugPrint('path===$path');
    return path;
  }

  static Future<String> getBinPath() async {
    // var currentPath = Directory.current.absolute.path;
    // 获取当前可执行文件的路径
    String executablePath = Platform.resolvedExecutable;
    // 获取安装目录
    String installDir = p.dirname(executablePath); // 获取目录路径
    String path = p.join(installDir, 'lib/fastmodel/');
    if (Platform.isAndroid || Platform.isIOS) {
      path = 'assets/fastmodel/RWKV-5-ABC-82M-v1-20230901-ctx1024-ncnn.bin';
    } else {
      // String currentPath = Directory.current.absolute.path;
      if (currentModelType == ModelType.qnn) {
        path = p.join(
            path, 'RWKV-6-ABC-85M-v1-20240217-ctx1024-QNN2.26-XElite.bin');
      } else {
        path = p.join(path, 'RWKV-6-ABC-85M-v1-20240217-ctx1024-webrwkv.st');
      }
    }
    debugPrint('getBinPath===$path');
    return path;
  }

  static Future<String> getCachePath() async {
    String tempDirPath = '';
    try {
      Directory tempDir = await getApplicationCacheDirectory();
      tempDirPath = tempDir.path;
    } catch (e) {
      print('Error getCachePath: $e');
    }
    return tempDirPath;
  }

  static Future<String> copyFileFromAssets(String dllFileName) async {
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

  static Future<String> getHardware() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      print(
          'Running on ${androidInfo.board},---${androidInfo.bootloader},---${androidInfo.brand},---${androidInfo.device},---${androidInfo.display},---${androidInfo.fingerprint},---${androidInfo.hardware},---${androidInfo.host},---${androidInfo.id},${androidInfo.isLowRamDevice},${androidInfo.isPhysicalDevice},${androidInfo.manufacturer},${androidInfo.model},${androidInfo.product},${androidInfo.serialNumber},${androidInfo.tags},${androidInfo.type},${androidInfo.version},${androidInfo.systemFeatures}'); // e.g. "Moto G (4)"
      print('hardware :${androidInfo.hardware}');
      return androidInfo.hardware;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      print('Running on ${iosInfo.utsname.machine}');
      return iosInfo.utsname.machine;
    }
    print('getDeviceName=unknown');
    return 'unknown';
  }

  static Future<String> getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final allInfo = deviceInfo.data;
    debugPrint('getDeviceInfo=${allInfo.toString()}');
    return allInfo.toString();
  }

  static void downloadfile(BuildContext context, String downloadurl,
      Function(DownloadStatus, double) progressStatus) async {
    String downloadPath = await CommonUtils.getCachePath();
    // Initialize
    await DownloadManager.instance.init(
      isolates: 3,
    );

    Uri uri = Uri.parse(downloadurl);
    var name = uri.pathSegments.last;
    print('file name=$name');
    var request = DownloadManager.instance
        .download(downloadurl, path: '$downloadPath/$name');

    // Listen
    request.events.listen((event) {
      if (event is DownloadState) {
        print("event: $event");
        if (event == DownloadState.started) {
          progressStatus(DownloadStatus.start, 0);
        } else if (event == DownloadState.finished) {
          print('finished');
          // CommonUtils.setIsdownload(true);
          // Navigator.of(context).pop();
          progressStatus(DownloadStatus.finish, 1.0);

          AppInstaller.installApk('$downloadPath/$name');
        }
      } else if (event is double) {
        // progress.value = event;
        print("progress: ${(event * 100.0).toStringAsFixed(0)}%");
        progressStatus(DownloadStatus.downloading, event);
      }
    }, onError: (error) {
      print("error $error");
      progressStatus(DownloadStatus.fail, -1);
    });
  }

  static Future<String> getWindowsDeviceId() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final windowsInfo = await deviceInfoPlugin.windowsInfo;

    // 组合硬件信息生成唯一编号
    String uniqueId = windowsInfo.deviceId;
    debugPrint('uuid=$uniqueId');
    return uniqueId;
  }

  static Future<bool> checkDHM(
      String encryptionKeyId, String deviceUuid) async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) {
      return status! < 500; // 所有小于500的状态码都视为成功，包括4xx客户端错误
    }));

    int statusCode = -1;
    bool isValid = false;
    String url = 'https://api.rwkv.cn/rest/v1/rwkv_music_redeem_record';

    Map<String, dynamic> data = {
      'encryption_key_id': encryptionKeyId,
      'device_uuid': deviceUuid,
    };

    // 设置 headers
    dio.options.headers = {
      'Content-Type': 'application/json',
      'apikey':
          ' eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzIzMDQ2NDAwLAogICJleHAiOiAxODgwODEyODAwCn0.rcb3MeytmRZQFWx5cGAN2C7BOvVOuBFOQJbJRE4ygmw',
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzIzMDQ2NDAwLAogICJleHAiOiAxODgwODEyODAwCn0.rcb3MeytmRZQFWx5cGAN2C7BOvVOuBFOQJbJRE4ygmw',
    };

    try {
      Response response = await dio.post(url, data: data);
      statusCode = response.statusCode!;
      int subCode = 0;
      debugPrint('statusCode=$statusCode,subCode=$subCode');
      if (statusCode == 201) {
        print('Response data:${response.data}');
        Get.snackbar('提示', '激活成功，您可正常使用该软件', colorText: Colors.black);
        isValid = true;
      } else {
        print('Request failed with status: ${response.data}');
        subCode = int.parse(response.data['code']);
        if (statusCode == 409) {
          if (subCode == 23505) {
            Get.snackbar('提示', '设备已经激活过了，可正常使用该软件', colorText: Colors.black);
            isValid = true;
          } else if (subCode == 23503) {
            Get.snackbar('提示', '验证码不正确', colorText: Colors.black);
          }
        } else if (statusCode == 400) {
          if (subCode == 45005) {
            Get.snackbar('提示', '验证码已经注册五台设备', colorText: Colors.black);
          }
        }
      }
    } catch (e) {
      print('checkDHM Error: $e');
    }
    return isValid;
  }

  static Future<bool> checkDeviceIsJihuo(String deviceUuid) async {
    Dio dio = Dio(BaseOptions(validateStatus: (status) {
      return status! < 500; // 所有小于500的状态码都视为成功，包括4xx客户端错误
    }));

    int statusCode = -1;
    bool isValid = false;
    String url = 'https://api.rwkv.cn/rest/v1/rpc/check_device_uuid_exists';

    Map<String, dynamic> data = {
      'device_uuid_input': deviceUuid,
    };

    // 设置 headers
    dio.options.headers = {
      'Content-Type': 'application/json',
      'apikey':
          ' eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzIzMDQ2NDAwLAogICJleHAiOiAxODgwODEyODAwCn0.rcb3MeytmRZQFWx5cGAN2C7BOvVOuBFOQJbJRE4ygmw',
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogImFub24iLAogICJpc3MiOiAic3VwYWJhc2UiLAogICJpYXQiOiAxNzIzMDQ2NDAwLAogICJleHAiOiAxODgwODEyODAwCn0.rcb3MeytmRZQFWx5cGAN2C7BOvVOuBFOQJbJRE4ygmw',
    };

    try {
      Response response = await dio.post(url, data: data);
      statusCode = response.statusCode!;
      int subCode = 0;
      debugPrint('statusCode=$statusCode,subCode=$subCode');
      debugPrint('checkDeviceIsJihuo Response data:${response.data}');
      isValid = response.data;
      // if (statusCode == 201) {
      //   print('Response data:${response.data}');
      //   Get.snackbar('提示', '激活成功，您可正常使用该软件', colorText: Colors.black);
      //   isValid = true;
      // } else {
      //   print('Request failed with status: ${response.data}');
      //   subCode = int.parse(response.data['code']);
      //   if (statusCode == 409) {
      //     if (subCode == 23505) {
      //       Get.snackbar('提示', '设备已经激活过了，可正常使用该软件', colorText: Colors.black);
      //       isValid = true;
      //     } else if (subCode == 23503) {
      //       Get.snackbar('提示', '验证码不正确', colorText: Colors.black);
      //     }
      //   } else if (statusCode == 400) {
      //     if (subCode == 45005) {
      //       Get.snackbar('提示', '验证码已经注册五台设备', colorText: Colors.black);
      //     }
      //   }
      // }
    } catch (e) {
      print('checkDeviceIsJihuo Error: $e');
    }
    return isValid;
  }

  // void getABCDataByAPI() async {
  //   var dic = {
  //     "frequency_penalty": 0.4,
  //     "max_tokens": 1000,
  //     "model": "rwkv",
  //     "presence_penalty": 0.4,
  //     "prompt": "S:2",
  //     "stream": true,
  //     "temperature": 1.2,
  //     "top_p": 0.5
  //   };
  //   httpClient = HttpClient();
  //   HttpClientRequest request = await httpClient
  //       .postUrl(Uri.parse('http://192.168.0.106:8000/completions'));
  //   request.headers.contentType = ContentType
  //       .json; //这个要设置，否则报错{"error":{"message":"当前分组 reverse-times 下对于模型  计费模式 [按次计费] 无可用渠道 (request id: 20240122102439864867952mIY4Ma3k)","type":"shell_api_error"}}
  //   request.write(jsonEncode(dic));
  //   // request.headers.add('Accept', 'text/event-stream');
  //   HttpClientResponse response = await request.close();
  //   subscription = response.listen((List<int> chunk) {
  //     if (!isGenerating.value) {
  //       subscription.cancel();
  //       httpClient.close();
  //       stringBuffer.clear();
  //       stringBuffer = StringBuffer();
  //       addCount = 0;
  //       return;
  //     } // 处理数据流的每个块
  //     listenCount++;
  //     String responseData = utf8.decode(chunk);
  //     String textstr = CommonUtils.extractTextValue(responseData)!;
  //     String tempStr = textstr;
  //     debugPrint('responseData=$textstr');
  //     stringBuffer.write(textstr);
  //     textstr = CommonUtils.escapeString(stringBuffer.toString());
  //     abcString =
  //         "setAbcString(\"${ABCHead.getABCWithInstrument(textstr, midiProgramValue)}\",false)";
  //     abcString = ABCHead.appendTempoParam(abcString, tempo.value.toInt());
  //     debugPrint('abcstring result=$abcString');
  //     // 方案一
  //     if (isWindowsOrMac) {
  //       int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
  //       int gap = currentTimestamp - preTimestamp;
  //       if (gap > 400) {
  //         //&& tempStr.trim().isEmpty
  //         // debugPrint('runJavaScript');
  //         preTimestamp = currentTimestamp;
  //         controllerPiano.runJavaScript(abcString.toString());
  //       }
  //       return;
  //     }

  //     // // 方案二
  //     // int currentCount = sb.length;
  //     // int gap = currentCount - preCount;
  //     // // debugdebugPrint('gap==$gap');
  //     // if (gap >= 5) {
  //     //   preCount = currentCount;
  //     //   controllerPiano.runJavaScript(sb.toString());
  //     // }

  //     // 方案三
  //     if (listenCount % 3 == 0) {
  //       controllerPiano.runJavaScript(abcString.toString());
  //     }
  //   }, onDone: () {
  //     // 数据流接收完成
  //     debugPrint('请求完成');
  //     httpClient.close();
  //     isGenerating.value = false;
  //     finalabcStringPreset = abcString.toString();
  //   }, onError: (error) {
  //     // 处理错误
  //     debugPrint('请求发生错误: $error');
  //     isGenerating.value = false;
  //   });
  // }
}
