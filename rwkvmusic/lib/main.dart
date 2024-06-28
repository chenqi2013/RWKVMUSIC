import 'dart:ffi' hide Size;
import 'dart:isolate';
import 'dart:ui';
import 'package:ffi/ffi.dart';
// import 'dart:html';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';

import 'package:rwkvmusic/services/storage.dart';
import 'package:rwkvmusic/store/config.dart';
import 'package:rwkvmusic/utils/abchead.dart';
// import 'package:rwkvmusic/test/testwebviewuniversal.dart';

import 'package:rwkvmusic/utils/midiconvert_abc.dart';
import 'package:rwkvmusic/utils/common_utils.dart';
import 'package:rwkvmusic/utils/note.dart';
import 'package:rwkvmusic/values/constantdata.dart';
import 'package:rwkvmusic/values/values.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:webview_win_floating/webview_plugin.dart';

import 'faster_rwkvd.dart';
import 'homepage.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:window_manager/window_manager.dart';
// import 'package:flutter_gen_runner/flutter_gen_runner.dart';
import 'package:event_bus/event_bus.dart';

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
  runApp(ScreenUtilInit(
    designSize: Platform.isWindows
        ? const Size(2880, 1600)
        : const Size(2436, 1125), //812, 375
    child: const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ),
  ));
}

bool isShowDialog = false;
RxBool isGenerating = false.obs;
EventBus eventBus = EventBus();
EventBus isolateEventBus = EventBus();
late ReceivePort mainReceivePort;
late SendPort isolateSendPort;
bool isFinishABCEvent = false;
late String finalabcStringPreset;
late String finalabcStringCreate;
// late bool isNeedRestart; //曲谱及键盘动画需要重新开始
late String presentPrompt;
var createPrompt = '';
String timeSingnatureStr = '4/4';
OverlayEntry? overlayEntry;
bool isShowOverlay = false;

RxList<BleScanResult> bleList = <BleScanResult>[].obs;
List bleListName = [];
String? connectDeviceId;

MidiToABCConverter convertABC = MidiToABCConverter();

late int midiProgramValue;

RxInt timeSignature = 2.obs;
RxInt defaultNoteLenght = 0.obs;
RxDouble randomness = 0.7.obs;
RxInt seed = 22416.obs;
bool isUseCurrentTime = true;
RxDouble tempo = 180.0.obs;
bool isChangeTempo = false;
RxBool autoChord = true.obs;
RxBool infiniteGeneration = false.obs;

List midiNotes = [];
// bool isNeedConvertMidiNotes = false;

List virtualNotes = []; //虚拟键盘按键音符
List<int> intNodes = []; //计算和弦需要使用
String prechord = '';

var selectstate = 0.obs;
late bool isWindowsOrMac;
late WebViewControllerPlus controllerPiano;
var isRememberPrompt = false.obs;
var isRememberEffect = false.obs;
var isAutoSwitch = false.obs;

ScrollController controller = ScrollController();
var tokens = ''.obs;
var currentClickNoteInfo = [];

// var noteLengthList = ['1/4', '1/8', '1/16'];
List<Note> notes = [];
Isolate? userIsolate;
var isCreateGenerate = false.obs;
var promptSelectedIndex = 0.obs;
var keyboardSelectedIndex = 0.obs;

int modelAddress = 0;
int abcTokenizerAddress = 0;
int samplerAddress = 0;
bool isClicking = false;

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
    // String frameworkpath = await CommonUtils.frameworkpath();
    // if (!(await File(frameworkpath).exists())) {
    //   dllPath = await CommonUtils.loadDllFromAssets('libfaster_rwkvddebug.zip');
    //   CommonUtils.unzipfile(dllPath);
    //   debugPrint('frameworkpath is not exists');
    // } else {
    //   debugPrint('frameworkpath is exists');
    // }
    // dllPath = frameworkpath;
    //ios 只要把.a放入工程目录并设置即可
    dllPath = '';
    binPath = await CommonUtils.loadDllFromAssets(
        'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.bin');
    configPath = await CommonUtils.loadDllFromAssets(
        'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.config');
    paramPath = await CommonUtils.loadDllFromAssets(
        'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.param');
  } else if (Platform.isAndroid) {
    dllPath = await CommonUtils.loadDllFromAssets('libfaster_rwkvd.so');
    binPath = await CommonUtils.loadDllFromAssets(
        'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.bin');
    configPath = await CommonUtils.loadDllFromAssets(
        'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.config');
    paramPath = await CommonUtils.loadDllFromAssets(
        'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.param');
  } else if (Platform.isWindows) {
    dllPath = await CommonUtils.getdllPath();
    binPath = await CommonUtils.getBinPath();
  }

  if (isUseCurrentTime) {
    DateTime now = DateTime.now();
    seed.value = now.millisecondsSinceEpoch;
    debugPrint('isUseCurrentTime');
  }

  mainReceivePort = ReceivePort();

  String prompt = '';
  if (selectstate.value == 0) {
    prompt = promptsAbc[promptSelectedIndex.value];
  } else {
    prompt = "L:1/4\nM:$timeSingnatureStr\nK:C\n|$createPrompt";
  }
  debugPrint('generate Prompt==$prompt');
  var fastmodel = [];
  if (modelAddress > 0) {
    fastmodel = [modelAddress, abcTokenizerAddress, samplerAddress];
  } else {
    debugPrint(
        'modelAddress==$modelAddress,abcTokenizerAddress==$abcTokenizerAddress');
  }

  userIsolate = await Isolate.spawn(getABCDataByLocalModel, [
    mainReceivePort.sendPort,
    selectstate.value == 0 ? prompt : prompt,
    midiProgramValue,
    seed.value,
    randomness.value,
    dllPath,
    binPath,
    fastmodel,
  ]);

  mainReceivePort.listen((data) {
    if (data is SendPort) {
      isolateSendPort = data;
    } else if (data is List) {
      debugPrint('Received lit data: $data');
      modelAddress = data[0];
      abcTokenizerAddress = data[1];
      samplerAddress = data[2];
    } else if (data is EventBus) {
      isolateEventBus = data;
    } else if (data == "finish") {
      mainReceivePort.close(); // 操作完成后，关闭 ReceivePort
      userIsolate!.kill(priority: Isolate.immediate);
      userIsolate = null;
      debugPrint('userIsolate!.kill()');
      isGenerating.value = false;
      eventBus.fire('finish');
      isClicking = false;
    } else if (data.toString().startsWith('tokens')) {
      isClicking = false;
      eventBus.fire(data);
    } else {
      if (selectstate.value == 0) {
        finalabcStringPreset = data;
      } else {
        finalabcStringCreate = data;
      }
      eventBus.fire(data);
    }
  });
}

void getABCDataByLocalModel(var array) async {
  SendPort sendPort = array[0];
  String currentPrompt = array[1];
  currentPrompt = currentPrompt.replaceAll('\\"', '"');
  // currentPrompt = 'L:1/8\nM:4/4\nK:G\n D GB |:"G"';
//   currentPrompt = r'''
// L:1/4
// M:4/4
// K:C
// ^G,^A,^C^D "A"''';
  debugPrint('currentPrompt==$currentPrompt');
  int midiprogramvalue = array[2];
  int seed = array[3];
  double randomness = array[4];
  debugPrint('randomness==$randomness');
  // randomness = 0;
  String dllPath = array[5];
  String binPath = array[6];
  var falstmodel = array[7];
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
    debugPrint('isolateReceivePort22==$event');
    isStopGenerating = true;
    sendPort.send('finish');
  });

  Pointer<Void> model;
  Pointer<Void> abcTokenizer;
  Pointer<Void> sampler;

  Pointer<Char> promptChar = prompt.toNativeUtf8().cast<Char>();
  faster_rwkvd fastrwkv = faster_rwkvd(
      Platform.isIOS ? DynamicLibrary.process() : DynamicLibrary.open(dllPath));
  Pointer<Char> strategy = 'ncnn fp32'.toNativeUtf8().cast<Char>();
  if (!falstmodel.isNotEmpty) {
    model = fastrwkv.rwkv_model_create(
        binPath.toNativeUtf8().cast<Char>(), strategy);
    abcTokenizer = fastrwkv.rwkv_ABCTokenizer_create();
    sampler = fastrwkv.rwkv_sampler_create();
    debugPrint('fastrwkv.rwkv_model_create');
  } else {
    model = Pointer<Void>.fromAddress(falstmodel[0]);
    abcTokenizer = Pointer<Void>.fromAddress(falstmodel[1]);
    sampler = Pointer<Void>.fromAddress(falstmodel[2]);
    debugPrint('not fastrwkv.rwkv_model_create');
  }
  sendPort.send(isolateReceivePort.sendPort);
  sendPort.send(eventBus);
  sendPort.send([model.address, abcTokenizer.address, sampler.address]);

  fastrwkv.rwkv_sampler_set_seed(sampler, seed);
  StringBuffer stringBuffer = StringBuffer();
  int preTimestamp = 0;
  late String abcString;
  // fastrwkv.rwkv_model_clear_states(model);
  // 默认的就按照temp=1.0 top_k=8, top_p=0.8?
  int token = fastrwkv.rwkv_abcmodel_run_prompt(model, abcTokenizer, sampler,
      promptChar, prompt.length, 1.0, 8, randomness);
  isGenerating.value = true;
  int duration = 0;
  for (int i = 0; i < 1024; i++) {
    if (isStopGenerating) {
      debugPrint('stop getABCDataByLocalModel');
      break;
    } else {
      // debugPrint('isGenerating $i');
    }
    DateTime now = DateTime.now();
    int millisecondsSinceEpoch1 = now.millisecondsSinceEpoch;
    // print(millisecondsSinceEpoch1);
    int result = fastrwkv.rwkv_abcmodel_run_with_tokenizer_and_sampler(
        model, abcTokenizer, sampler, token, 1.0, 8, randomness);
    if (eosId == result) {
      debugPrint('getABCDataByLocalModel break22');
      break;
    }
    now = DateTime.now();
    int millisecondsSinceEpoch2 = now.millisecondsSinceEpoch;
    duration = duration + millisecondsSinceEpoch2 - millisecondsSinceEpoch1;
    var counts = 1000 * i;
    double tokens = counts / duration;
    // debugPrint('tokens==$tokens');
    sendPort.send('tokens==$tokens');
    // if (token == result && result == 124) {
    //   //双||abc展示出错
    //   continue;
    // }
    token = result;
    String resultstr = String.fromCharCode(result);
    // debugPrint('resultstr==$resultstr,token==$result');
    // result :10=换行;47=/;41=);40=(;94=^;34=";32=空格
    if (result == 10) {
      //|| result == 0
      // || result == 34
      //|| result == 32
      // ||
      //   // result == 40 ||
      //   // result == 94 ||
      //   // result == 47 ||
      //   // result == 41
      debugPrint('continue responseData=$resultstr,resultint=$result');
      continue;
    }

    // debugPrint('responseData=$resultstr,resultint=$result');
    String textstr = resultstr.replaceAll('\n', '').replaceAll('\r', '');
    stringBuffer.write(resultstr);
    textstr = CommonUtils.escapeString(stringBuffer.toString());
    int subindex = currentPrompt.indexOf('L:');
    String subpresentPrompt = currentPrompt.substring(subindex);
    textstr = '$subpresentPrompt $textstr';
    // debugPrint('subpresentPrompt=$subpresentPrompt');
    abcString =
        "setAbcString(\"${ABCHead.getABCWithInstrument(textstr, midiprogramvalue)}\",false)";
    abcString = ABCHead.appendTempoParam(abcString, tempo.value.toInt());
    // debugPrint('abcString==$abcString');
    // 方案一
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    int gap = currentTimestamp - preTimestamp;
    if (gap > 400) {
      preTimestamp = currentTimestamp;
      sendPort.send(abcString);
    }
  }
  isGenerating.value = false;

  sendPort.send(abcString.toString());
  sendPort.send('finish');
  debugPrint('getABCDataByLocalModel all data=${stringBuffer.toString()}');
}
