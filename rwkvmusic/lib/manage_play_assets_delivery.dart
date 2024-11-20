import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rwkvmusic/adapter.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/utils/common_utils.dart';
import 'package:rwkvmusic/values/constantdata.dart';

void main() {
  runApp(const _CheckApp());
}

// ignore: unused_element
void _cc(Object? object) {
  if (kDebugMode) print("💬: $object");
}

class ManagePlayAssetsDelivery {
  static const _loadFromAssets = true;

  static Future<String?> copyAssetsToCache(String assetName) async {
    if (_loadFromAssets) {
      final inMollysFiles = _availableFiles.contains(assetName);
      if (!inMollysFiles) {
        throw "copyAssetsToCache failed: $assetName is not in the available files list";
      }
      final res = await Adapter.call<String?>(
        ToNative.getAssetPath,
        {"assetName": assetName},
      );
      return res;
    }

    final res = await CommonUtils.copyFileFromAssets(assetName);
    return res;
  }

  static Future<List<String>> listAllAssets({String? path}) async {
    final raw =
        await Adapter.call(ToNative.listAllAssets, {"path": path ?? ""});
    final res = (raw as List).map((e) => e.toString()).toList();
    return res;
  }

  static const _availableFiles = {
    // MTK
    'RWKV-6-ABC-85M-v1-20240217-ctx1024-MTK-MT6989.config',
    'RWKV-6-ABC-85M-v1-20240217-ctx1024-MTK-MT6989.dla',
    'RWKV-6-ABC-85M-v1-20240217-ctx1024-MTK-MT6989.emb',
    // NCNN
    'RWKV-6-ABC-85M-v1-20240217-ctx1024-NCNN.bin',
    'RWKV-6-ABC-85M-v1-20240217-ctx1024-NCNN.config',
    'RWKV-6-ABC-85M-v1-20240217-ctx1024-NCNN.param',
    // QNN runtimes
    'libQnnCpu.so',
    'libQnnGpu.so',
    'libQnnGpuNetRunExtensions.so',
    'libQnnHtp.so',
    'libQnnHtpNetRunExtensions.so',
    'libQnnHtpPrepare.so',
    'libQnnHtpV68Skel.so',
    'libQnnHtpV68Stub.so',
    'libQnnHtpV69Skel.so',
    'libQnnHtpV69Stub.so',
    'libQnnHtpV73Skel.so',
    'libQnnHtpV73Stub.so',
    'libQnnHtpV75Skel.so',
    'libQnnHtpV75Stub.so',
    'libQnnSystem.so',
    // QNN weights
    'libRWKV-6-ABC-85M-v1-20240217-ctx1024-QNN2.26.config',
    'libRWKV-6-ABC-85M-v1-20240217-ctx1024-QNN2.26.so',
    // RWKV runtime
    'libfaster_rwkvd.so',
  };

  static Future<void> initStack() async {
    _cc("initStack");

    if (kDebugMode) listAllAssets(path: "");

    String cachePath = await CommonUtils.getCachePath();
    String soPath = '$cachePath/libfaster_rwkvd.so';
    bool isFileExists = File(soPath).existsSync();

    if (isFileExists) {
      dllPath.value = soPath;
    } else {
      final soPath = await copyAssetsToCache('libfaster_rwkvd.so');
      if (soPath == null) {
        throw "copyAssetsToCache failed: Can not find libfaster_rwkvd.so";
      }
      dllPath.value = soPath;
    }

    switch (currentModelType) {
      case ModelType.ncnn:
        if (kDebugMode) print("✅ Using ncnn");
        final p = await copyAssetsToCache(
            'RWKV-6-ABC-85M-v1-20240217-ctx1024-NCNN.bin');
        if (p == null) {
          throw "What the fuck?!";
        }
        binPath.value = p;
        await copyAssetsToCache(
            'RWKV-6-ABC-85M-v1-20240217-ctx1024-NCNN.config');
        await copyAssetsToCache(
            'RWKV-6-ABC-85M-v1-20240217-ctx1024-NCNN.param');
        break;
      case ModelType.qnn:
        if (kDebugMode) print("✅ Using qnn");
        if (!isFileExists) {
          final p = await copyAssetsToCache(
              'libRWKV-6-ABC-85M-v1-20240217-ctx1024-QNN2.26.so');
          if (p == null) {
            throw "What the fuck?!";
          }
          binPath.value = p;
          for (String soName in qnnListFromMolly) {
            await copyAssetsToCache(soName);
          }
        } else {
          String qnnsoPath =
              '$cachePath/libRWKV-6-ABC-85M-v1-20240217-ctx1024-QNN2.26.so';
          binPath.value = "$qnnsoPath:$cachePath";
        }
        await copyAssetsToCache(
            'libRWKV-6-ABC-85M-v1-20240217-ctx1024-QNN2.26.config');
        await copyAssetsToCache(
            'RWKV-6-ABC-85M-v1-20240217-ctx1024-NCNN.param');
        break;
      case ModelType.mtk:
        if (kDebugMode) print("✅ Using mtk");
        await copyAssetsToCache(
            'RWKV-6-ABC-85M-v1-20240217-ctx1024-MTK-MT6989.config');
        await copyAssetsToCache(
            'RWKV-6-ABC-85M-v1-20240217-ctx1024-MTK-MT6989.dla');
        await copyAssetsToCache(
            'RWKV-6-ABC-85M-v1-20240217-ctx1024-MTK-MT6989.emb');
        break;
      case ModelType.webgpu:
        throw "webgpu not supported in Android";
    }
  }
}

class _CheckApp extends StatefulWidget {
  const _CheckApp();

  static const channel = MethodChannel('universal');

  @override
  State<_CheckApp> createState() => _CheckAppState();
}

class _CheckAppState extends State<_CheckApp> {
  void _copyAll() async {
    const list = [
      "libQnnGpuNetRunExtensions.so",
      "libQnnHtpNetRunExtensions.so",
      "libQnnHtpV68Stub.so",
      "libQnnHtpV69Stub.so",
      "libQnnHtpV73Stub.so",
      "libQnnHtpV75Stub.so",
      "libQnnSystem.so",
      "libRWKV-6-ABC-85M-v1-20240217-ctx1024-QNN.config",
      "libRWKV-6-ABC-85M-v1-20240217-ctx1024-QNN2.26.config",
      "RWKV-6-ABC-85M-v1-20240217-ctx1024-MTK-MT6989.config",
      "RWKV-6-ABC-85M-v1-20240217-ctx1024-MTK-MT6989.emb",
      "RWKV-6-ABC-85M-v1-20240217-ctx1024-NCNN.config",
      "RWKV-6-ABC-85M-v1-20240217-ctx1024-NCNN.param",
    ];
    for (var assetName in list) {
      await _copyToCacheAndGetPath(assetName);
    }
  }

  Future<void> _copyToCacheAndGetPath(String assetName) async {
    final start = DateTime.now();
    final result = await _CheckApp.channel
        .invokeMethod("getAssetPath", {"assetName": assetName});
    final end = DateTime.now();
    final cost = end.difference(start).inMilliseconds;
    print('cost: $cost ms');
    print(result);
  }

  Future<void> _listAllAssets(String path) async {
    final start = DateTime.now();
    final result =
        await _CheckApp.channel.invokeMethod("listAllAssets", {"path": path});
    final end = DateTime.now();
    final cost = end.difference(start).inMilliseconds;
    print('cost: $cost ms');

    if (result is! List) return;

    final r = (result).map((e) => e.toString()).toList();
    setState(() {
      all = r;
    });
  }

  List<String> all = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('PAD')),
        body: Column(
          children: [
            ElevatedButton(
                onPressed: () => _copyAll(), child: Text('将所有资源放到 cache 中')),
            ElevatedButton(
                onPressed: () => _listAllAssets(""), child: Text('遍历所有资源')),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return Text(all[index]);
                },
                itemCount: all.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
