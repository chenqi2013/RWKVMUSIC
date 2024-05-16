// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter_midi_command/flutter_midi_command.dart';
// import 'package:flutter_midi_command_platform_interface/flutter_midi_command_platform_interface.dart';

// void main(List<String> args) {
//   runApp(MaterialApp(
//     home: const Testmidicommandwindows(),
//   ));
// }

// class Testmidicommandwindows extends StatefulWidget {
//   const Testmidicommandwindows({super.key});

//   @override
//   State<Testmidicommandwindows> createState() => _TestmidicommandwindowsState();
// }

// class _TestmidicommandwindowsState extends State<Testmidicommandwindows> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: InkWell(
//           child: Text('mididevice'),
//           onTap: () {
//             test();
//           },
//         ),
//       ),
//     );
//   }
// }

// void test() {
// // // 通过调用启动蓝牙子系统
//   Future<void> startBluetoothCentral = MidiCommand().startBluetoothCentral();
//   startBluetoothCentral.asStream().listen((event) {
//     print('startBluetoothCentral->');
//   });

// // // 通过调用观察蓝牙系统状态
//   Stream<BluetoothState> onBluetoothStateChanged =
//       MidiCommand().onBluetoothStateChanged;
//   onBluetoothStateChanged.asBroadcastStream().listen((event) {
//     print('onBluetoothStateChanged->$onBluetoothStateChanged');
//   });

// // 通过调用获取当前蓝牙系统状态
//   BluetoothState bluetoothState = MidiCommand().bluetoothState;
//   print('bluetoothState->$bluetoothState');

// // 通过调用开始扫描 BLE MIDI 设备
//   Future<void> startScanningForBluetoothDevices =
//       MidiCommand().startScanningForBluetoothDevices();

//   //  通过调用返回列表来获取可用 MIDI 设备的列表MidiDevice
//   Future<List<MidiDevice>?> devices = MidiCommand().devices;
//   devices.asStream().listen((devices) {
//     for (MidiDevice device in devices!) {
//       print('scan devices->${device.name}');
//     }
//   });

//   return;

// // MidiDevice通过调用连接到特定的
//   MidiDevice selectedDevice = MidiDevice('id', 'name', 'type', true);
//   Future<void> connectToDevice = MidiCommand().connectToDevice(selectedDevice);

// // 通过调用停止扫描 BLE MIDI 设备
//   MidiCommand().stopScanningForBluetoothDevices();

// // 通过调用断开与当前设备的连接
//   MidiCommand().disconnectDevice(selectedDevice);

// // 通过订阅来收听 MIDI 设置中的更新
//   Stream<String>? onMidiSetupChanged = MidiCommand().onMidiSetupChanged;

// // 通过订阅 监听从当前设备传入的 MIDI 消息
// // 之后监听器将以可变长度的 UInt8List 形式接收入站 MIDI 消息。
//   Stream<MidiPacket>? onMidiDataReceived = MidiCommand().onMidiDataReceived;

// // 通过调用 发送 MIDI 消息
// // 其中 data 是遵循 MIDI 规范的 UInt8List 字节。
// // 或者使用各种子MidiCommand类型发送 PC、CC、NoteOn 和 NoteOff 消息。
//   Uint8List data = Uint8List(10);
//   MidiCommand().sendData(data);

// // 在 iOS 上用于
// //创建虚拟 MIDI 目标和虚拟 MIDI 源。这些虚拟 MIDI 设备显示在其他应用程序中，并且可以被其他应用程序用来向您的应用程序发送和接收 MIDI。要使此功能发挥作用，请为您的应用程序启用背景音频，即将UIBackgroundModes带有值的密钥添加audio到您的应用程序info.plist文件中。
//   MidiCommand().addVirtualDevice(name: "Your Device Name");
// }
