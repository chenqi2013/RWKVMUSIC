import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/mainwidget/ProgressbarTime.dart';
import 'package:rwkvmusic/test/bletest.dart';
import 'package:rwkvmusic/values/constantdata.dart';

import 'mainwidget/BorderBtnWidget.dart';
import 'mainwidget/BtnImageTextWidget.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:on_popup_window_widget/on_popup_window_widget.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  // 强制横屏显示
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
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
  late WebViewControllerPlus controllerPiano;
  late WebViewControllerPlus controllerKeyboard;
  String filePath1 = 'assets/piano/index.html';
  String filePath2 = 'assets/piano/keyboard.html';
  String filePath3 = 'assets/player/player.html';
  var selectstate = 0.obs;
  late StringBuffer stringBuffer;
  int addGap = 2; //间隔多少刷新
  int addCount = 0; //刷新次数
  var isPlay = false.obs;
  var playProgress = 0.0.obs;
  var pianoAllTime = 0.0.obs;
  late Timer timer;
  late StreamSubscription subscription;
  var isGenerating = false.obs;
  late HttpClient httpClient;
  int preTimestamp = 0;
  int preCount = 0;
  int listenCount = 0;
  @override
  void initState() {
    super.initState();
    stringBuffer = StringBuffer();
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
            print("controllerPiano onPageFinished" + url);
            controllerPiano.runJavaScript(
                "setAbcString(\"%%MIDI program 40\\nL:1/4\\nM:4/4\\nK:D\\n\\\"D\\\" A F F\", false)");
            controllerPiano.runJavaScript("setPromptNoteNumberCount(3)");
            controllerPiano.runJavaScript("setStyle()");
          },
        ),
      )
      ..loadFlutterAssetServer(filePath3)
      ..addJavaScriptChannel("flutteronStartPlay",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        String message = jsMessage.message;
        print('flutteronStartPlay onMessageReceived=' + message);
        pianoAllTime.value = double.parse(message.split(',')[1]);
        print('pianoAllTime:${pianoAllTime.value}');
        playProgress.value = 0.0;
        createTimer();
        isPlay.value = true;
      })
      ..addJavaScriptChannel("flutteronPausePlay",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        print('flutteronPausePlay onMessageReceived=' + jsMessage.message);
        timer.cancel();
        isPlay.value = false;
      })
      ..addJavaScriptChannel("flutteronResumePlay",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        print('flutteronResumePlay onMessageReceived=' + jsMessage.message);
        createTimer();
        isPlay.value = true;
      })
      ..addJavaScriptChannel("flutteronCountPromptNoteNumber",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        // print('flutteronCountPromptNoteNumber onMessageReceived=' +
        //     jsMessage.message);
      })
      ..addJavaScriptChannel("flutteronEvents",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        print('flutteronEvents onMessageReceived=' + jsMessage.message);
      })
      ..addJavaScriptChannel("flutteronPlayFinish",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        print('flutteronPlayFinish onMessageReceived=' + jsMessage.message);
        isPlay.value = false;
      });

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
            print("controllerKeyboard onPageFinished" + url);
            controllerKeyboard.runJavaScript('resetPlay()');
            // controllerKeyboard.runJavaScript('setPiano(55, 76)');
          },
        ),
      )
      ..loadFlutterAssetServer(filePath2);
    // controllerKeyboard.addJavaScriptChannel("controller", onMessageReceived: (JavaScriptMessage jsMessage){
    //       print('controllerKeyboard onMessageReceived='+jsMessage.message);
    // });
  }

  void createTimer() {
    timer = Timer.periodic(Duration(milliseconds: 1000), (Timer timer) {
      if (playProgress.value >= 1) {
        playProgress.value = 1;
        timer.cancel();
      } else {
        if (playProgress.value + 1000.0 / pianoAllTime.value > 1.0) {
          playProgress.value = 1.0;
        } else {
          playProgress.value += 1000.0 / pianoAllTime.value;
        }
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    httpClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
              body: Container(
            color: Color(0xff3a3a3a),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'RWKV AI Music Composer',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Spacer(),
                      Container(child: Obx(() {
                        return CupertinoSegmentedControl(
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
                            selectstate.value = newValue;
                            segmengChange(newValue);
                          },
                          groupValue: selectstate.value, // 当前选中的选项值
                          selectedColor: Color(0xff44be1c),
                          unselectedColor: Colors.transparent,
                          borderColor: Color(0xff6d6d6d),
                        );
                      })),
                    ],
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: WebViewWidget(
                    controller: controllerPiano,
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: WebViewWidget(
                    controller: controllerKeyboard,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                    color: Color(0xff3a3a3a),
                    child: Row(
                      children: [
                        creatBottomBtn('Prompts', () {
                          print("Promptss");
                        }),
                        SizedBox(
                          width: 8,
                        ),
                        creatBottomBtn('Sounds Effect', () {
                          print("Sounds Effect");
                        }),
                        ProgressbarTime(playProgress, pianoAllTime),
                        Obx(() => isGenerating.value
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Container(
                                child: null,
                              )),
                        Spacer(),
                        Container(
                          child: Row(
                            children: [
                              Obx(() => createButtonImageWithText(
                                      !isGenerating.value ? 'Generate' : 'Stop',
                                      !isGenerating.value
                                          ? Icons.edit
                                          : Icons.refresh, () {
                                    print('Generate');
                                    isGenerating.value = !isGenerating.value;
                                    if (isGenerating.value) {
                                      playProgress.value = 0.0;
                                      pianoAllTime.value = 0.0;
                                      // controllerPiano.runJavaScript(
                                      //     "setAbcString(\"%%MIDI program 40\\nL:1/4\\nM:4/4\\nK:D\\n\\\"D\\\" A F F\", false)");
                                      // controllerPiano.runJavaScript(
                                      //     'resetTimingCallbacks()');
                                      getABCData();
                                    }
                                  })),
                              Obx(() {
                                return createButtonImageWithText(
                                    !isPlay.value ? 'Play' : 'Pause',
                                    !isPlay.value
                                        ? Icons.play_arrow
                                        : Icons.pause, () {
                                  print('Play');
                                  if (!isPlay.value) {
                                    // controllerPiano.runJavaScript("ABCtoEvents(\"L:1/4\\nM:4/4\\nK:D\\n\\\"D\\\" A F F\")");
                                    controllerPiano
                                        .runJavaScript("startPlay()");
                                  } else {
                                    controllerPiano
                                        .runJavaScript("pausePlay()");
                                  }
                                  // isPlay.value = !isPlay.value;
                                });
                              }),
                              createButtonImageWithText(
                                  'Settings', Icons.settings, () {
                                print('Settings');
                                Get.to(FlutterBlueApp());
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ))),
    );
  }

  void getABCData() async {
    var dic = {
      "frequency_penalty": 0.4,
      "max_tokens": 1000,
      "model": "rwkv",
      "presence_penalty": 0.4,
      "prompt": "S:2",
      "stream": true,
      "temperature": 1.2,
      "top_p": 0.5
    };
    httpClient = HttpClient();
    HttpClientRequest request = await httpClient
        .postUrl(Uri.parse('http://192.168.3.4:8000/completions'));
    request.headers.contentType = ContentType
        .json; //这个要设置，否则报错{"error":{"message":"当前分组 reverse-times 下对于模型  计费模式 [按次计费] 无可用渠道 (request id: 20240122102439864867952mIY4Ma3k)","type":"shell_api_error"}}
    request.write(jsonEncode(dic));
    // request.headers.add('Accept', 'text/event-stream');
    HttpClientResponse response = await request.close();
    subscription = response.listen((List<int> chunk) {
      if (!isGenerating.value) {
        subscription.cancel();
        httpClient.close();
        stringBuffer.clear();
        stringBuffer = StringBuffer();
        addCount = 0;
        return;
      } // 处理数据流的每个块
      listenCount++;
      String responseData = utf8.decode(chunk);
      String textstr = extractTextValue(responseData)!;
      // print('responseData=$textstr');
      stringBuffer.write(textstr);
      textstr = escapeString(stringBuffer.toString());
      String sb = "setAbcString(\"" + textstr + "\",false)";
      // 方案一
      // int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      // int gap = currentTimestamp - preTimestamp;
      // if (gap > 200) {
      //   preTimestamp = currentTimestamp;
      //   controllerPiano.runJavaScript(sb.toString());
      // }

      // // 方案二
      // int currentCount = sb.length;
      // int gap = currentCount - preCount;
      // // debugPrint('gap==$gap');
      // if (gap >= 5) {
      //   preCount = currentCount;
      //   controllerPiano.runJavaScript(sb.toString());
      // }

      // 方案三
      if (listenCount % 3 == 0) {
        controllerPiano.runJavaScript(sb.toString());
      }
    }, onDone: () {
      // 数据流接收完成
      print('请求完成');
      httpClient.close();
      isGenerating.value = false;
    }, onError: (error) {
      // 处理错误
      print('请求发生错误: $error');
      isGenerating.value = false;
    });
  }

  void establishSSEConnection() async {
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

  String? extractTextValue(String jsonData) {
    // 正则表达式匹配 "text" 字段的值
    RegExp regExp = RegExp(r'"text":\s*"(.*?)"');

    // 查找匹配项
    RegExpMatch? match = regExp.firstMatch(jsonData);

    // 返回匹配的值（如果存在）
    return match!.group(1);
  }

  String escapeString(String input) {
    input = input.replaceAll("\r\n", "\n");
    input = input.replaceAll("\\|\\s+", "|");
    input = input.replaceAll("\\|\n", "|");
    return input
        .replaceAll("\\", "\\\\")
        .replaceAll("\"", "\\\"")
        .replaceAll("\'", "\\\'")
        .replaceAll("\n", "\\n")
        .replaceAll("\r", "\\r")
        .replaceAll("\t", "\\t");
  }

  void showPromptDialog(BuildContext context) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 100, 0, 0),
      items: [
        PopupMenuItem(
          value: 'Option 1',
          child: Text('Option 1'),
        ),
        PopupMenuItem(
          value: 'Option 2',
          child: Text('Option 2'),
        ),
        PopupMenuItem(
          value: 'Option 3',
          child: Text('Option 3'),
        ),
      ],
    );
  }

  void segmengChange(int index) {
    if (index == 0) {
      //preset
      controllerPiano.runJavaScript(
          "setAbcString(\"%%MIDI program 40\\nL:1/4\\nM:4/4\\nK:D\\n\\\"D\\\" A F F\", false)");
      controllerPiano.runJavaScript("setPromptNoteNumberCount(3)");
      controllerKeyboard.runJavaScript('resetPlay()');
      controllerKeyboard.runJavaScript('setPiano(55, 76)');
    } else {
      //creative
      controllerPiano.runJavaScript(
          "setAbcString(\"%%MIDI program 0\\nL:1/4\\nM:4/4\\nK:C\\n|\", false)");
      controllerPiano.runJavaScript("setPromptNoteNumberCount(0)");
      controllerKeyboard.runJavaScript('resetPlay()');
      controllerKeyboard.runJavaScript('setPiano(55, 76)');
    }
  }

  void popupwindow11(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => OnPopupWindowWidget(
          title: const Text("Please select your Language"),
          footer: Text('close'),
          child: Container(
            color: Colors.red,
          )),
    );
  }

  List<Widget> children(BuildContext context) {
    List<Widget> res = prompts
        .map(
          (e) => Text(e),
        )
        .toList();

    return res + res;
  }
}
