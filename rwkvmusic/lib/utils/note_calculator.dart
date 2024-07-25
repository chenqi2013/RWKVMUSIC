import 'package:flutter/foundation.dart';

class NoteCalculator {
  static final NoteCalculator _instance = NoteCalculator._internal();

  factory NoteCalculator() => _instance;

  NoteCalculator._internal() {
    if (kDebugMode) print('_internal');
  }

  /// 默认 1/4
  ///
  /// 如果没有在 noteMap 中就是 1/4
  ///
  /// 如果在，取 [noteMap] 中的长度值
  final noteMap = {};

  /// 默认长度字符
  final defaultNoteLength = "1/4";

  /// 获取音符长度索引
  int getNoteLengthIndex(String note, int index) {
    String realNote = noteMap[index] ?? note;
    if (realNote.contains("/2")) {
      return 1;
    } else if (realNote.contains("/4")) {
      return 2;
    } else if (realNote.contains("/8")) {
      return 4;
    } else {
      return 0;
    }
  }

  String calculateNewNoteByLength(
    String note,
    String newNoteLength,
  ) {
    String newNote = note;
    if (defaultNoteLength == newNoteLength) return newNote;

    switch (newNoteLength) {
      case "1/1":
        newNote = "${note}4";
      case "1/2":
        newNote = "${note}2";
      case "1/4":
        break;
      case "1/8":
        newNote = "$note/2";
        break;
      case "1/16":
        newNote = "$note/4";
        break;
      case "1/32":
        newNote = "$note/8";
    }
    if (kDebugMode) {
      print(
          "calculateNewNoteByLength: note=$note, defaultNoteLength=$defaultNoteLength, newNoteLength=$newNoteLength, newNote=$newNote");
    }
    return newNote;
  }
}
