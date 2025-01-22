import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:basic_pitch_flutter/basic_pitch_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:rwkvmusic/half_heart_painter.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/mainwidget/text_btn.dart';
import 'package:rwkvmusic/style/color.dart';
import 'package:rwkvmusic/utils/common_utils.dart';
import 'package:rwkvmusic/values/values.dart';
import 'package:rwkvmusic/widgets/toast.dart';

class RecordDialog extends StatefulWidget {
  RecordDialog({super.key, required this.callBack});
  Function(int) callBack;
  @override
  State<RecordDialog> createState() => _RecordDialogState();
}

class _RecordDialogState extends State<RecordDialog> {
  late final RecorderController recorderController;
  var recordStatus = RecordStatus.start.index;
  PlayerController controller = PlayerController();
  final playerWaveStyle = PlayerWaveStyle(
    fixedWaveColor: Colors.white54,
    liveWaveColor: Colors.red,
    spacing: 6,
    showSeekLine: false,
  );

  int index = 1;
  late StreamSubscription<PlayerState> playerStateSubscription;
//  String path = await CommonUtils.copyFileFromAssets('audio2.mp3');
  String? path;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;
  late Directory appDirectory;
  var recordDuration = 0;
  var recordDurationStr = "".obs;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    _getDir();
    _initialiseControllers();
  }

  void _getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
    path = "${appDirectory.path}/recording.m4a";
    isLoading = false;
    setState(() {});
  }

  void _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30.w)),
            color: Colors.transparent,
            image: const DecorationImage(
              image:
                  AssetImage('assets/images/backgroundbg.jpg'), // 替换为你的背景图片路径
              fit: BoxFit.cover,
            ),
          ),
          width: isWindowsOrMac ? 1400.w : 1200.w,
          // height: isWindowsOrMac ? 1000.h : 910.h,
          padding: EdgeInsets.symmetric(
              horizontal: isWindowsOrMac ? 60.w : 40.w,
              vertical: isWindowsOrMac ? 40.h : 60.h),
          child: Column(
            children: [
              Row(
                children: [
                  Spacer(),
                  InkWell(
                    child: Icon(
                      Icons.close,
                      size: 70.w,
                    ),
                    onTap: () {
                      isShowDialog = false;
                      // playerStateSubscription.cancel();
                      controller.dispose();
                      // if (isWindowsOrMac) {
                      //   isVisibleWebview.value = !isVisibleWebview.value;
                      //   setState(() {});
                      // }
                      Navigator.of(context).pop();
                      // closeDialog();
                    },
                  ),
                ],
              ),
              if (recordStatus == RecordStatus.start.index)
                Text(
                  'Click to start humming',
                  style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.color_D9D9D9),
                ),
              if (recordStatus == RecordStatus.start.index)
                Text(
                  'Currently, only pitch recognition is supported, and note duration recognition is not supported yet.',
                  style: TextStyle(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.normal,
                      color: AppColor.color_999999),
                ),
              if (recordStatus == RecordStatus.stop.index)
                Text(
                  'Recording',
                  style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.color_D9D9D9),
                ),
              if (recordStatus == RecordStatus.stop.index)
                Obx(() {
                  return Text(
                    recordDurationStr.value,
                    style: TextStyle(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.normal,
                        color: AppColor.color_999999),
                  );
                }),
              if (recordStatus == RecordStatus.stop.index)
                AudioWaveforms(
                  enableGesture: true,
                  size: Size(MediaQuery.of(context).size.width / 2, 30),
                  recorderController: recorderController,
                  waveStyle: const WaveStyle(
                    waveColor: Colors.white,
                    extendWaveform: true,
                    showMiddleLine: false,
                  ),
                  // decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.circular(12.0),
                  //   color: const Color(0xFF1E1B26),
                  // ),
                  padding: const EdgeInsets.only(left: 18),
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                ),
              if (recordStatus == RecordStatus.play.index)
                Text(
                  'Recording completed',
                  style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.color_D9D9D9),
                ),
              if (recordStatus == RecordStatus.pause.index)
                Text(
                  'Playing',
                  style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColor.color_D9D9D9),
                ),
              if (recordStatus == RecordStatus.pause.index)
                Obx(() => Text(
                      recordDurationStr.value,
                      style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.normal,
                          color: AppColor.color_999999),
                    )),
              if (recordStatus == RecordStatus.pause.index)
                AudioFileWaveforms(
                  size: Size(MediaQuery.of(context).size.width / 2, 30),
                  playerController: controller,
                  waveformType:
                      index.isOdd ? WaveformType.fitWidth : WaveformType.long,
                  playerWaveStyle: playerWaveStyle,
                  backgroundColor: Colors.green,
                ),
              Stack(
                children: [
                  // 自定义的半心圆
                  if (recordStatus == RecordStatus.start.index ||
                      recordStatus == RecordStatus.stop.index)
                    Align(
                      alignment: Alignment.center,
                      child: CustomPaint(
                        size: Size(120, 120), // 自定义画布的大小
                        painter: HalfHeartPainter(),
                      ),
                    ),
                  // 图片居中显示
                  Align(
                    alignment: Alignment.center, // 确保对齐到中心
                    child: InkWell(
                      child: SvgPicture.asset(
                        'assets/images/${recordStatus == 0 ? 'record_start.svg' : recordStatus == 1 ? 'record_pause.svg' : recordStatus == 2 ? 'play_start.svg' : 'play_pause.svg'}',
                        height: 44, // 确保图标大小合适
                      ).marginOnly(
                          top: 38,
                          bottom: (recordStatus == RecordStatus.start.index ||
                                  recordStatus == RecordStatus.stop.index)
                              ? 0
                              : 35),
                      onTap: () async {
                        if (recordStatus == RecordStatus.start.index) {
                          recordStatus = RecordStatus.stop.index;
                          recordAudio();
                          calRecordTime();
                          await _startOrStopRecording();
                          setState(() {});
                        } else if (recordStatus == RecordStatus.stop.index) {
                          stopRecordTimer();
                          await stopRecording(context);
                          await _startOrStopRecording();
                          path = recordAudioPath!;
                          controller.preparePlayer(
                            path: path!,
                            shouldExtractWaveform: true,
                          );
                          controller
                              .extractWaveformData(
                                path: path!,
                                noOfSamples:
                                    playerWaveStyle.getSamplesForWidth(200),
                              )
                              .then((waveformData) =>
                                  debugPrint(waveformData.toString()));
                          recordStatus = RecordStatus.play.index;
                          setState(() {});
                        } else if (recordStatus == RecordStatus.play.index ||
                            recordStatus == RecordStatus.pause.index) {
                          if (controller.playerState.isPlaying) {
                            await controller.pausePlayer();
                            recordStatus = RecordStatus.play.index;
                          } else {
                            await controller.startPlayer();
                            recordStatus = RecordStatus.pause.index;
                          }
                          controller.setFinishMode(finishMode: FinishMode.loop);
                          setState(() {});
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (recordStatus == RecordStatus.play.index ||
                  recordStatus == RecordStatus.pause.index)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextBtn(
                      width: isWindowsOrMac ? 1000.w : 420.w,
                      height: isWindowsOrMac ? 113.h : 80.h,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      text: 'Cancle'.tr,
                      linearColorStart: AppColor.color_805353,
                      linearColorEnd: AppColor.color_5E1E1E,
                    ),
                    TextBtn(
                      width: isWindowsOrMac ? 1000.w : 420.w,
                      height: isWindowsOrMac ? 113.h : 80.h,
                      onPressed: () {
                        Navigator.of(context).pop();
                        basicPitch(recordAudioPath!);
                      },
                      text: 'Recognition'.tr,
                      textColor: AppColor.color_A1D632,
                      // linearColorStart: AppColor.color_A1D632,
                      // linearColorEnd: AppColor.color_EBFEC1,
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  void calRecordTime() {
    recordDuration = 0;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      recordDuration++;
      print('Elapsed time: $recordDuration seconds');
      recordDurationStr.value = CommonUtils.formatDuration(recordDuration);
    });
  }

  void stopRecordTimer() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
  }

  Future<void> _startOrStopRecording() async {
    try {
      if (isRecording) {
        recorderController.reset();

        path = await recorderController.stop(false);

        if (path != null) {
          isRecordingCompleted = true;
          debugPrint(path);
          debugPrint("Recorded file size: ${File(path!).lengthSync()}");
        }
      } else {
        await recorderController.record(path: path); // Path is optional
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (recorderController.hasPermission) {
        setState(() {
          isRecording = !isRecording;
        });
      }
    }
  }

  void _refreshWave() {
    if (isRecording) recorderController.refresh();
  }

  Future<void> recordAudio() async {
    Directory tempDir = await getApplicationCacheDirectory();
    audioRecord ??= AudioRecorder();
    if (await audioRecord!.hasPermission()) {
      await audioRecord!.start(
          RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 22050,
          ),
          path: '${tempDir.path}/hengchang.wav');

      // //------第二种，实时流
      // final stream = await audioRecord!.startStream(
      //   RecordConfig(
      //     encoder: AudioEncoder.pcm16bits,
      //     sampleRate: 22050,
      //   ),
      // );
      // streamSubscription = stream.listen((onData) {
      //   debugPrint('receive audio data=$onData');
      // }, onDone: () {
      //   debugPrint('record onDone');
      // }, onError: (e) {
      //   debugPrint('record error=${e.toString()}');
      // });
    }

    // bool result = await audioRecorder.hasPermission();
    // if (result) {
    //   await audioRecorder.start(
    //     path: '${tempDir.path}/myFile.m4a', // required
    //     encoder: AudioEncoder.AAC, // by default
    //     bitRate: 128000, // by default
    //     samplingRate: 44100, // by default
    //   );
    // } else {
    //   debugPrint('no permission to record');
    // }

    // final hasPermission = await recorderController
    //     .checkPermission(); // Check mic permission (also called during record)
    // if (hasPermission) {
    //   debugPrint('has permission to start record');
    //   await recorderController.record(
    //       sampleRate: 22050,
    //       bitRate: 128000,
    //       path: '${tempDir.path}/recordaudio.wav'); // Record (path is optional)
    // } else {
    //   debugPrint('no permission to record');
    //   toastInfo(msg: 'no permission to record');
    // }
    // await recorderController.openRecorder();
    // await recorderController.startRecorder(
    //   toFile: 'recordaudio.wav',
    //   codec: Codec.pcm16WAV,
    //   sampleRate: 22050,
    //   numChannels: 1,
    // );
  }

  Future<void> stopRecording(BuildContext context) async {
    if (await audioRecord!.isRecording()) {
      recordAudioPath = await audioRecord!.stop();
      streamSubscription?.cancel();
      // audioRecord!.cancel();
      // audioRecord!.dispose();
      // audioRecord = null;
      debugPrint('stopRecording path=$recordAudioPath');
      // showRecordDialog(context, recordAudioPath!, (bool result) {
      //   debugPrint('showRecordDialog');
      // });
    }
    streamSubscription?.cancel();
    // bool isRecording = await audioRecorder.isRecording();
    // if (isRecording) {
    //   await audioRecorder.stop();
    // }

    // await recorderController.pause(); // Pause recording
    // if (recorderController.isRecording) {
    //   recordAudioPath = await recorderController
    //       .stopRecorder(); // Stop recording and get the path
    //   // recorderController.refresh(); // Refresh waveform to original position
    //   debugPrint('stopRecording path=$recordAudioPath');
    //   basicPitch(recordAudioPath!);
    // } else {
    //   debugPrint('no recording');
    // }
  }

  Future<List<int>> basicPitch(String path) async {
    toastInfo(msg: 'Start analysis, please wait...'.tr);
    var pitchs = <int>[];
    final basicPitchInstance = BasicPitch();
    basicPitchInstance.init();

    // 复制音频文件并获取新路径
    // path = await CommonUtils.copyFileFromAssets('test_audio.wav');

    if (File(path).existsSync()) {
      debugPrint('$path exists');
      // resetToDefaulValueInCreateMode();
      final audioData = await File(path).readAsBytes();
      final noteEvents = await basicPitchInstance.predictBytes(
        audioData,
        onsetThreshold: double.parse(onsetThreshold),
        frameThreshold: double.parse(frameThreshold),
        minimalNoteLength: double.parse(minimalNoteLength),
      );
      debugPrint('noteEvents=${noteEvents.length}');

      if (noteEvents.isEmpty) {
        toastInfo(msg: 'Unable to recognize the current humming content');
      }

      // 2. 收集音符事件
      List<NoteEvent> noteEventsList = [];
      for (int i = noteEvents.length - 1; i >= 0; i--) {
        var note = noteEvents[i];
        print(
            "start: ${note['start']}, end: ${note['end']}, pitch: ${note['pitch']}");
        int pitch = int.parse('${note['pitch']}');
        double onsetTime =
            double.parse(note['start'].toString()); // 'start' 以秒为单位
        double offsetTime = double.parse(note['end'].toString()); // 'end' 以秒为单位

        noteEventsList.add(NoteEvent(
          pitch: pitch,
          onsetTime: onsetTime,
          offsetTime: offsetTime,
        ));
      }

      basicPitchInstance.release();

      // 3. 合并相邻的同音音符
      List<NoteEvent> mergedNotes = CommonUtils.mergeAdjacentNotes(
          noteEventsList,
          gapThreshold: double.parse(gapThreshold));

      // 4. 生成最终的音高列表
      pitchs = mergedNotes.map((note) => note.pitch).toList();

      // 更新钢琴键或执行其他操作
      for (var note in mergedNotes) {
        // updatePianoNote(note.pitch);
        // 如果需要，可以在这里播放音符或进行其他处理
        widget.callBack(note.pitch);
      }

      return pitchs;
    } else {
      debugPrint('$path not exists');
      return [];
    }
  }
}

String? recordAudioPath;
bool isRecording = false;
AudioRecorder? audioRecord;
StreamSubscription<Uint8List>? streamSubscription;
