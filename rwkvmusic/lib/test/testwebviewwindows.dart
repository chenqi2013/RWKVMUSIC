// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';

// import 'package:webview_windows/webview_windows.dart';
// // import 'package:window_manager/window_manager.dart';

// final navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   // For full-screen example
//   WidgetsFlutterBinding.ensureInitialized();
//   // await windowManager.ensureInitialized();

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(navigatorKey: navigatorKey, home: ExampleBrowser());
//   }
// }

// class ExampleBrowser extends StatefulWidget {
//   @override
//   State<ExampleBrowser> createState() => _ExampleBrowser();
// }

// class _ExampleBrowser extends State<ExampleBrowser> {
//   final _webViewController = WebviewController();
//   final _textController = TextEditingController();
//   final List<StreamSubscription> _subscriptions = [];
//   bool _isWebviewSuspended = false;

//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }

//   Future<void> initPlatformState() async {
//     // Optionally initialize the webview environment using
//     // a custom user data directory
//     // and/or a custom browser executable directory
//     // and/or custom chromium command line flags
//     //await WebviewController.initializeEnvironment(
//     //    additionalArguments: '--show-fps-counter');

//     try {
//       await _webViewController.initialize();
//       _subscriptions.add(_webViewController.url.listen((url) {
//         _textController.text = url;
//       }));

//       _subscriptions.add(
//           _webViewController.containsFullScreenElementChanged.listen((flag) {
//         debugPrint('Contains fullscreen element: $flag');
//         // windowManager.setFullScreen(flag);
//       }));

//       await _webViewController.setBackgroundColor(Colors.transparent);
//       await _webViewController
//           .setPopupWindowPolicy(WebviewPopupWindowPolicy.deny);
//       await _webViewController.loadUrl('https://www.baidu.com');

//       if (!mounted) return;
//       setState(() {});
//     } on PlatformException catch (e) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         showDialog(
//             context: context,
//             builder: (_) => AlertDialog(
//                   title: Text('Error'),
//                   content: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text('Code: ${e.code}'),
//                       Text('Message: ${e.message}'),
//                     ],
//                   ),
//                   actions: [
//                     TextButton(
//                       child: Text('Continue'),
//                       onPressed: () {
//                         Navigator.of(context).pop();
//                       },
//                     )
//                   ],
//                 ));
//       });
//     }
//   }

//   Widget compositeView() {
//     if (!_webViewController.value.isInitialized) {
//       return const Text(
//         'Not Initialized',
//         style: TextStyle(
//           fontSize: 24.0,
//           fontWeight: FontWeight.w900,
//         ),
//       );
//     } else {
//       return Padding(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Card(
//               elevation: 0,
//               child: Row(children: [
//                 Expanded(
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: 'URL',
//                       contentPadding: EdgeInsets.all(10.0),
//                     ),
//                     textAlignVertical: TextAlignVertical.center,
//                     controller: _textController,
//                     onSubmitted: (val) {
//                       _webViewController.loadUrl(val);
//                     },
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.refresh),
//                   splashRadius: 20,
//                   onPressed: () {
//                     _webViewController.reload();
//                   },
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.developer_mode),
//                   tooltip: 'Open DevTools',
//                   splashRadius: 20,
//                   onPressed: () {
//                     _webViewController.openDevTools();
//                   },
//                 )
//               ]),
//             ),
//             Expanded(
//                 child: Card(
//                     color: Colors.transparent,
//                     elevation: 0,
//                     clipBehavior: Clip.antiAliasWithSaveLayer,
//                     child: Stack(
//                       children: [
//                         Webview(
//                           _webViewController,
//                           permissionRequested: _onPermissionRequested,
//                         ),
//                         StreamBuilder<LoadingState>(
//                             stream: _webViewController.loadingState,
//                             builder: (context, snapshot) {
//                               if (snapshot.hasData &&
//                                   snapshot.data == LoadingState.loading) {
//                                 return LinearProgressIndicator();
//                               } else {
//                                 return SizedBox();
//                               }
//                             }),
//                       ],
//                     ))),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         tooltip: _isWebviewSuspended ? 'Resume webview' : 'Suspend webview',
//         onPressed: () async {
//           if (_isWebviewSuspended) {
//             await _webViewController.resume();
//           } else {
//             await _webViewController.suspend();
//           }
//           setState(() {
//             _isWebviewSuspended = !_isWebviewSuspended;
//           });
//         },
//         child: Icon(_isWebviewSuspended ? Icons.play_arrow : Icons.pause),
//       ),
//       appBar: AppBar(
//           title: StreamBuilder<String>(
//         stream: _webViewController.title,
//         builder: (context, snapshot) {
//           return Text(
//               snapshot.hasData ? snapshot.data! : 'WebView (Windows) Example');
//         },
//       )),
//       body: Center(
//         child: compositeView(),
//       ),
//     );
//   }

//   Future<WebviewPermissionDecision> _onPermissionRequested(
//       String url, WebviewPermissionKind kind, bool isUserInitiated) async {
//     final decision = await showDialog<WebviewPermissionDecision>(
//       context: navigatorKey.currentContext!,
//       builder: (BuildContext context) => AlertDialog(
//         title: const Text('WebView permission requested'),
//         content: Text('WebView has requested permission \'$kind\''),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () =>
//                 Navigator.pop(context, WebviewPermissionDecision.deny),
//             child: const Text('Deny'),
//           ),
//           TextButton(
//             onPressed: () =>
//                 Navigator.pop(context, WebviewPermissionDecision.allow),
//             child: const Text('Allow'),
//           ),
//         ],
//       ),
//     );

//     return decision ?? WebviewPermissionDecision.none;
//   }

//   @override
//   void dispose() {
//     _subscriptions.forEach((s) => s.cancel());
//     _webViewController.dispose();
//     super.dispose();
//   }
// }
