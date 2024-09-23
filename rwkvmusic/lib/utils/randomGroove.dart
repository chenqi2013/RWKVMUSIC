import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:rwkvmusic/utils/automeasure_randomizeabc.dart';
import 'package:rwkvmusic/utils/unique_rhythm_dataset.dart';

List<dynamic>? getRandomGroove(String M, List<dynamic> rhythmDataset,
    [int? remainingNotes]) {
  /*
  根据给定的M从数据集中随机调取节奏型或选择匹配的节奏型

  参数:
  M: 拍号
  rhythmDataset: 节奏数据集
  remainingNotes: 剩余音符数量

  返回:
  选择的节奏型（Groove）或null（如果没有匹配的节奏型）
  */
  var matchingRhythms = rhythmDataset.where((r) => r['M'] == M).toList();

  if (remainingNotes != null && Random().nextDouble() < 0.75) {
    var perfectMatch = matchingRhythms
        .where((r) => r['Groove'].length == remainingNotes)
        .toList();
    if (perfectMatch.isNotEmpty) {
      return perfectMatch[Random().nextInt(perfectMatch.length)]['Groove'];
    }
  }

  if (matchingRhythms.isNotEmpty) {
    return matchingRhythms[Random().nextInt(matchingRhythms.length)]['Groove'];
  }

  return null;
}

Future<String> randomizeNoteLengths(String abcNotation) async {
  // 假设 parseAbc 函数已定义，返回一个包含 header 和 notes 的 Map
  var result = parseAbc(abcNotation);
  var header = result[0];
  var notes = result[1];

  header['M'] = randomizeMeter();
  print("M: ${header['M']}");

  // var fileContent = File('unique_rhythm_dataset.json').readAsStringSync();
  // var rhythmDataset = jsonDecode(fileContent);

  var rhythmDataset = unique_rhythm_dataset;

  var newNotes = <String>[];
  var isFirstGroove = true;

  while (notes.isNotEmpty) {
    var remainingNotes = notes.length;

    List<dynamic>? groove;
    if (isFirstGroove) {
      groove = getRandomGroove(header['M'], rhythmDataset);
      isFirstGroove = false;
    } else {
      groove = getRandomGroove(header['M'], rhythmDataset, remainingNotes);
    }

    if (kDebugMode) print(groove);

    if (groove == null) {
      break;
    }

    for (var length in groove) {
      if (notes.isEmpty) {
        break;
      }
      // 假设 parseNoteLength 函数已定义，返回一个包含 noteChar 的 Map
      var noteParseResult = parseNoteLength(notes[0]);
      var noteChar = noteParseResult['note'];
      newNotes.add("$noteChar$length");
      notes.removeAt(0);
    }
  }

  // 假设 formatNotes 函数已定义，返回格式化后的 ABC 记谱字符串
  var formattedAbc = formatNotes(header, newNotes);
  // var output = processAbc(formattedAbc);
  return splitMeasureAbc(formattedAbc);
}
