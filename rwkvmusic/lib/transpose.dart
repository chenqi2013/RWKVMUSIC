import 'dart:core';

import 'package:rwkvmusic/utils/automeasure_randomizeabc.dart';

// 半音阶音符列表
List<String> semitoneLists = [
  "A,,,,",
  "^A,,,,",
  "B,,,,",
  "C,,,",
  "^C,,,",
  "D,,,",
  "^D,,,",
  "E,,,",
  "F,,,",
  "^F,,,",
  "G,,,",
  "^G,,,",
  "A,,,",
  "^A,,,",
  "B,,,",
  "C,,",
  "^C,,",
  "D,,",
  "^D,,",
  "E,,",
  "F,,",
  "^F,,",
  "G,,",
  "^G,,",
  "A,,",
  "^A,,",
  "B,,",
  "C,",
  "^C,",
  "D,",
  "^D,",
  "E,",
  "F,",
  "^F,",
  "G,",
  "^G,",
  "A",
  "^A",
  "B",
  "C",
  "^C",
  "D",
  "^D",
  "E",
  "F",
  "^F",
  "G",
  "^G",
  "A",
  "^A",
  "B",
  "C",
  "^C",
  "D",
  "^D",
  "E",
  "F",
  "^F",
  "G",
  "^G",
  "c",
  "^c",
  "d",
  "^d",
  "e",
  "f",
  "^f",
  "g",
  "^g",
  "a",
  "^a",
  "b",
  "c'",
  "^c'",
  "d'",
  "^d'",
  "e'",
  "f'",
  "^f'",
  "g'",
  "^g'",
  "a'",
  "^a'",
  "b'",
  "c''",
  "^c''",
  "d''",
  "^d''",
  "e''",
  "f''",
  "^f''",
  "g''",
  "^g''",
  "a''",
  "^a''",
  "b''",
  "c'''"
];

String transposeAbc(String abcNotation, int N) {
  // 解析ABC notation，分离header和notes部分
  var parsedAbc = parseAbc(abcNotation);
  dynamic header = parsedAbc[0];
  List<String> notes = parsedAbc[1];

  List<String> transposedNotes = [];

  // 遍历所有音符
  for (String note in notes) {
    // 使用正则表达式提取音符中的音高部分
    RegExp regex =
        RegExp(r'''([\-=]?)([\^_]?[A-Ga-gz][,\']*)(\d+)?(/(\d+)?)?''');
    Match? match = regex.firstMatch(note);

    if (match != null) {
      // 提取音符的音高部分 (如 ^A,,)
      String originalPitch = match.group(2) ?? '';
      // 在 semitone_lists 中找到该音高的索引
      if (semitoneLists.contains(originalPitch)) {
        int currentIndex = semitoneLists.indexOf(originalPitch);
        int newIndex = currentIndex + N;

        // 检查移调后的音高是否超出范围
        if (0 <= newIndex && newIndex < semitoneLists.length) {
          String newPitch = semitoneLists[newIndex];
          // 使用新的音高替换原始音符中的音高部分
          String transposedNote = note.replaceFirstMapped(
              RegExp(
                  r'''([\-]?)([=]?)([\^_]?[A-Ga-gz][,\']*)(\d+)?(/(\d+)?)?'''),
              (Match m) => '${m[1] ?? ''}$newPitch${m[4] ?? ''}${m[5] ?? ''}');
          transposedNotes.add(transposedNote);
        } else {
          // 如果移调超出范围，保持音符不变
          transposedNotes.add(note);
        }
      } else {
        // 如果音高不在 semitoneLists 中，保持不变
        transposedNotes.add(note);
      }
    } else {
      // 如果音符不匹配正则表达式，保持原样
      transposedNotes.add(note);
    }
  }

  // 返回移调后的ABC notation
  return formatNotes(header, transposedNotes);
}
