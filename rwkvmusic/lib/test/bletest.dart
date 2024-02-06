// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/widgets/toast.dart';

void main() {
  runApp(FlutterBlueApp());
}

class FlutterBlueApp extends StatelessWidget {
  List<BluetoothDevice> list = <BluetoothDevice>[].obs;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  late BluetoothDevice currentDevice;
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
                    startScanBLE();
                  },
                  child: Text('scan'),
                ),
                flex: 1,
              ),
              Expanded(
                child: MaterialButton(
                  onPressed: () {
                    stopScanBLE();
                  },
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

  void startScanBLE() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    var subscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        String name = r.device.name;
        print('$name found! rssi: ${r.rssi}');
        if (!name.isEmpty && !list.contains(r.device)) {
          list.add(r.device);
        }
      }
    });
    flutterBlue.state.listen((state) {
      if (state == BluetoothState.on) {
        print('chenqi Bluetooth is on');
        // Bluetooth is on, you can start scanning or do other tasks.
      } else {
        toastInfo(msg:'请先打开你手机上的蓝牙');
        // Bluetooth is off, handle accordingly.
      }
    });

    // Listen to device connection and disconnection events
    flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        print('chenqi Connected to device: ${device.name}');
        // Handle device connection
      }
    });
  }

  void stopScanBLE() {
    flutterBlue.stopScan();
  }

  Widget getlistwidget() {
    return Obx(() => ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () async {
                print('chenqi index==$index');
                currentDevice = list[index];
                currentDevice.connect().asStream().listen((event) {
                  // disconnected, connecting, connected, disconnecting
                  print('chenqi connect state=${currentDevice.state}');
                });
                currentDevice.state.listen((state) {
                  switch (state) {
                    case BluetoothDeviceState.connected:
                      print('chenqi Device is connected.');
                      toastInfo(msg: 'Device is connected');
                      stopScanBLE();
                      test();
                      break;
                    case BluetoothDeviceState.connecting:
                      print('chenqi Device is connecting.');
                      toastInfo(msg: 'Device is connecting');
                      break;
                    case BluetoothDeviceState.disconnected:
                      print('chenqi Device is disconnected.');
                      toastInfo(msg: 'Device is disconnected');
                      currentDevice.connect();
                      break;
                    default:
                    // Handle other states if needed
                  }
                });
              },
              child: ListTile(
                leading: Icon(Icons.star),
                title: Text(list[index].name),
              ),
            );
          },
          itemCount: list.length,
        ));
  }

  Future<void> test() async {
    List<BluetoothService> services = await currentDevice.discoverServices();
    services.forEach((service) async {
      // Reads all characteristics
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic characteristic in characteristics) {
        // List<int> value = await characteristic.read();
        // print('chenqi characteristic.read()==$value');
        // var descriptors = characteristic.descriptors;
        // for (BluetoothDescriptor descriptor in descriptors) {
        //   List<int> value = await descriptor.read();
        //   print('chenqi descriptor.read()==$value');
        // }
        characteristic.setNotifyValue(true);
        characteristic.value.listen((value) {
          print('chenqi characteristic.value.listen==$value');
        });
      }
    });
  }
}
