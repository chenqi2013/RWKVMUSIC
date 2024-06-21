import 'dart:isolate';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Isolate? isolate;

  void startFor() async {
    isolate ??= await Isolate.spawn(amazingFor, null);
  }

  void stopFor() {
    isolate?.kill(priority: Isolate.immediate);
    // isolate?.pause();
    isolate = null;
  }

  static void amazingFor(_) {
    for (int i = 0; i < 1000000; i++) {
      print('===$i,,DateTime.now()');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed: startFor, child: const Text("start")),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child:
                  ElevatedButton(onPressed: stopFor, child: const Text("stop")),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
