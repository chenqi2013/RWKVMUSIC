import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'widget/BorderBtnWidget.dart';
import 'widget/BtnImageTextWidget.dart';
// import "package:webview_universal/webview_universal.dart";

void main(List<String> args) {
  // 强制横屏显示
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebViewController controller1;
  late WebViewController controller2;
  String filePath1 = 'assets/piano/index.html';
  String filePath2 = 'assets/piano/keyboard.html';
  String filePath3 = 'assets/player/player.html';
  var selectstate = 0;
  @override
  void initState() {
    super.initState();
    // webViewController1.init(
    //   context: context,
    //   setState: setState,
    //   uri: Uri.parse("https://www.baidu.com"),
    // );
    // webViewController2.init(
    //   context: context,
    //   setState: setState,
    //   uri: Uri.parse("https://www.qq.com/"),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            // appBar: AppBar(
            //   leading: MaterialButton(
            //     onPressed: () {
            //       webViewController1.goBackSync();
            //       webViewController2.goBackSync();
            //     },
            //     child: Icon(Icons.arrow_back),
            //   ),
            // ),
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
              Expanded(
                flex: 2,
                child: WebView(
                  initialUrl: '',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController controller) {
                    this.controller1 = controller;
                    _loadHtmlFromAssets(filePath3, controller);
                  },
                  onPageFinished: (url) async {
                    var javascript = 'setAbcString("%%MIDI program 0\nL:1/4\nM:4/4\nK:C\n|", false)';
                    await controller1.runJavascript(javascript);
                    // controller1.runJavascript("setStyle()");
                    // controller1.runJavascript("setPiano(55,76)");
                    // _executeJavaScript(javascript);

                    // try {
//   var result = await controller1.evaluateJavascript(javascript);
//   print('JavaScript execution result: $result');
// } catch (e) {
//   print('JavaScript execution error: $e');
// }
                  },
                  navigationDelegate: (navigation) {
                    //其他请求正常跳转
                    return NavigationDecision.navigate;
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: WebView(
                  initialUrl: '',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController controller) {
                    this.controller2 = controller;
                    _loadHtmlFromAssets(filePath2, controller);
                  },
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

  // 执行JavaScript脚本的方法
  _executeJavaScript(String jsstr) {
    print(jsstr);
    // controller1.evaluateJavascript("console.log('Hello from Flutter!');");
    controller1.runJavascript(jsstr);
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

  // 加载显示html文件；
  _loadHtmlFromAssets(String filePath, WebViewController controller) async {
    String fileHtmlContents = await rootBundle.loadString(filePath);
    controller.loadUrl(Uri.dataFromString(fileHtmlContents,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
