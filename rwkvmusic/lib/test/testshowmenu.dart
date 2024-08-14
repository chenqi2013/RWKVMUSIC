import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('showMenu Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // toastInfo(msg: 'testhello');
              // Show the menu when the button is pressed
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                items: [
                  const PopupMenuItem(
                    value: 'Option 1',
                    child: Text('Option 1'),
                  ),
                  const PopupMenuItem(
                    value: 'Option 2',
                    child: Text('Option 2'),
                  ),
                  const PopupMenuItem(
                    value: 'Option 3',
                    child: Text('Option 3'),
                  ),
                ],
              );
            },
            child: const Text('Show Menu'),
          ),
        ),
      ),
    );
  }
}
