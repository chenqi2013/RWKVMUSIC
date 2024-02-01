// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

void main() {
  runApp(FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  var list = [].obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ble scan'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Center(
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: getlistwidget(),
                flex: 5,
              ),
              Expanded(
                child: MaterialButton(
                  onPressed: () {
                    scanble();
                  },
                  child: Text('scan'),
                ),
                flex: 1,
              ),
              Expanded(
                child: MaterialButton(
                  onPressed: () {},
                  child: Text('stop'),
                ),
                flex: 1,
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
    );
  }

  void scanble() {
    FlutterBlue flutterBlue = FlutterBlue.instance;
// Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));
// Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        String name = r.device.name;
        print('$name found! rssi: ${r.rssi}');
        if (!name.isEmpty && !list.contains(name)) {
          list.add(name);
        }
      }
    });

// Stop scanning
    flutterBlue.stopScan();
  }

  void stopScan() {}

  Widget getlistwidget() {
    return Obx(() => ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: Icon(Icons.star),
              title: Text(list[index]),
            );
          },
          itemCount: list.length,
        ));
  }
}
