import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class AgreementPolicyPage extends StatelessWidget {
  WebViewControllerPlus? controllerPiano;

  AgreementPolicyPage({super.key, required this.type});
  int type;

  @override
  Widget build(BuildContext context) {
    String url = 'http://www.baidu.com';
    if (type == 1) {
      url = 'https://www.rwkvos.com/';
    }
    controllerPiano = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    controllerPiano?.loadRequest(Uri.parse(url));
    return Scaffold(
      appBar: AppBar(
        title: Text('用户协议'),
      ),
      body: WebViewWidget(
        controller: controllerPiano!,
      ),
    );
  }
}
