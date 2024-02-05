import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Settingswidgets extends StatelessWidget {
  Settingswidgets({Key? key, required this.list}) : super(key: key);
  List list;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(list[index]),
              );
            },
          ),
        ),
      ),
    );
  }
}
