import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import "package:webview_universal/webview_universal.dart";

void main(List<String> args) {
  // 强制横屏显示
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const MaterialApp(
    home: MyApp(),
  ));
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
    return Scaffold(
        // appBar: AppBar(
        //   leading: MaterialButton(
        //     onPressed: () {
        //       webViewController1.goBackSync();
        //       webViewController2.goBackSync();
        //     },
        //     child: Icon(Icons.arrow_back),
        //   ),
        // ),
        body: Column(
      children: [
        Expanded(
          flex: 2,
          child: WebView(
        initialUrl: '',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController controller) {
          this.controller1 = controller;
          _loadHtmlFromAssets(filePath1,controller);
        },
      ),
        ),
        Expanded(
          flex: 2,
          child: WebView(
        initialUrl: '',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController controller) {
          this.controller2 = controller;
          _loadHtmlFromAssets(filePath2,controller);
        },
      ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey,
            child: Row(
              children: [
                Expanded(
                  child: creatBottomBtn('Prompts'),
                  flex: 2,
                ),
                Expanded(
                  child: creatBottomBtn('Sounds Effect'),
                  flex: 2,
                ),
                Expanded(
                  child: createButtonImageWithText('Generate', Icons.edit),
                  flex: 1,
                ),
                Expanded(
                  child: createButtonImageWithText('Play', Icons.play_arrow),
                  flex: 1,
                ),
                Expanded(
                  child: createButtonImageWithText('Settings', Icons.settings),
                  flex: 1,
                ),
                Expanded(
                  child: CupertinoSegmentedControl(
                    children: const {
                      0: Text('Preset Mode'),
                      1: Text('Creative Mode'),
                    },
                    onValueChanged: (int newValue) {
                      // 当选择改变时执行的操作
                      print('选择了选项 $newValue');
                      setState(() {
                        selectstate = newValue;
                      });
                    },
                    groupValue: selectstate, // 当前选中的选项值
                  ),
                  flex: 3,
                ),
              ],
            ),
          ),
        )
      ],
    ));
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

  Widget createButtonImageWithText(String text, IconData icondata) {
    return InkWell(
      onTap: () {
        establishSSEConnection();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 9),
        decoration: BoxDecoration(
          // color: Colors.blue, // 设置背景色
          borderRadius: BorderRadius.circular(8), // 设置圆角
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icondata,
              color: Colors.white, // 设置图标颜色
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white, // 设置文本颜色
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget creatBottomBtn(String text) {
    return InkWell(
      onTap: () {
        // 按钮被点击时执行的操作
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 9),
        decoration: BoxDecoration(
          // color: Colors.blue, // 设置背景色
          borderRadius: BorderRadius.circular(8), // 设置圆角
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white, // 设置文本颜色
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_drop_down_sharp,
              color: Colors.white, // 设置图标颜色
            ),
          ],
        ),
      ),
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
    request.headers.contentType = ContentType.json;//这个要设置，否则报错{"error":{"message":"当前分组 reverse-times 下对于模型  计费模式 [按次计费] 无可用渠道 (request id: 20240122102439864867952mIY4Ma3k)","type":"shell_api_error"}}
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
  _loadHtmlFromAssets(String filePath,WebViewController controller) async {
    String fileHtmlContents = await rootBundle.loadString(filePath);
    controller.loadUrl(Uri.dataFromString(fileHtmlContents,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
