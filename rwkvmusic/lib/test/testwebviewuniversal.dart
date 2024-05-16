// import 'package:flutter/material.dart';
// import "package:webview_universal/webview_universal.dart";

// void main(List<String> args) {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(const MaterialApp(
//     debugShowCheckedModeBanner: false,
//     home: TestWebUniversal(),
//   ));
// }

// class TestWebUniversal extends StatefulWidget {
//   const TestWebUniversal({super.key});

//   @override
//   State<TestWebUniversal> createState() => _TestWebUniversalState();
// }

// class _TestWebUniversalState extends State<TestWebUniversal> {
//   WebViewController webViewController = WebViewController();

//   @override
//   void initState() {
//     super.initState();
//     webViewController.init(
//       context: context,
//       setState: setState,
//       uri: Uri.parse("https://www.baidu.com"),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: FloatingActionButton(
//           onPressed: () {
//             webViewController.goBackSync();
//           },
//           child: Icon(Icons.arrow_back),
//         ),
//       ),
//       body: WebView(
//         controller: webViewController,
//       ),
//     );
//   }
// }
