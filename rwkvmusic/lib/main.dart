import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:webview_universal/webview_universal.dart";

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
  WebViewController webViewController1 = WebViewController();
  WebViewController webViewController2 = WebViewController();
  @override
  void initState() {
    super.initState();
    webViewController1.init(
      context: context,
      setState: setState,
      uri: Uri.parse("https://www.baidu.com"),
    );
    webViewController2.init(
      context: context,
      setState: setState,
      uri: Uri.parse("https://www.qq.com/"),
    );
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
                controller: webViewController1,
              ),
            ),
            Expanded(
              flex: 2,
              child: WebView(
                controller: webViewController2,
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
                    child:
                        createButtonImageWithText('Settings', Icons.settings),
                    flex: 1,
                  ),
                ],
              ),
              ),
            )
          ],
        ));
  }

  Widget createButtonImageWithText(String text, IconData icondata) {
    return InkWell(
      onTap: () {
        // 按钮被点击时执行的操作
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 9),
        decoration: BoxDecoration(
          color: Colors.blue, // 设置背景色
          borderRadius: BorderRadius.circular(8), // 设置圆角
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icondata,
              color: Colors.white, // 设置图标颜色
            ),
            SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
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
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 9),
        decoration: BoxDecoration(
          color: Colors.blue, // 设置背景色
          borderRadius: BorderRadius.circular(8), // 设置圆角
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                color: Colors.white, // 设置文本颜色
                fontSize: 16,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down_sharp,
              color: Colors.white, // 设置图标颜色
            ),
          ],
        ),
      ),
    );
  }
}
