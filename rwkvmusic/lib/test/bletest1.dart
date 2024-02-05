// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyBluetoothApp(),
    );
  }
}

class MyBluetoothApp extends StatefulWidget {
  @override
  _MyBluetoothAppState createState() => _MyBluetoothAppState();
}

class _MyBluetoothAppState extends State<MyBluetoothApp> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? selectedDevice;
  List<BluetoothService> services = [];
  List<BluetoothCharacteristic> characteristics = [];

  @override
  void initState() {
    super.initState();
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      // 处理蓝牙扫描结果
      for (ScanResult result in results) {
        print('Found device: ${result.device.name}');
      }
    });

    flutterBlue.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              selectedDevice == null
                  ? 'No Device Selected'
                  : 'Selected Device: ${selectedDevice!.name}',
            ),
            ElevatedButton(
              onPressed: () async {
                // 选择蓝牙设备
                BluetoothDevice? device11 = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return BluetoothDeviceListDialog(
                      devices: [],//flutterBlue.scanResults.map((result) => result.device).toList()
                    );
                  },
                );
                if (device11 != null) {
                  setState(() {
                    selectedDevice = device11;
                  });
                  await connectToDevice(device11);
                }
              },
              child: Text('Select Device'),
            ),
            ElevatedButton(
              onPressed: () async {
                // 断开蓝牙设备连接
                if (selectedDevice != null) {
                  await selectedDevice!.disconnect();
                  setState(() {
                    selectedDevice = null;
                  });
                }
              },
              child: Text('Disconnect'),
            ),
            ElevatedButton(
              onPressed: () {
                // 获取蓝牙服务和特征值
                if (selectedDevice != null) {
                  discoverServices();
                }
              },
              child: Text('Discover Services'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  Future<void> discoverServices() async {
    if (selectedDevice != null) {
      List<BluetoothService> services =
          await selectedDevice!.discoverServices();
      setState(() {
        this.services = services;
      });

      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          // 监听数据变化
          await characteristic.setNotifyValue(true);
          characteristic.value.listen((List<int>? value) {
            // 处理接收到的数据
            print('Received data: $value');
          });
        }
      }
    }
  }
}

class BluetoothDeviceListDialog extends StatelessWidget {
  List<BluetoothDevice> devices;

  BluetoothDeviceListDialog({
    Key? key,
    required this.devices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select a Bluetooth Device'),
      content: Container(
        width: double.maxFinite,
        height: 300,
        child: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(devices[index].name),
              onTap: () {
                Navigator.of(context).pop(devices[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
