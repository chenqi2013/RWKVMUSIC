import 'dart:async';
import 'dart:convert';
import 'dart:ffi' hide Size;
import 'dart:isolate';
import 'package:archive/archive_io.dart';
import 'package:ffi/ffi.dart';
// import 'dart:html';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rwkvmusic/gen/assets.gen.dart';
import 'package:rwkvmusic/mainwidget/ProgressbarTime.dart';
import 'package:rwkvmusic/services/storage.dart';
import 'package:rwkvmusic/store/config.dart';
import 'package:rwkvmusic/test/bletest.dart';
import 'package:rwkvmusic/test/midi_devicelist_page.dart';
import 'package:rwkvmusic/utils/abchead.dart';
// import 'package:rwkvmusic/test/testwebviewuniversal.dart';
import 'package:rwkvmusic/utils/audioplayer.dart';
import 'package:rwkvmusic/utils/midiconvertabc.dart';
import 'package:rwkvmusic/utils/mididevicemanage.dart';
import 'package:rwkvmusic/utils/commonutils.dart';
import 'package:rwkvmusic/utils/midifileconvert.dart';
import 'package:rwkvmusic/values/constantdata.dart';
import 'package:rwkvmusic/values/storage.dart';
import 'package:rwkvmusic/widgets/toast.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:webview_win_floating/webview_plugin.dart';

import 'faster_rwkvd.dart';
import 'mainwidget/BorderBtnWidget.dart';
import 'mainwidget/BtnImageTextWidget.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:on_popup_window_widget/on_popup_window_widget.dart';
import 'package:window_manager/window_manager.dart';
// import 'package:flutter_gen_runner/flutter_gen_runner.dart';
import 'package:event_bus/event_bus.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_extend/share_extend.dart';

// import 'package:share_plus/share_plus.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isMacOS) {
    WindowsWebViewPlatform.registerWith();
    if (Platform.isWindows) {
      WindowOptions windowOptions = const WindowOptions(
        size: Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        // skipTaskbar: false,
        // titleBarStyle: TitleBarStyle.hidden,
        // windowButtonVisibility: false,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
      windowManager.setResizable(false);
    }
  } else {
    // 强制横屏显示
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }
  await Get.putAsync<StorageService>(() => StorageService().init());
  Get.put<ConfigStore>(ConfigStore());
  runApp(const ScreenUtilInit(
    designSize: Size(812, 375),
    child: GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  ));
}

RxBool isGenerating = false.obs;
EventBus eventBus = EventBus();
EventBus isolateEventBus = EventBus();
late ReceivePort mainReceivePort;
late SendPort isolateSendPort;
bool isFinishABCEvent = false;
late String finalabcStringPreset;
late String finalabcStringCreate;
late bool isNeedRestart; //曲谱及键盘动画需要重新开始
late String presentPrompt;
late String createPrompt;
late OverlayEntry? overlayEntry;

RxList<BleScanResult> bleList = <BleScanResult>[].obs;
List bleListName = [];
late String deviceId;

MidiToABCConverter convertABC = MidiToABCConverter();

late int midiProgramValue;

RxInt timeSignature = 2.obs;
RxInt defaultNoteLenght = 0.obs;
RxDouble randomness = 0.7.obs;
RxInt seed = 22416.obs;
RxDouble tempo = 180.0.obs;
RxBool autoChord = true.obs;
RxBool infiniteGeneration = false.obs;

List midiNotes = [];
bool isNeedConvertMidiNotes = false;

List virtualNotes = []; //虚拟键盘按键音符
var selectstate = 0.obs;
late bool isWindowsOrMac;
late WebViewControllerPlus controllerPiano;
var isRemember = false.obs;
var isAutoSwitch = false.obs;

void fetchABCDataByIsolate() async {
  String? dllPath;
  String? binPath;
  String? configPath;
  String? paramPath;
  if (Platform.isMacOS) {
    dllPath = await CommonUtils.loadDllFromAssets('libfaster_rwkvd.dylib');
    binPath = await CommonUtils.loadDllFromAssets(
        'RWKV-5-ABC-82M-v1-20230901-ctx1024-ncnn.bin');
    configPath = await CommonUtils.loadDllFromAssets(
        'RWKV-5-ABC-82M-v1-20230901-ctx1024-ncnn.config');
    paramPath = await CommonUtils.loadDllFromAssets(
        'RWKV-5-ABC-82M-v1-20230901-ctx1024-ncnn.param');
  }
  if (Platform.isIOS) {
    String frameworkpath = await CommonUtils.frameworkpath();
    if (!(await File(frameworkpath).exists())) {
      dllPath = await CommonUtils.loadDllFromAssets('libfaster_rwkvddebug.zip');
      CommonUtils.unzipfile(dllPath);
      debugPrint('frameworkpath is not exists');
    } else {
      debugPrint('frameworkpath is exists');
    }
    dllPath = frameworkpath;
    binPath = await CommonUtils.loadDllFromAssets(
        'RWKV-5-ABC-82M-v1-20230901-ctx1024-ncnn.bin');
    configPath = await CommonUtils.loadDllFromAssets(
        'RWKV-5-ABC-82M-v1-20230901-ctx1024-ncnn.config');
    paramPath = await CommonUtils.loadDllFromAssets(
        'RWKV-5-ABC-82M-v1-20230901-ctx1024-ncnn.param');
  } else if (Platform.isAndroid) {
    dllPath = await CommonUtils.loadDllFromAssets('libfaster_rwkvd.so');
    binPath = await CommonUtils.loadDllFromAssets(
        'RWKV-5-ABC-82M-v1-20230901-ctx1024-ncnn.bin');
    configPath = await CommonUtils.loadDllFromAssets(
        'RWKV-5-ABC-82M-v1-20230901-ctx1024-ncnn.config');
    paramPath = await CommonUtils.loadDllFromAssets(
        'RWKV-5-ABC-82M-v1-20230901-ctx1024-ncnn.param');
  } else if (Platform.isWindows) {
    dllPath = await CommonUtils.getdllPath();
    binPath = await CommonUtils.getBinPath();
  }
  mainReceivePort = ReceivePort();
  // if (Platform.isIOS) {
  //   var arr = [
  //     mainReceivePort.sendPort,
  //     selectstate.value == 0 ? presentPrompt : createPrompt,
  //     midiProgramValue,
  //     seed.value,
  //     randomness.value,
  //     dllPath,
  //     binPath,
  //   ];
  //   getABCDataByLocalModel(arr);
  // } else {
// 创建 ReceivePort，以接收来自子线程的消息
  // 创建一个新的 Isolate
  await Isolate.spawn(getABCDataByLocalModel, [
    mainReceivePort.sendPort,
    selectstate.value == 0 ? presentPrompt : createPrompt,
    midiProgramValue,
    seed.value,
    randomness.value,
    dllPath,
    binPath,
  ]);
  // 监听来自子线线程的数据
  mainReceivePort.listen((data) {
    // debugPrint('Received data: $data');
    if (data is SendPort) {
      isolateSendPort = data;
    } else if (data is EventBus) {
      isolateEventBus = data;
    } else if (data == "finish") {
      mainReceivePort.close(); // 操作完成后，关闭 ReceivePort
      isGenerating.value = false;
      eventBus.fire('finish');
    } else {
      finalabcStringPreset = data;
      eventBus.fire(data);
    }
  });
  // }
}

void getABCDataByLocalModel(var array) async {
  SendPort sendPort = array[0];
  String currentPrompt = array[1];
  int midiprogramvalue = array[2];
  int seed = array[3];
  double randomness = array[4];
  String dllPath = array[5];
  String binPath = array[6];
  int eosId = 3;
  String prompt = currentPrompt;
  debugPrint('promptprompt==$prompt');
  var isolateReceivePort = ReceivePort();
  var isStopGenerating = false;
  bool isIOS = Platform.isIOS;
  // isolateReceivePort.listen((data) {
  //   debugPrint('isolateReceivePort==$data');
  //   isStopGenerating = true;
  // });

  EventBus eventBus = EventBus();

  eventBus.on().listen((event) {
    debugPrint('isolateReceivePort==$event');
    isStopGenerating = true;
    sendPort.send('finish');
  });
  sendPort.send(isolateReceivePort.sendPort);
  sendPort.send(eventBus);
  Pointer<Char> promptChar = prompt.toNativeUtf8().cast<Char>();
  faster_rwkvd fastrwkv = faster_rwkvd(
      Platform.isIOS ? DynamicLibrary.process() : DynamicLibrary.open(dllPath));
  Pointer<Char> strategy = 'ncnn fp32'.toNativeUtf8().cast<Char>();
  Pointer<Void> model =
      fastrwkv.rwkv_model_create(binPath.toNativeUtf8().cast<Char>(), strategy);
  Pointer<Void> abcTokenizer = fastrwkv.rwkv_ABCTokenizer_create();
  Pointer<Void> sampler = fastrwkv.rwkv_sampler_create();
  fastrwkv.rwkv_sampler_set_seed(sampler, seed);
  StringBuffer stringBuffer = StringBuffer();
  int preTimestamp = 0;
  late String abcString;
  // 默认的就按照pengbo的demo里面的temp=1.0 top_k=8, top_p=0.8?
  int token = fastrwkv.rwkv_abcmodel_run_prompt(model, abcTokenizer, sampler,
      promptChar, prompt.length, 1.0, 8, randomness);
  isGenerating.value = true;
  for (int i = 0; i < 1024; i++) {
    if (isStopGenerating) {
      debugPrint('stop getABCDataByLocalModel');
      break;
    }
    int result = fastrwkv.rwkv_abcmodel_run_with_tokenizer_and_sampler(
        model, abcTokenizer, sampler, token, 1.0, 8, randomness);
    if (token == result && result == 124) {
      //双||abc展示出错
      continue;
    }
    token = result;
    String resultstr = String.fromCharCode(result);
    // result :10=换行;47=/;41=);40=(;94=^;34=";32=空格
    if (result == 10 || result == 0 || result == 34) {
      //|| result == 32
      // ||
      //   // result == 40 ||
      //   // result == 94 ||
      //   // result == 47 ||
      //   // result == 41
      debugPrint('continue responseData=$resultstr,resultint=$result');
      continue;
    }
    // sb.write(resultstr);
    // debugPrint('getABCDataByLocalModel=$resultstr');
    // if (result == 10) {
    //   continue;
    // }
    // debugPrint('responseData=$resultstr,resultint=$result');
    String textstr = resultstr.replaceAll('\n', '').replaceAll('\r', '');
    stringBuffer.write(resultstr);
    textstr = CommonUtils.escapeString(stringBuffer.toString());
    abcString =
        "setAbcString(\"${ABCHead.getABCWithInstrument(textstr, midiprogramvalue)}\",false)";
    abcString = ABCHead.appendTempoParam(abcString, tempo.value.toInt());
    // debugPrint('abcString==$abcString');
    // 方案一
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    int gap = currentTimestamp - preTimestamp;
    if (gap > 400) {
      //&& resultstr.startsWith("|")
      //&& tempStr.trim().isEmpty
      // debugPrint('runJavaScript');
      preTimestamp = currentTimestamp;
      // if (i < 250) {
      //   continue;
      // }
      // if (isIOS) {
      //   controllerPiano.runJavaScript(abcString);
      // } else {
      sendPort.send(abcString);
      // }
    }

    if (eosId == token) {
      debugPrint('getABCDataByLocalModel break');
      break;
    }
  }
  isGenerating.value = false;
  // if (isIOS) {
  //   controllerPiano.runJavaScript(abcString.toString());
  // } else {
  sendPort.send(abcString.toString());
  // }
  sendPort.send('finish');
  debugPrint('getABCDataByLocalModel all data=${abcString.toString()}');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebViewControllerPlus controllerKeyboard;
  String filePathKeyboardAnimation =
      "http://leolin.wiki"; //assets/piano/index.html
  String filePathKeyboard = 'assets/piano/keyboard.html';
  String filePathPiano = 'assets/player/player.html';
  late StringBuffer stringBuffer;
  int addGap = 2; //间隔多少刷新
  int addCount = 0; //刷新次数
  var isPlay = false.obs;
  var playProgress = 0.0.obs;
  var pianoAllTime = 0.0.obs;
  late Timer timer;
  late StreamSubscription subscription;
  late HttpClient httpClient;
  int preTimestamp = 0;
  int preCount = 0;
  int listenCount = 0;
  var radioSelectedValue = 0.obs;
  String? currentSoundEffect;
  // late StringBuffer sbNoteCreate = StringBuffer();
  late MidiDeviceManage deviceManage;
  late String abcString;
  var isVisibleWebview = true.obs;
  @override
  void initState() {
    super.initState();
    midiProgramValue = ConfigStore.to.getMidiProgramSelect();
    if (midiProgramValue == -1) {
      midiProgramValue = 0;
      debugPrint('set midiprogramvalue = 0');
    }
    debugPrint('midiprogramvalue value= $midiProgramValue');
    finalabcStringCreate =
        "setAbcString(\"${ABCHead.getABCWithInstrument(r'L:1/4\nM:4/4\nK:C\n|', midiProgramValue)}\",false)";
    finalabcStringCreate =
        ABCHead.appendTempoParam(finalabcStringCreate, tempo.value.toInt());
    isWindowsOrMac = Platform.isWindows || Platform.isMacOS;
    stringBuffer = StringBuffer();
    deviceManage = MidiDeviceManage.getInstance();
    debugPrint('deviceManage22=$identityHashCode($deviceManage)');
    deviceManage.receiveCallback = (int data) {
      debugPrint('receiveCallback main =$data');
      updatePianoNote(data);
    };
    controllerPiano = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            controllerPiano.onLoaded((msg) {
              controllerPiano.getWebViewHeight().then((value) {});
            });
          },
          onPageFinished: (url) {
            debugPrint("controllerPiano onPageFinished$url");
            int index = ConfigStore.to.getPromptsSelect();
            if (index < 0) {
              index = 0;
            }
            // if (index < 0) {
            //   controllerPiano.runJavaScript(
            //       "setAbcString(\"%%MIDI program 40\\nL:1/4\\nM:4/4\\nK:D\\n\\\"D\\\" A F F\", false)");
            // } else {
            presentPrompt = CommonUtils.escapeString(promptsAbc[index]);
            finalabcStringPreset =
                "setAbcString(\"${ABCHead.getABCWithInstrument(presentPrompt, midiProgramValue)}\", false)";
            finalabcStringPreset = ABCHead.appendTempoParam(
                finalabcStringPreset, tempo.value.toInt());
            // String testabc =
            //     'setAbcString("%%MIDI program 42\\n|AGAB|eBAG|AFED|EFGE|AGFE|DEFD|GFED|E2E2|EFGE|AGFE|DEFD|GFED|EFGE|AGFE|DEFD|GFED|E2E2|z2z2|z2z2|z2z2|z2z2|z2z2|z2z2|z2z2|z2z2|z2z2|z2z2|z2z2|z2z2|z2z2|z2z2|z2z2|z2z2|EditedByCGPdded|fdgf|edcd|edcG|dded|fdgf|eagf|edc2|3gag3fgfed|cdec|3gag3fgfed|ecAc|3gag3fgfed|cdec|fedc|dBAG|EGEG|EGAG|cGAG|EGAG|EGEG|EGAG|cGAG|EGAG|AcAc|AcdcBA|GBGB|GBcBAG|AcAc|AcdcBA|GBGB|GBcBAG|cefedc|gcac|gcac|gcBAG|AcBcdB|cedefd|efgGB|c3c|AcAc|fcAF|BdBd|gdBG|egeg|cgec|defGB|c3c|AFABc|f2f2|BGBcd|g2g2|afabc|dbca|BgGe|f3f|d",false)';
            controllerPiano.runJavaScript(finalabcStringPreset);
            // }
            controllerPiano.runJavaScript("setPromptNoteNumberCount(3)");
            controllerPiano.runJavaScript("setStyle()");
          },
        ),
      )
      ..loadFlutterAssetServer(filePathPiano)
      ..addJavaScriptChannel("flutteronStartPlay",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        String message = jsMessage.message;
        debugPrint('flutteronStartPlay onMessageReceived=$message');
        pianoAllTime.value = double.parse(message.split(',')[1]);
        debugPrint('pianoAllTime:${pianoAllTime.value}');
        playProgress.value = 0.0;
        createTimer();
        isPlay.value = true;
        isNeedRestart = false;
      })
      ..addJavaScriptChannel("flutteronPausePlay",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        debugPrint('flutteronPausePlay onMessageReceived=${jsMessage.message}');
        timer.cancel();
        isPlay.value = false;
        isNeedRestart = false;
      })
      ..addJavaScriptChannel("flutteronResumePlay",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        debugPrint(
            'flutteronResumePlay onMessageReceived=${jsMessage.message}');
        createTimer();
        isPlay.value = true;
        isNeedRestart = false;
      })
      ..addJavaScriptChannel("flutteronCountPromptNoteNumber",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        debugPrint(
            'flutteronCountPromptNoteNumber onMessageReceived=${jsMessage.message}');
      })
      ..addJavaScriptChannel("flutteronEvents",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        debugPrint('flutteronEvents onMessageReceived=${jsMessage.message}');
        midiNotes = jsonDecode(jsMessage.message);
        if (!isNeedConvertMidiNotes) {
          // String jsstr =
          //     r'startPlay("[[0,\"on\",49],[333,\"on\",46],[333,\"off\",49],[1000,\"off\",46]]")';
          String jsstr =
              r'startPlay("' + jsMessage.message.replaceAll('"', r'\"') + r'")';
          controllerKeyboard.runJavaScript(jsstr);
          isFinishABCEvent = true;
          debugPrint('isFinishABCEvent == true');
        } else {
          isNeedConvertMidiNotes = false;
        }
      })
      ..addJavaScriptChannel("flutteronPlayFinish",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        debugPrint(
            'flutteronPlayFinish onMessageReceived=${jsMessage.message}');
        isPlay.value = false;
        isNeedRestart = true;
      })
      ..addJavaScriptChannel("flutteronClickNote",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        debugPrint('flutteronClickNote onMessageReceived=${jsMessage.message}');
      });

    controllerKeyboard = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            controllerKeyboard.onLoaded((msg) {
              controllerKeyboard.getWebViewHeight().then((value) {});
            });
          },
          onPageFinished: (url) {
            debugPrint("controllerKeyboard onPageFinished$url");
            controllerKeyboard.runJavaScript('resetPlay()');
            controllerKeyboard.runJavaScript('setPiano(55, 76)');
            if (selectstate.value == 1) {
              controllerKeyboard.runJavaScript('setPiano(55, 76)');
            }
          },
        ),
      )
      ..addJavaScriptChannel("flutteronNoteOff",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        debugPrint('flutteronNoteOff onMessageReceived=${jsMessage.message}');
      })
      ..addJavaScriptChannel("flutteronNoteOn",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        debugPrint('flutteronNoteOn onMessageReceived=${jsMessage.message}');
        String name =
            MidiToABCConverter().getNoteMp3Path(int.parse(jsMessage.message));
        if (currentSoundEffect != null) {
          String? mp3Folder = soundEffect[currentSoundEffect];
          debugPrint('mp3Folder==$mp3Folder');
          AudioPlayerManage().playAudio('player/soundfont/$mp3Folder/$name');
        } else {
          AudioPlayerManage()
              .playAudio('player/soundfont/acoustic_grand_piano-mp3/$name');
        }
        updatePianoNote(int.parse(jsMessage.message));
      });
    // controllerKeyboard.loadFlutterAssetServer(filePathKeyboardAnimation);
    controllerKeyboard.loadRequest(Uri.parse(filePathKeyboardAnimation));

    eventBus.on().listen((event) {
      // debugPrint('event bus==$event');
      if (event == 'finish') {
        Future.delayed(const Duration(seconds: 1), () {
          playOrPausePiano();
        });
      } else {
        controllerPiano.runJavaScript(event);
      }
    });
  }

  void updatePianoNote(int node) {
    String noteName = MidiToABCConverter().getNoteName(node);
    // sbNoteCreate.write(noteName);
    virtualNotes.add(noteName);
    StringBuffer sbff = StringBuffer();
    for (String note in virtualNotes) {
      sbff.write(note);
    }
    finalabcStringCreate = sbff.toString();
    String sb =
        "setAbcString(\"%%MIDI program $midiProgramValue}\\nL:1/4\\nM:4/4\\nK:C\\n|\\$finalabcStringCreate\",false)";
    sb = ABCHead.appendTempoParam(sb, tempo.value.toInt());
    debugPrint('curr=$sb');
    controllerPiano.runJavaScript(sb);
    createPrompt = finalabcStringCreate;
  }

  void resetLastNote() {
    if (virtualNotes.isNotEmpty) {
      virtualNotes.removeLast();
      if (virtualNotes.isEmpty) {
        finalabcStringCreate =
            "setAbcString(\"${ABCHead.getABCWithInstrument(r'L:1/4\nM:4/4\nK:C\n|', midiProgramValue)}\",false)";
        finalabcStringCreate =
            ABCHead.appendTempoParam(finalabcStringCreate, tempo.value.toInt());
        debugPrint('str112==$finalabcStringCreate');
        controllerPiano.runJavaScript(finalabcStringCreate);
        createPrompt = '';
      } else {
        StringBuffer sbff = StringBuffer();
        for (String note in virtualNotes) {
          sbff.write(note);
        }
        String sb =
            "setAbcString(\"%%MIDI program $midiProgramValue}\\nL:1/4\\nM:4/4\\nK:C\\n|\\${sbff.toString()}\",false)";
        debugPrint('curr=$sb');
        sb = ABCHead.appendTempoParam(sb, tempo.value.toInt());
        controllerPiano.runJavaScript(sb);
        createPrompt = sbff.toString();
      }
    }
  }

  void playPianoAnimation(String abcString, bool play) {
    if (play) {
      if (isFinishABCEvent && !isNeedRestart && !isNeedConvertMidiNotes) {
        controllerKeyboard.runJavaScript('resumePlay()');
        debugPrint('resumePlay()playPianoAnimation');
        // createTimer();
      } else {
        abcString = abcString.replaceAll('setAbcString', 'ABCtoEvents');
        // abcString = r'ABCtoEvents("L:1/4\nM:4/4\nK:D\n\"D\" A F F")';
        debugPrint('playPianoAnimation ABCtoEvents==$abcString');
        controllerPiano.runJavaScript(abcString);
      }
    } else {
      controllerKeyboard.runJavaScript('pausePlay()');
      // timer.cancel();
    }
  }

  void createTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) {
      if (playProgress.value >= 1) {
        playProgress.value = 1;
        timer.cancel();
      } else {
        if (playProgress.value + 1000.0 / pianoAllTime.value > 1.0) {
          playProgress.value = 1.0;
        } else {
          playProgress.value += 1000.0 / pianoAllTime.value;
        }
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    httpClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          color: const Color(0xff3a3a3a),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'RWKV AI Music Composer',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(child: Obx(() {
                      return CupertinoSegmentedControl(
                        children: const {
                          0: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Preset Mode',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                          1: Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Creative Mode',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                        },
                        onValueChanged: (int newValue) {
                          // 当选择改变时执行的操作
                          debugPrint('选择了选项 $newValue');
                          selectstate.value = newValue;
                          segmengChange(newValue);
                        },
                        groupValue: selectstate.value, // 当前选中的选项值
                        selectedColor: const Color(0xff44be1c),
                        unselectedColor: Colors.transparent,
                        borderColor: const Color(0xff6d6d6d),
                      );
                    })),
                  ],
                ),
              ),
              Flexible(
                flex: isWindowsOrMac ? 2 : 5,
                child: Visibility(
                    key: const ValueKey('ValueKey11'),
                    visible: isVisibleWebview.value,
                    // maintainSize: true, // 保持占位空间
                    // maintainAnimation: true, // 保持动画
                    // maintainState: true,
                    child: WebViewWidget(
                      controller: controllerPiano,
                    )),
              ),
              Flexible(
                  flex: isWindowsOrMac ? 3 : 5,
                  child: Visibility(
                    visible: isVisibleWebview.value,
                    // maintainSize: true, // 保持占位空间
                    // maintainAnimation: true, // 保持动画
                    // maintainState: true,
                    key: const ValueKey('ValueKey22'),
                    child: WebViewWidget(
                      controller: controllerKeyboard,
                    ),
                  )),
              //   ],
              // )),
              Expanded(
                  flex: isWindowsOrMac ? 1 : 3,
                  child: Visibility(
                      visible: isVisibleWebview.value,
                      key: const ValueKey('ValueKey33'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 5),
                        color: const Color(0xff3a3a3a),
                        child: Obx(
                          () => Row(
                            children: [
                              if (selectstate.value == 0)
                                Row(
                                  children: [
                                    creatBottomBtn('Prompts', () {
                                      debugPrint("Promptss");
                                      showPromptDialog(context, 'Prompts',
                                          prompts, STORAGE_PROMPTS_SELECT);
                                    }),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    creatBottomBtn('Sounds Effect', () {
                                      debugPrint("Sounds Effect");
                                      showPromptDialog(
                                          context,
                                          'Sounds Effect',
                                          soundEffect.keys.toList(),
                                          STORAGE_SOUNDSEFFECT_SELECT);
                                    })
                                  ],
                                ),
                              if (selectstate.value == 1)
                                creatBottomBtn('Simulate keyboard', () {
                                  debugPrint("Simulate keyboard");
                                  showPromptDialog(context, 'Keyboard Options',
                                      keyboardOptions, STORAGE_KEYBOARD_SELECT);
                                }),
                              const SizedBox(
                                width: 15,
                              ),
                              Obx(() => isGenerating.value
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    )
                                  : Container(
                                      child: null,
                                    )),
                              ProgressbarTime(playProgress, pianoAllTime),
                              const Spacer(),
                              Container(
                                child: Row(
                                  children: [
                                    Obx(() => createButtonImageWithText(
                                            !isGenerating.value
                                                ? 'Generate'
                                                : 'Stop',
                                            !isGenerating.value
                                                ? Icons.edit
                                                : Icons.refresh, () {
                                          debugPrint('Generate');
                                          isGenerating.value =
                                              !isGenerating.value;
                                          if (isGenerating.value) {
                                            playProgress.value = 0.0;
                                            pianoAllTime.value = 0.0;
                                            // controllerPiano.runJavaScript(
                                            //     "setAbcString(\"%%MIDI program 40\\nL:1/4\\nM:4/4\\nK:D\\n\\\"D\\\" A F F\", false)");
                                            // controllerPiano.runJavaScript(
                                            //     'resetTimingCallbacks()');
                                            // if (isWindowsOrMac) {
                                            fetchABCDataByIsolate();
                                            // } else {
                                            //   getABCDataByAPI();
                                            // }
                                            controllerKeyboard
                                                .runJavaScript('resetPlay()');
                                            isFinishABCEvent = false;
                                          } else {
                                            // isolateSendPort.send('stop Generating');
                                            isolateEventBus
                                                .fire("stop Generating");
                                          }
                                        })),
                                    SizedBox(
                                      width: isWindowsOrMac ? 10 : 4,
                                    ),
                                    Obx(() => Visibility(
                                        visible: selectstate.value == 1,
                                        child: createButtonImageWithText(
                                            'Undo', Icons.undo, () {
                                          debugPrint('Undo');
                                          resetLastNote();
                                        }))),
                                    SizedBox(
                                      width: isWindowsOrMac ? 10 : 4,
                                    ),
                                    Obx(() {
                                      return createButtonImageWithText(
                                          !isPlay.value ? 'Play' : 'Pause',
                                          !isPlay.value
                                              ? Icons.play_arrow
                                              : Icons.pause, () {
                                        playOrPausePiano();
                                      });
                                    }),
                                    SizedBox(
                                      width: isWindowsOrMac ? 10 : 4,
                                    ),
                                    createButtonImageWithText(
                                        'Settings', Icons.settings, () {
                                      debugPrint('Settings');
                                      if (isWindowsOrMac) {
                                        isVisibleWebview.value =
                                            !isVisibleWebview.value;
                                        setState(() {});
                                      }
                                      // Get.to(FlutterBlueApp());
                                      // Get.to(const MIDIDeviceListPage());
                                      if (selectstate.value == 0) {
                                        showSettingDialog(context);
                                      } else {
                                        showCreateModelSettingDialog(context);
                                      }
                                    }),
                                    SizedBox(
                                      width: isWindowsOrMac ? 10 : 4,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )))
            ],
          ),
        ));
  }

  void playOrPausePiano() {
    debugPrint('playOrPausePiano');
    if (!isPlay.value) {
      controllerPiano.runJavaScript("startPlay()");
    } else {
      controllerPiano.runJavaScript("pausePlay()");
    }
    playPianoAnimation(finalabcStringPreset, !isPlay.value);
    // if (isWindowsOrMac) {
    //   isPlay.value = !isPlay.value;
    // }
  }

  void getABCDataByAPI() async {
    var dic = {
      "frequency_penalty": 0.4,
      "max_tokens": 1000,
      "model": "rwkv",
      "presence_penalty": 0.4,
      "prompt": "S:2",
      "stream": true,
      "temperature": 1.2,
      "top_p": 0.5
    };
    httpClient = HttpClient();
    HttpClientRequest request = await httpClient
        .postUrl(Uri.parse('http://192.168.0.106:8000/completions'));
    request.headers.contentType = ContentType
        .json; //这个要设置，否则报错{"error":{"message":"当前分组 reverse-times 下对于模型  计费模式 [按次计费] 无可用渠道 (request id: 20240122102439864867952mIY4Ma3k)","type":"shell_api_error"}}
    request.write(jsonEncode(dic));
    // request.headers.add('Accept', 'text/event-stream');
    HttpClientResponse response = await request.close();
    subscription = response.listen((List<int> chunk) {
      if (!isGenerating.value) {
        subscription.cancel();
        httpClient.close();
        stringBuffer.clear();
        stringBuffer = StringBuffer();
        addCount = 0;
        return;
      } // 处理数据流的每个块
      listenCount++;
      String responseData = utf8.decode(chunk);
      String textstr = CommonUtils.extractTextValue(responseData)!;
      String tempStr = textstr;
      debugPrint('responseData=$textstr');
      stringBuffer.write(textstr);
      textstr = CommonUtils.escapeString(stringBuffer.toString());
      abcString =
          "setAbcString(\"${ABCHead.getABCWithInstrument(textstr, midiProgramValue)}\",false)";
      abcString = ABCHead.appendTempoParam(abcString, tempo.value.toInt());
      debugPrint('abcstring result=$abcString');
      // 方案一
      if (isWindowsOrMac) {
        int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
        int gap = currentTimestamp - preTimestamp;
        if (gap > 400) {
          //&& tempStr.trim().isEmpty
          // debugPrint('runJavaScript');
          preTimestamp = currentTimestamp;
          controllerPiano.runJavaScript(abcString.toString());
        }
        return;
      }

      // // 方案二
      // int currentCount = sb.length;
      // int gap = currentCount - preCount;
      // // debugdebugPrint('gap==$gap');
      // if (gap >= 5) {
      //   preCount = currentCount;
      //   controllerPiano.runJavaScript(sb.toString());
      // }

      // 方案三
      if (listenCount % 3 == 0) {
        controllerPiano.runJavaScript(abcString.toString());
      }
    }, onDone: () {
      // 数据流接收完成
      debugPrint('请求完成');
      httpClient.close();
      isGenerating.value = false;
      finalabcStringPreset = abcString.toString();
    }, onError: (error) {
      // 处理错误
      debugPrint('请求发生错误: $error');
      isGenerating.value = false;
    });
  }

  void segmengChange(int index) {
    if (index == 0) {
      //preset
      // controllerPiano.runJavaScript(
      //     "setAbcString(\"%%MIDI program $midiProgramValue\\nL:1/4\\nM:4/4\\nK:D\\n\\\"D\\\" A F F\", false)");
      controllerPiano.runJavaScript(finalabcStringPreset);
      controllerPiano.runJavaScript("setPromptNoteNumberCount(3)");
      // controllerKeyboard.loadFlutterAssetServer(filePathKeyboardAnimation);
      controllerKeyboard.loadRequest(Uri.parse(filePathKeyboardAnimation));
      controllerKeyboard.runJavaScript('resetPlay()');
      // controllerKeyboard.runJavaScript('setPiano(55, 76)');
    } else {
      virtualNotes.clear();
      //creative
      // String str1 =
      //     "setAbcString(\"%%MIDI program $midiProgramValue\\nL:1/4\\nM:4/4\\nK:C\\n|\", false)";
      // debugPrint('str111==$str1');
      finalabcStringCreate =
          "setAbcString(\"${ABCHead.getABCWithInstrument(r'L:1/4\nM:4/4\nK:C\n|', midiProgramValue)}\",false)";
      finalabcStringCreate =
          ABCHead.appendTempoParam(finalabcStringCreate, tempo.value.toInt());
      debugPrint('str112==$finalabcStringCreate');
      controllerPiano.runJavaScript(finalabcStringCreate);
      controllerPiano.runJavaScript("setPromptNoteNumberCount(0)");
      controllerPiano.runJavaScript("setStyle()");
      controllerKeyboard.loadFlutterAssetServer(filePathKeyboard);
      controllerKeyboard.runJavaScript('resetPlay()');
      createPrompt = '';
    }
  }

  // Widget getLogoImage() {
  //   return Assets.images.logo.image();
  // }

  void showSettingDialog(BuildContext context) {
    TextEditingController controller = TextEditingController(
        text: ''); // ${DateTime.now().microsecondsSinceEpoch}
    showDialog(
      barrierDismissible: isWindowsOrMac ? false : true,
      context: context,
      builder: (BuildContext context) {
        // 返回一个Dialog
        return Dialog(
          child: SingleChildScrollView(
              child: Container(
            width: isWindowsOrMac ? 360.w : 510.w,
            height: isWindowsOrMac ? 190.h : 370.h,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    InkWell(
                      child: const Icon(Icons.close),
                      onTap: () {
                        // if (isWindowsOrMac) {
                        //   isVisibleWebview.value = !isVisibleWebview.value;
                        //   setState(() {});
                        // }
                        // Navigator.of(context).pop();
                        closeDialog();
                      },
                    )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Obx(() => Row(children: [
                      Text('Randomness: ${(randomness.value * 100).toInt()}%'),
                      const SizedBox(
                        width: 10,
                      ),
                      Slider(
                        value: randomness.value,
                        onChanged: (newValue) {
                          randomness.value = newValue;
                        },
                      ),
                    ])),
                const SizedBox(
                  height: 10,
                ),
                Obx(() => Row(children: [
                      Text('Seed: ${seed.value}'),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                          width: 200,
                          height: 40,
                          child: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')), // 只允许输入数字
                            ],
                            decoration: const InputDecoration(
                                labelText: 'Please input seed value',
                                hintText: 'Enter a number',
                                border: OutlineInputBorder()),
                            onChanged: (text) {
                              // 当文本字段内容变化时调用
                              seed.value = int.parse(text);
                              debugPrint('Current text: ');
                            },
                          )),
                    ])),
                const SizedBox(
                  height: 10,
                ),
                Center(
                    child: Row(children: [
                  const Text('Auto Chord'),
                  const SizedBox(
                    width: 5,
                  ),
                  Obx(() => Switch(
                        value: autoChord.value,
                        onChanged: (newValue) {
                          autoChord.value = newValue;
                        },
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                  const Text('Infinite Generation'),
                  const SizedBox(
                    width: 5,
                  ),
                  Obx(() => Switch(
                        value: infiniteGeneration.value,
                        onChanged: (newValue) {
                          infiniteGeneration.value = newValue;
                        },
                      )),
                ])),
                const SizedBox(
                  height: 10,
                ),
                Center(
                    child: Row(children: [
                  Expanded(
                      flex: 2,
                      child: TextButton(
                        onPressed: () async {
                          if (midiNotes.isEmpty) {
                            // String oriabcString = finalabcStringPreset
                            //     .replaceAll('setAbcString', 'ABCtoEvents');
                            // // abcString = r'ABCtoEvents("L:1/4\nM:4/4\nK:D\n\"D\" A F F")';
                            // debugPrint(
                            //     'playPianoAnimation ABCtoEvents==');
                            isNeedConvertMidiNotes = true;
                            // controllerPiano.runJavaScript(oriabcString);
                            playPianoAnimation(finalabcStringPreset, true);
                            Future.delayed(const Duration(seconds: 2),
                                () async {
                              debugPrint('Delayed action after 3 seconds');
                              isNeedConvertMidiNotes = false;
                              if (isWindowsOrMac) {
                                final file = DirectoryPicker()
                                  ..title = 'Select a directory';
                                final result = file.getDirectory();
                                if (result != null) {
                                  debugPrint(
                                      'Select a directory=${result.path}');
                                }
                                MidifileConvert.saveMidiFile(
                                    midiNotes, result!.path);
                                Get.snackbar('提示', '文件保存成功',
                                    colorText: Colors.black);
                                // toastInfo(msg: '文件保存成功');
                              } else {
                                //phone save file
                                Directory tempDir =
                                    await getApplicationCacheDirectory();
                                String path = MidifileConvert.saveMidiFile(
                                    midiNotes, tempDir.path);
                                shareFile(path);
                              }
                            });
                          } else {
                            if (isWindowsOrMac) {
                              final file = DirectoryPicker()
                                ..title = 'Select a directory';
                              final result = file.getDirectory();
                              if (result != null) {
                                debugPrint('Select a directory=${result.path}');
                              }
                              MidifileConvert.saveMidiFile(
                                  midiNotes, result!.path);
                              Get.snackbar('提示', '文件保存成功',
                                  colorText: Colors.black);
                              // toastInfo(msg: '文件保存成功');
                            } else {
                              // phone save file
                              Directory tempDir =
                                  await getApplicationCacheDirectory();
                              String path = MidifileConvert.saveMidiFile(
                                  midiNotes, tempDir.path);
                              shareFile(path);
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          fixedSize: const Size.fromHeight(45),
                        ),
                        child: const Text(
                          'Export Midi File',
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    flex: 3,
                    child: TextButton(
                      onPressed: () {
                        showBleDeviceOverlay(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fixedSize: const Size.fromHeight(45),
                      ),
                      child: const Text('Scan BlueTooth Device',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ])),
                const SizedBox(
                  height: 20,
                ),
                const Center(child: Text('Version: 1.1.0')),
              ],
            ),
          )),
        );
      },
    ).then((value) {
      UniversalBle.stopScan();
      if (overlayEntry != null) {
        overlayEntry!.remove();
      }
    });
  }

  void showCreateModelSettingDialog(BuildContext context) {
    TextEditingController controller = TextEditingController(
        text: ''); // ${DateTime.now().microsecondsSinceEpoch}
    showDialog(
      barrierDismissible: isWindowsOrMac ? false : true,
      context: context,
      builder: (BuildContext context) {
        // 返回一个Dialog
        return Dialog(
          child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                    width: isWindowsOrMac ? 360.w : 510.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Settings',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            InkWell(
                              child: const Icon(Icons.close),
                              onTap: () {
                                // if (isWindowsOrMac) {
                                //   isVisibleWebview.value = !isVisibleWebview.value;
                                //   setState(() {});
                                // }
                                // Navigator.of(context).pop();
                                closeDialog();
                              },
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Obx(() => Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline:
                                  TextBaseline.alphabetic, // 指定基线对齐的基线
                              children: [
                                const Text('Time signature'),
                                SizedBox(
                                    width: 80, // 设置RadioListTile的宽度
                                    height: 30,
                                    child: RadioButton(
                                      description: "2/4",
                                      value: 0,
                                      groupValue: timeSignature.value,
                                      onChanged: (value) {
                                        timeSignature.value = value!;
                                      },
                                    )),
                                SizedBox(
                                    width: 80, // 设置RadioListTile的宽度
                                    height: 30,
                                    child: RadioButton(
                                      description: "3/4",
                                      value: 1,
                                      groupValue: timeSignature.value,
                                      onChanged: (value) {
                                        timeSignature.value = value!;
                                      },
                                    )),
                                SizedBox(
                                    width: 80, // 设置RadioListTile的宽度
                                    height: 30,
                                    child: RadioButton(
                                      description: "4/4",
                                      value: 2,
                                      groupValue: timeSignature.value,
                                      onChanged: (value) {
                                        timeSignature.value = value!;
                                      },
                                    )),
                                SizedBox(
                                    width: 80, // 设置RadioListTile的宽度
                                    height: 30,
                                    child: RadioButton(
                                      description: "3/8",
                                      value: 3,
                                      groupValue: timeSignature.value,
                                      onChanged: (value) {
                                        timeSignature.value = value!;
                                      },
                                    )),
                                SizedBox(
                                    width: 80, // 设置RadioListTile的宽度
                                    height: 30,
                                    child: RadioButton(
                                      description: "6/8",
                                      value: 4,
                                      groupValue: timeSignature.value,
                                      onChanged: (value) {
                                        timeSignature.value = value!;
                                      },
                                    )),
                                const Spacer(),
                              ],
                            )),
                        Obx(() => Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline:
                                  TextBaseline.alphabetic, // 指定基线对齐的基线
                              children: [
                                const Text('Default note length'),
                                SizedBox(
                                    width: 80,
                                    height: 30,
                                    child: RadioButton(
                                      description: "1/4",
                                      value: 0,
                                      groupValue: defaultNoteLenght.value,
                                      onChanged: (value) {
                                        defaultNoteLenght.value = value!;
                                      },
                                    )),
                                SizedBox(
                                    width: 80,
                                    height: 30,
                                    child: RadioButton(
                                      description: "1/8",
                                      value: 1,
                                      groupValue: defaultNoteLenght.value,
                                      onChanged: (value) {
                                        defaultNoteLenght.value = value!;
                                      },
                                    )),
                                SizedBox(
                                    width: 80,
                                    height: 30,
                                    child: RadioButton(
                                      description: "1/16",
                                      value: 2,
                                      groupValue: defaultNoteLenght.value,
                                      onChanged: (value) {
                                        defaultNoteLenght.value = value!;
                                      },
                                    )),
                              ],
                            )),
                        Obx(() => Row(children: [
                              Text(
                                  'Randomness: ${(randomness.value * 100).toInt()}%'),
                              const SizedBox(
                                width: 10,
                              ),
                              Slider(
                                value: randomness.value,
                                onChanged: (newValue) {
                                  randomness.value = newValue;
                                },
                              ),
                            ])),
                        const SizedBox(
                          height: 10,
                        ),
                        Obx(() => Row(children: [
                              Text('Seed: ${seed.value}'),
                              const SizedBox(
                                width: 20,
                              ),
                              SizedBox(
                                  height: 40,
                                  width: 200,
                                  child: TextField(
                                    controller: controller,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]')), // 只允许输入数字
                                    ],
                                    decoration: const InputDecoration(
                                        labelText: 'Please input seed value',
                                        hintText: 'Enter a number',
                                        border: OutlineInputBorder()),
                                    onChanged: (text) {
                                      // 当文本字段内容变化时调用
                                      seed.value = int.parse(text);
                                      debugPrint('Current text: ');
                                    },
                                  )),
                            ])),
                        Obx(() => Row(children: [
                              Text('Tempo: ${tempo.value.toInt()}'),
                              const SizedBox(
                                width: 10,
                              ),
                              Slider(
                                min: 40,
                                max: 208,
                                value: tempo.value,
                                onChanged: (newValue) {
                                  tempo.value = newValue;
                                },
                              ),
                            ])),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                            child: Row(children: [
                          const Text('Auto Chord'),
                          const SizedBox(
                            width: 5,
                          ),
                          Obx(() => Switch(
                                value: autoChord.value,
                                onChanged: (newValue) {
                                  autoChord.value = newValue;
                                },
                              )),
                          const SizedBox(
                            width: 20,
                          ),
                          const Text('Infinite Generation'),
                          const SizedBox(
                            width: 5,
                          ),
                          Obx(() => Switch(
                                value: infiniteGeneration.value,
                                onChanged: (newValue) {
                                  infiniteGeneration.value = newValue;
                                },
                              )),
                        ])),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                            child: Row(children: [
                          Expanded(
                              flex: 2,
                              child: TextButton(
                                onPressed: () {
                                  if (midiNotes.isEmpty) {
                                    // String oriabcString = finalabcStringPreset
                                    //     .replaceAll('setAbcString', 'ABCtoEvents');
                                    // // abcString = r'ABCtoEvents("L:1/4\nM:4/4\nK:D\n\"D\" A F F")';
                                    // debugPrint(
                                    //     'playPianoAnimation ABCtoEvents==$oriabcString');
                                    isNeedConvertMidiNotes = true;
                                    // controllerPiano.runJavaScript(oriabcString);

                                    playPianoAnimation(
                                        finalabcStringPreset, true);
                                    Future.delayed(const Duration(seconds: 2),
                                        () {
                                      debugPrint(
                                          'Delayed action after 3 seconds');
                                      isNeedConvertMidiNotes = false;
                                      final file = DirectoryPicker()
                                        ..title = 'Select a directory';
                                      final result = file.getDirectory();
                                      if (result != null) {
                                        debugPrint(
                                            'Select a directory=${result.path}');
                                      }
                                      MidifileConvert.saveMidiFile(
                                          midiNotes, result!.path);
                                      Get.snackbar('提示', '文件保存成功',
                                          colorText: Colors.black);
                                      // toastInfo(msg: '文件保存成功');
                                    });
                                  } else {
                                    final file = DirectoryPicker()
                                      ..title = 'Select a directory';
                                    final result = file.getDirectory();
                                    if (result != null) {
                                      debugPrint(
                                          'Select a directory=${result.path}');
                                    }
                                    MidifileConvert.saveMidiFile(
                                        midiNotes, result!.path);
                                    Get.snackbar('提示', '文件保存成功',
                                        colorText: Colors.black);
                                    // toastInfo(msg: '文件保存成功');
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  fixedSize: const Size.fromHeight(45),
                                ),
                                child: const Text(
                                  'Export Midi File',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                              flex: 3,
                              child: TextButton(
                                onPressed: () {
                                  showBleDeviceOverlay(context);
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  fixedSize: const Size.fromHeight(45),
                                ),
                                child: const Text('Scan BlueTooth Device',
                                    style: TextStyle(color: Colors.white)),
                              )),
                        ])),
                        const SizedBox(
                          height: 20,
                        ),
                        const Center(child: Text('Version: 1.1.0')),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ))),
          ),
        );
      },
    ).then((value) {
      UniversalBle.stopScan();
      if (overlayEntry != null) {
        overlayEntry!.remove();
      }
    });
  }

  showConnectDialog() {
    String title = 'Connect Midi Keyboard';
    String msg =
        'Please connect your midi keyboard first. Wireless connection is recommended.';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            TextButton(
              onPressed: () {
                // 处理取消按钮点击事件
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
            TextButton(
              onPressed: () {
                // 处理确定按钮点击事件
                Navigator.of(context).pop();
              },
              child: const Text("Bluetooth Connect"),
            ),
          ],
        );
      },
    );
  }

  void showPromptDialog(
      BuildContext context, String titleStr, List list, String type) {
    if (isWindowsOrMac) {
      isVisibleWebview.value = !isVisibleWebview.value;
      setState(() {});
    }
    // if (!isWindows) {
    //   FlutterPlatformAlert.showAlert(
    //     windowTitle: 'This is title',
    //     text: 'This is body',
    //     // positiveButtonTitle: "Positive",
    //     // negativeButtonTitle: "Negative",
    //     // neutralButtonTitle: "Neutral",
    //     options: PlatformAlertOptions(
    //       windows: WindowsAlertOptions(
    //         additionalWindowTitle: 'Window title',
    //         showAsLinks: true,
    //       ),
    //     ),
    //   );
    // } else {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Container(
        // width: 50,
        // height: 50,
        // color: Colors.red,
        child: OnPopupWindowWidget(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(titleStr),
              InkWell(
                child: const Icon(Icons.close),
                onTap: () {
                  // if (isWindowsOrMac) {
                  //   isVisibleWebview.value = !isVisibleWebview.value;
                  //   setState(() {});
                  // }
                  // Navigator.of(context).pop();
                  closeDialog();
                },
              )
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: isWindowsOrMac ? 200.h : 150.h,
                // width: 40,
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    // ListTile(title: Text(list[index]));
                    if (type == STORAGE_PROMPTS_SELECT) {
                      radioSelectedValue.value =
                          ConfigStore.to.getPromptsSelect();
                    } else if (type == STORAGE_SOUNDSEFFECT_SELECT) {
                      radioSelectedValue.value =
                          ConfigStore.to.getSoundsEffectSelect();
                      if (radioSelectedValue.value == -1) {
                        currentSoundEffect = list[0];
                      } else {
                        currentSoundEffect = list[radioSelectedValue.value];
                      }
                    }
                    return Obx(() {
                      return RadioListTile(
                        title: Text(list[index]),
                        value: index,
                        groupValue: radioSelectedValue.value,
                        onChanged: (value) {
                          radioSelectedValue.value = value!;
                          // isHideWebview.value = !isHideWebview.value;
                          // setState(() {});
                          if (type == STORAGE_PROMPTS_SELECT) {
                            ConfigStore.to.savePromptsSelect(value);
                            presentPrompt =
                                CommonUtils.escapeString(promptsAbc[value]);
                          } else if (type == STORAGE_SOUNDSEFFECT_SELECT) {
                            ConfigStore.to.saveSoundsEffectSelect(value);
                            midiProgramValue = soundEffectInt[list[index]]!;
                            ConfigStore.to
                                .saveMidiProgramSelect(midiProgramValue);
                            currentSoundEffect = list[radioSelectedValue.value];
                          } else if (type == STORAGE_KEYBOARD_SELECT) {
                            if (index == 0) {
                            } else if (index == 1) {
                              showConnectDialog();

                              toastInfo(msg: 'Midi device connected');
                            }
                          }

                          if (selectstate.value == 0) {
                            String abcstr = ABCHead.getABCWithInstrument(
                                presentPrompt, midiProgramValue);
                            abcstr = ABCHead.appendTempoParam(
                                abcstr, tempo.value.toInt());
                            controllerPiano.runJavaScript(
                                "setAbcString(\"$abcstr\", false)");
                            controllerKeyboard.runJavaScript('resetPlay()');
                            debugPrint(abcstr);
                            Future.delayed(const Duration(seconds: 1), () {
                              playOrPausePiano();
                            });
                          }
                        },
                      );
                    });
                  },
                ),
              ),
              if (selectstate.value == 0)
                const Divider(
                  height: 1,
                ),
              if (selectstate.value == 0)
                Obx(
                  () => ListTile(
                    leading: Checkbox(
                      value: isRemember.value,
                      onChanged: (bool? value) {
                        isRemember.value = value!;
                      },
                    ),
                    title: Transform.translate(
                      offset: const Offset(-20, 0), // 向左移动文本以减少间距
                      child: const Text('Remember Last Option'),
                    ),
                    onTap: () {},
                  ),
                ),
              if (type == STORAGE_PROMPTS_SELECT)
                Obx(
                  () => ListTile(
                    leading: Checkbox(
                      value: isAutoSwitch.value,
                      onChanged: (bool? value) {
                        isAutoSwitch.value = value!;
                      },
                    ),
                    title: Transform.translate(
                      offset: const Offset(-20, 0), // 向左移动文本以减少间距
                      child: const Text('Auto Switch Next Prompt'),
                    ),
                    onTap: () {},
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    // }
  }

  void closeDialog() {
    UniversalBle.stopScan();
    if (isWindowsOrMac) {
      setState(() {
        isVisibleWebview.value = true;
      });
    }
    Navigator.of(context).pop();
    if (overlayEntry != null) {
      overlayEntry!.remove();
    }
  }

  void showBleDeviceOverlay(BuildContext context) async {
    String? tips;
    AvailabilityState state = await UniversalBle
        .getBluetoothAvailabilityState(); // e.g. poweredOff or poweredOn,
    if (state == AvailabilityState.unknown) {
      tips = "系统蓝牙不可用";
    } else if (state == AvailabilityState.unsupported) {
      tips = "不支持蓝牙";
    } else if (state == AvailabilityState.unauthorized) {
      tips = "蓝牙没有授权，请先授权";
    } else if (state == AvailabilityState.poweredOff) {
      tips = "请先打开系统蓝牙";
    }
    if (tips != null) {
      if (isWindowsOrMac) {
        Get.snackbar('提示', tips, colorText: Colors.red);
      } else {
        toastInfo(msg: tips);
      }
      return;
    }

    debugPrint('showBleDeviceOverlay');
    startScan();
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0.0,
        right: 50.0,
        left: 50.0,
        child: Material(
          color: Colors.transparent,
          child: SizedBox(
              height: 100.h,
              width: 300.w,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.white,
                child: Obx(() => ListView.builder(
                      itemCount: bleList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(bleList[index].name!),
                          subtitle: Text(bleList[index].deviceId),
                          onTap: () {
                            UniversalBle.stopScan();
                            conectDevice(bleList[index]);
                            overlayEntry!.remove();
                          },
                        );
                      },
                    )),
              )),
        ),
      ),
    );

    // 插入Overlay
    Overlay.of(context).insert(overlayEntry!);

    // // 假设我们想在3秒后自动移除浮层
    // Future.delayed(const Duration(seconds: 3)).then((value) {
    //   overlayEntry.remove();
    // });
  }

  void startScan() async {
    // bool isGranted = await Permission.bluetooth.isGranted;
    // debugPrint('isGranted=$isGranted');
    if (!isWindowsOrMac) {
      PermissionStatus status = PermissionStatus.denied;
      if (Platform.isAndroid) {
        status = await Permission.location.request();
        debugPrint('11Permission==$status');
        if (status != PermissionStatus.granted) {
          toastInfo(msg: '需要开启定位权限');
          // Get.snackbar('提示', '需要开启定位权限', colorText: Colors.red);
          return;
        }

        status = await Permission.bluetoothScan.request();
        debugPrint('22Permission==$status');
        if (status != PermissionStatus.granted) {
          toastInfo(msg: '需要开启蓝牙扫描权限');
          // Get.snackbar('提示', '需要开启蓝牙扫描权限', colorText: Colors.red);
          return;
        }

        status = await Permission.bluetoothConnect.request();
        debugPrint('33Permission==$status');
        if (status != PermissionStatus.granted) {
          toastInfo(msg: '需要开启蓝牙连接权限');
          // Get.snackbar('提示', '需要开启蓝牙连接权限', colorText: Colors.red);
          return;
        }
      }
    }
    UniversalBle.onScanResult = (BleScanResult scanResult) {
      if (scanResult.name != null) {
        //&& scanResult.name!.startsWith('SMK25V2')
        if (!bleListName.contains(scanResult.name)) {
          // for (String service in scanResult.services) {
          // if (service.contains('midi')) {
          debugPrint('scanResult==${scanResult.name}');
          bleList.add(scanResult);
          bleListName.add(scanResult.name);
          // break;
          // }
          // }
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
      debugPrint('OnConnectionChanged $deviceId, $state');
      if (state == BleConnectionState.connected) {
        if (isWindowsOrMac) {
          Get.snackbar(device.name!, '连接成功', colorText: Colors.black);
        } else {
          toastInfo(msg: 'device connected');
        }
        // Discover services of a specific device
        List<BleService> bleServices =
            await UniversalBle.discoverServices(deviceId);
        for (BleService service in bleServices) {
          debugPrint('ble serviceid==${service.uuid}');
          debugPrint('ble BleCharacteristic==${service.characteristics}');
          for (BleCharacteristic characteristic in service.characteristics) {
            // Subscribe to a characteristic
            UniversalBle.setNotifiable(deviceId, service.uuid,
                characteristic.uuid, BleInputProperty.notification);
            // Get characteristic updates in `onValueChanged`
            UniversalBle.onValueChanged =
                (String deviceId, String characteristicId, Uint8List value) {
              Uint8List sublist = value.sublist(2);
              debugPrint(
                  'onValueChanged $deviceId, $characteristicId, $sublist');
              var result = convertABC.midiToABC(sublist, false);
              debugPrint('convertdata=$result');
              if ((result[0] as String).isNotEmpty) {
                String path = convertABC.getNoteMp3Path(result[1]);
                updatePianoNote(result[1]);
                AudioPlayerManage().playAudio(
                    'player/soundfont/acoustic_grand_piano-mp3/$path');
              }
            };
          }
        }
        Future.delayed(const Duration(seconds: 3)).then((value) {
          closeDialog();
        });
      } else if (state == BleConnectionState.disconnected) {
        if (isWindowsOrMac) {
          Get.snackbar(device.name!, '连接失败', colorText: Colors.red);
        } else {
          toastInfo(msg: 'device disconnected');
        }
      }
    };
  }

  Future<void> shareFile(String filepath) async {
    print('shareFile path=$filepath');
    ShareExtend.share(filepath, "file");

    // ShareExtend.share("share text", "text",
    //     sharePanelTitle: "share text title", subject: "share text subject");

    // Share.share('check out my website https://example.com');
    // return;
    // await FlutterShare.shareFile(
    //   title: '分享',
    //   text: 'midi文件分享',
    //   filePath: filepath,
    // );
  }
}
