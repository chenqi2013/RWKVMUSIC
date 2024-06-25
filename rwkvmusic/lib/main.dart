import 'dart:async';
import 'dart:convert';
import 'dart:ffi' hide Size;
import 'dart:isolate';
import 'dart:ui';
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
import 'package:flutter_advanced_segment/flutter_advanced_segment.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:flutter_platform_alert/flutter_platform_alert.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:flutter_share/flutter_share.dart';
import 'package:get/get.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rwkvmusic/gen/assets.gen.dart';
import 'package:rwkvmusic/mainwidget/ProgressbarTime.dart';
import 'package:rwkvmusic/mainwidget/checkbox_item.dart';
import 'package:rwkvmusic/mainwidget/container_line.dart';
import 'package:rwkvmusic/mainwidget/container_textfield.dart';
import 'package:rwkvmusic/mainwidget/customsegmentcontroller.dart';
import 'package:rwkvmusic/mainwidget/Custom_Segment_Controller.dart';
import 'package:rwkvmusic/mainwidget/drop_button_down.dart';
import 'package:rwkvmusic/mainwidget/radio_list_item.dart';
import 'package:rwkvmusic/mainwidget/switch_item.dart';
import 'package:rwkvmusic/mainwidget/text_btn.dart';
import 'package:rwkvmusic/mainwidget/text_item.dart';
import 'package:rwkvmusic/mainwidget/text_title.dart';
import 'package:rwkvmusic/services/storage.dart';
import 'package:rwkvmusic/store/config.dart';
import 'package:rwkvmusic/style/color.dart';
import 'package:rwkvmusic/style/style.dart';
import 'package:rwkvmusic/test/bletest.dart';
import 'package:rwkvmusic/test/midi_devicelist_page.dart';
import 'package:rwkvmusic/utils/abchead.dart';
// import 'package:rwkvmusic/test/testwebviewuniversal.dart';
import 'package:rwkvmusic/utils/audioplayer.dart';
import 'package:rwkvmusic/utils/chord_util.dart';
import 'package:rwkvmusic/utils/justaudioplayer.dart';
import 'package:rwkvmusic/utils/midiconvertabc.dart';
import 'package:rwkvmusic/utils/mididevicemanage.dart';
import 'package:rwkvmusic/utils/commonutils.dart';
import 'package:rwkvmusic/utils/midifileconvert.dart';
import 'package:rwkvmusic/utils/note.dart';
import 'package:rwkvmusic/utils/notecaculate.dart';
import 'package:rwkvmusic/utils/notes_database.dart';
import 'package:rwkvmusic/values/colors.dart';
import 'package:rwkvmusic/values/constantdata.dart';
import 'package:rwkvmusic/values/storage.dart';
import 'package:rwkvmusic/values/values.dart';
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
// import 'package:snapping_sheet/snapping_sheet.dart';

// import 'package:share_plus/share_plus.dart';
// final controller = AdvancedSegmentController('all');

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
      home: MyApp(),
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

ScrollController _controller = ScrollController();
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

Isolate? childSendPort;
void testisolate22() async {
  ReceivePort mainReceivePort = ReceivePort();
  childSendPort =
      await Isolate.spawn(isolateFunction, mainReceivePort.sendPort);
  mainReceivePort.listen((message) {
    if (message == 'pause') {
      print('Received pause signal. Pausing child isolate.');
      // childSendPort.send('pause');
    } else if (message is SendPort) {
      print('Received child isolate. SendPort');
      SendPort sendport = message;
      sendport.send('pause Child isolate');
    }
  });
  // 等待一段时间，然后发送暂停信号给子Isolate
  await Future.delayed(const Duration(seconds: 5));
  mainReceivePort.sendPort.send('pause');
}

void isolateFunction(SendPort mainSendPort) {
  ReceivePort childReceivePort = ReceivePort();
  mainSendPort.send(childReceivePort.sendPort);

  bool paused = false;

  childReceivePort.listen((message) {
    if (message == 'pause Child isolate') {
      paused = !paused;
      if (paused) {
        print('Child isolate paused.');
      } else {
        print('Child isolate resumed.');
      }
    }
  });

  // 执行一个百万次的for循环
  for (int i = 0; i < 10000; i++) {
    if (paused) {
      print('stop Executing task $i');
      break;
      // await Future.delayed(const Duration(milliseconds: 100)); // 等待100毫秒后再继续执行
    } else {
      // 执行任务
      print('Executing task $i');
    }
  }
  print('end Executing task');
}

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
  // if (seed.value == 22416) {
  //   isUseCurrentTime = true;
  // } else {
  //   isUseCurrentTime = false;
  // }
  if (isUseCurrentTime) {
    DateTime now = DateTime.now();
    seed.value = now.millisecondsSinceEpoch;
    debugPrint('isUseCurrentTime');
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

  // 创建一个新的 Isolate
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
  // 监听来自子线线程的数据
  mainReceivePort.listen((data) {
    // debugPrint('Received data: $data');
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
    } else if (data.toString().startsWith('tokens')) {
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
  // }
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
  // 默认的就按照pengbo的demo里面的temp=1.0 top_k=8, top_p=0.8?
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
    // sb.write(resultstr);
    // debugPrint('getABCDataByLocalModel=$resultstr');
    // if (result == 10) {
    //   continue;
    // }
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
      // debugPrint('abcString==$abcString');
      sendPort.send(abcString);
      // }
    }
  }
  isGenerating.value = false;
  // if (isIOS) {
  //   controllerPiano.runJavaScript(abcString.toString());
  // } else {
  sendPort.send(abcString.toString());
  // }
  sendPort.send('finish');
  debugPrint('getABCDataByLocalModel all data=${stringBuffer.toString()}');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late WebViewControllerPlus controllerKeyboard;
  // String filePathKeyboardAnimation =
  //     "http://192.168.3.14:3000"; //http://192.168.3.14:3000
  String filePathKeyboardAnimation = "assets/doctor/doctor.html";
  String filePathKeyboard = 'assets/piano/keyboard.html';
  String filePathPiano = 'assets/player/player.html';
  late StringBuffer stringBuffer;
  int addGap = 2; //间隔多少刷新
  int addCount = 0; //刷新次数
  var isPlay = false.obs;
  var playProgress = 0.0.obs;
  var pianoAllTime = 0.0.obs;
  Timer? timer;
  late StreamSubscription subscription;
  late HttpClient httpClient;
  int preTimestamp = 0;
  int preCount = 0;
  int listenCount = 0;
  var effectSelectedIndex = 0.obs;
  var noteLengthSelectedIndex = 0.obs; //选中单个音符出现的弹框
  String? currentSoundEffect;
  // late StringBuffer sbNoteCreate = StringBuffer();
  late MidiDeviceManage deviceManage;
  late String abcString;
  var isVisibleWebview = true.obs;
  @override
  void initState() {
    super.initState();
    midiProgramValue = ConfigStore.to.getMidiProgramSelect();
    isRememberPrompt.value = ConfigStore.to.getRemberPromptSelect();
    if (isRememberPrompt.value == false) {
      //prompt 默认选择的一个
    }
    isRememberEffect.value = ConfigStore.to.getRemberEffectSelect();
    if (isRememberEffect.value == false) {
      //effect 默认选择的一个
    }
    isAutoSwitch.value = ConfigStore.to.getAutoNextSelect();

    if (midiProgramValue == -1) {
      midiProgramValue = 0;
      debugPrint('set midiprogramvalue = 0');
    }
    debugPrint('midiprogramvalue value= $midiProgramValue');
    finalabcStringCreate =
        "setAbcString(\"${ABCHead.getABCWithInstrument('L:1/4\nM:$timeSingnatureStr\nK:C\n|', midiProgramValue)}\",false)";
    finalabcStringCreate =
        ABCHead.appendTempoParam(finalabcStringCreate, tempo.value.toInt());
    isWindowsOrMac = Platform.isWindows || Platform.isMacOS;
    stringBuffer = StringBuffer();
    deviceManage = MidiDeviceManage.getInstance();
    // debugPrint('deviceManage22=$identityHashCode($deviceManage)');
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
            //       "setAbcString(\"%%MIDI program 40\\nL:1/4\\nM:4/4\\nK:D\\n\\\"D\\\" A F F\",false)");
            // } else {
            presentPrompt = CommonUtils.escapeString(promptsAbc[index]);
            int subindex = presentPrompt.indexOf('L:');
            String subpresentPrompt = presentPrompt.substring(subindex);
            debugPrint('load presentPrompt=$presentPrompt');
            finalabcStringPreset =
                "setAbcString(\"${ABCHead.getABCWithInstrument(subpresentPrompt, midiProgramValue)}\",false)";
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
        debugPrint(
            'playOrPausePiano flutteronStartPlay onMessageReceived=$message');
        pianoAllTime.value = double.parse(message.split(',')[1]);
        debugPrint('playOrPausePiano pianoAllTime:${pianoAllTime.value}');
        playProgress.value = 0.0;
        createTimer();
        isPlay.value = true;
        // isNeedRestart = false;
      })
      ..addJavaScriptChannel("flutteronPausePlay",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        debugPrint(
            'playOrPausePiano flutteronPausePlay onMessageReceived=${jsMessage.message}');
        timer?.cancel();
        isPlay.value = false;
        // isNeedRestart = false;
      })
      ..addJavaScriptChannel("flutteronResumePlay",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        debugPrint(
            'playOrPausePiano flutteronResumePlay onMessageReceived=${jsMessage.message}');
        createTimer();
        isPlay.value = true;
        // isNeedRestart = false;
      })
      ..addJavaScriptChannel("flutteronCountPromptNoteNumber",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        debugPrint(
            'flutteronCountPromptNoteNumber onMessageReceived=${jsMessage.message}');
      })
      ..addJavaScriptChannel("flutteronEvents",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        // debugPrint('flutteronEvents onMessageReceived=${jsMessage.message}');
        midiNotes = jsonDecode(jsMessage.message);
        // if (!isNeedConvertMidiNotes) {
        //   // String jsstr =
        //   //     r'startPlay("[[0,\"on\",49],[333,\"on\",46],[333,\"off\",49],[1000,\"off\",46]]")';
        String jsstr =
            r'startPlay("' + jsMessage.message.replaceAll('"', r'\"') + r'")';
        controllerKeyboard.runJavaScript(jsstr);
        // controllerPiano.runJavaScript("startPlay()");
        // debugPrint('isFinishABCEvent == true,,,controllerPiano startPlay()');

        isFinishABCEvent = true;
        debugPrint('isFinishABCEvent == true,,,');
        // } else {
        //   isNeedConvertMidiNotes = false;
        // }
      })
      ..addJavaScriptChannel("flutteronPlayFinish",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        debugPrint(
            'flutteronPlayFinish onMessageReceived=${jsMessage.message}');
        isPlay.value = false;
        isFinishABCEvent = false;

        // // isNeedRestart = true;
        // if (isAutoSwitch.value) {
        //   //自动切换下一个prompt
        //   promptSelectedIndex.value += 1;
        //   // isHideWebview.value = !isHideWebview.value;
        //   if (isRememberPrompt.value) {
        //     ConfigStore.to.savePromptsSelect(promptSelectedIndex.value);
        //   }
        //   presentPrompt =
        //       CommonUtils.escapeString(promptsAbc[promptSelectedIndex.value]);
        //   if (selectstate.value == 0) {
        //     String abcstr =
        //         ABCHead.getABCWithInstrument(presentPrompt, midiProgramValue);
        //     abcstr = ABCHead.appendTempoParam(abcstr, tempo.value.toInt());
        //     controllerPiano.runJavaScript("setAbcString(\"$abcstr\",false)");
        //     controllerKeyboard.runJavaScript('resetPlay()');
        //     debugPrint(abcstr);
        //     // Future.delayed(const Duration(milliseconds: 300), () {
        //     //   playOrPausePiano();
        //     // });
        //   }
        // }
      })
      ..addJavaScriptChannel("flutteronClickNote",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        debugPrint('flutteronClickNote onMessageReceived=${jsMessage.message}');
        if (isShowDialog) {
          debugPrint('isShowDialog return');
          return;
        }
        List list = jsMessage.message.split(',');
        if (int.parse(list[list.length - 1]) >= 0) {
          if (selectstate.value == 1 && isPlay.value == false) {
            currentClickNoteInfo = [list[0], list[list.length - 1]];
            debugPrint('list===$currentClickNoteInfo');
            noteLengthSelectedIndex.value = NoteCaculate()
                .getNoteLengthIndex(list[0], int.parse(list[list.length - 1]));
            showPromptDialog(context, 'Change note length', noteLengths,
                'STORAGE_note_SELECT');
          }
        }
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
        if (isShowDialog) {
          debugPrint('isShowDialog return');
          return;
        }
        String name =
            MidiToABCConverter().getNoteMp3Path(int.parse(jsMessage.message));
        playNoteMp3(name);
        updatePianoNote(int.parse(jsMessage.message));
      });
    controllerKeyboard.loadFlutterAssetServer(filePathKeyboardAnimation);
    // controllerKeyboard.loadRequest(Uri.parse(filePathKeyboardAnimation));

    eventBus.on().listen((event) {
      // debugPrint('event bus==$event');
      if (event.toString().startsWith('tokens')) {
        // debugPrint('chenqi $event');
        tokens.value = ' -- ${event.toString()}';
      } else if (event == 'finish') {
        virtualNotes.clear();
        intNodes.clear();
        if (!isPlay.value) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            //改短了播放状态不对，曲谱没播放
            // isPlay.value = false;
            playOrPausePiano();
          });
        }
      } else {
        // // debugPrint('abcset=$event');

        // String result =
        //     event.replaceAll('setAbcString("%%', '').replaceAll('",false)', '');
        // // debugPrint('setAbcString replace==$result');
        // String encodedString = base64.encode(utf8.encode(result));
        // // debugPrint("Encoded setAbcString: $encodedString");
        // String base64AbcString = "setAbcString('$encodedString',false)";
        controllerPiano.runJavaScript(ABCHead.base64AbcString(event));
        // debugPrint('base64abctoEvents==$base64abctoEvents');
        // controllerPiano.runJavaScript(event);
      }
    });
  }

  void playNoteMp3(String name) {
    debugPrint('playNoteMp3playNoteMp3');
    if (currentSoundEffect != null) {
      String? mp3Folder = soundEffect[currentSoundEffect];
      debugPrint('mp3Folder==$mp3Folder');
      if (isWindowsOrMac) {
        AudioPlayerManage().playAudio('player/soundfont/$mp3Folder/$name');
      } else {
        JustAudioPlayerManage().playAudio('player/soundfont/$mp3Folder/$name');
      }
      debugPrint('player/soundfont/$mp3Folder/$name');
    } else {
      debugPrint('mp3Folder==null');
      if (isWindowsOrMac) {
        AudioPlayerManage()
            .playAudio('player/soundfont/acoustic_grand_piano-mp3/$name');
      } else {
        JustAudioPlayerManage()
            .playAudio('player/soundfont/acoustic_grand_piano-mp3/$name');
      }
    }
  }

  void updateNote(int index, int noteLengthIndex, String note) {
    debugPrint('updateNote index=$index,note=$note');
    String newnote = NoteCaculate()
        .calculateNewNoteByLength(note, noteLengths[noteLengthIndex]);
    NoteCaculate().noteMap[index] = newnote;
    virtualNotes[index] = newnote;
    StringBuffer sbff = StringBuffer();
    for (String note in virtualNotes) {
      sbff.write(note);
    }
    createPrompt = sbff.toString();
    String sb =
        "setAbcString(\"%%MIDI program $midiProgramValue\\nL:1/4\\nM:$timeSingnatureStr\\nK:C\\n|$createPrompt\",false)";
    finalabcStringCreate = ABCHead.appendTempoParam(sb, tempo.value.toInt());
    debugPrint('curr=$finalabcStringCreate');
    controllerPiano.runJavaScript(finalabcStringCreate);
    // createPrompt = sbff.toString();
  }

  void updatePianoNote(int node) {
    String noteName = MidiToABCConverter().getNoteName(node);
    if (defaultNoteLenght.value == 0) {
    } else if (defaultNoteLenght.value == 1) {
      noteName = "$noteName/2";
    } else if (defaultNoteLenght.value == 2) {
      noteName = "$noteName/4";
    }
    // sbNoteCreate.write(noteName);
    virtualNotes.add(noteName);
    intNodes.add(node);

    StringBuffer sbff = StringBuffer();
    List chordList = [];
    if (timeSignature.value == 2) {
      String chordStr = ChordUtil.getChord(intNodes.toString());
      chordList = jsonDecode(chordStr);
      debugPrint('chordStr=${chordList.length}');
    }
    String timeSignatureStr = timeSignatures[timeSignature.value];
    String noteLengthStr = noteLengths[defaultNoteLenght.value];
    debugPrint(
        'timeSignatureStr=$timeSignatureStr,noteLengthStr=$noteLengthStr');
    for (int i = 0; i < virtualNotes.length; i++) {
      String note = virtualNotes[i];
      if (timeSignatureStr == '4/4' && noteLengthStr == '1/4') {
        if (i % 4 == 0) {
          int chordLenght = i ~/ 4;
          if (chordList.length > chordLenght) {
            //插入竖线和和弦
            if (i == 0) {
              sbff.write('\\"${chordList[chordLenght]}\\" ');
            } else {
              sbff.write('|\\"${chordList[chordLenght]}\\" ');
            }
          }
        }
      } else {
        int postion =
            ABCHead.insertMeasureLinePosition(timeSignatureStr, noteLengthStr);
        if (i % postion == 0 && i > 0) {
          sbff.write('|');
        }
      }
      sbff.write(note);
    }
    createPrompt = sbff.toString();
    // ChordUtil.getResult();
    // ChordUtil.checkContentIsSame();
    // ChordUtil.findDifferent();
    String sb;
    if (isChangeTempo) {
      sb =
          "setAbcString(\"Q:${tempo.value.toInt()}\\nL:1/4\\nM:$timeSingnatureStr\\nK:C\\n|$createPrompt\",false)";
    } else {
      sb =
          "setAbcString(\"%%MIDI program $midiProgramValue\\nL:1/4\\nM:$timeSingnatureStr\\nK:C\\n|$createPrompt\",false)";
    }
    finalabcStringCreate = ABCHead.appendTempoParam(sb, tempo.value.toInt());
    debugPrint('curr=$finalabcStringCreate');
    controllerPiano.runJavaScript(finalabcStringCreate);
    // createPrompt = finalabcStringCreate;
  }

  void updateTimeSignature() {
    // setAbcString("%%MIDI program 0\nL:1/4\nM:4/4\nK:C\n|",false)
    String sb =
        "setAbcString(\"%%MIDI program $midiProgramValue\\nL:1/4\\nM:$timeSingnatureStr\\nK:C\\n|$createPrompt\",false)";
    sb = ABCHead.appendTempoParam(sb, tempo.value.toInt());
    debugPrint('curr=$sb');
    controllerPiano.runJavaScript(sb);
  }

  void resetLastNote() {
    debugPrint('resetLastNote');
    if (isCreateGenerate.value) {
      if (!isGenerating.value) {
        isCreateGenerate.value = false;
        segmentChange(1);
      } else {
        debugPrint('需要先停止生成再暫停');
      }
      return;
    }
    if (virtualNotes.isNotEmpty) {
      virtualNotes.removeLast();
      intNodes.removeLast();
      if (virtualNotes.isEmpty) {
        finalabcStringCreate =
            "setAbcString(\"${ABCHead.getABCWithInstrument('L:1/4\nM:$timeSingnatureStr\nK:C\n|', midiProgramValue)}\",false)";
        finalabcStringCreate =
            ABCHead.appendTempoParam(finalabcStringCreate, tempo.value.toInt());
        debugPrint('str112==$finalabcStringCreate');
        controllerPiano
            .runJavaScript(ABCHead.base64AbcString(finalabcStringCreate));
        createPrompt = '';
      } else {
        StringBuffer sbff = StringBuffer();
        List chordList = [];
        if (timeSignature.value == 2) {
          String chordStr = ChordUtil.getChord(intNodes.toString());
          chordList = jsonDecode(chordStr);
          debugPrint('chordStr=${chordList.length}');
        }
        String timeSignatureStr = timeSignatures[timeSignature.value];
        String noteLengthStr = noteLengths[defaultNoteLenght.value];
        debugPrint(
            'timeSignatureStr=$timeSignatureStr,noteLengthStr=$noteLengthStr');
        for (int i = 0; i < virtualNotes.length; i++) {
          String note = virtualNotes[i];
          if (timeSignatureStr == '4/4' && noteLengthStr == '1/4') {
            if (i % 4 == 0) {
              int chordLenght = i ~/ 4;
              if (chordList.length > chordLenght) {
                //插入竖线和和弦
                if (i == 0) {
                  sbff.write('\\"${chordList[chordLenght]}\\" ');
                } else {
                  sbff.write('|\\"${chordList[chordLenght]}\\" ');
                }
              }
            }
          } else {
            int postion = ABCHead.insertMeasureLinePosition(
                timeSignatureStr, noteLengthStr);
            if (i % postion == 0 && i > 0) {
              sbff.write('|');
            }
          }
          sbff.write(note);
        }
        String sb =
            "setAbcString(\"%%MIDI program $midiProgramValue\\nL:1/4\\nM:$timeSingnatureStr\\nK:C\\n|${sbff.toString()}\",false)";
        debugPrint('curr=$sb');
        sb = ABCHead.appendTempoParam(sb, tempo.value.toInt());
        controllerPiano.runJavaScript(sb);
        createPrompt = sbff.toString();
      }
    }
  }

  void playPianoAnimation(String playAbcString, bool needPlayKeyboard) {
    debugPrint('playAbcString==$playAbcString');
    if (isFinishABCEvent) {
      if (!isPlay.value) {
        // controllerKeyboard.runJavaScript('resetPlay()');
        controllerPiano.runJavaScript("startPlay()");
        debugPrint('playOrPausePiano controllerPiano startPlay()');
      } else {
        controllerPiano.runJavaScript("pausePlay()");
        debugPrint('playOrPausePiano controllerPiano pausePlay()');
      }
    } else {
      debugPrint('playPianoAnimation isFinishABCEvent not');
    }

    if (needPlayKeyboard) {
      if (isFinishABCEvent) {
        //&& !isNeedRestart && !isNeedConvertMidiNotes
        debugPrint(
            'playOrPausePiano isFinishABCEvent yes  resumePlay() keyboard');
        controllerKeyboard.runJavaScript('resumePlay()');
        // createTimer();
      } else {
        // String result = playAbcString
        //     .replaceAll('setAbcString("%%', '')
        //     .replaceAll('",false)', '');
        // debugPrint('replace==$result');
        // String encodedString = base64.encode(utf8.encode(result));
        // print("Encoded string: $encodedString");
        // String base64abctoEvents = "ABCtoEvents('$encodedString',false)";
        controllerPiano.runJavaScript(ABCHead.base64abctoEvents(playAbcString));
        // debugPrint('playOrPausePiano base64abctoEvents==$base64abctoEvents');
        controllerPiano.runJavaScript("startPlay()");

        // String abcStringTmp =
        //     playAbcString.replaceAll('setAbcString', 'ABCtoEvents');
        // debugPrint('playOrPausePiano  ABCtoEvents==$abcStringTmp');
        // controllerPiano.runJavaScript(abcStringTmp);
        // // controllerPiano.runJavaScript(
        // //     r'ABCtoEvents("L:1/4\nM:4/4\nK:D\n\"D\" A F F"),false');
      }
    } else {
      controllerKeyboard.runJavaScript('pausePlay()');
      debugPrint('playOrPausePiano controllerKeyboard pausePlay()');
      // timer.cancel();
    }
  }

  void createTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer timer) {
      if (playProgress.value >= 1) {
        playProgress.value = 0;
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
    timer?.cancel();
    httpClient.close();
    super.dispose();
  }

  Future addNote() async {
    final note = Note(
      // id: id ?? this.id,
      isUserCreate: true,
      orderNumber: 1122,
      title: 'title11',
      content: 'description11',
      createdTime: DateTime.now(),
    );
    await NotesDatabase.instance.create(note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 85.w, vertical: 30.h),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage('assets/images/backgroundbg.jpg'), // 替换为你的背景图片路径
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // AdvancedSegment(

                      //   // controller: _controller, // AdvancedSegmentController
                      //   segments: const {
                      //     // Map<String, String>
                      //     'all': 'All',
                      //     'primary': 'Primary',
                      //     'secondary': 'Secondary',
                      //     'tertiary': 'Tertiary',
                      //   },
                      //   activeStyle: const TextStyle(
                      //     // TextStyle
                      //     color: Colors.white,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      //   inactiveStyle: const TextStyle(
                      //     // TextStyle
                      //     color: Colors.white54,
                      //   ),
                      //   backgroundColor: Colors.black26, // Color
                      //   sliderColor: Colors.white, // Color
                      //   sliderOffset: 2.0, // Double
                      //   borderRadius: const BorderRadius.all(
                      //       Radius.circular(8.0)), // BorderRadius
                      //   itemPadding: const EdgeInsets.symmetric(
                      //     // EdgeInsets
                      //     horizontal: 15,
                      //     vertical: 10,
                      //   ),
                      //   animationDuration:
                      //       const Duration(milliseconds: 250), // Duration
                      //   shadow: const <BoxShadow>[
                      //     BoxShadow(
                      //       color: Colors.black26,
                      //       blurRadius: 8.0,
                      //     ),
                      //   ],
                      // ),

                      SizedBox(
                        width: isWindowsOrMac ? 605.w : 535.w,
                        height: isWindowsOrMac ? 123.h : 104.h,
                        child: CustomSegmentControl11(
                          selectedIndex: selectstate,
                          segments: const ['Prompt Mode', 'Create Mode'],
                          callBack: (int newValue) {
                            // 当选择改变时执行的操作
                            debugPrint('选择了选项 $newValue');
                            selectstate.value = newValue;
                            segmentChange(newValue);
                          },
                        ),
                      ),
                      // CustomSegment(
                      //   callBack: (int newValue) {
                      //     // 当选择改变时执行的操作
                      //     debugPrint('选择了选项 $newValue');
                      //     selectstate.value = newValue;
                      //     segmengChange(newValue);
                      //   },
                      // ),

                      // Container(
                      //   child: Obx(() {
                      //     return CupertinoSegmentedControl(
                      //       children: {
                      //         0: Padding(
                      //             padding: const EdgeInsets.symmetric(
                      //                 vertical: 8, horizontal: 0),
                      //             child: Text(
                      //               'Preset Mode',
                      //               style: TextStyle(
                      //                 color: Colors.white,
                      //                 fontSize: 14,
                      //                 fontWeight: selectstate.value == 0
                      //                     ? FontWeight.bold
                      //                     : FontWeight.normal,
                      //               ),
                      //             )),
                      //         1: Padding(
                      //             padding: const EdgeInsets.symmetric(
                      //                 vertical: 8, horizontal: 10),
                      //             child: Text(
                      //               'Creative Mode',
                      //               style: TextStyle(
                      //                 color: Colors.white,
                      //                 fontSize: 14,
                      //                 fontWeight: selectstate.value == 1
                      //                     ? FontWeight.bold
                      //                     : FontWeight.normal,
                      //               ),
                      //             )),
                      //       },
                      //       onValueChanged: (int newValue) {
                      //         // 当选择改变时执行的操作
                      //         debugPrint('选择了选项 $newValue');
                      //         selectstate.value = newValue;
                      //         segmengChange(newValue);
                      //       },
                      //       groupValue: selectstate.value, // 当前选中的选项值
                      //       selectedColor: const Color(0xff44be1c),
                      //       unselectedColor: Colors.transparent,
                      //       borderColor: const Color(0xff6d6d6d),
                      //     );
                      //   }),
                      // ),
                      Row(
                        children: [
                          Obx(
                            () => selectstate.value == 0
                                ? CreatBottomBtn(
                                    width: 253.w,
                                    height: isWindowsOrMac ? 123.h : 96.h,
                                    text: 'Prompt',
                                    icon: SvgPicture.asset(
                                      'assets/images/ic_arrowdown.svg',
                                      width: 28.w,
                                      height: 21.h,
                                    ),
                                    onPressed: () {
                                      debugPrint("Promptss");
                                      showPromptDialog(context, 'Prompts',
                                          prompts, STORAGE_PROMPTS_SELECT);
                                    },
                                  )
                                : CreatBottomBtn(
                                    width: 372.w,
                                    height: isWindowsOrMac ? 123.h : 96.h,
                                    text: 'Soft keyboard',
                                    icon: SvgPicture.asset(
                                      'assets/images/ic_arrowdown.svg',
                                      width: 28.w,
                                      height: 21.h,
                                    ),
                                    onPressed: () {
                                      debugPrint("Simulate keyboard");
                                      showPromptDialog(
                                          context,
                                          'Keyboard Options',
                                          keyboardOptions,
                                          STORAGE_KEYBOARD_SELECT);
                                    },
                                  ),
                          ),
                          // Obx(
                          //   () => selectstate.value == 0
                          //       ? creatBottomBtn('Prompts', () {
                          //           debugPrint("Promptss");
                          //           showPromptDialog(context, 'Prompts', prompts,
                          //               STORAGE_PROMPTS_SELECT);
                          //         }, 'btn_prompts', 243.w, 123.h, 'ic_arrowdown',
                          //           28.w, 21.h)
                          //       : creatBottomBtn('Soft keyboard', () {
                          //           debugPrint("Simulate keyboard");
                          //           showPromptDialog(context, 'Keyboard Options',
                          //               keyboardOptions, STORAGE_KEYBOARD_SELECT);
                          //         }, 'btn_softkeyboard', 253.w, 123.h,
                          //           'ic_arrowdown', 20.w, 30.h),
                          // ),
                          SizedBox(
                            width: 55.w,
                          ),
                          CreatBottomBtn(
                            width: selectstate.value == 0 ? 357.w : 358.w,
                            height: isWindowsOrMac ? 123.h : 96.h,
                            text: 'Instrument',
                            icon: SvgPicture.asset(
                              'assets/images/ic-${instruments[effectSelectedIndex.value]}.svg', //
                              width: isWindowsOrMac ? 61.w : 52.w,
                              height: isWindowsOrMac ? 57.h : 48.h,
                            ),
                            onPressed: () {
                              debugPrint("Sounds Effect");
                              var list = soundEffect.keys.toList();
                              showPromptDialog(context, 'Instrument', list,
                                  STORAGE_SOUNDSEFFECT_SELECT);
                            },
                          ),
                          // creatBottomBtn('Instrument', () {
                          //   debugPrint("Sounds Effect");
                          //   showPromptDialog(
                          //       context,
                          //       'Instrument',
                          //       soundEffect.keys.toList(),
                          //       STORAGE_SOUNDSEFFECT_SELECT);
                          // }, 'btn_instrument', 348.w, 123.h, 'ic-piano', 61.w,
                          //     61.h),
                          SizedBox(
                            width: 55.w,
                          ),
                          CreatBottomBtn(
                            width: isWindowsOrMac ? 123.h : 96.h,
                            height: isWindowsOrMac ? 123.h : 96.h,
                            text: '',
                            icon: SvgPicture.asset(
                              'assets/images/ic_setting.svg',
                              width: isWindowsOrMac ? 61.w : 52.w,
                              height: isWindowsOrMac ? 61.h : 52.h,
                            ),
                            onPressed: () {
                              // CommonUtils.getDeviceInfo();
                              // CommonUtils.getDeviceName();
                              // // testisolate22();
                              // return;
                              debugPrint('Settings');
                              if (isShowOverlay) {
                                closeOverlay();
                              }
                              if (isWindowsOrMac) {
                                isVisibleWebview.value =
                                    !isVisibleWebview.value;
                                // setState(() {});
                              }
                              // bottomsheetsetting();
                              // return;
                              // Get.to(FlutterBlueApp());
                              // Get.to(const MIDIDeviceListPage());
                              if (selectstate.value == 0) {
                                showSettingDialog(context);
                              } else {
                                showCreateModelSettingDialog(context);
                              }
                            },
                          ),

                          // creatBottomBtn('', () {
                          //   debugPrint('Settings');
                          //   if (isWindowsOrMac) {
                          //     isVisibleWebview.value = !isVisibleWebview.value;
                          //     setState(() {});
                          //   }
                          //   // Get.to(FlutterBlueApp());
                          //   // Get.to(const MIDIDeviceListPage());
                          //   if (selectstate.value == 0) {
                          //     showSettingDialog(context);
                          //   } else {
                          //     showCreateModelSettingDialog(context);
                          //   }
                          // }, 'btn_setting', 123.w, 123.h, 'ic_setting', 61.w,
                          //     57.h),

                          // createButtonImageWithText(
                          //     'Settings',
                          //     Image.asset(
                          //       'assets/images/setting.jpg',
                          //       fit: BoxFit.cover,
                          //     ), () {
                          //   debugPrint('Settings');

                          //   if (isWindowsOrMac) {
                          //     isVisibleWebview.value = !isVisibleWebview.value;
                          //     setState(() {});
                          //   }
                          //   // Get.to(FlutterBlueApp());
                          //   // Get.to(const MIDIDeviceListPage());
                          //   if (selectstate.value == 0) {
                          //     showSettingDialog(context);
                          //   } else {
                          //     showCreateModelSettingDialog(context);
                          //   }
                          // }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: isWindowsOrMac ? 33.h : 15.h,
              ),
              Obx(() => Flexible(
                    flex: isWindowsOrMac ? 2 : 2,
                    child: Visibility(
                        key: const ValueKey('ValueKey11'),
                        visible: isVisibleWebview.value,
                        // maintainSize: true, // 保持占位空间
                        // maintainAnimation: true, // 保持动画
                        // maintainState: true,
                        child: WebViewWidget(
                          controller: controllerPiano,
                        )),
                  )),
              SizedBox(
                height: isWindowsOrMac ? 33.h : 15.h,
              ),
              Obx(
                () => Flexible(
                    flex: isWindowsOrMac ? 6 : 4,
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
              ),
              //   ],
              // )),
              Obx(
                () => Expanded(
                  flex: isWindowsOrMac ? 1 : 1,
                  child: Visibility(
                    visible: isVisibleWebview.value,
                    key: const ValueKey('ValueKey33'),
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 0,
                          top: isWindowsOrMac ? 40.h : 28.h,
                          right: 0,
                          bottom: 2),
                      child: Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(
                              'assets/images/title_logo.svg',
                              width: isWindowsOrMac ? 433.w : 366.w,
                              height: isWindowsOrMac ? 33.h : 28.h,
                              fit: BoxFit.cover,
                            ),
                            // if (selectstate.value == 0)
                            Row(
                              children: [
                                Obx(() => isGenerating.value
                                    ? SizedBox(
                                        width: isWindowsOrMac ? 48.w : 32.w,
                                        height: isWindowsOrMac ? 48.w : 32.w,
                                        child: const CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Container(
                                        child: null,
                                      )),
                                SizedBox(
                                  width: 40.w,
                                ),
                                Obx(() => ProgressbarTime(
                                        playProgress, pianoAllTime, () {
                                      playOrPausePiano();
                                    }, isPlay.value)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Obx(
                                  () => CreatBottomBtn(
                                    textColor: AppColor.color_A1D632,
                                    width: selectstate.value == 0
                                        ? (isWindowsOrMac ? 666.w : 555.w)
                                        : (isWindowsOrMac ? 453.w : 354.w),
                                    height: isWindowsOrMac ? 123.h : 96.h,
                                    text: !isGenerating.value
                                        ? 'AI Compose'
                                        : 'Stop Compose',
                                    icon: SvgPicture.asset(
                                      'assets/images/ic_generate.svg',
                                      width: isWindowsOrMac ? 68.w : 58.w,
                                      height: isWindowsOrMac ? 75.h : 64.h,
                                    ),
                                    onPressed: () {
                                      debugPrint('Generate');
                                      isGenerating.value = !isGenerating.value;
                                      if (isGenerating.value) {
                                        resetPianoAndKeyboard();
                                        // playProgress.value = 0.0;
                                        // pianoAllTime.value = 0.0;
                                        // controllerPiano.runJavaScript(
                                        //     "setAbcString(\"%%MIDI program 40\\nL:1/4\\nM:4/4\\nK:D\\n\\\"D\\\" A F F\",false)");
                                        // controllerPiano.runJavaScript(
                                        //     'resetTimingCallbacks()');
                                        // if (isWindowsOrMac) {
                                        fetchABCDataByIsolate();
                                        // } else {
                                        //   getABCDataByAPI();
                                        // }
                                        // controllerKeyboard
                                        //     .runJavaScript('resetPlay()');
                                        // controllerPiano.runJavaScript(
                                        //     'resetTimingCallbacks()');
                                        isFinishABCEvent = false;
                                        if (selectstate.value == 1) {
                                          isCreateGenerate.value = true;
                                          controllerKeyboard
                                              .loadFlutterAssetServer(
                                                  filePathKeyboardAnimation);
                                          // controllerKeyboard.loadRequest(
                                          //     Uri.parse(
                                          //         filePathKeyboardAnimation));
                                        }
                                      } else {
                                        // isolateSendPort.send('stop Generating');
                                        isolateEventBus.fire("stop Generating");
                                      }
                                    },
                                  ),
                                  // creatBottomBtn('AI Compose', () {
                                  //   {
                                  //     debugPrint('Generate');
                                  //     isGenerating.value = !isGenerating.value;
                                  //     if (isGenerating.value) {
                                  //       resetPlay();
                                  //       // playProgress.value = 0.0;
                                  //       // pianoAllTime.value = 0.0;
                                  //       // controllerPiano.runJavaScript(
                                  //       //     "setAbcString(\"%%MIDI program 40\\nL:1/4\\nM:4/4\\nK:D\\n\\\"D\\\" A F F\",false)");
                                  //       // controllerPiano.runJavaScript(
                                  //       //     'resetTimingCallbacks()');
                                  //       // if (isWindowsOrMac) {
                                  //       fetchABCDataByIsolate();
                                  //       // } else {
                                  //       //   getABCDataByAPI();
                                  //       // }
                                  //       // controllerKeyboard
                                  //       //     .runJavaScript('resetPlay()');
                                  //       // controllerPiano.runJavaScript(
                                  //       //     'resetTimingCallbacks()');
                                  //       isFinishABCEvent = false;
                                  //       if (selectstate.value == 1) {
                                  //         controllerKeyboard
                                  //             .loadFlutterAssetServer(
                                  //                 filePathKeyboardAnimation);
                                  //         // controllerKeyboard.loadRequest(
                                  //         //     Uri.parse(
                                  //         //         filePathKeyboardAnimation));
                                  //       }
                                  //     } else {
                                  //       // isolateSendPort.send('stop Generating');
                                  //       isolateEventBus.fire("stop Generating");
                                  //     }
                                  //   }
                                  // },
                                  //     selectstate.value == 0
                                  //         ? 'btn_generate'
                                  //         : 'btn_create_generate',
                                  //     656.w,
                                  //     123.h,
                                  //     'ic_generate',
                                  //     68.w,
                                  //     75.h),
                                  // Obx(() => createButtonImageWithText(
                                  //         !isGenerating.value
                                  //             ? 'Generate'
                                  //             : 'Stop',
                                  //         !isGenerating.value
                                  //             ? Image.asset(
                                  //                 'assets/images/generate.jpg',
                                  //                 fit: BoxFit.cover,
                                  //               )
                                  //             : Image.asset(
                                  //                 'assets/images/stopgenerate.jpg'),
                                  //         () {
                                  //       debugPrint('Generate');
                                  //       isGenerating.value =
                                  //           !isGenerating.value;
                                  //       if (isGenerating.value) {
                                  //         resetPlay();
                                  //         // playProgress.value = 0.0;
                                  //         // pianoAllTime.value = 0.0;
                                  //         // controllerPiano.runJavaScript(
                                  //         //     "setAbcString(\"%%MIDI program 40\\nL:1/4\\nM:4/4\\nK:D\\n\\\"D\\\" A F F\",false)");
                                  //         // controllerPiano.runJavaScript(
                                  //         //     'resetTimingCallbacks()');
                                  //         // if (isWindowsOrMac) {
                                  //         fetchABCDataByIsolate();
                                  //         // } else {
                                  //         //   getABCDataByAPI();
                                  //         // }
                                  //         // controllerKeyboard
                                  //         //     .runJavaScript('resetPlay()');
                                  //         // controllerPiano.runJavaScript(
                                  //         //     'resetTimingCallbacks()');
                                  //         isFinishABCEvent = false;
                                  //         if (selectstate.value == 1) {
                                  //           controllerKeyboard
                                  //               .loadFlutterAssetServer(
                                  //                   filePathKeyboardAnimation);
                                  //           // controllerKeyboard.loadRequest(
                                  //           //     Uri.parse(
                                  //           //         filePathKeyboardAnimation));
                                  //         }
                                  //       } else {
                                  //         // isolateSendPort.send('stop Generating');
                                  //         isolateEventBus
                                  //             .fire("stop Generating");
                                  //       }
                                  //     })),
                                ),
                                if (selectstate.value == 1)
                                  SizedBox(
                                    width: 55.w,
                                  ),
                                Obx(() => Visibility(
                                      visible: selectstate.value == 1,
                                      child: CreatBottomBtn(
                                        width: isWindowsOrMac ? 257.w : 200.w,
                                        height: isWindowsOrMac ? 123.h : 96.h,
                                        text: !isCreateGenerate.value
                                            ? 'Undo'
                                            : 'Reset',
                                        icon: SvgPicture.asset(
                                          'assets/images/ic_undo.svg',
                                          width: isWindowsOrMac ? 61.w : 50.w,
                                          height: isWindowsOrMac ? 61.h : 50.h,
                                        ),
                                        onPressed: () {
                                          debugPrint('Undo');
                                          resetLastNote();
                                        },
                                      ),
                                    )),
                                // Obx(() => Visibility(
                                //       visible: selectstate.value == 1,
                                //       child: creatBottomBtn('Undo', () {
                                //         debugPrint('Undo');
                                //         resetLastNote();
                                //       }, 'btn_undo', 48.w, 123.h, 'ic_undo',
                                //           61.w, 61.h),
                                //     )),
                                // Obx(() => Visibility(
                                //     visible: selectstate.value == 1,
                                //     child: createButtonImageWithText(
                                //         'Undo',
                                //         Image.asset(
                                //           'assets/images/undo.jpg',
                                //           fit: BoxFit.cover,
                                //         ), () {
                                //       debugPrint('Undo');
                                //       resetLastNote();
                                //     }))),
                                // SizedBox(
                                //   width: isWindowsOrMac ? 10 : 20,
                                // ),
                                // Obx(() {
                                //   return createButtonImageWithText(
                                //       !isPlay.value ? 'Play' : 'Pause',
                                //       !isPlay.value
                                //           ? Image.asset(
                                //               'assets/images/play.jpg',
                                //               fit: BoxFit.cover,
                                //             )
                                //           : Image.asset(
                                //               'assets/images/pause.jpg',
                                //               fit: BoxFit.cover,
                                //             ), () {
                                //     playOrPausePiano();
                                //   });
                                // }),
                                // SizedBox(
                                //   width: isWindowsOrMac ? 10 : 20,
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void playOrPausePiano() {
    debugPrint('playOrPausePiano status =${isPlay.value}');
    playPianoAnimation(
        selectstate.value == 0 ? finalabcStringPreset : finalabcStringCreate,
        !isPlay.value);
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

  void resetPianoAndKeyboard() {
    // if (isPlay.value) {
    // playOrPausePiano();
    // // controllerPiano.runJavaScript("setPlayButtonDisable(true)");
    // controllerKeyboard.runJavaScript('resetPlay()');
    // debugPrint('pausePlay()');

    controllerPiano.runJavaScript("pausePlay()");
    controllerPiano.runJavaScript("resetTimingCallbacks()");
    controllerPiano.runJavaScript("triggerRestartBtnClick()");

    controllerKeyboard.runJavaScript('clearAll()'); //resetPlay()
    // if (selectstate.value == 0 || isCreateGenerate.value) {
    //   debugPrint('loadFlutterAssetServer-filePathKeyboardAnimation-');
    //   controllerKeyboard.loadFlutterAssetServer(filePathKeyboardAnimation);
    // }

    isPlay.value = false;
    timer?.cancel();
    // isNeedRestart = true;
    // }
    if (playProgress.value > 0) {
      playProgress.value = 0.0;
      pianoAllTime.value = 0.0;
    }
    isFinishABCEvent = false;
  }

  void segmentChange(int index) {
    resetPianoAndKeyboard();
    if (isShowOverlay) {
      closeOverlay();
    }
    if (index == 0) {
      //preset
      // controllerPiano.runJavaScript(
      //     "setAbcString(\"%%MIDI program $midiProgramValue\\nL:1/4\\nM:4/4\\nK:D\\n\\\"D\\\" A F F\",false)");
      controllerPiano
          .runJavaScript(ABCHead.base64AbcString(finalabcStringPreset));
      debugPrint('finalabcStringPreset=$finalabcStringPreset');
      controllerPiano.runJavaScript("setPromptNoteNumberCount(3)");
      controllerKeyboard.loadFlutterAssetServer(filePathKeyboardAnimation);
      // controllerKeyboard.loadRequest(Uri.parse(filePathKeyboardAnimation));
      controllerKeyboard.runJavaScript('resetPlay()');
      // controllerKeyboard.runJavaScript('setPiano(55, 76)');
    } else {
      createModeDefault();
    }
  }

  void createModeDefault() {
    virtualNotes.clear();
    intNodes.clear();
    //creative
    // String str1 =
    //     "setAbcString(\"%%MIDI program $midiProgramValue\\nL:1/4\\nM:4/4\\nK:C\\n|\",false)";
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

  // Widget getLogoImage() {
  //   return Assets.images.logo.image();
  // }

  void showSettingDialog(BuildContext context) {
    isShowDialog = true;
    TextEditingController controller = TextEditingController(
        text: ''); // ${DateTime.now().microsecondsSinceEpoch}
    showDialog(
      // barrierColor: Colors.transparent,
      barrierDismissible: isWindowsOrMac ? false : false,
      context: context,
      builder: (BuildContext context) {
        // 返回一个Dialog
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30.w)),
                  color: Colors.transparent,
                  image: const DecorationImage(
                    image: AssetImage(
                        'assets/images/backgroundbg.jpg'), // 替换为你的背景图片路径
                    fit: BoxFit.cover,
                  ),
                ),
                width: isWindowsOrMac ? 1400.w : 1200.w,
                height: isWindowsOrMac ? 1000.h : 890.h,
                padding: EdgeInsets.symmetric(
                    horizontal: isWindowsOrMac ? 60.w : 40.w,
                    vertical: isWindowsOrMac ? 40.h : 20.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextTitle(
                          text: 'Settings',
                        ),
                        InkWell(
                          child: Icon(
                            Icons.close,
                            size: 50.w,
                          ),
                          onTap: () {
                            isShowDialog = false;
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextItem(text: 'Randomness'),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 500.w,
                                    child: Slider(
                                      activeColor: Colors.white,
                                      inactiveColor: Colors.black,
                                      thumbColor: Colors.white,
                                      value: randomness.value,
                                      onChanged: (newValue) {
                                        randomness.value = newValue;
                                      },
                                    ),
                                  ),
                                  TextItem(
                                      text:
                                          '${(randomness.value * 100).toInt()}%'),
                                ],
                              )
                            ])),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextItem(text: 'Seed'), //: ${seed.value}
                          ContainerTextField(
                            seed: seed.value,
                            onChanged: (String text) {
                              // 当文本字段内容变化时调用
                              seed.value = int.parse(text);
                              debugPrint('Current text: ');
                            },
                          ),
                          // SizedBox(
                          //   width: 200,
                          //   height: 40,
                          //   child: TextField(
                          //     controller: controller,
                          //     keyboardType: TextInputType.number,
                          //     inputFormatters: <TextInputFormatter>[
                          //       FilteringTextInputFormatter.allow(
                          //           RegExp(r'[0-9]')), // 只允许输入数字
                          //     ],
                          //     decoration: const InputDecoration(
                          //         labelText: 'Please input seed value',
                          //         hintText: 'Enter a number',
                          //         border: OutlineInputBorder()),
                          //     onChanged: (text) {
                          //       // 当文本字段内容变化时调用
                          //       seed.value = int.parse(text);
                          //       debugPrint('Current text: ');
                          //     },
                          //   ),
                          // ),
                        ]),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextItem(text: 'Auto Chord'),
                            Obx(() => SwitchItem(
                                  value: autoChord.value,
                                  onChanged: (newValue) {
                                    autoChord.value = newValue;
                                  },
                                )),
                          ]),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Center(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextItem(text: 'Infinite Generation'),
                            Obx(() => SwitchItem(
                                  value: infiniteGeneration.value,
                                  onChanged: (newValue) {
                                    infiniteGeneration.value = newValue;
                                  },
                                )),
                          ]),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    // Row(children: [
                    Obx(() => CheckBoxItem(
                          title: 'Demo Mode$tokens',
                          // visualDensity: VisualDensity.compact, // 去除空白间距
                          isSelected: isAutoSwitch.value,
                          onChanged: (bool? value) {
                            isAutoSwitch.value = value!;
                            ConfigStore.to.saveAutoNext(value);
                          },
                        )),
                    // Obx(() => TextItem(text: 'Demo Mode$tokens')),
                    // ]),
                    SizedBox(
                      height: 40.h,
                    ),
                    Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          TextBtn(
                            width: isWindowsOrMac ? 500.w : 500.w,
                            height: isWindowsOrMac ? 113.h : 80.h,
                            onPressed: () async {
                              if (midiNotes.isEmpty) {
                                // String oriabcString = finalabcStringPreset
                                //     .replaceAll('setAbcString', 'ABCtoEvents');
                                // // abcString = r'ABCtoEvents("L:1/4\nM:4/4\nK:D\n\"D\" A F F")';
                                // debugPrint(
                                //     'playPianoAnimation ABCtoEvents==');
                                // isNeedConvertMidiNotes = true;
                                // controllerPiano.runJavaScript(oriabcString);
                                playPianoAnimation(
                                    selectstate.value == 0
                                        ? finalabcStringPreset
                                        : finalabcStringCreate,
                                    true);
                                Future.delayed(const Duration(seconds: 2),
                                    () async {
                                  debugPrint('Delayed action after 3 seconds');
                                  // isNeedConvertMidiNotes = false;
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
                                    debugPrint(
                                        'Select a directory=${result.path}');
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
                            text: 'Export Midi File',
                          ),
                          SizedBox(
                            width: 30.w,
                          ),
                          TextBtn(
                            width: isWindowsOrMac ? 500.w : 500.w,
                            height: isWindowsOrMac ? 113.h : 80.h,
                            onPressed: () {
                              showBleDeviceOverlay(context, false);
                            },
                            text: 'Scan BlueTooth Device',
                          ),
                        ])),
                    SizedBox(
                      height: isWindowsOrMac ? 60.h : 40.h,
                    ),
                    Center(child: TextItem(text: 'Version: RWKV-6 1.2.0')),
                  ],
                ),
              )),
        );
      },
    ).then((value) {
      UniversalBle.stopScan();
      if (overlayEntry != null) {
        overlayEntry!.remove();
        isShowOverlay = false;
      }
    });
  }

  void showCreateModelSettingDialog(BuildContext context) {
    isShowDialog = true;
    TextEditingController controller = TextEditingController(
        text: ''); // ${DateTime.now().microsecondsSinceEpoch}
    showDialog(
      barrierDismissible: isWindowsOrMac ? false : false,
      context: context,
      builder: (BuildContext context) {
        // 返回一个Dialog
        return Dialog(
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            physics:
                const ClampingScrollPhysics(), // 设置滚动物理属性为 ClampingScrollPhysics
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30.w)),
                  color: Colors.transparent,
                  image: const DecorationImage(
                    image: AssetImage(
                        'assets/images/backgroundbg.jpg'), // 替换为你的背景图片路径
                    fit: BoxFit.cover,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: isWindowsOrMac ? 60.w : 40.w,
                    vertical: isWindowsOrMac ? 40.h : 20.h),
                child: SizedBox(
                    width: isWindowsOrMac ? 1400.w : 1200.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextTitle(
                              text: 'Settings',
                            ),
                            InkWell(
                              child: Icon(
                                Icons.close,
                                size: 50.w,
                              ),
                              onTap: () {
                                isShowDialog = false;
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
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          textBaseline: TextBaseline.alphabetic, // 指定基线对齐的基线
                          children: [
                            TextItem(text: 'Time signature'),
                            Obx(() => DropButtonList(
                                  key: const ValueKey('Time'),
                                  items: timeSignatures,
                                  index: timeSignature.value,
                                  onChanged: (index) {
                                    timeSignature.value = index;
                                    timeSingnatureStr = timeSignatures[index];
                                    updateTimeSignature();
                                  },
                                )),
                            // SizedBox(
                            //     width: 80, // 设置RadioListTile的宽度
                            //     height: 30,
                            //     child: RadioButton(
                            //       description: "2/4",
                            //       value: 0,
                            //       groupValue: timeSignature.value,
                            //       onChanged: (value) {
                            //         timeSignature.value = value!;
                            //         timeSingnatureStr = '2/4';
                            //         updateTimeSignature();
                            //       },
                            //     )),
                            // SizedBox(
                            //     width: 80, // 设置RadioListTile的宽度
                            //     height: 30,
                            //     child: RadioButton(
                            //       description: "3/4",
                            //       value: 1,
                            //       groupValue: timeSignature.value,
                            //       onChanged: (value) {
                            //         timeSignature.value = value!;
                            //         timeSingnatureStr = '3/4';
                            //         updateTimeSignature();
                            //       },
                            //     )),
                            // SizedBox(
                            //     width: 80, // 设置RadioListTile的宽度
                            //     height: 30,
                            //     child: RadioButton(
                            //       description: "4/4",
                            //       value: 2,
                            //       groupValue: timeSignature.value,
                            //       onChanged: (value) {
                            //         timeSignature.value = value!;
                            //         timeSingnatureStr = '4/4';
                            //         updateTimeSignature();
                            //       },
                            //     )),
                            // SizedBox(
                            //     width: 80, // 设置RadioListTile的宽度
                            //     height: 30,
                            //     child: RadioButton(
                            //       description: "3/8",
                            //       value: 3,
                            //       groupValue: timeSignature.value,
                            //       onChanged: (value) {
                            //         timeSignature.value = value!;
                            //         timeSingnatureStr = '3/8';
                            //         updateTimeSignature();
                            //       },
                            //     )),
                            // SizedBox(
                            //     width: 80, // 设置RadioListTile的宽度
                            //     height: 30,
                            //     child: RadioButton(
                            //       description: "6/8",
                            //       value: 4,
                            //       groupValue: timeSignature.value,
                            //       onChanged: (value) {
                            //         timeSignature.value = value!;
                            //         timeSingnatureStr = '6/8';
                            //         updateTimeSignature();
                            //       },
                            //     )),
                            // const Spacer(),
                          ],
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic, // 指定基线对齐的基线
                          children: [
                            TextItem(text: 'Default note length'),
                            Obx(() => DropButtonList(
                                  key: const ValueKey('Default'),
                                  items: noteLengths,
                                  index: defaultNoteLenght.value,
                                  onChanged: (index) {
                                    defaultNoteLenght.value = index;
                                  },
                                )),
                            // SizedBox(
                            //     width: 80,
                            //     height: 30,
                            //     child: RadioButton(
                            //       description: "1/4",
                            //       value: 0,
                            //       groupValue: defaultNoteLenght.value,
                            //       onChanged: (value) {
                            //         defaultNoteLenght.value = value!;
                            //       },
                            //     )),
                            // SizedBox(
                            //     width: 80,
                            //     height: 30,
                            //     child: RadioButton(
                            //       description: "1/8",
                            //       value: 1,
                            //       groupValue: defaultNoteLenght.value,
                            //       onChanged: (value) {
                            //         defaultNoteLenght.value = value!;
                            //       },
                            //     )),
                            // SizedBox(
                            //     width: 80,
                            //     height: 30,
                            //     child: RadioButton(
                            //       description: "1/16",
                            //       value: 2,
                            //       groupValue: defaultNoteLenght.value,
                            //       onChanged: (value) {
                            //         defaultNoteLenght.value = value!;
                            //       },
                            //     )),
                          ],
                        ),
                        Obx(() => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextItem(text: 'Randomness'),
                                  Row(
                                    children: [
                                      SizedBox(
                                          width: 500.w,
                                          child: Slider(
                                            activeColor: Colors.white,
                                            inactiveColor: Colors.black,
                                            thumbColor: Colors.white,
                                            value: randomness.value,
                                            onChanged: (newValue) {
                                              randomness.value = newValue;
                                            },
                                          )),
                                      TextItem(
                                          text:
                                              '${(randomness.value * 100).toInt()}%'),
                                    ],
                                  )
                                ])),
                        SizedBox(
                          height: 20.h,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextItem(text: 'Seed'), //: ${seed.value}
                              ContainerTextField(
                                seed: seed.value,
                                onChanged: (String text) {
                                  // 当文本字段内容变化时调用
                                  seed.value = int.parse(text);
                                  debugPrint('Current text: ');
                                  isUseCurrentTime = false;
                                },
                              ),
                              // SizedBox(
                              //     height: 40,
                              //     width: 200,
                              //     child: TextField(
                              //       controller: controller,
                              //       keyboardType: TextInputType.number,
                              //       inputFormatters: <TextInputFormatter>[
                              //         FilteringTextInputFormatter.allow(
                              //             RegExp(r'[0-9]')), // 只允许输入数字
                              //       ],
                              //       decoration: const InputDecoration(
                              //           labelText:
                              //               'Please input seed value',
                              //           hintText: 'Enter a number',
                              //           border: OutlineInputBorder()),
                              //       onChanged: (text) {
                              //         // 当文本字段内容变化时调用
                              //         seed.value = int.parse(text);
                              //         debugPrint('Current text: ');
                              //       },
                              //     )),
                            ]),
                        Obx(() => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextItem(text: 'Tempo'),
                                  Row(
                                    children: [
                                      SizedBox(
                                          width: 500.w,
                                          child: Slider(
                                            activeColor: Colors.white,
                                            inactiveColor: Colors.black,
                                            thumbColor: Colors.white,
                                            min: 40,
                                            max: 208,
                                            value: tempo.value,
                                            onChanged: (newValue) {
                                              tempo.value = newValue;
                                              isChangeTempo = true;
                                            },
                                          )),
                                      TextItem(text: '${tempo.value.toInt()}'),
                                    ],
                                  )
                                ])),
                        SizedBox(
                          height: 20.h,
                        ),
                        Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextItem(text: 'Auto Chord'),
                                Obx(() => SwitchItem(
                                      value: autoChord.value,
                                      onChanged: (newValue) {
                                        autoChord.value = newValue;
                                      },
                                    )),
                              ]),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextItem(text: 'Infinite Generation'),
                                Obx(() => SwitchItem(
                                      value: infiniteGeneration.value,
                                      onChanged: (newValue) {
                                        infiniteGeneration.value = newValue;
                                      },
                                    )),
                              ]),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),

                        SizedBox(
                          height: 20.h,
                        ),
                        // Row(children: [
                        Obx(() => CheckBoxItem(
                              title: 'Demo Mode$tokens',
                              // visualDensity: VisualDensity.compact, // 去除空白间距
                              isSelected: isAutoSwitch.value,
                              onChanged: (bool? value) {
                                isAutoSwitch.value = value!;
                                ConfigStore.to.saveAutoNext(value);
                              },
                            )),
                        //   const TextItem(text: 'Demo Mode'),
                        // ]),
                        SizedBox(
                          height: 40.h,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextBtn(
                                width: isWindowsOrMac ? 500.w : 500.w,
                                height: isWindowsOrMac ? 113.h : 80.h,
                                onPressed: () {
                                  if (midiNotes.isEmpty) {
                                    // String oriabcString = finalabcStringPreset
                                    //     .replaceAll('setAbcString', 'ABCtoEvents');
                                    // // abcString = r'ABCtoEvents("L:1/4\nM:4/4\nK:D\n\"D\" A F F")';
                                    // debugPrint(
                                    //     'playPianoAnimation ABCtoEvents==$oriabcString');
                                    // isNeedConvertMidiNotes = true;
                                    // controllerPiano.runJavaScript(oriabcString);

                                    playPianoAnimation(
                                        selectstate.value == 0
                                            ? finalabcStringPreset
                                            : finalabcStringCreate,
                                        true);
                                    Future.delayed(const Duration(seconds: 2),
                                        () {
                                      debugPrint(
                                          'Delayed action after 3 seconds');
                                      // isNeedConvertMidiNotes = false;
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
                                text: 'Export Midi File',
                              ),
                              SizedBox(
                                width: 30.w,
                              ),
                              TextBtn(
                                width: isWindowsOrMac ? 500.w : 500.w,
                                height: isWindowsOrMac ? 113.h : 80.h,
                                onPressed: () {
                                  showBleDeviceOverlay(context, false);
                                },
                                text: 'Scan BlueTooth Device',
                              ),
                            ]),
                        SizedBox(
                          height: isWindowsOrMac ? 60.h : 40.h,
                        ),
                        Center(child: TextItem(text: 'Version: RWKV-6 1.2.0')),
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
        isShowOverlay = false;
      }
    });
  }

  showConnectDialog(context) {
    String title = 'Connect Midi Keyboard';
    String msg =
        'Please connect your midi keyboard first. Wireless connection is recommended.';
    showDialog(
      context: context,
      builder: (BuildContext buildcontext) {
        return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(30.w),
              width: isWindowsOrMac ? 1400.w : 1200.w,
              height: 630.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30.w)),
                color: Colors.transparent,
                image: const DecorationImage(
                  image: AssetImage(
                      'assets/images/backgroundbg.jpg'), // 替换为你的背景图片路径
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  // backgroundColor: Colors.transparent,
                  TextTitle(text: title),
                  SizedBox(
                    height: 30.h,
                  ),
                  TextItem(text: msg),

                  SizedBox(
                    height: 100.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextBtn(
                        width: 500.w,
                        height: 113.h,
                        onPressed: () {
                          // 处理取消按钮点击事件
                          if (isWindowsOrMac) {
                            // setState(() {
                            isVisibleWebview.value = true;
                            // });
                          }
                          Navigator.of(buildcontext).pop();
                        },
                        text: 'OK',
                      ),
                      SizedBox(
                        width: 40.w,
                      ),
                      // TextButton(
                      //   onPressed: () {
                      //     // 处理取消按钮点击事件
                      //     if (isWindowsOrMac) {
                      //       // setState(() {
                      //       isVisibleWebview.value = true;
                      //       // });
                      //     }
                      //     Navigator.of(buildcontext).pop();
                      //   },
                      //   child: const Text("OK"),
                      // ),
                      // TextButton(
                      //   onPressed: () {
                      //     // 处理确定按钮点击事件
                      //     Navigator.of(buildcontext).pop();
                      //     showBleDeviceOverlay(buildcontext, true);
                      //   },
                      //   child: const Text("Bluetooth Connect"),
                      // ),
                      TextBtn(
                        width: 500.w,
                        height: 113.h,
                        onPressed: () {
                          // 处理确定按钮点击事件
                          Navigator.of(buildcontext).pop();
                          showBleDeviceOverlay(buildcontext, true);
                        },
                        text: 'Bluetooth Connect',
                      ),
                    ],
                  )
                ],
              ),
            ));
      },
    );
  }

  void scrollToRow(int rowIndex) {
    const double rowHeight = 40.0; // Assuming the height of each row is 56.0
    _controller.animateTo(rowIndex * rowHeight,
        duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
  }

  void showPromptDialog(
      BuildContext context, String titleStr, List list, String type) {
    isShowDialog = true;
    if (isShowOverlay) {
      closeOverlay();
    }
    if (isWindowsOrMac) {
      isVisibleWebview.value = !isVisibleWebview.value;
      // setState(() {});
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
    if (!isRememberEffect.value) {
      // effectSelectedIndex.value = 0;
    }
    if (!isRememberPrompt.value) {
      // promptSelectedIndex.value = 0;
    }
    debugPrint(
        '11keyboardSelectedIndex=${keyboardSelectedIndex.value},promptSelectedIndex=${promptSelectedIndex.value}');
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          // 返回一个Dialog
          return Dialog(
              key: ValueKey(type),
              backgroundColor: Colors.transparent,
              child: SingleChildScrollView(
                  child: Container(
                key: ValueKey(type),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30.w)),
                  color: Colors.transparent,
                  image: const DecorationImage(
                    image: AssetImage(
                        'assets/images/backgroundbg.jpg'), // 替换为你的背景图片路径
                    fit: BoxFit.cover,
                  ),
                ),
                width: isWindowsOrMac ? 1400.w : 1200.w,
                padding: EdgeInsets.all(isWindowsOrMac ? 20.w : 20.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextTitle(
                          text: titleStr,
                        ),
                        InkWell(
                          child: Icon(
                            Icons.close,
                            size: 50.w,
                          ),
                          onTap: () {
                            // if (isWindowsOrMac) {
                            //   isVisibleWebview.value = !isVisibleWebview.value;
                            //   setState(() {});
                            // }
                            // Navigator.of(context).pop();
                            isShowDialog = false;
                            debugPrint(
                                'onChanged keyboardSelectedIndex close=${keyboardSelectedIndex.value}');
                            closeDialog();
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: isWindowsOrMac ? 40.h : 10.h,
                    ),
                    SizedBox(
                      height: isWindowsOrMac ? 600.h : 500.h,
                      child: ListView.builder(
                        controller: _controller,
                        itemCount: list.length,
                        itemBuilder: (BuildContext context, int index) {
                          // ListTile(title: Text(list[index]));
                          if (type == STORAGE_PROMPTS_SELECT &&
                              isRememberPrompt.value) {
                            promptSelectedIndex.value =
                                ConfigStore.to.getPromptsSelect();
                          } else if (type == STORAGE_SOUNDSEFFECT_SELECT &&
                              isRememberEffect.value) {
                            effectSelectedIndex.value =
                                ConfigStore.to.getSoundsEffectSelect();
                            if (effectSelectedIndex.value == -1) {
                              currentSoundEffect = list[0];
                            } else {
                              currentSoundEffect =
                                  list[effectSelectedIndex.value];
                            }
                          }
                          return Obx(() {
                            return SizedBox(
                              height: isWindowsOrMac ? 120.h : 100.h,
                              child: RadioListItem(
                                index: index,
                                isSelected: type == STORAGE_KEYBOARD_SELECT
                                    ? keyboardSelectedIndex.value == index
                                    : (type == STORAGE_PROMPTS_SELECT
                                        ? promptSelectedIndex.value == index
                                        : type == STORAGE_SOUNDSEFFECT_SELECT
                                            ? effectSelectedIndex.value == index
                                            : noteLengthSelectedIndex.value ==
                                                index),
                                // activeColor: AppColor.color_A1D632,
                                title: list[index],
                                // value: index,
                                // groupValue: type == STORAGE_KEYBOARD_SELECT
                                //     ? keyboardSelectedIndex.value
                                //     : (type == STORAGE_PROMPTS_SELECT
                                //         ? promptSelectedIndex.value
                                //         : type == STORAGE_SOUNDSEFFECT_SELECT
                                //             ? effectSelectedIndex.value
                                //             : noteLengthSelectedIndex.value),
                                onChanged: (value) {
                                  if (type == STORAGE_PROMPTS_SELECT) {
                                    promptSelectedIndex.value = value;
                                  } else if (type ==
                                      STORAGE_SOUNDSEFFECT_SELECT) {
                                    effectSelectedIndex.value = value;
                                  } else if (type == 'STORAGE_note_SELECT') {
                                    noteLengthSelectedIndex.value = value;
                                  } else if (type == STORAGE_KEYBOARD_SELECT) {
                                    keyboardSelectedIndex.value == value;
                                    debugPrint(
                                        'onChanged keyboardSelectedIndex=$value');
                                  }
                                  // isHideWebview.value = !isHideWebview.value;
                                  // setState(() {});
                                  if (type == STORAGE_PROMPTS_SELECT) {
                                    if (isRememberPrompt.value) {
                                      ConfigStore.to.savePromptsSelect(value);
                                    }
                                    presentPrompt = CommonUtils.escapeString(
                                        promptsAbc[value]);
                                  } else if (type ==
                                      STORAGE_SOUNDSEFFECT_SELECT) {
                                    midiProgramValue =
                                        soundEffectInt[list[index]]!;
                                    debugPrint(
                                        'midiProgramValue==$midiProgramValue');
                                    if (isRememberEffect.value) {
                                      ConfigStore.to
                                          .saveSoundsEffectSelect(value);
                                      ConfigStore.to.saveMidiProgramSelect(
                                          midiProgramValue);
                                    }
                                    currentSoundEffect =
                                        list[effectSelectedIndex.value];
                                  } else if (type == STORAGE_KEYBOARD_SELECT) {
                                    if (index == 0) {
                                      //切换虚拟键盘
                                      closeDialog();
                                    } else if (index == 1) {
                                      //切换midi键盘，先判断有没有连接上
                                      debugPrint('deviceId==$connectDeviceId');
                                      Navigator.of(context).pop();
                                      if (connectDeviceId == null) {
                                        showConnectDialog(context);
                                      } else {
                                        debugPrint('onConnectionChanged');
                                        if (isWindowsOrMac) {
                                          isVisibleWebview.value = true;
                                          // setState(() {});
                                        }
                                        UniversalBle.connect(connectDeviceId!);
                                        UniversalBle.onConnectionChanged =
                                            (String deviceId,
                                                BleConnectionState state) {
                                          print(
                                              'OnConnectionChanged $deviceId, $state');
                                          if (state ==
                                              BleConnectionState.connected) {
                                            if (isWindowsOrMac) {
                                              Get.snackbar('提示', 'midi键盘已连接',
                                                  colorText: Colors.black);
                                            } else {
                                              toastInfo(msg: 'midi键盘已连接');
                                            }
                                          } else {
                                            showConnectDialog(context);
                                          }
                                        };
                                      }
                                      // toastInfo(msg: 'Midi device connected');
                                    }
                                  } else if (type == 'STORAGE_note_SELECT') {
                                    print('STORAGE_note_SELECT');
                                    updateNote(
                                        int.parse(currentClickNoteInfo[1]),
                                        index,
                                        currentClickNoteInfo[0].toString());
                                  }
                                  if (type == STORAGE_PROMPTS_SELECT) {
                                    resetPianoAndKeyboard();
                                    int subindex = presentPrompt.indexOf('L:');
                                    String subpresentPrompt =
                                        presentPrompt.substring(subindex);
                                    String abcstr = subpresentPrompt;
                                    if (selectstate.value == 0) {
                                      abcstr = ABCHead.getABCWithInstrument(
                                          subpresentPrompt, midiProgramValue);
                                    } else {
                                      abcstr = ABCHead.getABCWithInstrument(
                                          createPrompt, midiProgramValue);
                                    }
                                    abcstr = ABCHead.appendTempoParam(
                                        abcstr, tempo.value.toInt());
                                    if (selectstate.value == 0) {
                                      finalabcStringPreset =
                                          "setAbcString(\"$abcstr\",false)";

                                      controllerPiano
                                          .runJavaScript(finalabcStringPreset);
                                      debugPrint(
                                          'finalabcStringPreset=$finalabcStringPreset');
                                    } else {
                                      finalabcStringCreate =
                                          "setAbcString(\"$abcstr\",false)";
                                      controllerPiano
                                          .runJavaScript(finalabcStringCreate);
                                      debugPrint(
                                          'finalabcStringCreate=$finalabcStringCreate');
                                    }
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      // if (!isWindowsOrMac) {
                                      //   controllerKeyboard
                                      //       .runJavaScript('clearAll()');
                                      //   controllerKeyboard
                                      //       .runJavaScript('resetPlay()');
                                      // }
                                      playOrPausePiano();
                                    });
                                    if (isWindowsOrMac) {
                                      closeDialog();
                                    }
                                  } else if (type ==
                                      STORAGE_SOUNDSEFFECT_SELECT) {
                                    // if (isPlay.value == false) {
                                    //   controllerPiano.runJavaScript("resetPage()");
                                    //   if (selectstate.value == 0) {
                                    //     controllerKeyboard.loadFlutterAssetServer(
                                    //         filePathKeyboardAnimation);
                                    //   }
                                    // }
                                    resetPianoAndKeyboard();
                                    debugPrint(
                                        '选择midiProgramValue==$midiProgramValue');
                                    String modifyABCWithInstrument =
                                        ABCHead.modifyABCWithInstrument(
                                            selectstate.value == 0
                                                ? finalabcStringPreset
                                                : finalabcStringCreate,
                                            midiProgramValue);
                                    debugPrint(
                                        'modifyABCWithInstrument==$modifyABCWithInstrument');
                                    if (selectstate.value == 0) {
                                      finalabcStringPreset =
                                          modifyABCWithInstrument;
                                      controllerPiano.runJavaScript(
                                          ABCHead.base64AbcString(
                                              finalabcStringPreset));
                                    } else {
                                      finalabcStringCreate =
                                          modifyABCWithInstrument;
                                      controllerPiano.runJavaScript(
                                          ABCHead.base64AbcString(
                                              finalabcStringCreate));
                                    }
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      // if (!isWindowsOrMac) {
                                      //   controllerKeyboard
                                      //       .runJavaScript('clearAll()');
                                      //   controllerKeyboard
                                      //       .runJavaScript('resetPlay()');
                                      // }
                                      playPianoAnimation(
                                          selectstate.value == 0
                                              ? finalabcStringPreset
                                              : finalabcStringCreate,
                                          true);
                                    });
                                    if (isWindowsOrMac) {
                                      closeDialog();
                                    }
                                  }
                                },
                              ),
                            );
                          });
                        },
                      ),
                    ),
                    if (type != STORAGE_KEYBOARD_SELECT)
                      SizedBox(
                        height: 40.h,
                      ),
                    if (type != STORAGE_KEYBOARD_SELECT) const ContainerLine(),
                    if (type != STORAGE_KEYBOARD_SELECT)
                      SizedBox(
                        height: 40.h,
                      ),
                    if (type != STORAGE_KEYBOARD_SELECT)
                      Obx(
                        () => CheckBoxItem(
                          title: 'Remember Last Option',
                          isSelected: type == STORAGE_PROMPTS_SELECT
                              ? isRememberPrompt.value
                              : isRememberEffect.value,
                          onChanged: (bool value) {
                            if (type == STORAGE_PROMPTS_SELECT) {
                              isRememberPrompt.value = value;
                              ConfigStore.to.saveRemberPromptSelect(value);
                            } else {
                              isRememberEffect.value = value;
                              ConfigStore.to.saveRemberEffectSelect(value);
                            }
                          },
                        ),
                      ),
                    // if (type == STORAGE_PROMPTS_SELECT)
                    //   Obx(
                    //     () => ListTile(
                    //       leading: Checkbox(
                    //         value: isAutoSwitch.value,
                    //         onChanged: (bool? value) {
                    //           isAutoSwitch.value = value!;
                    //           ConfigStore.to.saveAutoNext(value);
                    //         },
                    //       ),
                    //       title: Transform.translate(
                    //         offset: const Offset(-20, 0), // 向左移动文本以减少间距
                    //         child: const Text('Auto Switch Next Prompt'),
                    //       ),
                    //       onTap: () {},
                    //     ),
                    //   ),
                  ],
                ),
              )));
        });
    Future.delayed(const Duration(milliseconds: 100)).then((value) {
      if (type == STORAGE_PROMPTS_SELECT) {
        scrollToRow(promptSelectedIndex.value);
      } else {
        scrollToRow(effectSelectedIndex.value);
      }
    });
  }

  void closeDialog() {
    isShowDialog = false;
    UniversalBle.stopScan();
    if (isWindowsOrMac) {
      // setState(() {
      isVisibleWebview.value = true;
      // });
    }
    Navigator.of(context).pop();
    if (overlayEntry != null) {
      overlayEntry!.remove();
      isShowOverlay = false;
    }
  }

  void showBleDeviceOverlay(BuildContext context, bool isVisible) async {
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
        right: 0.0,
        left: 0.0,
        child: Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Container(
                height:
                    !isVisible ? 600.h : 600.h, //!isVisible ? 600.h : 1300.h
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30.w)),
                  // color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/${isVisible ? 'backgroundbg.jpg' : 'backgroundbg.jpg'}'), //isVisible ? 'dialogbg.png' : 'backgroundbg.jpg'
                    fit: BoxFit.cover,
                  ),
                ),
                padding: const EdgeInsets.all(10),
                // color: Colors.white,
                child: Column(
                  children: [
                    if (isVisible)
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: isWindowsOrMac ? 26.w : 16.w,
                            vertical: isWindowsOrMac ? 25.h : 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextTitle(
                              text: 'Bluetooth Connect',
                            ),
                            InkWell(
                              child: Icon(
                                Icons.close,
                                size: 50.w,
                              ),
                              onTap: () {
                                isShowDialog = false;
                                if (isVisible) {
                                  closeOverlay();
                                } else {
                                  closeDialog();
                                }
                              },
                            )
                          ],
                        ),
                      ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                        child: Obx(() => ListView.builder(
                              itemCount: bleList.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    debugPrint('stopScanstopScan');
                                    if (isWindowsOrMac) {
                                      isVisibleWebview.value = isVisible;
                                      // setState(() {});
                                    }
                                    UniversalBle.stopScan();
                                    debugPrint(
                                        'isVisibleWebview.value = $isVisible');
                                    conectDevice(bleList[index]);
                                    overlayEntry!.remove();
                                    isShowOverlay = false;
                                  },
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          bleList[index].name!,
                                          style: TextStyle(
                                            color: AppColor.color_999999,
                                            fontSize: 45.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        Text(
                                          bleList[index].deviceId,
                                          style: TextStyle(
                                            color: AppColor.color_757575,
                                            fontSize: 35.sp,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                      ]),
                                );
                              },
                            )))
                  ],
                ),
              ),
            )),
      ),
    );

    // 插入Overlay
    Overlay.of(context).insert(overlayEntry!);
    isShowOverlay = true;
    // // 假设我们想在3秒后自动移除浮层
    // Future.delayed(const Duration(seconds: 3)).then((value) {
    //   overlayEntry.remove();
    // });
  }

  void closeOverlay() {
    isShowDialog = false;
    UniversalBle.stopScan();
    if (isWindowsOrMac) {
      // setState(() {
      isVisibleWebview.value = true;
      // });
    }
    if (overlayEntry != null) {
      overlayEntry!.remove();
      isShowOverlay = false;
    }
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
    UniversalBle.connect(device.deviceId);
    UniversalBle.onConnectionChanged =
        (String deviceId, BleConnectionState state) async {
      debugPrint('OnConnectionChanged $deviceId, $state');
      if (state == BleConnectionState.connected) {
        connectDeviceId = device.deviceId;
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
              if (selectstate.value == 0) {
                return;
              }
              Uint8List sublist = value.sublist(2);
              debugPrint(
                  'onValueChanged $deviceId, $characteristicId, $sublist');
              var result = convertABC.midiToABC(sublist, false);
              debugPrint('convertdata=$result');
              if ((result[0] as String).isNotEmpty) {
                String path = convertABC.getNoteMp3Path(result[1]);
                updatePianoNote(result[1]);
                playNoteMp3(path);
                // if (isWindowsOrMac) {
                //   AudioPlayerManage().playAudio(
                //       'player/soundfont/acoustic_grand_piano-mp3/$path');
                // } else {
                //   JustAudioPlayerManage().playAudio(
                //       'player/soundfont/acoustic_grand_piano-mp3/$path');
                // }
              }
            };
          }
        }
        // Future.delayed(const Duration(seconds: 3)).then((value) {
        //   closeDialog();
        // });
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

  void bottomsheetsetting() {
    // 弹出底部面板
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 3100.h,
          color: Colors.white,
          child: const Text(
            'This is a Bottom Sheet',
            style: TextStyle(fontSize: 20),
          ),
        );
      },
    );
  }
}
