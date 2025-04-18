import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/utils/audioplayer.dart';
import 'package:rwkvmusic/utils/midiconvertabc.dart';
import 'package:rwkvmusic/utils/mididevicemanage.dart';

// import 'controller.dart';

void main() => runApp(const MIDIDeviceListPage());

class MIDIDeviceListPage extends StatefulWidget {
  const MIDIDeviceListPage({super.key});

  @override
  MIDIDeviceListPageState createState() => MIDIDeviceListPageState();
}

class MIDIDeviceListPageState extends State<MIDIDeviceListPage> {
  late MidiDeviceManage deviceManage;
  var allDives = <MidiDevice>[].obs;
  @override
  void initState() {
    super.initState();
    deviceManage = MidiDeviceManage.getInstance();
    print('deviceManage11=$identityHashCode($deviceManage)');
    // deviceManage.receiveCallback = (int data) {
    //   print('receiveCallback=$data');
    // };
    // deviceManage.updateNetworkSessionState();
  }

  @override
  void dispose() {
    // deviceManage.cancelMidi();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MIDIDevice List'),
        actions: <Widget>[
          // Switch(
          //     value: deviceManage.iOSNetworkSessionEnabled.value,
          //     onChanged: (newValue) {
          //       deviceManage.networkSessionEnabled(newValue);
          //     }),
          // Switch(
          //     value: deviceManage.virtualDeviceActivated.value,
          //     onChanged: (newValue) {
          //       deviceManage.addOrRemoveVirtualDevice(newValue);
          //     }),
          Builder(builder: (context) {
            return IconButton(
                onPressed: () async {
                  deviceManage.refreshMIDIDevice(context);
                  List<MidiDevice>? list =
                      await deviceManage.midiCommand!.devices;
                  allDives.clear();
                  if (list!.isNotEmpty) {
                    allDives.addAll(list);
                  }
                },
                icon: const Icon(Icons.refresh));
          }),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        child: const Text(
          "Tap to connnect/disconnect, long press to control.",
          textAlign: TextAlign.center,
        ),
      ),
      body: Center(
        child: Obx(() {
          return ListView.builder(
            itemCount: allDives.length,
            itemBuilder: (context, index) {
              var device = allDives[index];
              return ListTile(
                title: Text(
                  device.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                subtitle: Text(
                    "ins:${device.inputPorts.length} outs:${device.outputPorts.length}, ${device.id}, ${device.type}"),
                leading: Icon(device.connected
                    ? Icons.radio_button_on
                    : Icons.radio_button_off),
                trailing: Icon(deviceManage.deviceIconForType(device.type)),
                onLongPress: () {
                  deviceManage.stopDevice();
                  print('stopScanningForBluetoothDevices');
                },
                onTap: () {
                  deviceManage.connectOrDisconnect(device, context);
                },
              );
            },
          );
        }),
      ),
    );
  }
}
