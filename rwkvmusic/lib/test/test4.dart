import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/widgets/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('showMenu Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            toastInfo(msg: 'title');
            Get.snackbar('title', 'message');
            Get.defaultDialog(title: 'hello',content: null);
            return;
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            var offset = renderBox.localToGlobal(Offset.zero);
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(offset.dx, 250, 0, 0),
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
            ).then((value) {
              // Handle the selected option
              if (value != null) {
                print('Selected: $value');
              }
            });
          },
          child: Text('Show Menu',style: TextStyle(color: Colors.red),),
        ),
      ),
    );
  }
}
