import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/utils/audioplayer.dart';
import 'package:rwkvmusic/utils/midiconvertabc.dart';
import 'package:rwkvmusic/widgets/toast.dart';

typedef ReceiveCallback = void Function(int data);

class MidiDeviceManage {
  // static MidiDeviceManage _instance = MidiDeviceManage._internal();
  // factory MidiDeviceManage() => _instance;
  StreamSubscription<String>? _setupSubscription;
  StreamSubscription<BluetoothState>? _bluetoothStateSubscription;
  MidiCommand? midiCommand;

  var virtualDeviceActivated = false.obs;
  var iOSNetworkSessionEnabled = false.obs;
  var _didAskForBluetoothPermissions = false.obs;

  ReceiveCallback? receiveCallback;

  MidiToABCConverter? convertABC;

  // 单例模式固定格式
  // MidiDeviceManage._();

  // 单例模式固定格式
  static MidiDeviceManage? _instance;

  // 单例模式固定格式
  static MidiDeviceManage getInstance() {
    if (_instance == null) {
      _instance = MidiDeviceManage._();
    }
    return _instance!;
  }

  MidiDeviceManage._() {
    // if (_instance == null) {
    midiCommand = MidiCommand();
    convertABC = MidiToABCConverter();
    _setupSubscription = midiCommand?.onMidiSetupChanged?.listen((data) async {
      if (kDebugMode) {
        print("setup changed $data");
      }
    });
    _bluetoothStateSubscription =
        midiCommand?.onBluetoothStateChanged.listen((data) {
      if (kDebugMode) {
        print("bluetooth state change $data");
      }
    });

    updateNetworkSessionState();
    // }
  }

  // void initdata() {
  //   _setupSubscription = midiCommand.onMidiSetupChanged?.listen((data) async {
  //     if (kDebugMode) {
  //       print("setup changed $data");
  //     }
  //   });

  //   _bluetoothStateSubscription =
  //       midiCommand.onBluetoothStateChanged.listen((data) {
  //     if (kDebugMode) {
  //       print("bluetooth state change $data");
  //     }
  //   });

  //   _updateNetworkSessionState();
  // }

  updateNetworkSessionState() async {
    var nse = await midiCommand?.isNetworkSessionEnabled;
    if (nse != null) {
      iOSNetworkSessionEnabled.value = nse;
    }
  }

  void networkSessionEnabled(bool newValue) {
    midiCommand?.setNetworkSessionEnabled(newValue);
    iOSNetworkSessionEnabled.value = newValue;
  }

  void addOrRemoveVirtualDevice(bool newValue) {
    virtualDeviceActivated.value = newValue;
    if (newValue) {
      midiCommand?.addVirtualDevice(name: "Flutter MIDI Command");
    } else {
      midiCommand?.removeVirtualDevice(name: "Flutter MIDI Command");
    }
  }

  IconData deviceIconForType(String type) {
    switch (type) {
      case "native":
        return Icons.devices;
      case "network":
        return Icons.language;
      case "BLE":
        return Icons.bluetooth;
      default:
        return Icons.device_unknown;
    }
  }

  Future<void> _informUserAboutBluetoothPermissions(
      BuildContext context) async {
    if (_didAskForBluetoothPermissions.value) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
              'Please Grant Bluetooth Permissions to discover BLE MIDI Devices.'),
          content: const Text(
              'In the next dialog we might ask you for bluetooth permissions.\n'
              'Please grant permissions to make bluetooth MIDI possible.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok. I got it!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    _didAskForBluetoothPermissions.value = true;

    return;
  }

  void refreshMIDIDevice(BuildContext context) async {
    // Ask for bluetooth permissions
    await _informUserAboutBluetoothPermissions(context);
    // Start bluetooth
    if (kDebugMode) {
      print("start ble central");
    }
    await midiCommand?.startBluetoothCentral().catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err),
      ));
    });

    if (kDebugMode) {
      print("wait for init");
    }
    await midiCommand!
        .waitUntilBluetoothIsInitialized()
        .timeout(const Duration(seconds: 5), onTimeout: () {
      if (kDebugMode) {
        print("Failed to initialize Bluetooth");
      }
    });

    // If bluetooth is powered on, start scanning
    if (midiCommand?.bluetoothState == BluetoothState.poweredOn) {
      midiCommand?.startScanningForBluetoothDevices().catchError((err) {
        if (kDebugMode) {
          print("Error $err");
        }
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Scanning for bluetooth devices ...'),
        ));
      }
    } else {
      final messages = {
        BluetoothState.unsupported:
            'Bluetooth is not supported on this device.',
        BluetoothState.poweredOff: 'Please switch on bluetooth and try again.',
        BluetoothState.poweredOn: 'Everything is fine.',
        BluetoothState.resetting: 'Currently resetting. Try again later.',
        BluetoothState.unauthorized:
            'This app needs bluetooth permissions. Please open settings, find your app and assign bluetooth access rights and start your app again.',
        BluetoothState.unknown: 'Bluetooth is not ready yet. Try again later.',
        BluetoothState.other:
            'This should never happen. Please inform the developer of your app.',
      };
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(messages[midiCommand?.bluetoothState] ??
              'Unknown bluetooth state: ${midiCommand?.bluetoothState}'),
        ));
      }
    }
    if (kDebugMode) {
      print("done");
    }
    // If not show a message telling users what to do
  }

  void stopDevice() {
    midiCommand?.stopScanningForBluetoothDevices();
  }

  Future<List<MidiDevice>?> getDevice() {
    return midiCommand!.devices;
  }

  void connectOrDisconnect(MidiDevice device, BuildContext context) {
    if (device.connected) {
      if (kDebugMode) {
        toastInfo(msg: "disconnect");
      }
      midiCommand?.disconnectDevice(device);
    } else {
      if (kDebugMode) {
        print("connect");
      }
      midiCommand?.connectToDevice(device).then((_) {
        if (kDebugMode) {
          toastInfo(msg: "device connected async");
        }
        midiCommand?.onMidiDataReceived?.listen((data) {
          MidiPacket datatmp = data;
          print('Received MIDI data: ${data.data}');
          var result = convertABC!.midiToABC(datatmp.data, false);
          print('convertdata=$result');
          if ((result[0] as String).isNotEmpty) {
            String path = convertABC!.getNoteMp3Path(result[1]);
            if (receiveCallback != null) {
              receiveCallback!(result[1]);
            }
            AudioPlayerManage()
                .playAudio('player/soundfont/acoustic_grand_piano-mp3/$path');
          }
        });
      }).catchError((err) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error: ${(err as PlatformException?)?.message}")));
      });
    }
  }

  void cancelMidi() {
    _setupSubscription?.cancel();
    _bluetoothStateSubscription?.cancel();
  }
}
