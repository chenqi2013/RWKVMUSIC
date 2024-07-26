import 'dart:ffi' hide Size;
import 'dart:isolate';
import 'package:ffi/ffi.dart';
// import 'dart:html';
import 'dart:io';
import 'package:flutter/services.dart';
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

/// 在 create 模式xAI最新的
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

int midiProgramValue = 0;

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

/// prompt mode or create mode
var selectstate = 0.obs;
late bool isWindowsOrMac;

/// 五线谱 webview 控制器
late WebViewControllerPlus controllerPiano;
var isRememberPrompt = false.obs;
var isRememberEffect = false.obs;
var isAutoSwitch = false.obs;

ScrollController controller = ScrollController();
var tokens = ''.obs;

// TODO: @wangce 何时置空
SelectedNote? selectedNote;

class SelectedNote {
  String name = "";
  int index = -1;
  num duration = 0.0;

  String get notation {
    if (duration == 1) {
      return "${name}4";
    }
    if (duration == 0.5) {
      return "${name}2";
    }
    if (duration == 0.25) {
      return name;
    }
    if (duration == 0.125) {
      return "$name/2";
    }
    if (duration == 0.0625) {
      return "$name/4";
    }
    if (duration == 0.03125) {
      return "$name/8";
    }

    return name;
  }

  int get noteLengthIndex {
    if (duration == 1) {
      return 0;
    }
    if (duration == 0.5) {
      return 1;
    }
    if (duration == 0.25) {
      return 2;
    }
    if (duration == 0.125) {
      return 3;
    }
    if (duration == 0.0625) {
      return 4;
    }
    if (duration == 0.03125) {
      return 5;
    }

    return 2;
  }
}

List<Note> notes = [];
Isolate? userIsolate;
var isCreateGenerate = false.obs;
var promptSelectedIndex = 0.obs;
var keyboardSelectedIndex = 0.obs;

int modelAddress = 0;
int abcTokenizerAddress = 0;
int samplerAddress = 0;
bool isClicking = false;
ModelType currentModelType = ModelType.ncnn;
bool isOnlyLoadFastModel = true; //提前模型初始化，加快生成速度

void fetchABCDataByIsolate() async {
  String? dllPath;
  String? binPath;
  String? configPath;
  String? paramPath;
  if (Platform.isMacOS) {
    dllPath = await CommonUtils.copyFileFromAssets('libfaster_rwkvd.dylib');
    binPath = await CommonUtils.copyFileFromAssets(
        'RWKV-5-ABC-82M-v1-20230901-ctx1024-ncnn.bin');
    configPath = await CommonUtils.copyFileFromAssets(
        'RWKV-5-ABC-82M-v1-20230901-ctx1024-ncnn.config');
    paramPath = await CommonUtils.copyFileFromAssets(
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
    binPath = await CommonUtils.copyFileFromAssets(
        'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.bin');
    configPath = await CommonUtils.copyFileFromAssets(
        'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.config');
    paramPath = await CommonUtils.copyFileFromAssets(
        'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.param');
  } else if (Platform.isAndroid) {
    String cachePath = await CommonUtils.getCachePath();
    String soPath = '$cachePath/libfaster_rwkvd.so';
    bool isFileExists = File(soPath).existsSync();
    if (isFileExists) {
      debugPrint('file exits');
      dllPath = soPath;
    } else {
      dllPath = await CommonUtils.copyFileFromAssets('libfaster_rwkvd.so');
    }
    if (currentModelType == ModelType.ncnn) {
      binPath = await CommonUtils.copyFileFromAssets(
          'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.bin');
      configPath = await CommonUtils.copyFileFromAssets(
          'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.config');
      paramPath = await CommonUtils.copyFileFromAssets(
          'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.param');
    } else if (currentModelType == ModelType.qnn) {
      if (!isFileExists) {
        String sopath = await CommonUtils.copyFileFromAssets(
            'libRWKV-6-ABC-85M-v1-20240217-ctx1024-QNN.so');
        binPath = "$sopath:$cachePath";
        debugPrint('binPath==$binPath');
        for (String soName in qnnSoList) {
          //拷贝qnn so文件
          await CommonUtils.copyFileFromAssets(soName);
        }
      } else {
        String qnnsoPath =
            '$cachePath/libRWKV-6-ABC-85M-v1-20240217-ctx1024-QNN.so';
        binPath = "$qnnsoPath:$cachePath";
        debugPrint('file exits binpath==$binPath');
      }
      configPath = await CommonUtils.copyFileFromAssets(
          'libRWKV-6-ABC-85M-v1-20240217-ctx1024-QNN.config');
      paramPath = await CommonUtils.copyFileFromAssets(
          'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.param');
    } else if (currentModelType == ModelType.mtk) {
      binPath = await CommonUtils.copyFileFromAssets(
          'RWKV-6-ABC-85M-v1-20240217-ctx1024-MTK-MT6989.dla');
      configPath = await CommonUtils.copyFileFromAssets(
          'RWKV-6-ABC-85M-v1-20240217-ctx1024-MTK-MT6989.config');
      paramPath = await CommonUtils.copyFileFromAssets(
          'RWKV-6-ABC-85M-v1-20240217-ctx1024-MTK-MT6989.emb');
    }
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
  if (modelAddress != 0) {
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
    isOnlyLoadFastModel,
    tempo.value
  ]);

  mainReceivePort.listen((data) {
    if (data is SendPort) {
      isolateSendPort = data;
    } else if (data is List) {
      debugPrint('Received lit data: $data');
      modelAddress = data[0];
      abcTokenizerAddress = data[1];
      samplerAddress = data[2];
      if (isOnlyLoadFastModel) {
        isOnlyLoadFastModel = false;
        mainReceivePort.close(); // 操作完成后，关闭 ReceivePort
        userIsolate!.kill(priority: Isolate.immediate);
        userIsolate = null;
        debugPrint('userIsolate!.kill()');
      }
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
  // currentPrompt = currentPrompt.replaceAll('\\"', '"');
  // currentPrompt = 'L:1/8\nM:4/4\nK:G\n D GB |:"G"';
//   currentPrompt = r'''
// L:1/4
// M:4/4
// K:C
// ^G,^A,^C^D "A"''';
// |"F" cBFD''';
//   currentPrompt = r'''
// L:1/4
// M:4/4
// Q:90
// z z z "D" A/ B/ |"Bm" d3/2 e/ ^f/ ^c/ B/4 ^c/4 B/4 A/4 |"G" B3 d/ e/ |"D" ^f3/2 a/ b/ d/ e/4 ^f/4 g/ |"D" ^f3 ^f/ a/ |"Bm" b3/2 a/ b |''';
  debugPrint('currentPrompt==$currentPrompt');
  int midiprogramvalue = array[2];
  int seed = array[3];
  double randomness = array[4];
  debugPrint('randomness==$randomness');
  // randomness = 0;
  String dllPath = array[5];
  String binPath = array[6];
  var falstmodel = array[7];
  var isOnlyLoadFastModeltmep = array[8];
  double tempo = array[9];
  int eosId = 3;
  String prompt = currentPrompt;
  debugPrint('promptprompt==$prompt');
  debugPrint('dllPath==$dllPath,binPath==$binPath');
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
  // Pointer<Char> strategy = 'webgpu auto'
  //     .toNativeUtf8()
  //     .cast<Char>(); //ncnn fp32    webgpu auto  (通用pc上和ios上可以webgpu auto)
  if (currentModelType == ModelType.qnn) {
    strategy = 'qnn auto'.toNativeUtf8().cast<Char>();
  } else if (currentModelType == ModelType.mtk) {
    strategy = 'mtk auto'.toNativeUtf8().cast<Char>();
  }
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
  debugPrint(
      'model address=${model.address},abcTokenizer address==${abcTokenizer.address},sampler address==${sampler.address}');
  sendPort.send(isolateReceivePort.sendPort);
  sendPort.send(eventBus);
  sendPort.send([model.address, abcTokenizer.address, sampler.address]);
  if (isOnlyLoadFastModeltmep) {
    return;
  }
  fastrwkv.rwkv_sampler_set_seed(sampler, seed);
  StringBuffer stringBuffer = StringBuffer();
  int preTimestamp = 0;
  late String abcString;
  fastrwkv.rwkv_model_clear_states(model);
  // 默认的就按照temp=1.0 top_k=8, top_p=0.8?
  int token = fastrwkv.rwkv_abcmodel_run_prompt(model, abcTokenizer, sampler,
      promptChar, prompt.length, 1.0, 8, randomness);
  String firstResultstr = String.fromCharCode(token);
  stringBuffer.write(firstResultstr);
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
    abcString = ABCHead.appendTempoParam(abcString, tempo.toInt());
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
