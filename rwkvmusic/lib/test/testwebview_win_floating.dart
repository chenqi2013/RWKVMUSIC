import 'package:flutter/material.dart';
import 'package:webview_win_floating/webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WindowsWebViewPlatform.registerWith();
  runApp(const WindowsWebviewTest());
}

class WindowsWebviewTest extends StatefulWidget {
  const WindowsWebviewTest({super.key});

  @override
  State<WindowsWebviewTest> createState() => _WindowsWebviewTestState();
}

class _WindowsWebviewTestState extends State<WindowsWebviewTest> {
  final controller = WebViewController();
  String filePathKeyboardAnimation = 'assets/piano/index.html';
  String filePathKeyboard = 'assets/piano/keyboard.html';
  String filePathPiano = 'assets/player/player.html';
  @override
  void initState() {
    super.initState();
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.setBackgroundColor(Colors.cyanAccent);
    controller.setNavigationDelegate(NavigationDelegate(
      onNavigationRequest: (request) {
        if (request.url.startsWith(filePathKeyboard)) {
          return NavigationDecision.navigate;
        } else {
          print("prevent user navigate out of google website!");
          return NavigationDecision.prevent;
        }
      },
      onPageStarted: (url) => print("onPageStarted: $url"),
      onPageFinished: (url) => print("onPageFinished: $url"),
      onWebResourceError: (error) =>
          print("onWebResourceError: ${error.description}"),
    ));
    // controller.loadRequest(Uri.parse("https://www.baidu.com/"))
    controller.loadFile(filePathKeyboard);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Windows Webview example app'),
        ),
        body: WebViewWidget(controller: controller),
      ),
    );
  }
}
