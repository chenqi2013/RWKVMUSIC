import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/jiepai/jiepai_audioplayer.dart';
import 'package:rwkvmusic/jiepai/jiepai_wheel.dart';
import 'package:rwkvmusic/values/constantdata.dart';

class JiePaiQi extends StatefulWidget {
  JiePaiQi({super.key, required this.jiepaiCallback});
  Function jiepaiCallback;
  @override
  State<JiePaiQi> createState() => _JiePaiQiState();
}

class _JiePaiQiState extends State<JiePaiQi> {
  // RxString jiepaiStr = '3/4'.obs;

  // RxInt bpm = 60.obs;
  // RxDouble volume = 1.0.obs;

  // SoundEffect? _soundEffect;

  // Timer? _timer;
  // int _beatCount = 0;
  // // final int bpm = 60; // 设置每分钟节拍数 (BPM)
  // RxInt beatsPerBar = 3.obs; // 每小节拍数 (3/4 拍)

  JiepaiAudioPlayerManage audioPlayerManage = JiepaiAudioPlayerManage();
  @override
  void initState() {
    super.initState();
    audioPlayerManage.callback = () {
      debugPrint('jiepai callback');
      widget.jiepaiCallback();
    };
    // loadAll();
  }

  // void loadAll() async {
  //   _soundEffect = SoundEffect();
  //   _soundEffect?.initialize();

  //   Future.microtask(() async {
  //     _soundEffect?.load('bpmvoice1', "assets/audio/bpmvoice1.wav");
  //     _soundEffect?.load('bpmvoice2', "assets/audio/bpmvoice2.wav");
  //   });
  // }

  // void startMetronome() {
  //   int interval = (60000 / bpm.value).round();

  //   // 使用高精度时间戳来管理节拍
  //   DateTime nextTick = DateTime.now();

  //   _timer = Timer.periodic(Duration(milliseconds: interval), (timer) {
  //     DateTime now = DateTime.now();
  //     if (now.isAfter(nextTick) || now.isAtSameMomentAs(nextTick)) {
  //       _playSound();
  //       _beatCount = (_beatCount % beatsPerBar.value) + 1;
  //       // 计算下一个节拍的时间
  //       nextTick = nextTick.add(Duration(milliseconds: interval));
  //     }
  //   });
  // }

  // void _playSound() async {
  //   if (_beatCount == 1) {
  //     _soundEffect?.play('bpmvoice1', volume: volume.value);
  //   } else {
  //     _soundEffect?.play('bpmvoice2', volume: volume.value);
  //   }
  // }

  // @override
  // void dispose() {
  //   _timer?.cancel();
  //   _soundEffect?.release();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 290,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context,
                      '${audioPlayerManage.bpm.value} ${audioPlayerManage.beatsPerBar.value}/${listJiepai[audioPlayerManage.rightIndex.value]}');
                },
                child: const Text(
                  '确定',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ).marginOnly(bottom: 15),
            Row(
              children: [
                const Text('开启节拍器'),
                const SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onTap: () {
                    audioPlayerManage.isPlay.value =
                        !audioPlayerManage.isPlay.value;
                    if (!audioPlayerManage.isPlay.value) {
                      // _beatCount = 0;
                      // _timer?.cancel();
                      audioPlayerManage.stopAudio();
                    } else {
                      // startMetronome();
                      audioPlayerManage.startMetronome();
                    }
                  },
                  child: Obx(() {
                    return Image.asset(
                      !audioPlayerManage.isPlay.value
                          ? 'assets/images/bpmstart.png'
                          : 'assets/images/bpmpause.png',
                      width: 15,
                      height: 15,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Text('请选择节拍'),
                const SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () async {
                    var result = await showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return JiePaiWheelPicker(
                            leftWheelIndex:
                                audioPlayerManage.beatsPerBar.value - 1,
                            rightWheelIndex:
                                audioPlayerManage.rightIndex.value);
                      },
                      isDismissible: true,
                    );
                    debugPrint('result: $result');
                    if (result != null) {
                      // jiepaiStr.value =
                      //     '${result[0] + 1}/${listJiepai[result[1]]}';
                      audioPlayerManage.beatsPerBar.value = result[0] + 1;
                      audioPlayerManage.rightIndex.value = result[1];
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(0x00000000),
                      border: Border.all(color: Colors.white, width: 0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Obx(() {
                          return Text(
                              '${audioPlayerManage.beatsPerBar.value}/${listJiepai[audioPlayerManage.rightIndex.value]}');
                        }),
                        const SizedBox(
                          width: 15,
                        ),
                        Image.asset(
                          'assets/images/arrowdown.png',
                          width: 10,
                          height: 7,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Text('BPM: '),
                Obx(() {
                  return Text('${audioPlayerManage.bpm.value}');
                }),
                const SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () {
                    audioPlayerManage.bpm.value -= 1;
                    if (audioPlayerManage.bpm.value < 20) {
                      audioPlayerManage.bpm.value = 20;
                    }
                    if (audioPlayerManage.isPlay.value) {
                      audioPlayerManage.stopAudio();
                      audioPlayerManage.startMetronome();
                    }
                  },
                  child: Image.asset(
                    'assets/images/jianbpm.png',
                    width: 20,
                    height: 20,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                const Text('20'),
                Expanded(
                  // flex: 8,
                  child: Obx(() {
                    return Slider(
                        value: audioPlayerManage.bpm.toDouble(),
                        onChanged: (double value) {
                          audioPlayerManage.bpm.value = value.toInt();
                          if (audioPlayerManage.isPlay.value) {
                            audioPlayerManage.stopAudio();
                            audioPlayerManage.startMetronome();
                            // _timer?.cancel();
                            // startMetronome();
                          }
                        },
                        min: 20,
                        max: 200);
                  }),
                ),
                const Text('200'),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    audioPlayerManage.bpm.value += 1;
                    if (audioPlayerManage.bpm.value > 200) {
                      audioPlayerManage.bpm.value = 200;
                    }
                    if (audioPlayerManage.isPlay.value) {
                      audioPlayerManage.stopAudio();
                      audioPlayerManage.startMetronome();
                      // _beatCount = 0;
                      // _timer?.cancel();
                      // startMetronome();
                    }
                  },
                  child: Image.asset(
                    'assets/images/addbpm.png',
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Text('节拍器音量'),
                const SizedBox(
                  width: 20,
                ),
                Image.asset(
                  'assets/images/bpmvolume.png',
                  width: 18,
                  height: 13,
                ),
                Obx(() {
                  return Slider(
                      value: audioPlayerManage.volume.value,
                      onChanged: (double value) {
                        audioPlayerManage.volume.value = value;
                      },
                      min: 0,
                      max: 1);
                }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
