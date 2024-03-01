import 'dart:collection';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  // 强制横屏显示
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  String filePath1 = 'assets/piano/index.html';
  String filePath2 = 'assets/piano/keyboard.html';
  String filePath3 = 'assets/player/player.html';
  runApp(WebViewInAppScreen(url: filePath1));
}

class WebViewInAppScreen extends StatefulWidget {
  const WebViewInAppScreen({
    Key? key,
    required this.url,
    this.onWebProgress,
    this.onWebResourceError,
    this.onLoadFinished,
    this.onWebTitleLoaded,
    this.onWebViewCreated,
  }) : super(key: key);

  final String url;
  final Function(int progress)? onWebProgress;
  final Function(String? errorMessage)? onWebResourceError;
  final Function(String? url)? onLoadFinished;
  final Function(String? webTitle)? onWebTitleLoaded;
  final Function(InAppWebViewController controller)? onWebViewCreated;

  @override
  State<WebViewInAppScreen> createState() => _WebViewInAppScreenState();
}

class _WebViewInAppScreenState extends State<WebViewInAppScreen> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings viewOptions = InAppWebViewSettings(
    // useShouldOverrideUrlLoading: true,
    // mediaPlaybackRequiresUserGesture: true,
    // applicationNameForUserAgent: "dface-yjxdh-webview",
    allowFileAccessFromFileURLs: true,
    allowUniversalAccessFromFileURLs: true,
    mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
    supportZoom: false,
    databaseEnabled: true,
    domStorageEnabled: true,
    allowBackgroundAudioPlaying: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsAirPlayForMediaPlayback: true,
    allowsInlineMediaPlayback: true,
    allowsPictureInPictureMediaPlayback: true,
    automaticallyAdjustsScrollIndicatorInsets: true,
    limitsNavigationsToAppBoundDomains: true,
    // javaScriptEnabled: false,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    webViewController?.clearCache();
    super.dispose();
  }

  // 设置页面标题
  void setWebPageTitle(data) {
    if (widget.onWebTitleLoaded != null) {
      widget.onWebTitleLoaded!(data);
    }
  }

  // flutter调用H5方法
  void callJSMethod() async {
    ByteData data = await rootBundle
        .load('assets/player/soundfont/acoustic_grand_piano-mp3/A4.mp3');
    List<int> bytes = data.buffer.asUint8List();
    print("rootBundle=${bytes}");

    webViewController!.evaluateJavascript(source: 'startPlay()');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              child: InAppWebView(
                key: webViewKey,
                initialFile: widget.url,
                // initialUserScripts: UnmodifiableListView<UserScript>([
                //   UserScript(
                //       source:
                //           "controller",
                //       injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START),
                // ]),
                initialSettings: viewOptions,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  if (widget.onWebViewCreated != null) {
                    widget.onWebViewCreated!(controller);
                  }
                },
                onTitleChanged: (controller, title) {
                  if (widget.onWebTitleLoaded != null) {
                    widget.onWebTitleLoaded!(title);
                  }
                },
                onLoadStart: (controller, url) {
                  print('onLoadStart');
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  print('shouldOverrideUrlLoading');
                  // 允许路由替换
                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStop: (controller, url) async {
                  // 加载完成
                  print('onLoadStop');
                  // widget.onLoadFinished!(url.toString());
                  webViewController!
                      .evaluateJavascript(source: 'setPiano(55, 76)');
                },
                onProgressChanged: (controller, progress) {
                  print('progress=$progress');
                  if (widget.onWebProgress != null) {
                    widget.onWebProgress!(progress);
                  }
                },
                onLoadError: (controller, Uri? url, int code, String message) {
                  print('onLoadError');
                  if (widget.onWebResourceError != null) {
                    widget.onWebResourceError!(message);
                  }
                },
                onUpdateVisitedHistory: (controller, url, androidIsReload) {},
                onConsoleMessage: (controller, consoleMessage) {
                  print(consoleMessage);
                },
              ),
            ),
            Container(
              height: 50.0,
              color: Colors.red,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          child: Icon(Icons.arrow_back),
                          onPressed: () {
                            webViewController?.goBack();
                          },
                        ),
                        SizedBox(
                          width: 25.0,
                        ),
                        ElevatedButton(
                          child: Icon(Icons.arrow_forward),
                          onPressed: () {
                            webViewController?.goForward();
                          },
                        ),
                        SizedBox(
                          width: 25.0,
                        ),
                        ElevatedButton(
                          child: Icon(Icons.refresh),
                          onPressed: () {
                            callJSMethod();
                            // webViewController?.reload();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
