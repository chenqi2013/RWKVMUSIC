import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/jiepai/jiepai_audioplayer.dart';
import 'package:rwkvmusic/jiepai/jiepai_wheel.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/mainwidget/drop_button_down.dart';
import 'package:rwkvmusic/mainwidget/text_item.dart';
import 'package:rwkvmusic/mainwidget/text_title.dart';
import 'package:rwkvmusic/style/color.dart';
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
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30.w)),
          color: Colors.transparent,
          image: const DecorationImage(
            image: AssetImage('assets/images/backgroundbg.jpg'), // 替换为你的背景图片路径
            fit: BoxFit.cover,
          ),
        ),
        width: isWindowsOrMac ? 1400.w : 1200.w,
        // height: isWindowsOrMac ? 1000.h : 910.h,
        padding: EdgeInsets.symmetric(
            horizontal: isWindowsOrMac ? 60.w : 40.w,
            vertical: isWindowsOrMac ? 40.h : 20.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextTitle(
                    text: 'Metronome Settings'.tr,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context,
                            '${audioPlayerManage.bpm.value} ${audioPlayerManage.beatsPerBar.value}/${listJiepai[audioPlayerManage.rightIndex.value]}');
                      },
                      child: Icon(
                        Icons.close,
                        size: 70.w,
                      )),
                ],
              ),

              // Row(
              //   children: [
              //     const Text('开启节拍器'),
              //     const SizedBox(
              //       width: 15,
              //     ),
              //     GestureDetector(
              //       onTap: () {
              //         audioPlayerManage.isPlay.value =
              //             !audioPlayerManage.isPlay.value;
              //         if (!audioPlayerManage.isPlay.value) {
              //           // _beatCount = 0;
              //           // _timer?.cancel();
              //           audioPlayerManage.stopAudio();
              //         } else {
              //           // startMetronome();
              //           audioPlayerManage.startMetronome();
              //         }
              //       },
              //       child: Obx(() {
              //         return Image.asset(
              //           !audioPlayerManage.isPlay.value
              //               ? 'assets/images/bpmstart.png'
              //               : 'assets/images/bpmpause.png',
              //           width: 15,
              //           height: 15,
              //         );
              //       }),
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 20,
              // ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textBaseline: TextBaseline.alphabetic, // 指定基线对齐的基线
                children: [
                  TextItem(text: 'Beat'.tr),
                  Obx(() => DropButtonList(
                        key: const ValueKey('Time'),
                        items: timeSignatures,
                        index: timeSignature.value,
                        onChanged: (index) {
                          timeSignature.value = index;
                          timeSingnatureStr = timeSignatures[index];
                          // updateTimeSignature();
                        },
                      )),
                ],
              ).marginOnly(top: 20.h),
              // Row(
              //   children: [
              //     TextItem(text: 'Beat'.tr),
              //     const SizedBox(
              //       width: 20,
              //     ),
              //     GestureDetector(
              //       onTap: () async {
              //         var result = await showModalBottomSheet(
              //           context: context,
              //           builder: (BuildContext context) {
              //             return JiePaiWheelPicker(
              //                 leftWheelIndex:
              //                     audioPlayerManage.beatsPerBar.value - 1,
              //                 rightWheelIndex:
              //                     audioPlayerManage.rightIndex.value);
              //           },
              //           isDismissible: true,
              //         );
              //         debugPrint('result: $result');
              //         if (result != null) {
              //           // jiepaiStr.value =
              //           //     '${result[0] + 1}/${listJiepai[result[1]]}';
              //           audioPlayerManage.beatsPerBar.value = result[0] + 1;
              //           audioPlayerManage.rightIndex.value = result[1];
              //         }
              //       },
              //       child: Container(
              //         padding: const EdgeInsets.symmetric(
              //             horizontal: 10, vertical: 5),
              //         decoration: BoxDecoration(
              //           color: Color(0x00000000),
              //           border: Border.all(color: Colors.white, width: 0.5),
              //           borderRadius: BorderRadius.circular(5),
              //         ),
              //         child: Row(
              //           children: [
              //             Obx(() {
              //               return Text(
              //                   '${audioPlayerManage.beatsPerBar.value}/${listJiepai[audioPlayerManage.rightIndex.value]}');
              //             }),
              //             const SizedBox(
              //               width: 15,
              //             ),
              //             Image.asset(
              //               'assets/images/arrowdown.png',
              //               width: 10,
              //               height: 7,
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextItem(text: 'BPM'.tr),
                  // Obx(() {
                  //   return Text('${audioPlayerManage.bpm.value}');
                  // }),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                    width: isWindowsOrMac ? 1163.w : 884.w,
                    height: isWindowsOrMac ? 113.h : 96.h,
                    decoration: BoxDecoration(
                      color: AppColor.color_2C2C2C,
                      borderRadius:
                          BorderRadius.circular(isWindowsOrMac ? 14.h : 12.h),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(.25),
                          blurRadius: 1,
                          spreadRadius: 0,
                          offset: const Offset(
                            2,
                            2,
                          ),
                        ),
                        const BoxShadow(
                          color: Colors.black,
                          blurRadius: 1,
                          spreadRadius: 0,
                          offset: Offset(
                            -2,
                            -2,
                          ),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            audioPlayerManage.bpm.value -= 1;
                            if (audioPlayerManage.bpm.value < 20) {
                              audioPlayerManage.bpm.value = 20;
                            }
                            if (audioPlayerManage.isPlay.value) {
                              audioPlayerManage.stopMetronome();
                              audioPlayerManage.startMetronome();
                            }
                          },
                          child: SvgPicture.asset(
                            'assets/images/bpm_jian.svg',
                            width: 44.w,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          '20',
                          style: TextStyle(color: Colors.white),
                        ),
                        Obx(() {
                          return Expanded(
                            child: Slider(
                                activeColor: Colors.white,
                                inactiveColor: Colors.black,
                                thumbColor: Colors.white,
                                value: audioPlayerManage.bpm.toDouble(),
                                onChanged: (double value) {
                                  audioPlayerManage.bpm.value = value.toInt();
                                  if (audioPlayerManage.isPlay.value) {
                                    audioPlayerManage.stopMetronome();
                                    audioPlayerManage.startMetronome();
                                    // _timer?.cancel();
                                    // startMetronome();
                                  }
                                },
                                min: 20,
                                max: 200),
                          );
                        }),
                        const Text(
                          '200',
                          style: TextStyle(color: Colors.white),
                        ),
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
                              audioPlayerManage.stopMetronome();
                              audioPlayerManage.startMetronome();
                              // _beatCount = 0;
                              // _timer?.cancel();
                              // startMetronome();
                            }
                          },
                          child: SvgPicture.asset(
                            'assets/images/bpm_jia.svg',
                            width: 44.w,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextItem(text: 'Beat volume'.tr),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                    width: isWindowsOrMac ? 1163.w : 784.w,
                    height: isWindowsOrMac ? 113.h : 96.h,
                    decoration: BoxDecoration(
                      color: AppColor.color_2C2C2C,
                      borderRadius:
                          BorderRadius.circular(isWindowsOrMac ? 14.h : 12.h),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(.25),
                          blurRadius: 1,
                          spreadRadius: 0,
                          offset: const Offset(
                            2,
                            2,
                          ),
                        ),
                        const BoxShadow(
                          color: Colors.black,
                          blurRadius: 1,
                          spreadRadius: 0,
                          offset: Offset(
                            -2,
                            -2,
                          ),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/beat_volume.svg',
                          width: 44.w,
                        ),
                        Obx(() {
                          return Expanded(
                            child: Slider(
                                activeColor: Colors.white,
                                inactiveColor: Colors.black,
                                thumbColor: Colors.white,
                                value: audioPlayerManage.volume.value,
                                onChanged: (double value) {
                                  audioPlayerManage.volume.value = value;
                                },
                                min: 0,
                                max: 1),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
