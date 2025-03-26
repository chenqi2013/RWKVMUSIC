// ignore: unused_import
import 'dart:developer';
import 'dart:ffi' hide Size;
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Response;
import 'package:rwkvmusic/langs/translation_service.dart';

import 'package:rwkvmusic/services/storage.dart';
import 'package:rwkvmusic/state.dart';
import 'package:rwkvmusic/store/config.dart';
import 'package:rwkvmusic/test_linuxwindows.dart';
import 'package:rwkvmusic/utils/abchead.dart';

import 'package:rwkvmusic/utils/midiconvert_abc.dart';
import 'package:rwkvmusic/utils/common_utils.dart';
import 'package:rwkvmusic/utils/note.dart';
import 'package:rwkvmusic/values/constantdata.dart';
import 'package:rwkvmusic/values/values.dart';
import 'package:sentry/sentry.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:universal_ble/universal_ble.dart';
import 'package:webview_win_floating/webview_plugin.dart';

import 'faster_rwkvd.dart';
import 'homepage.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:window_manager/window_manager.dart';
import 'package:event_bus/event_bus.dart';

import 'utils/automeasure_randomizeabc.dart';
import 'utils/key_convert.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await startWebServer1();
  await startWebServer2();
  await startWebServer3();

  if (Platform.isWindows || Platform.isMacOS) {
    WindowsWebViewPlatform.registerWith();
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
  GlobalState.init();

  // TODO: @WangCe Enable it for release mode
  if (kDebugMode) {
    _initApp();
    return;
  }
  await Sentry.init(
    (options) {
      options.dsn =
          'https://e7b4e1cfa474037accf726c5893d86f8@o4507886670708736.ingest.us.sentry.io/4507886687944704';
      options.tracesSampleRate = 1.0;
    },
    appRunner: _initApp,
  );
}

void _initApp() {
  runApp(ScreenUtilInit(
    designSize: Platform.isWindows
        ? const Size(2880, 1600)
        : const Size(2436, 1125), //812, 375
    child: GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      builder: EasyLoading.init(),
      locale: Locale('en', 'US'), // 默认语言
      fallbackLocale: Locale('en', 'US'), // 回退语言
      translations: TranslationService(), // 注册翻译类
    ),
  ));
}

Future<(Request req, Response res)> _resparse(Request req, Response res) async {
  if (!res.statusCode.toString().startsWith("2")) {
    if (kDebugMode) print("😡 ${req.method}");
    if (kDebugMode) print("😡 ${req.url}");
    if (kDebugMode) print("😡 ${req.requestedUri}");
    if (kDebugMode) print("😡 ${req.handlerPath}");
  }
  return (req, res);
}

Future<void> startWebServer1() async {
  final rootDir = Directory('assets/doctor');
  final handler = createStaticHandler(
    rootDir.path,
    defaultDocument: 'doctor.html',
    serveFilesOutsidePath: false,
  );

  HttpServer server = await shelf_io.serve((req) async {
    final res = await handler(req);
    final r = await _resparse(req, res);
    return r.$2;
  }, 'localhost', 28081);
  debugPrint('server==$server');
  print('✅ Web server started at http://localhost:28081');
}

Future<void> startWebServer2() async {
  final rootDir = Directory('assets/piano');
  final handler = createStaticHandler(
    rootDir.path,
    defaultDocument: 'keyboard.html',
    serveFilesOutsidePath: false,
  );

  HttpServer server = await shelf_io.serve((req) async {
    final res = await handler(req);
    final r = await _resparse(req, res);
    return r.$2;
  }, 'localhost', 8123);
  debugPrint('server==$server');
  print('✅ Web server started at http://localhost:8123');
}

Future<void> startWebServer3() async {
  final rootDir = Directory('assets/player');
  final handler = createStaticHandler(
    rootDir.path,
    defaultDocument: 'player.html',
    serveFilesOutsidePath: false,
  );

  HttpServer server = await shelf_io.serve((req) async {
    Response res = await handler(req);
    final statusCodeString = res.statusCode.toString();
    final isError =
        statusCodeString.startsWith("4") || statusCodeString.startsWith("5");
    if (isError && Platform.isLinux) {
      if (req.requestedUri.path.contains("assets/player")) {
        // I found that the router on linux is wrong
        req = Request(
          req.method,
          Uri.parse(
              req.requestedUri.toString().replaceAll("assets/player/", "")),
          protocolVersion: req.protocolVersion,
          headers: req.headers,
          handlerPath: req.handlerPath,
          url: Uri.parse(req.url.toString().replaceAll("assets/player/", "")),
          body: null,
          encoding: req.encoding,
          context: req.context,
        );
        res = await handler(req);
      }
    }
    return res;
  }, 'localhost', 8083);
  debugPrint('server==$server');
  print('✅ Web server started at http://localhost:8083');
}

// http://localhost:8083/soundfont/acoustic_grand_piano-mp3/Gb4.mp3
// http://localhost:8083/assets/player/soundfont/acoustic_grand_piano-mp3/Gb4.mp3

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
RxDouble randomness = 0.7.obs;
RxInt seed = 22416.obs;
bool isUseCurrentTime = true;
RxDouble tempo = 180.0.obs;
bool isChangeTempo = false;
RxBool autoChord = true.obs;
RxBool infiniteGeneration = false.obs;
RxBool showPrompt = false.obs;
List midiNotes = [];
// bool isNeedConvertMidiNotes = false;

/// 虚拟键盘按键音符
///
/// (3 被包含在其中
///
/// z 被包含在其中
List<String> virtualNotes = [];

/// 计算和弦需要使用
// List<int> intNodes = [];
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

String? splitMeasure;
List chords = [];

List<Note> notes = [];
Isolate? userIsolate;
var isCreateGenerate = false.obs;
var promptSelectedIndex = 0.obs;
var keyboardSelectedIndex = 0.obs;

int modelAddress = 0;
int abcTokenizerAddress = 0;
int samplerAddress = 0;
bool isClicking = false;
// ModelType currentModelType = ModelType.ncnn;
ModelType currentModelType = ModelType.rwkvcpp;

/// 打包时候需要修改这个开关
bool isExe = false; //msix或者exe格式安装包
bool isOnlyLoadFastModel = false; //提前模型初始化，加快生成速度
String currentGeneratePrompt = '';
RxString currentGeneratePromptTmp = ''.obs;
var isVisibleWebview = true.obs;
RxString dllPath = ''.obs;
RxString binPath = ''.obs;

void fetchABCDataByIsolate() async {
  String? configPath;
  String? paramPath;
  if (Platform.isMacOS) {
    dllPath.value =
        await CommonUtils.copyFileFromAssets('libfaster_rwkvd.dylib');
    binPath.value = await CommonUtils.copyFileFromAssets(
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
    dllPath.value = '';
    // binPath.value = await CommonUtils.copyFileFromAssets(
    //     'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.bin');
    binPath.value = await CommonUtils.copyFileFromAssets(
        'RWKV-7-ABC-2024-11-22-webrwkv.st');
    configPath = await CommonUtils.copyFileFromAssets(
        'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.config');
    paramPath = await CommonUtils.copyFileFromAssets(
        'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.param');
  } else if (Platform.isAndroid || Platform.isLinux) {
    String cachePath = await CommonUtils.getCachePath();
    String soPath = '$cachePath/libfaster_rwkvd.so';
    bool isFileExists = File(soPath).existsSync();
    if (isFileExists) {
      debugPrint('file exits');
      dllPath.value = soPath;
    } else {
      dllPath.value =
          await CommonUtils.copyFileFromAssets('libfaster_rwkvd.so');
    }
    // debugger();
    if (currentModelType == ModelType.ncnn) {
      // 没做v7 ncnn，用rwkv.cpp代替
      // binPath.value = await CommonUtils.copyFileFromAssets(
      //     'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.bin');
      // configPath = await CommonUtils.copyFileFromAssets(
      //     'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.config');
      // paramPath = await CommonUtils.copyFileFromAssets(
      //     'RWKV-6-ABC-85M-v1-20240217-ctx1024-ncnn.param');
    } else if (currentModelType == ModelType.rwkvcpp) {
      binPath.value = await CommonUtils.copyFileFromAssets(
          'RWKV-6-ABC-85M-v1-20240217-ctx1024-rwkvcpp.bin');
      configPath = await CommonUtils.copyFileFromAssets(
          'RWKV-6-ABC-85M-v1-20240217-ctx1024-rwkvcpp.config');
    } else if (currentModelType == ModelType.qnn) {
      if (!isFileExists) {
        String sopath = await CommonUtils.copyFileFromAssets(
            'libRWKV-7-ABC-2024-11-22-QNN.so');
        binPath.value = "$sopath:$cachePath";
        // debugPrint('binPath==$binPath');
        for (String soName in qnnSoList) {
          //拷贝qnn so文件
          await CommonUtils.copyFileFromAssets(soName);
        }
      } else {
        if (File('$cachePath/model_cache.bin').existsSync()) {
          // QNN加载成功过一次.so模型后，会生成model_cache.bin文件
          // 之后加载模型时，加载model_cache.bin加载时间会短很多
          String qnnsoPath = '$cachePath/model_cache.bin';
          binPath.value = "$qnnsoPath:$cachePath";
        } else {
          String qnnsoPath = '$cachePath/libRWKV-7-ABC-2024-11-22-QNN.so';
          binPath.value = "$qnnsoPath:$cachePath";
        }
        // debugPrint('file exits binpath==$binPath');
      }
      configPath = await CommonUtils.copyFileFromAssets(
          'libRWKV-7-ABC-2024-11-22-QNN.config');
    } else if (currentModelType == ModelType.mtk) {
      binPath.value = await CommonUtils.copyFileFromAssets(
          'RWKV-7-ABC-2024-11-22-15-50-00-MTK-MT6989.dla');
      configPath = await CommonUtils.copyFileFromAssets(
          'RWKV-7-ABC-2024-11-22-15-50-00-MTK-MT6989.config');
      paramPath = await CommonUtils.copyFileFromAssets(
          'RWKV-7-ABC-2024-11-22-15-50-00-MTK-MT6989.emb');
    }
  } else if (Platform.isWindows) {
    dllPath.value = await CommonUtils.getdllPath();
    binPath.value = await CommonUtils.getBinPath();
  }

  if (isUseCurrentTime) {
    DateTime now = DateTime.now();
    seed.value = now.millisecondsSinceEpoch;
    debugPrint('isUseCurrentTime');
  }

  mainReceivePort = ReceivePort();

  if (selectstate.value == 0) {
    currentGeneratePrompt = promptsAbc[promptSelectedIndex.value];
  } else {
    // prompt = "L:1/4\nM:$timeSingnatureStr\nK:C\n|$createPrompt";

    //--------ai compose 转换prompt
    String convertAbcNotationstr =
        convertAbcNotation(splitMeasure!, chords[1].toString());
    if (kDebugMode) print('convertAbcNotationstr---$convertAbcNotationstr');

    String splitmeasureabcEndstr = splitMeasureAbc_end(convertAbcNotationstr);
    if (kDebugMode) print('splitMeasureAbc_endstr---$splitmeasureabcEndstr');

    String combineabcChordstr =
        ABCHead.combineAbc_Chord(chords[0], splitmeasureabcEndstr);
    if (kDebugMode) print('combineAbc_Chord---$combineabcChordstr');
    currentGeneratePrompt = combineabcChordstr.replaceAll('\\"', '"');

    // prompt = 'L:1/4\nM:4/4\nK:C\n| "C" E G B c | "G" ^A ^G =G E';
    // prompt = "L:1/4\nM:4/4\n|\"C\" C3/4 G B c | \"F\" F ^G d c";

    //--------ai compose 转换prompt
  }
  debugPrint('generate prompt before==$currentGeneratePrompt');
  var fastmodel = [];
  if (modelAddress != 0) {
    fastmodel = [modelAddress, abcTokenizerAddress, samplerAddress];
  } else {
    debugPrint(
        'modelAddress==$modelAddress,abcTokenizerAddress==$abcTokenizerAddress');
  }
  currentGeneratePromptTmp.value = currentGeneratePrompt +
      '\nseed:${seed.value}' +
      '\nrandomness:${randomness.value}';
  userIsolate = await Isolate.spawn(getABCDataByLocalModel, [
    mainReceivePort.sendPort,
    selectstate.value == 0 ? currentGeneratePrompt : currentGeneratePrompt,
    midiProgramValue,
    seed.value,
    randomness.value,
    dllPath.value,
    binPath.value,
    fastmodel,
    isOnlyLoadFastModel,
    tempo.value,
    currentModelType,
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
        EasyLoading.dismiss();
        eventBus.fire('EasyLoading dismiss');
      }
    } else if (data is EventBus) {
      isolateEventBus = data;
    } else if (data == kFinish) {
      mainReceivePort.close(); // 操作完成后，关闭 ReceivePort
      userIsolate!.kill(priority: Isolate.immediate);
      userIsolate = null;
      debugPrint('userIsolate!.kill()');
      isGenerating.value = false;
      eventBus.fire(kFinish);
      isClicking = false;
    } else if (data == kLoadModelFail) {
      //加载模型失败,使用ncnn/rwkv.cpp模型
      mainReceivePort.close(); // 操作完成后，关闭 ReceivePort
      userIsolate!.kill(priority: Isolate.immediate);
      userIsolate = null;
      debugPrint('$kLoadModelFail,userIsolate!.kill()');
      ConfigStore.to.saveDeviceOnlyCPU();
      // currentModelType = ModelType.ncnn;
      currentModelType = ModelType.rwkvcpp;
      appVersion = 'rwkv.cpp' + appVersionNumber;
      fetchABCDataByIsolate();
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
  ModelType currentModelType = array[10];
  int eosId = 3;
  String prompt = currentPrompt;
  debugPrint('promptprompt==$currentPrompt');
  debugPrint('dllPath==$dllPath,binPath==$binPath');
  var isolateReceivePort = ReceivePort();
  var isStopGenerating = false;
  bool isIOS = Platform.isIOS;
  // isolateReceivePort.listen((data) {
  //   debugPrint('isolateReceivePort==$data');
  //   isStopGenerating = true;
  // });

  // EventBus eventBus = EventBus();

  eventBus.on().listen((event) {
    debugPrint('isolateReceivePort22==$event');
    isStopGenerating = true;
    sendPort.send(kFinish);
    isVisibleWebview.value = true;
  });

  Pointer<Void> model;
  Pointer<Void> abcTokenizer;
  Pointer<Void> sampler;
  debugPrint('generate prompt after==$prompt');
  Pointer<Char> promptChar = prompt.toNativeUtf8().cast<Char>();
  faster_rwkvd fastrwkv = faster_rwkvd(
      Platform.isIOS ? DynamicLibrary.process() : DynamicLibrary.open(dllPath));
  Pointer<Char> strategy = 'webgpu auto'
      .toNativeUtf8()
      .cast<Char>(); // webgpu auto  (通用pc上和ios上可以webgpu auto)
  // Pointer<Char> strategy = 'rwkv.cpp auto'.toNativeUtf8().cast<Char>();
  if (Platform.isAndroid || Platform.isLinux) {
    // strategy = 'ncnn fp32'.toNativeUtf8().cast<Char>();
    strategy = 'rwkv.cpp fp32'.toNativeUtf8().cast<Char>();
  }
  if (currentModelType == ModelType.qnn) {
    strategy = 'qnn auto'.toNativeUtf8().cast<Char>();
  } else if (currentModelType == ModelType.mtk) {
    strategy = 'mtk auto'.toNativeUtf8().cast<Char>();
  }
  debugPrint('currentModelType==$currentModelType');
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
  if (model.address == 0 || abcTokenizer.address == 0 || sampler.address == 0) {
    sendPort.send(kLoadModelFail);
    return;
  }
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
  sendPort.send(kFinish);
  debugPrint('getABCDataByLocalModel all data=${stringBuffer.toString()}');
}
