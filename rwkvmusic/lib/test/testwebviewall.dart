// import 'package:flutter/material.dart';
// import 'package:webview_all/webview_all.dart';
// import 'package:webview_dart/webview_dart.dart';

// void main() => runApp(const MyApp());

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: 'Webview All',
//       debugShowCheckedModeBanner: false,
//       home: MyBrowser(),
//     );
//   }
// }

// class MyBrowser extends StatefulWidget {
//   const MyBrowser({Key? key, this.title}) : super(key: key);
//   final String? title;
  
//   @override
//   _MyBrowserState createState() => _MyBrowserState();
// }

// class _MyBrowserState extends State<MyBrowser> {
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//         body: Center(
//           // Look here!  
//           child: WebView(url: "https://www.wechat.com/en")
//       )
//     );
//   }
// }