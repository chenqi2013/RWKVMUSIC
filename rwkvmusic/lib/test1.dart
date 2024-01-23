import 'package:flutter/material.dart';

void main(List<String> args) {
  // 强制横屏显示
  
  runApp(const MaterialApp(
    home: MyApp(),
  ));
}

 class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image(image: AssetImage('assets/images/account_header.png')),
    );
  }
}