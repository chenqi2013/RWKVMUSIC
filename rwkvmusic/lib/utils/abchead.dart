import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rwkvmusic/note_length.dart';
import 'package:rwkvmusic/utils/automeasure_randomizeabc.dart';
import 'package:rwkvmusic/utils/convert_chord.dart';
import 'package:rwkvmusic/utils/key_convert.dart';

class ABCHead {
  static const String headContent = "L:1/4\n"
      "M:4/4\n"
      "K:C\n";
  static const String headContentForEmpty = "L:1/8\n"
      "M:4/4\n"
      "K:C\n"
      "\"C\"";

  static String getABCWithInstrument(String? content, int instrumentType) {
    return "%%MIDI program $instrumentType\\n$content";
  }

  static String modifyABCWithInstrument(String content, int instrumentType) {
    String result = content
        .replaceAll('MIDI program 0', 'MIDI program $instrumentType')
        .replaceAll('MIDI program 40', 'MIDI program $instrumentType')
        .replaceAll('MIDI program 79', 'MIDI program $instrumentType')
        .replaceAll('MIDI program 42', 'MIDI program $instrumentType')
        .replaceAll('MIDI program 25', 'MIDI program $instrumentType');

    return result;
  }

  static String appendTempoParam(String abc, int tempo) {
    String tempoConfig = "Q:1/4=$tempo";
    String result = '';
    if (abc.contains("Q:1/4=")) {
      result = abc.replaceAll(RegExp(r"Q:1/4=\d+"), tempoConfig);
    } else {
      // return abc;
      // result = "$tempoConfig\\n$abc";
      result =
          abc.replaceAll('%%MIDI program', '$tempoConfig\\n%%MIDI program');
    }
    // print('appendTempoParam=$result');
    return result;
  }

  static String base64AbcString(String event) {
    // print('base64AbcString before11--$event');
    String result =
        event.replaceAll('setAbcString("', '').replaceAll('",false)', ''); //%%
    // print('base64AbcString before22--$result');
    String encodedString = base64.encode(utf8.encode(result));
    // debugPrint("Encoded setAbcString: $encodedString");
    String base64AbcString = "setAbcString('$encodedString',false)";
    // print("base64AbcString: $encodedString");
    return base64AbcString;
  }

  static String base64abctoEvents(String playAbcString) {
    String result = playAbcString
        .replaceAll('setAbcString("', '')
        .replaceAll('",false)', '');
    // print('replace==$result');
    String encodedString = base64.encode(utf8.encode(result));
    // print("Encoded string: $encodedString");
    String base64abctoEvents = "ABCtoEvents('$encodedString',false)";
    if (kDebugMode) print("base64abctoEvents: $encodedString");

    return base64abctoEvents;
  }

  static int insertMeasureLinePosition(
      String timeSignatures, NoteLength noteLength) {
    if (timeSignatures == '2/4' && noteLength == NoteLength.quarter) {
      return 2;
    } else if (timeSignatures == '2/4' && noteLength == NoteLength.eighth) {
      return 4;
    } else if (timeSignatures == '2/4' && noteLength == NoteLength.sixteenth) {
      return 8;
    } else if (timeSignatures == '3/4' && noteLength == NoteLength.quarter) {
      return 3;
    } else if (timeSignatures == '3/4' && noteLength == NoteLength.eighth) {
      return 6;
    } else if (timeSignatures == '3/4' && noteLength == NoteLength.sixteenth) {
      return 12;
    } else if (timeSignatures == '4/4' && noteLength == NoteLength.quarter) {
      return 4;
    } else if (timeSignatures == '4/4' && noteLength == NoteLength.eighth) {
      return 8;
    } else if (timeSignatures == '4/4' && noteLength == NoteLength.sixteenth) {
      return 16;
    } else if (timeSignatures == '3/8' && noteLength == NoteLength.quarter) {
      return 1;
    } else if (timeSignatures == '3/8' && noteLength == NoteLength.eighth) {
      return 3;
    } else if (timeSignatures == '3/8' && noteLength == NoteLength.sixteenth) {
      return 6;
    } else if (timeSignatures == '6/8' && noteLength == NoteLength.quarter) {
      return 3;
    } else if (timeSignatures == '6/8' && noteLength == NoteLength.eighth) {
      return 6;
    } else if (timeSignatures == '6/8' && noteLength == NoteLength.sixteenth) {
      return 12;
    }

    return 4;
  }

  static String combineAbc_Chord(List<String> chords, String input) {
    // input =
    //     'L:1/4\nM:4/4\nK:C\n| =D =E ^G =B |^c (3e e e |=A, ^D =G  A | B F =D';
    debugPrint('combineAbc_Chord array=$chords,inputString=$input');
    List<String> lines = input.split('\n'); // 将 inputString 拆分成多行
    int length = 3;
    int notel = 2;
    if (input.contains('K:')) {
      length = 4;
      notel = 3;
    }
    if (lines.length >= length) {
      String noteLine = lines[notel]; // 第三行是音符行
      List<String> bars = noteLine.split('|'); // 按小节符号拆分
      debugPrint('combineAbc_Chord bars=$bars');
      if (bars[0].isEmpty) {
        bars.removeAt(0);
      }
      // 创建新字符串并在每个小节前插入和弦
      StringBuffer updatedLine = StringBuffer();
      for (int i = 0; i < bars.length; i++) {
        if (i < chords.length) {
          updatedLine.write('\\"${chords[i]}\\" '); // 插入和弦
        }
        updatedLine.write(bars[i].trim()); // 插入小节内容
        if (i < bars.length - 1) {
          updatedLine.write(' | '); // 重新加上小节符号
        }
      }
      lines[notel] = updatedLine.toString(); // 更新音符行
    }
    String result = lines.join('\n'); // 重新组合所
    debugPrint('combineAbc_Chord result=$result');
    return result;
  }

  static String combineAbc_Chord22(List<String> array, String inputString) {
    debugPrint('combineAbc_Chord array=$array,inputString=$inputString');
    // 初始化数组和字符串
    // List<String> array = ['C#', 'D#m', 'C#'];
    // String inputString =
    //     "Q:180\n%%MIDI program 0\nL:1/4\nM:4/4\n|^C1 ^D1 ^G1 ^A1 |^A1 ^G1 G1 ^D1 |^F1";
    // debugPrint('inputString=$inputString');
    // 将字符串按 '|' 分割成列表
    List<String> parts = inputString.split('|');

    // 创建一个新的列表来存储插入后的字符串
    List<String> resultParts = [];

    // 遍历分割后的每个部分，插入对应的数组元素
    for (int i = 0; i < parts.length; i++) {
      // 去掉部分前后的空格
      String part = parts[i].trim();
      if (i > 0) {
        // 插入数组中的字符串，并加上一个空格
        if (i <= array.length) {
          part = '| \\"' + array[i - 1] + '\\" ' + part;
        } else {
          part = '| ' + part;
        }
        // 将处理后的部分添加到结果列表中
        resultParts.add(part);
      } else {
// 将处理后的部分添加到结果列表中
        resultParts.add(part + "\n");
      }
    }

    // 将结果列表合并成一个字符串
    String resultString = resultParts.join(' ');

    // 输出结果字符串
    // print(resultString);
    return resultString;
  }

  static void testchord_split(String splitstr) {
    String abcNotation =
        "Q:180\n%%MIDI program 0\nL:1/4\nM:4/4\nK:C\n|\"Em\" E ^D ^F ^G |\"F\" F ";
    abcNotation = splitstr;
    List abc = parseAbc(abcNotation);
    print('parseAbc---$abc');
    // 自动分割小节
    String splitMeasure = splitMeasureAbc(abcNotation);
    print('splitMeasureAbc---$splitMeasure');
    // 每一节生成一个和弦
    List<dynamic> chords = generateChordAbcNotation(splitMeasure);
    print('generateChordAbcNotation---$chords');
    // 添加随机律动
    String randomize = randomizeAbc(splitMeasure);
    print('randomizeAbc---$randomize');

    var abcNotation1 = "X:1\nK:C\nC D E ^f";
    var targetKey = "G";
    var result = convertAbcNotation(abcNotation1, targetKey);
    print('convertAbcNotation key:${jsonEncode(result)}');
  }
}
