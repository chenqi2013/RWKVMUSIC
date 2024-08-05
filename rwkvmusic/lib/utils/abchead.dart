import 'dart:convert';

import 'package:flutter/foundation.dart';
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
      String timeSignatures, String noteLengths) {
    if (timeSignatures == '2/4' && noteLengths == '1/4') {
      return 2;
    } else if (timeSignatures == '2/4' && noteLengths == '1/8') {
      return 4;
    } else if (timeSignatures == '2/4' && noteLengths == '1/16') {
      return 8;
    } else if (timeSignatures == '3/4' && noteLengths == '1/4') {
      return 3;
    } else if (timeSignatures == '3/4' && noteLengths == '1/8') {
      return 6;
    } else if (timeSignatures == '3/4' && noteLengths == '1/16') {
      return 12;
    } else if (timeSignatures == '4/4' && noteLengths == '1/4') {
      return 4;
    } else if (timeSignatures == '4/4' && noteLengths == '1/8') {
      return 8;
    } else if (timeSignatures == '4/4' && noteLengths == '1/16') {
      return 16;
    } else if (timeSignatures == '3/8' && noteLengths == '1/4') {
      return 1;
    } else if (timeSignatures == '3/8' && noteLengths == '1/8') {
      return 3;
    } else if (timeSignatures == '3/8' && noteLengths == '1/16') {
      return 6;
    } else if (timeSignatures == '6/8' && noteLengths == '1/4') {
      return 3;
    } else if (timeSignatures == '6/8' && noteLengths == '1/8') {
      return 6;
    } else if (timeSignatures == '6/8' && noteLengths == '1/16') {
      return 12;
    }

    return 4;
  }

  static String combineAbc_Chord(List<String> array, String inputString) {
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
