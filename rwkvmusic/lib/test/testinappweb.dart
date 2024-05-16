// import 'dart:collection';

// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// void main(List<String> args) {
//   debugPrint('args: $args');
//   // if (runWebViewTitleBarWidget(args)) {
//   //   return;
//   // }
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(WebViewInAppScreen(
//     url: "http://www.baidu.com",
//     onLoadFinished: (String? url) {},
//     onWebTitleLoaded: (String? webTitle) {},
//   ));
// }

// class WebViewInAppScreen extends StatefulWidget {
//   const WebViewInAppScreen({
//     Key? key,
//     required this.url,
//     this.onWebProgress,
//     this.onWebResourceError,
//     required this.onLoadFinished,
//     required this.onWebTitleLoaded,
//     this.onWebViewCreated,
//   }) : super(key: key);

//   final String url;
//   final Function(int progress)? onWebProgress;
//   final Function(String? errorMessage)? onWebResourceError;
//   final Function(String? url) onLoadFinished;
//   final Function(String? webTitle)? onWebTitleLoaded;
//   final Function(InAppWebViewController controller)? onWebViewCreated;

//   @override
//   State<WebViewInAppScreen> createState() => _WebViewInAppScreenState();
// }

// class _WebViewInAppScreenState extends State<WebViewInAppScreen> {
//   final GlobalKey webViewKey = GlobalKey();

//   InAppWebViewController? webViewController;
//   InAppWebViewOptions viewOptions = InAppWebViewOptions(
//     useShouldOverrideUrlLoading: true,
//     mediaPlaybackRequiresUserGesture: true,
//     applicationNameForUserAgent: "dface-yjxdh-webview",
//   );

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//   }

//   @override
//   void dispose() {
//     // TODO: implement dispose
//     webViewController?.clearCache();
//     super.dispose();
//   }

//   // 设置页面标题
//   void setWebPageTitle(data) {
//     if (widget.onWebTitleLoaded != null) {
//       widget.onWebTitleLoaded!(data);
//     }
//   }

//   // flutter调用H5方法
//   void callJSMethod() {}

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: <Widget>[
//         Expanded(
//           child: InAppWebView(
//             key: webViewKey,
//             initialUrlRequest:
//                 URLRequest(url: WebUri("http://www.baidu.com")), //widget.url
//             initialUserScripts: UnmodifiableListView<UserScript>([
//               UserScript(
//                   source:
//                       "document.cookie='token=${'234234234234234'};domain='.laileshuo.cb';path=/'",
//                   injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START),
//             ]),
//             initialOptions: InAppWebViewGroupOptions(
//               crossPlatform: viewOptions,
//             ),
//             onWebViewCreated: (controller) {
//               webViewController = controller;

//               if (widget.onWebViewCreated != null) {
//                 widget.onWebViewCreated!(controller);
//               }
//             },
//             onTitleChanged: (controller, title) {
//               if (widget.onWebTitleLoaded != null) {
//                 widget.onWebTitleLoaded!(title);
//               }
//             },
//             onLoadStart: (controller, url) {},
//             shouldOverrideUrlLoading: (controller, navigationAction) async {
//               // 允许路由替换
//               return NavigationActionPolicy.ALLOW;
//             },
//             onLoadStop: (controller, url) async {
//               // 加载完成
//               widget.onLoadFinished(url.toString());
//             },
//             onProgressChanged: (controller, progress) {
//               if (widget.onWebProgress != null) {
//                 widget.onWebProgress!(progress);
//               }
//             },
//             onLoadError: (controller, Uri? url, int code, String message) {
//               if (widget.onWebResourceError != null) {
//                 widget.onWebResourceError!(message);
//               }
//             },
//             onUpdateVisitedHistory: (controller, url, androidIsReload) {},
//             onConsoleMessage: (controller, consoleMessage) {
//               print(consoleMessage);
//             },
//           ),
//         ),
//         Container(
//           height: ScreenUtil().bottomBarHeight + 50.0,
//           color: Colors.white,
//           child: Column(
//             children: [
//               Expanded(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     ElevatedButton(
//                       child: Icon(Icons.arrow_back),
//                       onPressed: () {
//                         webViewController?.goBack();
//                       },
//                     ),
//                     SizedBox(
//                       width: 25.0,
//                     ),
//                     ElevatedButton(
//                       child: Icon(Icons.arrow_forward),
//                       onPressed: () {
//                         webViewController?.goForward();
//                       },
//                     ),
//                     SizedBox(
//                       width: 25.0,
//                     ),
//                     ElevatedButton(
//                       child: Icon(Icons.refresh),
//                       onPressed: () {
//                         // callJSMethod();
//                         webViewController?.reload();
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 height: ScreenUtil().bottomBarHeight,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
