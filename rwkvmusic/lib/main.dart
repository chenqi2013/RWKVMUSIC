import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:webview_flutter/webview_flutter.dart';

import 'widget/BorderBtnWidget.dart';
import 'widget/BtnImageTextWidget.dart';
// import "package:webview_universal/webview_universal.dart";
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  // 强制横屏显示
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebViewControllerPlus controllerPiano;
  late WebViewControllerPlus controllerKeyboard;
  String filePath1 = 'assets/piano/index.html';
  String filePath2 = 'assets/piano/keyboard.html';
  String filePath3 = 'assets/player/player.html';
  var selectstate = 0;
  @override
  void initState() {
    super.initState();
    controllerPiano = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            controllerPiano.onLoaded((msg) {
              controllerPiano.getWebViewHeight().then((value) {});
            });
          },
          onPageFinished: (url) {
            print("controllerPiano onPageFinished"+url);
          }, 
        ),
      )
      ..loadFlutterAssetServer(filePath3);

    controllerKeyboard = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            controllerKeyboard.onLoaded((msg) {
              controllerKeyboard.getWebViewHeight().then((value) {});
            });
          },
          onPageFinished: (url) {
           print("controllerKeyboard onPageFinished"+url); 
          },
        ),
      )
      ..loadFlutterAssetServer(filePath2);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Container(
          color: Color(0xff3a3a3a),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'RWKV AI Music Composer',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Container(
                      height: 50,
                      child: Expanded(
                        child: CupertinoSegmentedControl(
                          children: const {
                            0: Text(
                              'Preset Mode',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            1: Text(
                              'Creative Mode',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          },
                          onValueChanged: (int newValue) {
                            // 当选择改变时执行的操作
                            print('选择了选项 $newValue');
                            setState(() {
                              selectstate = newValue;
                            });
                          },
                          groupValue: selectstate, // 当前选中的选项值
                          selectedColor: Color(0xff44be1c),
                          unselectedColor: Colors.transparent,
                          borderColor: Color(0xff6d6d6d),
                        ),
                      )),
                ],
              ),
              SizedBox(
                height: 100,
                child: WebViewWidget(
                  controller: controllerPiano,
                ),
              ),
              SizedBox(
                height: 100,
                child: WebViewWidget(
                  controller: controllerKeyboard,
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                  color: Color(0xff3a3a3a),
                  child: Row(
                    children: [
                      creatBottomBtn('Prompts'),
                      SizedBox(
                        width: 8,
                      ),
                      creatBottomBtn('Sounds Effect'),
                      SizedBox(
                        width: 300,
                      ),
                      createButtonImageWithText('Generate', Icons.edit),
                      createButtonImageWithText('Play', Icons.play_arrow),
                      createButtonImageWithText('Settings', Icons.settings),
                    ],
                  ),
                ),
              )
            ],
          ),
        )));
  }

  Widget createwidget(int state) {
    return CupertinoSegmentedControl(
      children: const {
        0: Text('Preset Mode'),
        1: Text('Creative Mode'),
      },
      onValueChanged: (int newValue) {
        // 当选择改变时执行的操作
        print('选择了选项 $newValue');
      },
      groupValue: state, // 当前选中的选项值
    );
  }

  void establishSSEConnection() async {
    var dic = {
      'temperature': 0.5,
      'presence_penalty': 0,
      'top_p': 1,
      'max_tokens': 1024,
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
