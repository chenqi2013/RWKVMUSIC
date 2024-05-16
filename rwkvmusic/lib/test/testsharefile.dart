import 'dart:html';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
// import 'package:flutter_share/flutter_share.dart';
// import 'package:flutter_document_picker/flutter_document_picker.dart';

void main() => runApp(const TestShareFile());

class TestShareFile extends StatelessWidget {
  const TestShareFile({super.key});

  // Future<void> share() async {
  //   await FlutterShare.share(
  //       title: 'Example share',
  //       text: 'Example share text',
  //       linkUrl: 'https://flutter.dev/',
  //       chooserTitle: 'Example Chooser Title');
  // }

  // Future<void> shareFile() async {
  //   List<dynamic> docs = [
  //     '/data/user/0/com.example.rwkvmusic/cache/1712564515693.mid'
  //   ];
  //   if (docs.isEmpty) return;

  //   await FlutterShare.shareFile(
  //     title: 'Example share',
  //     text: 'Example share text',
  //     filePath: docs[0] as String,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () {},
              child: const Text('Share text and link'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Share local file'),
            ),
          ],
        ),
      ),
    );
  }
}
