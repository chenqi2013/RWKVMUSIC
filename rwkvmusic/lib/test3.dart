import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

void main() {
  runApp(const WebViewPlusExample());
}

class WebViewPlusExample extends StatelessWidget {
  const WebViewPlusExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late WebViewControllerPlus _controler;
  String filePath1 = 'assets/piano/index.html';
  String filePath2 = 'assets/piano/keyboard.html';
  String filePath3 = 'assets/player/player.html';
  @override
  void initState() {
    _controler = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            _controler.onLoaded((msg) {
              _controler.getWebViewHeight().then((value) {
                var height = int.parse(value.toString()).toDouble();
                if (height != _height) {
                  if (kDebugMode) {
                    print("Height is: $value");
                  }
                  setState(() {
                    _height = height;
                  });
                }
              });
            });
          },
        ),
      )
      ..loadFlutterAssetServer(filePath3);
    super.initState();
  }

  double _height = 0.1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('webview_flutter_plus Example'),
      ),
      body: ListView(
        children: [
          Text("Height of WebviewPlus: $_height",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 200,
            child: WebViewWidget(
              controller: _controler,
            ),
          ),
          const Text("End of WebviewPlus",
              style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controler.server.close();
    super.dispose();
  }
}