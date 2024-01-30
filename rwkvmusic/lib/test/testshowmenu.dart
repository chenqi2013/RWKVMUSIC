import 'package:flutter/material.dart';
import 'package:rwkvmusic/widgets/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('showMenu Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // toastInfo(msg: 'testhello');
              // Show the menu when the button is pressed
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100, 100, 0, 0),
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
              );
            },
            child: Text('Show Menu'),
          ),
        ),
      ),
    );
  }
}
