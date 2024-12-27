import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sound_effect/sound_effect.dart';

class JiepaiAudioPlayerManage {
  static final JiepaiAudioPlayerManage _instance =
      JiepaiAudioPlayerManage._internal();
  factory JiepaiAudioPlayerManage() => _instance;
  late SoundEffect? _soundEffect;
  int beatCount = 0;
  RxInt beatsPerBar = 3.obs; // 每小节拍数 (3/4 拍)
  RxInt rightIndex = 2.obs; //对应的是分母，index从0开始

  RxInt bpm = 60.obs;
  Timer? _timer;
  RxDouble volume = 1.0.obs;
  RxBool isPlay = false.obs;

  /// 小节数为2开始计算接收midi数据的时间戳
  int measureCount = 0;
  Function? callback;
  JiepaiAudioPlayerManage._internal() {
    loadAll();
  }

  void loadAll() async {
    _soundEffect = SoundEffect();
    _soundEffect?.initialize();

    Future.microtask(() async {
      _soundEffect?.load('bpmvoice1', "assets/sounds/bpmvoice1.wav");
      _soundEffect?.load('bpmvoice2', "assets/sounds/bpmvoice2.wav");
    });
  }

  void startMetronome() {
    int interval = (60000 / bpm.value).round();

    // 使用高精度时间戳来管理节拍
    DateTime nextTick = DateTime.now();
    isPlay.value = true;
    _timer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      DateTime now = DateTime.now();
      if (now.isAfter(nextTick) || now.isAtSameMomentAs(nextTick)) {
        playSound();
        beatCount = (beatCount % beatsPerBar.value) + 1;
        if (beatCount == beatsPerBar.value) {
          measureCount++;
          if (measureCount == 2) {
            // measureCount = 0;
            callback!();
          }
        }
        // 计算下一个节拍的时间
        nextTick = nextTick.add(Duration(milliseconds: interval));
        // debugPrint('beatCount=$beatCount');
      }
    });
  }

  void playSound() async {
    if (beatCount == 1) {
      _soundEffect?.play('bpmvoice2', volume: volume.value);
    } else {
      _soundEffect?.play('bpmvoice1', volume: volume.value);
    }
  }

  void stopMetronome() {
    _timer?.cancel();
    beatCount = 0;
    _timer = null;
    isPlay.value = false;
    measureCount = 0;
    // _soundEffect?.release();
  }
}
