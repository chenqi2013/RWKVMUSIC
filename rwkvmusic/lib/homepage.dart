import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_installer/app_installer.dart';
import 'package:crypto/crypto.dart';
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rwkvmusic/agree_dialog.dart';
import 'package:rwkvmusic/feedback_page.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/mainwidget/custom_segment_controller.dart';
import 'package:rwkvmusic/mainwidget/play_progressbar.dart';
import 'package:rwkvmusic/mainwidget/checkbox_item.dart';
import 'package:rwkvmusic/mainwidget/container_line.dart';
import 'package:rwkvmusic/mainwidget/container_textfield.dart';
import 'package:rwkvmusic/mainwidget/drop_button_down.dart';
import 'package:rwkvmusic/mainwidget/radio_list_item.dart';
import 'package:rwkvmusic/mainwidget/switch_item.dart';
import 'package:rwkvmusic/mainwidget/text_btn.dart';
import 'package:rwkvmusic/mainwidget/text_item.dart';
import 'package:rwkvmusic/mainwidget/text_title.dart';
import 'package:rwkvmusic/note_length.dart';
import 'package:rwkvmusic/state.dart';
import 'package:rwkvmusic/store/config.dart';
import 'package:rwkvmusic/style/color.dart';
import 'package:rwkvmusic/style/style.dart';
import 'package:rwkvmusic/transpose.dart';
import 'package:rwkvmusic/utils/abchead.dart';
import 'package:rwkvmusic/utils/audioplayer.dart';
import 'package:rwkvmusic/utils/automeasure_randomizeabc.dart';
import 'package:rwkvmusic/utils/chord_util.dart';
import 'package:rwkvmusic/utils/convert_chord.dart';
import 'package:rwkvmusic/utils/justaudioplayer.dart';
import 'package:rwkvmusic/utils/midiconvert_abc.dart';
import 'package:rwkvmusic/utils/mididevice_manage.dart';
import 'package:rwkvmusic/utils/common_utils.dart';
import 'package:rwkvmusic/utils/midifile_convert.dart';
import 'package:rwkvmusic/utils/note.dart';
import 'package:rwkvmusic/utils/note_calculator.dart';
import 'package:rwkvmusic/utils/notes_database.dart';
import 'package:rwkvmusic/utils/randomGroove.dart';
import 'package:rwkvmusic/values/values.dart';
import 'package:rwkvmusic/widgets/change_note.dart';
import 'package:rwkvmusic/widgets/chord_editing.dart';
import 'package:rwkvmusic/widgets/time_changing.dart';
import 'package:rwkvmusic/widgets/toast.dart';
import 'package:universal_ble/universal_ble.dart';

import 'mainwidget/border_bottom_btn.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
// import 'package:flutter_gen_runner/flutter_gen_runner.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:share_extend/share_extend.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

final List<String> history = [];
final List<List> virtualNotesHistory = [];
final List<List<int>> intNodesHistory = [];
RxDouble downloadProgress = 0.0.obs;
RxBool isdownloading = false.obs;

class _HomePageState extends State<HomePage> {
  /// 键盘 webview 控制器
  late WebViewControllerPlus controllerKeyboard;
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

  String? currentSoundEffect;
  late MidiDeviceManage deviceManage;
  late String abcString;
  var isVisibleWebview = true.obs;
  String? exportMidiStr; //导出midi需要的字符串数据
  @override
  void initState() {
    super.initState();
    midiProgramValue = ConfigStore.to.getMidiProgramSelect();
    isRememberPrompt.value = ConfigStore.to.getRemberPromptSelect();
    isRememberEffect.value = ConfigStore.to.getRemberEffectSelect();
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
    deviceManage.receiveCallback = (int data) {
      debugPrint('receiveCallback main =$data');
      updatePianoNote(data);
    };
    controllerPiano = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            // controllerPiano.onLoaded((msg) {
            //   controllerPiano.getWebViewHeight().then((value) {});
            // });
          },
          onPageFinished: (url) {
            debugPrint("controllerPiano onPageFinished$url");
            int index = ConfigStore.to.getPromptsSelect();
            if (index < 0) {
              index = 0;
            }

            presentPrompt = CommonUtils.escapeString(promptsAbc[index]);
            int subindex = presentPrompt.indexOf('L:');
            String subpresentPrompt = presentPrompt.substring(subindex);
            debugPrint('load presentPrompt=$presentPrompt');
            finalabcStringPreset =
                "setAbcString(\"${ABCHead.getABCWithInstrument(subpresentPrompt, midiProgramValue)}\",false)";
            finalabcStringPreset = ABCHead.appendTempoParam(
                finalabcStringPreset, tempo.value.toInt());

            _change(finalabcStringPreset);
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
      ..addJavaScriptChannel("flutteronMidiExport",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        exportMidiStr = jsMessage.message;
        // debugPrint('flutteronMidiExport onMessageReceived=$exportMidiStr');
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

        //生成midi数据
        String abc = selectstate.value == 0
            ? finalabcStringPreset
            : finalabcStringCreate;
        String result =
            abc.replaceAll('setAbcString("', '').replaceAll('",false)', '');
        result = result.replaceAll(r'\"', '"');
        result = result.replaceAll('\\n', '\n');
        // debugPrint('result==>>>>$result');
        abc = base64.encode(utf8.encode(result));
        controllerPiano.runJavaScript("exportMidiFile('$abc')");
      })
      ..addJavaScriptChannel("flutteronPlayFinish",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        debugPrint(
            'flutteronPlayFinish onMessageReceived=${jsMessage.message}');
        isPlay.value = false;
        isFinishABCEvent = false;
        if (!isWindowsOrMac) {
          resetPianoAndKeyboard();
          debugPrint('resetPianoAndKeyboard');
        }
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
          onMessageReceived: _onClickNote)
      ..addJavaScriptChannel("flutterOnClickTime",
          onMessageReceived: (JavaScriptMessage javaScriptMessage) {
        _showTimeChangingDialog();
      })
      ..addJavaScriptChannel("flutterOnTapEmpty",
          onMessageReceived: _flutterOnTapEmptyReceived)
      ..addJavaScriptChannel("flutterOnClickChord",
          onMessageReceived: _onReceiveChordClick);

    controllerKeyboard = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            // controllerKeyboard.onLoaded((msg) {
            //   controllerKeyboard.getWebViewHeight().then((value) {});
            // });
          },
          onPageFinished: (url) {
            debugPrint("controllerKeyboard onPageFinished$url");
            controllerKeyboard.runJavaScript('resetPlay()');
            controllerKeyboard.runJavaScript('setPiano(55, 76)');
            if (selectstate.value == 1) {
              controllerKeyboard.runJavaScript('setPiano(21, 108)');
            }
          },
        ),
      )
      ..addJavaScriptChannel("flutteronNoteOff",
          onMessageReceived: (JavaScriptMessage jsMessage) {
        debugPrint('flutteronNoteOff onMessageReceived=${jsMessage.message}');
      })
      // 按下 webview 中的琴键
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
        _change(ABCHead.base64AbcString(event));
        // debugPrint('base64abctoEvents==$base64abctoEvents');
        // controllerPiano.runJavaScript(event);
      }
    });
    if (isOnlyLoadFastModel && modelAddress == 0) {
      fetchABCDataByIsolate();
    }
    if (Platform.isAndroid) {
      checkAppUpdate('android', context);
    }

    if (Platform.isIOS || Platform.isAndroid) {
      if (!ConfigStore.to.isFirstOpen) {
        debugPrint('isFirstOpen');
        Future.delayed(const Duration(milliseconds: 1000), () {
          showAgreementDialog(context);
        });
      }
    }
  }

  /// 更改当前琴谱的 abc notation value
  ///
  /// 预设：这个过程一定调用了 setAbcString 这个函数
  Future<void> _change(String javaScript) async {
    try {
      await controllerPiano.runJavaScript(javaScript);
      if (selectstate.value == 1) {
        assert(javaScript.startsWith("setAbcString"));
        history.add(javaScript);
        virtualNotesHistory.add([...virtualNotes]);
        intNodesHistory.add([...intNodes]);
      }
      selectedNote.value = null;
    } catch (e) {
      // JS 是有可能执行出错的
      if (kDebugMode) print("😡 $e");
    }
  }

  Future<void> _unselectAll() async {
    if (selectstate.value != 1) return;
    selectedNote.value = null;
    await controllerPiano.runJavaScript("unselectAll()");
  }

  /// 使当前琴谱的 abc notation value 变为上一步的 abc notation value
  void _undo() async {
    if (selectstate.value != 1) return;
    if (isCreateGenerate.value) {
      if (!isGenerating.value) {
        isCreateGenerate.value = false;
        segmentChange(1);
      } else {
        debugPrint('需要先停止生成再暫停');
      }
      return;
    }
    if (history.isEmpty ||
        virtualNotesHistory.isEmpty ||
        intNodesHistory.isEmpty) return;

    final historyLength = history.length;
    final virtualNotesHistoryLength = virtualNotesHistory.length;
    final intNodesHistoryLength = intNodesHistory.length;

    // 因为上一步的添加过程是相等的

    assert(historyLength == virtualNotesHistoryLength);
    assert(virtualNotesHistoryLength == intNodesHistoryLength);
    assert(intNodesHistoryLength == historyLength);

    if (historyLength == 1) return;

    try {
      final historyStep = history[history.length - 2];
      final virtualNotesStep =
          virtualNotesHistory[virtualNotesHistory.length - 2];
      final intNodesStep = intNodesHistory[intNodesHistory.length - 2];
      await controllerPiano.runJavaScript(historyStep);
      history.removeLast();
      virtualNotes = [...virtualNotesStep];
      virtualNotesHistory.removeLast();
      intNodes = [...intNodesStep];
      intNodesHistory.removeLast();
    } catch (e) {
      // JS 是有可能执行出错的
      if (kDebugMode) print("😡 $e");
    }
  }

  void _onClickNote(JavaScriptMessage jsMessage) {
    final json = jsonDecode(jsMessage.message);

    String name = json["name"];
    if (name.contains("rest")) name = "z";
    if (name.contains("dots.dot")) name = "z";
    final duration = json["duration"] as num;
    final noteLength = noteLengthFromLength(duration);

    final _s = selectedNote.value;
    if (_s != null) {
      final isSameNote = _s.name == name &&
          _s.index == int.parse(json["index"]) &&
          _s.length == noteLength;
      if (isSameNote) {
        selectedNote.value = null;
        _unselectAll();
        return;
      }
    }

    // if (kDebugMode) print("✅ $");

    final index = int.parse(json["index"]);

    if (kDebugMode) print("✅ Note selected:");
    if (kDebugMode) print("✅ name: $name");
    if (kDebugMode) print("✅ index: $index");
    if (kDebugMode) print("✅ duration: $duration");
    if (kDebugMode) print("✅ noteLength: $noteLength");

    selectedNote.value = NewNote()
      ..name = name
      ..index = index
      ..length = noteLength;
  }

  /// 和弦点击
  void _onReceiveChordClick(JavaScriptMessage jsMessage) async {
    final _selectstate = selectstate.value;
    final _isPlay = isPlay.value;
    if (_selectstate != 1 || _isPlay) return;

    isShowDialog = true;
    if (isShowOverlay) closeOverlay();
    if (isWindowsOrMac) isVisibleWebview.value = !isVisibleWebview.value;

    final json = jsonDecode(jsMessage.message);

    final regExp = RegExp(r'\|\\"[ABCDEFGdim#7]+\\"');
    final matches = regExp.allMatches(finalabcStringCreate).toList();
    if (matches.isEmpty) return;
    final index = int.parse(json["index"]) ~/ 4;
    final m = matches[index];
    final text = finalabcStringCreate.substring(m.start + 3, m.end - 2);
    final r = calculateRootAndType(text);
    selectedChordRoot.value = r.$1;
    selectedChordType.value = r.$2;

    final ok = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return const ChordEditing();
        });

    _unselectAll();

    isShowDialog = false;
    if (ok == null) return;

    final newChord = selectedChordRoot.value.abcNotationValue +
        selectedChordType.value.abcNotationValue;
    finalabcStringCreate =
        finalabcStringCreate.replaceRange(m.start + 3, m.end - 2, newChord);
    await _change(finalabcStringCreate);
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

  void _updateDottod() async {
    final selected = selectedNote.value;
    if (selected == null) {
      if (kDebugMode) print("😡 No selected note when update dotted");
      // if (virtualNotes.isEmpty) return;
      // String name = "";
      // final last = virtualNotes.last as String;
      // if (last.startsWith("^")) {
      //   name = last.substring(0, 2);
      // } else {
      //   name = last.substring(0, 1);
      // }
      // selectedNote = SelectedNote()
      //   ..index = virtualNotes.length - 1
      //   ..name = name
      //   ..duration = SelectedNote.durationFromString(last);
      // _updateDottod();
      return;
    }
    // final note = selected.name;
    final noteIndex = selected.index;
    final newNote = selected.notationWithDotted(!selected.length.dotted);
    NoteCalculator().noteMap[noteIndex] = newNote;
    virtualNotes[noteIndex] = newNote;
    StringBuffer sbff = StringBuffer();
    for (String note in virtualNotes) {
      sbff.write(note);
      sbff.write(" ");
    }
    createPrompt = sbff.toString();
    String splitMeasureAndChordStr = splitMeasureAndChord(createPrompt);
    createPrompt = splitMeasureAndChordStr.replaceAll("\\n", "\n");
    String sb =
        "setAbcString(\"%%MIDI program $midiProgramValue\\n$splitMeasureAndChordStr\",false)";
    finalabcStringCreate = ABCHead.appendTempoParam(sb, tempo.value.toInt());
    debugPrint('curr=$finalabcStringCreate');
    await _change(finalabcStringCreate);
    selectedNote.value = null;
  }

  /// 通过执行 JS 更新琴谱
  ///
  /// TDOO: check selected note's dotted
  void _updateNote({
    NoteLength? noteLength,
    String? noteSymbol,
  }) async {
    final selected = selectedNote.value;
    if (selected == null) {
      if (kDebugMode) print("😡 No selected note when update note");
      // if (virtualNotes.isEmpty) return;
      // late final String name;

      // if (noteSymbol != null) {
      //   name = noteSymbol;
      // } else {
      //   final last = virtualNotes.last as String;
      //   if (last.startsWith("^")) {
      //     name = last.substring(0, 2);
      //   } else {
      //     name = last.substring(0, 1);
      //   }
      // }

      // final _selectedNote = SelectedNote()
      //   ..index = virtualNotes.length - 1
      //   ..name = name;
      // selectedNote = _selectedNote;
      // _updateNote(noteLengthIndex: noteLengthIndex);
      return;
    }
    final note = noteSymbol ?? selected.name;
    final noteIndex = selected.index;
    final inputDotted = inputNoteLength.value.dotted;
    noteLength ??= selected.length;
    String newNote = note + noteLength.withDotted(inputDotted).end;
    NoteCalculator().noteMap[noteIndex] = newNote;
    virtualNotes[noteIndex] = newNote;
    StringBuffer sbff = StringBuffer();
    for (String note in virtualNotes) {
      sbff.write(note);
      sbff.write(" ");
    }
    createPrompt = sbff.toString();
    String splitMeasureAndChordStr = splitMeasureAndChord(createPrompt);
    createPrompt = splitMeasureAndChordStr.replaceAll("\\n", "\n");
    String sb =
        "setAbcString(\"%%MIDI program $midiProgramValue\\n$splitMeasureAndChordStr\",false)";
    finalabcStringCreate = ABCHead.appendTempoParam(sb, tempo.value.toInt());
    debugPrint('curr=$finalabcStringCreate');
    await _change(finalabcStringCreate);
    selectedNote.value = null;
  }

  /// 插入休止符
  void _inserOrUpdatetRest(NoteLength noteLength) async {
    if (selectedNote.value != null) {
      _updateNote(noteLength: noteLength, noteSymbol: "z");
      return;
    }
    const node = 24;
    String noteName = "z";
    final _inputNoteLength = inputNoteLength.value;
    final inputDotted = _inputNoteLength.dotted;
    noteName = noteName + noteLength.withDotted(inputDotted).end;
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
    final _noteLength = noteLengthFromString(noteName);

    for (int i = 0; i < virtualNotes.length; i++) {
      String note = virtualNotes[i];
      if (timeSignatureStr == '4/4' && _noteLength == NoteLength.quarter) {
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
            ABCHead.insertMeasureLinePosition(timeSignatureStr, _noteLength);
        if (i % postion == 0 && i > 0) {
          sbff.write('|');
        }
      }
      sbff.write(note);
      sbff.write(" ");
    }
    createPrompt = sbff.toString();
    String splitMeasureAndChordStr = splitMeasureAndChord(createPrompt);
    createPrompt = splitMeasureAndChordStr.replaceAll("\\n", "\n");
    String sb;
    if (isChangeTempo) {
      sb =
          "setAbcString(\"Q:1/4=${tempo.value.toInt()}\\n$splitMeasureAndChordStr\",false)";
    } else {
      sb =
          "setAbcString(\"%%MIDI program $midiProgramValue\\n$splitMeasureAndChordStr\",false)";
    }
    finalabcStringCreate = ABCHead.appendTempoParam(sb, tempo.value.toInt());
    debugPrint('curr=$finalabcStringCreate');
    await _change(finalabcStringCreate);
    selectedNote.value = null;
  }

  /// 插入音符
  ///
  /// 1. 通过按下虚拟键盘触发
  void updatePianoNote(int node) async {
    String noteName = MidiToABCConverter().getNoteName(node);

    final selected = selectedNote.value;
    if (selected != null) {
      _updateNote(noteSymbol: noteName);
      selectedNote.value = null;
      return;
    }

    final noteLength = inputNoteLength.value;
    noteName = noteName + noteLength.end;

    // sbNoteCreate.write(noteName);
    virtualNotes.add(noteName);
    intNodes.add(node);

    StringBuffer sbff = StringBuffer();

    for (int i = 0; i < virtualNotes.length; i++) {
      String note = virtualNotes[i];
      sbff.write(note);
      sbff.write(" ");
    }

    createPrompt = sbff.toString();
    String splitMeasureAndChordStr = splitMeasureAndChord(createPrompt);
    createPrompt = splitMeasureAndChordStr.replaceAll("\\n", "\n");
    String sb;
    if (isChangeTempo) {
      sb =
          "setAbcString(\"Q:1/4=${tempo.value.toInt()}\\n$splitMeasureAndChordStr\",false)";
    } else {
      sb =
          "setAbcString(\"%%MIDI program $midiProgramValue\\n$splitMeasureAndChordStr\",false)";
    }
    finalabcStringCreate = ABCHead.appendTempoParam(sb, tempo.value.toInt());
    await _change(finalabcStringCreate);
  }

  /// 自动分割及生成和弦
  String splitMeasureAndChord(String createPrompt) {
    // // 自动分割小节
    String needSplitStr = 'L:1/4\\nM:$timeSingnatureStr\\nK:C\\n|$createPrompt'
        .replaceAll("\\n", "\n");
    // ABCHead.testchord_split(needSplitStr);
    splitMeasure = splitMeasureAbc(needSplitStr);
    print('splitMeasureAbcStr---$splitMeasure');
    // 每一节生成一个和弦
    chords = generateChordAbcNotation(splitMeasure!);
    print('generateChordAbcNotation---$chords');
    String combineabcChord = ABCHead.combineAbc_Chord(chords[0], splitMeasure!);
    print('combineAbc_Chord---$combineabcChord');
    needSplitStr = combineabcChord.replaceAll("\n", "\\n");
    return needSplitStr;
  }

  void updateTimeSignature() {
    // setAbcString("%%MIDI program 0\nL:1/4\nM:4/4\nK:C\n|",false)
    int index = createPrompt.indexOf('|');
    String createPromptTmp = createPrompt.substring(index + 1);
    String sb =
        "setAbcString(\"%%MIDI program $midiProgramValue\\nL:1/4\\nM:$timeSingnatureStr\\nK:C\\n|$createPromptTmp\",false)";
    sb = ABCHead.appendTempoParam(sb, tempo.value.toInt());
    debugPrint('curr=$sb');
    _change(sb);
  }

  void _delete() {
    resetLastNote();
  }

  void _randomizeAbc() async {
    if (virtualNotes.isEmpty || intNodes.isEmpty) {
      Fluttertoast.showToast(msg: "Please play some notes before randomizing.");
      return;
    }
    // createPrompt = "L:1/4\nM:3/8\nK:C\n e a c' e' d' c' b c' a ^g";
    // String randomizeAbcStr = randomizeAbc(createPrompt);
    String randomizeAbcStr = await randomizeNoteLengths(createPrompt);
    debugPrint('chenqi randomizeAbcStr==$randomizeAbcStr');
    String createPromptTmp = randomizeAbcStr.replaceAll("\n", "\\n");

    String sb =
        "setAbcString(\"%%MIDI program $midiProgramValue\\n$createPromptTmp\",false)";
    _change(sb);
    selectedNote.value = null;
    int index = randomizeAbcStr.indexOf('|');
    String promptStr = randomizeAbcStr.substring(index + 1);
    splitMeasureAndChord(promptStr);
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

    if (virtualNotes.isEmpty) return;

    virtualNotes.removeLast();
    intNodes.removeLast();

    if (virtualNotes.isEmpty) {
      finalabcStringCreate =
          "setAbcString(\"${ABCHead.getABCWithInstrument('L:1/4\nM:$timeSingnatureStr\nK:C\n|', midiProgramValue)}\",false)";
      finalabcStringCreate =
          ABCHead.appendTempoParam(finalabcStringCreate, tempo.value.toInt());
      debugPrint('str112==$finalabcStringCreate');
      _change(ABCHead.base64AbcString(finalabcStringCreate));
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
      final noteLength = inputNoteLength.value;
      for (int i = 0; i < virtualNotes.length; i++) {
        String note = virtualNotes[i];
        if (timeSignatureStr == '4/4' && noteLength == NoteLength.quarter) {
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
              ABCHead.insertMeasureLinePosition(timeSignatureStr, noteLength);
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
      _change(sb);
      createPrompt = sbff.toString();
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
        String base64abctoEvents = ABCHead.base64abctoEvents(
            ABCHead.appendTempoParam(playAbcString, tempo.value.toInt()));
        _change(base64abctoEvents);
        debugPrint('playOrPausePiano base64abctoEvents==$base64abctoEvents');
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
        body: GestureDetector(
          onTap: () {
            _unselectAll();
          },
          child: Container(
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
                        SizedBox(
                          width: isWindowsOrMac ? 605.w : 535.w,
                          height: isWindowsOrMac ? 123.h : 104.h,
                          child: CustomSegmentControl(
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
                        Row(
                          children: [
                            Obx(
                              () => selectstate.value == 0
                                  ? BorderBottomBtn(
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
                                  : BorderBottomBtn(
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
                            SizedBox(
                              width: 55.w,
                            ),
                            Obx(
                              () => BorderBottomBtn(
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
                            ),
                            SizedBox(
                              width: 55.w,
                            ),
                            BorderBottomBtn(
                              width: isWindowsOrMac ? 123.h : 96.h,
                              height: isWindowsOrMac ? 123.h : 96.h,
                              text: '',
                              icon: SvgPicture.asset(
                                'assets/images/ic_setting.svg',
                                width: isWindowsOrMac ? 61.w : 52.w,
                                height: isWindowsOrMac ? 61.h : 52.h,
                              ),
                              onPressed: () {
                                debugPrint('Settings');
                                // String result = transposeAbc(
                                //     "X:1\nL:1/4\nK:C\nE,,1/2 =F,, ^G, a/ ^f' g",
                                //     7);
                                // debugPrint('transposeAbc==$result');
                                // result = splitMeasureAbc(result);
                                // debugPrint('splitMeasureAbc==$result');
                                if (isShowOverlay) {
                                  closeOverlay();
                                }
                                if (isWindowsOrMac) {
                                  isVisibleWebview.value =
                                      !isVisibleWebview.value;
                                  // setState(() {});
                                }

                                if (selectstate.value == 0) {
                                  showSettingDialog(context);
                                } else {
                                  showCreateModelSettingDialog(context);
                                }
                              },
                            ),
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
                Obx(() {
                  return Visibility(
                    visible: selectstate.value == 1,
                    child: SizedBox(height: isWindowsOrMac ? 33.h : 15.h),
                  );
                }),
                Obx(() {
                  return Visibility(
                    visible: selectstate.value == 1,
                    child: ChangeNote(
                      onTapAtIndex: (context, key) {
                        final v = inputNoteLength.value;
                        final selected = selectedNote.value;
                        final noteSelected = selected != null;
                        switch (key) {
                          case ChangeNoteKey.whole:
                            if (noteSelected) {
                              _updateNote(noteLength: NoteLength.whole);
                            }
                            if (!noteSelected) {
                              inputNoteLength.value =
                                  NoteLength.whole.withDotted(v.dotted);
                            }
                            break;
                          case ChangeNoteKey.half:
                            if (noteSelected) {
                              _updateNote(noteLength: NoteLength.half);
                            }
                            if (!noteSelected) {
                              inputNoteLength.value =
                                  NoteLength.half.withDotted(v.dotted);
                            }
                            break;
                          case ChangeNoteKey.quarter:
                            if (noteSelected) {
                              _updateNote(noteLength: NoteLength.quarter);
                            }
                            if (!noteSelected) {
                              inputNoteLength.value =
                                  NoteLength.quarter.withDotted(v.dotted);
                            }
                            break;
                          case ChangeNoteKey.eighth:
                            if (noteSelected) {
                              _updateNote(noteLength: NoteLength.eighth);
                            }
                            if (!noteSelected) {
                              inputNoteLength.value =
                                  NoteLength.eighth.withDotted(v.dotted);
                            }
                            break;
                          case ChangeNoteKey.sixteenth:
                            if (noteSelected) {
                              _updateNote(noteLength: NoteLength.sixteenth);
                            }
                            if (!noteSelected) {
                              inputNoteLength.value =
                                  NoteLength.sixteenth.withDotted(v.dotted);
                            }
                            break;
                          case ChangeNoteKey.thirtySecond:
                            if (noteSelected) {
                              _updateNote(noteLength: NoteLength.thirtySecond);
                            }
                            if (!noteSelected) {
                              inputNoteLength.value =
                                  NoteLength.thirtySecond.withDotted(v.dotted);
                            }
                            break;
                          case ChangeNoteKey.dottodNote:
                            if (noteSelected) _updateDottod();
                            if (!noteSelected) {
                              inputNoteLength.value = v.withDotted(!v.dotted);
                            }
                            break;
                          case ChangeNoteKey.wholeZ:
                            _inserOrUpdatetRest(NoteLength.whole);
                            break;
                          case ChangeNoteKey.halfZ:
                            _inserOrUpdatetRest(NoteLength.half);
                            break;
                          case ChangeNoteKey.quarterZ:
                            _inserOrUpdatetRest(NoteLength.quarter);
                            break;
                          case ChangeNoteKey.eighthZ:
                            _inserOrUpdatetRest(NoteLength.eighth);
                            break;
                          case ChangeNoteKey.sixteenthZ:
                            _inserOrUpdatetRest(NoteLength.sixteenth);
                            break;
                          case ChangeNoteKey.randomGroove:
                            _randomizeAbc();
                            break;
                          case ChangeNoteKey.delete:
                            _delete();
                            break;
                        }
                      },
                      onLongPress: (BuildContext context, ChangeNoteKey key) {
                        if (key != ChangeNoteKey.delete) return;
                        resetToDefaulValueInCreateMode();
                      },
                    ),
                  );
                }),
                SizedBox(height: isWindowsOrMac ? 33.h : 15.h),
                Obx(
                  () => Flexible(
                      flex: isWindowsOrMac ? 6 : 4,
                      child: Visibility(
                        visible: isVisibleWebview.value,
                        // maintainSize: true, // 保持占位空间
                        // maintainAnimation: true, // 保持动画
                        // maintainState: true,
                        key: const ValueKey('ValueKey22'),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: WebViewWidget(
                            controller: controllerKeyboard,
                          ),
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
                                          child:
                                              const CircularProgressIndicator(
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
                                  PlayProgressBar(
                                      currentSliderValue: playProgress,
                                      totalTime: pianoAllTime,
                                      onPressed: () {
                                        playOrPausePiano();
                                      },
                                      isPlay: isPlay.value),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Obx(
                                    () => BorderBottomBtn(
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
                                        if (isClicking || isOnlyLoadFastModel) {
                                          debugPrint(
                                              'isClicking || isOnlyLoadFastModel');
                                          return;
                                        }
                                        if (selectstate.value == 1 &&
                                            splitMeasure == null) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Please input some notes before generating.");
                                          return;
                                        }
                                        isClicking = true;
                                        isGenerating.value =
                                            !isGenerating.value;
                                        if (isGenerating.value) {
                                          resetPianoAndKeyboard();

                                          // if (isWindowsOrMac) {
                                          fetchABCDataByIsolate();
                                          // } else {
                                          //   getABCDataByAPI();
                                          // }

                                          isFinishABCEvent = false;
                                          if (selectstate.value == 1) {
                                            isCreateGenerate.value = true;
                                            controllerKeyboard
                                                .loadFlutterAssetServer(
                                                    filePathKeyboardAnimation);
                                          }
                                        } else {
                                          // isolateSendPort.send('stop Generating');
                                          isolateEventBus
                                              .fire("stop Generating");
                                        }
                                      },
                                    ),
                                  ),
                                  if (selectstate.value == 1)
                                    SizedBox(
                                      width: 55.w,
                                    ),
                                  Obx(() => Visibility(
                                        visible: selectstate.value == 1,
                                        child: BorderBottomBtn(
                                          width: isWindowsOrMac ? 257.w : 200.w,
                                          height: isWindowsOrMac ? 123.h : 96.h,
                                          text: !isCreateGenerate.value
                                              ? 'Undo'
                                              : 'Reset',
                                          icon: SvgPicture.asset(
                                            'assets/images/ic_undo.svg',
                                            width: isWindowsOrMac ? 61.w : 50.w,
                                            height:
                                                isWindowsOrMac ? 61.h : 50.h,
                                          ),
                                          onPressed: () {
                                            debugPrint('Undo');
                                            _undo();
                                          },
                                        ),
                                      )),
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
    controllerKeyboard.runJavaScript('resetPlay()');

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
      _change(ABCHead.base64AbcString(finalabcStringPreset));
      debugPrint('finalabcStringPreset=$finalabcStringPreset');
      controllerPiano.runJavaScript("setPromptNoteNumberCount(3)");
      controllerKeyboard.loadFlutterAssetServer(filePathKeyboardAnimation);
      // controllerKeyboard.loadRequest(Uri.parse(filePathKeyboardAnimation));
      // controllerKeyboard.runJavaScript('resetPlay()');
      // controllerKeyboard.runJavaScript('setPiano(55, 76)');
    } else {
      resetToDefaulValueInCreateMode();
    }
  }

  /// 清除全部内容
  void resetToDefaulValueInCreateMode() {
    selectedNote.value = null;
    virtualNotes.clear();
    intNodes.clear();
    timeSingnatureStr = "4/4";
    timeSignature.value = 2;
    finalabcStringCreate =
        "setAbcString(\"${ABCHead.getABCWithInstrument('L:1/4\\nM:$timeSingnatureStr\\nK:C\\n|', midiProgramValue)}\",false)";
    finalabcStringCreate =
        ABCHead.appendTempoParam(finalabcStringCreate, tempo.value.toInt());
    debugPrint('str112==$finalabcStringCreate');
    _change(finalabcStringCreate);
    controllerPiano.runJavaScript("setPromptNoteNumberCount(0)");
    controllerPiano.runJavaScript("setStyle()");
    controllerKeyboard.loadFlutterAssetServer(filePathKeyboard);
    // controllerKeyboard.runJavaScript('resetPlay()');
    createPrompt = '';
  }

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
              // height: isWindowsOrMac ? 1000.h : 910.h,
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
                          size: 70.w,
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
                  Obx(
                    () => Row(
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
                                  text: '${(randomness.value * 100).toInt()}%'),
                            ],
                          )
                        ]),
                  ),
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
                  Obx(() => CheckBoxItem(
                        title: 'Demo Mode$tokens',
                        // visualDensity: VisualDensity.compact, // 去除空白间距
                        isSelected: isAutoSwitch.value,
                        onChanged: (bool? value) {
                          isAutoSwitch.value = value!;
                          ConfigStore.to.saveAutoNext(value);
                        },
                      )),
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
                            if (exportMidiStr == null) {
                              return;
                            }
                            if (isWindowsOrMac) {
                              final file = DirectoryPicker()
                                ..title = 'Select a directory';
                              final result = file.getDirectory();
                              if (result != null) {
                                debugPrint('Select a directory=${result.path}');
                              }
                              await MidifileConvert.exportMidiFile(
                                  exportMidiStr!, result!.path);
                              Get.snackbar('提示', '文件保存成功',
                                  colorText: Colors.black);
                              // toastInfo(msg: '文件保存成功');
                            } else {
                              // phone save file
                              Directory tempDir =
                                  await getApplicationCacheDirectory();
                              String path =
                                  await MidifileConvert.exportMidiFile(
                                      exportMidiStr!, tempDir.path);
                              shareFile(path);
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
                      ],
                    ),
                  ),
                  if (Platform.isIOS || Platform.isAndroid)
                    SizedBox(
                      height: 30.w,
                    ),
                  if (Platform.isIOS || Platform.isAndroid)
                    Center(
                      child: TextBtn(
                        width: isWindowsOrMac ? 1000.w : 1000.w,
                        height: isWindowsOrMac ? 113.h : 80.h,
                        onPressed: () {
                          Get.to(FeedbackPage());
                        },
                        text: 'FeedBack',
                        linearColorStart: AppColor.color_805353,
                        linearColorEnd: AppColor.color_5E1E1E,
                      ),
                    ),
                  SizedBox(
                    height: isWindowsOrMac ? 60.h : 40.h,
                  ),
                  Center(child: TextItem(text: 'Version: $appVersion')),
                ],
              ),
            ),
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
                                size: 70.w,
                              ),
                              onTap: () {
                                isShowDialog = false;
                                // if (isWindowsOrMac) {
                                //   isVisibleWebview.value = !isVisibleWebview.value;
                                //   setState(() {});
                                // }
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
                            ]),
                        Obx(
                          () => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              ]),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextItem(text: 'Auto Chord'),
                                Obx(
                                  () => SwitchItem(
                                    value: autoChord.value,
                                    onChanged: (newValue) {
                                      autoChord.value = newValue;
                                    },
                                  ),
                                ),
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
                        Center(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextItem(text: 'show Prompt'),
                                Obx(() => SwitchItem(
                                      value: showPrompt.value,
                                      onChanged: (newValue) {
                                        showPrompt.value = newValue;
                                      },
                                    )),
                              ]),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Obx(
                          () => showPrompt.value
                              ? SelectableText(
                                  currentGeneratePromptTmp.value,
                                  style: TextStyle(color: Colors.white),
                                )
                              : SizedBox(
                                  width: 0,
                                ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        Obx(() => CheckBoxItem(
                              title: 'Demo Mode$tokens',
                              // visualDensity: VisualDensity.compact, // 去除空白间距
                              isSelected: isAutoSwitch.value,
                              onChanged: (bool? value) {
                                isAutoSwitch.value = value!;
                                ConfigStore.to.saveAutoNext(value);
                              },
                            )),
                        SizedBox(
                          height: 40.h,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextBtn(
                                width: isWindowsOrMac ? 500.w : 500.w,
                                height: isWindowsOrMac ? 113.h : 80.h,
                                onPressed: () async {
                                  if (exportMidiStr == null) {
                                    return;
                                  }
                                  if (isWindowsOrMac) {
                                    final file = DirectoryPicker()
                                      ..title = 'Select a directory';
                                    final result = file.getDirectory();
                                    if (result != null) {
                                      debugPrint(
                                          'Select a directory=${result.path}');
                                    }
                                    await MidifileConvert.exportMidiFile(
                                        exportMidiStr!, result!.path);
                                    Get.snackbar('提示', '文件保存成功',
                                        colorText: Colors.black);
                                    // toastInfo(msg: '文件保存成功');
                                  } else {
                                    // phone save file
                                    Directory tempDir =
                                        await getApplicationCacheDirectory();
                                    String path =
                                        await MidifileConvert.exportMidiFile(
                                            exportMidiStr!, tempDir.path);
                                    shareFile(path);
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
                        if (Platform.isIOS || Platform.isAndroid)
                          SizedBox(
                            height: 30.w,
                          ),
                        if (Platform.isIOS || Platform.isAndroid)
                          Center(
                            child: TextBtn(
                              width: isWindowsOrMac ? 1000.w : 1000.w,
                              height: isWindowsOrMac ? 113.h : 80.h,
                              onPressed: () {
                                Get.to(FeedbackPage());
                              },
                              text: 'FeedBack',
                              linearColorStart: AppColor.color_805353,
                              linearColorEnd: AppColor.color_5E1E1E,
                            ),
                          ),
                        SizedBox(
                          height: isWindowsOrMac ? 60.h : 40.h,
                        ),
                        Center(child: TextItem(text: 'Version: $appVersion')),
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
    controller.animateTo(rowIndex * rowHeight,
        duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
  }

  void _showTimeChangingDialog() async {
    final _selectstate = selectstate.value;
    final _isPlay = isPlay.value;
    if (_selectstate != 1 || _isPlay) return;
    if (isShowDialog) return;
    isShowDialog = true;
    if (isShowOverlay) {
      closeOverlay();
    }
    if (isWindowsOrMac) {
      isVisibleWebview.value = !isVisibleWebview.value;
    }
    final index = await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return const TimeChanging();
        });

    _unselectAll();

    isShowDialog = false;
    if (index == null) return;

    timeSignature.value = index;
    timeSingnatureStr = timeSignatures[index];
    updateTimeSignature();
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
                            size: 70.w,
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
                        controller: controller,
                        itemCount: list.length,
                        itemBuilder: (BuildContext context, int index) {
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
                                            : 0 == index),
                                title: list[index],
                                onChanged: (value) {
                                  if (type == STORAGE_PROMPTS_SELECT) {
                                    promptSelectedIndex.value = value;
                                  } else if (type ==
                                      STORAGE_SOUNDSEFFECT_SELECT) {
                                    effectSelectedIndex.value = value;
                                  } else if (type == STORAGE_note_SELECT) {
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
                                    }
                                  } else if (type == STORAGE_note_SELECT) {}
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

                                      _change(finalabcStringPreset);
                                      debugPrint(
                                          'finalabcStringPreset=$finalabcStringPreset');
                                    } else {
                                      finalabcStringCreate =
                                          "setAbcString(\"$abcstr\",false)";
                                      _change(finalabcStringCreate);
                                      debugPrint(
                                          'finalabcStringCreate=$finalabcStringCreate');
                                    }
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
                                      playOrPausePiano();
                                    });
                                    if (isWindowsOrMac) {
                                      closeDialog();
                                    }
                                  } else if (type ==
                                      STORAGE_SOUNDSEFFECT_SELECT) {
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
                                      _change(ABCHead.base64AbcString(
                                          finalabcStringPreset));
                                    } else {
                                      finalabcStringCreate =
                                          modifyABCWithInstrument;
                                      _change(ABCHead.base64AbcString(
                                          finalabcStringCreate));
                                    }
                                    Future.delayed(
                                        const Duration(milliseconds: 500), () {
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
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/${isVisible ? 'backgroundbg.jpg' : 'backgroundbg.jpg'}'), //isVisible ? 'dialogbg.png' : 'backgroundbg.jpg'
                    fit: BoxFit.cover,
                  ),
                ),
                padding: const EdgeInsets.all(10),
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
                                size: 70.w,
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
                      child: Obx(
                        () => ListView.builder(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )),
      ),
    );

    // 插入Overlay
    Overlay.of(context).insert(overlayEntry!);
    isShowOverlay = true;
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
              }
            };
          }
        }
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
  }

  void _flutterOnTapEmptyReceived(JavaScriptMessage p1) {
    if (selectstate.value != 1) return;
    selectedNote.value = null;
  }

  Future<void> checkAppUpdate(String type, BuildContext context) async {
    var url =
        'https://api.rwkv.cn/rest/v1/rwkv_music_version?select=*&type=eq.$type';

    try {
      // 创建 HttpClient 实例
      final httpClient = HttpClient();

      // 创建 Http 请求
      final request = await httpClient.getUrl(Uri.parse(url));
      request.headers.add('apikey',
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.ewogICJyb2xlIjogInNlcnZpY2Vfcm9sZSIsCiAgImlzcyI6ICJzdXBhYmFzZSIsCiAgImlhdCI6IDE3MjMwNDY0MDAsCiAgImV4cCI6IDE4ODA4MTI4MDAKfQ.HxaITOB4IJ-Qf0dKOw0DcfFGo76wWVEsQVoJLev7qi8');
      // 等待请求的响应
      final response = await request.close();

      // 处理响应数据
      if (response.statusCode == 200) {
        final responseData = await response.transform(utf8.decoder).join();
        List array = jsonDecode(responseData);
        String downloadurl = array[0]['download_url'];
        String version = array[0]['version'];
        String description = array[0]['description'];
        bool isForce = array[0]['is_force'];
        String md5 = array[0]['md5'];

        print('checkAppUpdate: $array');
        if (version != appVersion) {
          // 下载新版本
          showDialog(
            context: context,
            builder: (BuildContext context) {
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
                    // height: isWindowsOrMac ? 1000.h : 910.h,
                    padding: EdgeInsets.symmetric(
                        horizontal: isWindowsOrMac ? 60.w : 40.w,
                        vertical: isWindowsOrMac ? 40.h : 60.h),
                    child: Obx(() => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextItem(
                              text: 'Version Update',
                              fontSize: 48.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            TextItem(text: description)
                                .marginSymmetric(vertical: 20.h),
                            if (isdownloading.value)
                              SizedBox(
                                width: double.infinity,
                                height: 20,
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 3.0, // 进度条高度
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 0, // 滑块的半径
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 0.0, // 滑块被拖动时的扩展半径
                                    ),
                                  ),
                                  child: Slider(
                                    // allowedInteraction: SliderInteraction.tapOnly,
                                    activeColor: AppColor.color_757575,
                                    inactiveColor: Colors.white,
                                    thumbColor: Colors.white,
                                    value: downloadProgress.value,
                                    onChanged: (double newValue) {},
                                  ),
                                ),
                              ),
                            if (isdownloading.value)
                              TextItem(
                                  text:
                                      '${(downloadProgress * 100).toStringAsFixed(0)}%'),
                            if (!isdownloading.value)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (!isForce)
                                    TextBtn(
                                      width: isWindowsOrMac ? 1000.w : 400.w,
                                      height: isWindowsOrMac ? 113.h : 80.h,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      text: 'Cancel',
                                      linearColorStart: AppColor.color_805353,
                                      linearColorEnd: AppColor.color_5E1E1E,
                                    ),
                                  TextBtn(
                                    width: isWindowsOrMac ? 1000.w : 400.w,
                                    height: isWindowsOrMac ? 113.h : 80.h,
                                    onPressed: () {
                                      downloadfile(context, downloadurl, md5);
                                    },
                                    text: 'Update',
                                    // linearColorStart: AppColor.color_805353,
                                    // linearColorEnd: AppColor.color_5E1E1E,
                                  ).marginOnly(left: 40.w),
                                ],
                              ).marginOnly(top: 40.h)
                          ],
                        )),
                  ),
                ),
              );
            },
            barrierDismissible: false,
          );
        }
      } else {
        print('checkAppUpdate Error: ${response.statusCode}');
      }

      // 关闭 HttpClient
      httpClient.close();
    } catch (e) {
      print('checkAppUpdate Exception: $e');
    }
  }

  void downloadfile(
      BuildContext context, String downloadurl, String md5Str) async {
    String downloadPath = await CommonUtils.getCachePath();
    Uri uri = Uri.parse(downloadurl);
    var name = uri.pathSegments.last;
    debugPrint('file name=$name');
    String filePath = '$downloadPath/$name';
    if (File(filePath).existsSync()) {
      debugPrint('file existsSync');
      var file = File(filePath);
      var fileBytes = await file.readAsBytes();
      // 计算 MD5
      var md5Digest = md5.convert(fileBytes);
      // 输出 MD5 哈希值
      print('MD5 hash: ${md5Digest.toString()}');
      if (md5Digest.toString() == md5Str) {
        Get.back();
        AppInstaller.installApk(filePath);
        return;
      }
    }
    CommonUtils.downloadfile(context, downloadurl, (status, progress) {
      if (status == DownloadStatus.start) {
        isdownloading.value = true;
      } else if (status == DownloadStatus.finish) {
        print('downloadfile finished');
        // CommonUtils.setIsdownload(true);
        Get.back();
        AppInstaller.installApk(filePath);
      } else if (status == DownloadStatus.downloading) {
        downloadProgress.value = progress;
      } else if (status == DownloadStatus.fail) {
        Fluttertoast.showToast(msg: "please check network,download fail");
      }
    });
  }
}
