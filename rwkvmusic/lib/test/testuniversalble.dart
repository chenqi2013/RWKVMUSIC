import 'dart:typed_data';

import 'package:universal_ble/universal_ble.dart';
import 'package:flutter/material.dart';

void main(List<String> args) {
  runApp(MaterialApp(
    home: TestUniversalBle(),
  ));
}

class TestUniversalBle extends StatelessWidget {
  TestUniversalBle({super.key});
  late List<BleScanResult> bleList = [];
  late List bleListName = [];
  late String deviceId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('showMenu Example'),
        ),
        body: Center(
          child: Column(children: [
            InkWell(
              onTap: () {
                startScan();
              },
              child: const Text('scan start'),
            ),
            const SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: () {
                UniversalBle.stopScan();
              },
              child: const Text('scan stop'),
            ),
            const SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: () async {
                BleScanResult device = bleList[0];
                conectDevice(device);
              },
              child: const Text('connect'),
            ),
            const SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: () {
                UniversalBle.disconnect(deviceId);
              },
              child: const Text('disconnect'),
            ),
            const SizedBox(
              height: 30,
            ),
          ]),
        ));
  }

  void startScan() {
    UniversalBle.onScanResult = (scanResult) {
      if (scanResult.name != null && scanResult.name!.startsWith('SMK25V2')) {
        if (!bleListName.contains(scanResult.name)) {
          print('scanResult==${scanResult.name}');
          bleList.add(scanResult);
          bleListName.add(scanResult.name);
        }
      }
    };
    UniversalBle.startScan();
  }

  void conectDevice(BleScanResult device) {
    deviceId = device.deviceId;
    UniversalBle.connect(deviceId);
    UniversalBle.onConnectionChanged =
        (String deviceId, BleConnectionState state) async {
      print('OnConnectionChanged $deviceId, $state');
      if (state == BleConnectionState.connected) {
        // Discover services of a specific device
        List<BleService> bleServices =
            await UniversalBle.discoverServices(deviceId);
        for (BleService service in bleServices) {
          print('ble serviceid==${service.uuid}');
          print('ble BleCharacteristic==${service.characteristics}');
          for (BleCharacteristic characteristic in service.characteristics) {
            // Subscribe to a characteristic
            UniversalBle.setNotifiable(deviceId, service.uuid,
                characteristic.uuid, BleInputProperty.notification);
            // Get characteristic updates in `onValueChanged`
            UniversalBle.onValueChanged =
                (String deviceId, String characteristicId, Uint8List value) {
              print(
                  'onValueChanged $deviceId, $characteristicId, ${value.sublist(2)}');
            };
          }
        }
      }
    };
  }
}
