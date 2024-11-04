import 'dart:math';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/note_length.dart';
import 'package:rwkvmusic/values/constantdata.dart';
import 'package:rwkvmusic/widgets/change_note.dart';

/// 输入 note 时匹配的时值
final inputNoteLength = Rx<NoteLength>(NoteLength.quarter);

final selectedNote = Rx<NewNote?>(null);

final latestUsedRest = Rx<ChangeNoteKey>(ChangeNoteKey.quarterZ);

class NewNote {
  late final String name;
  late final int index;
  late final NoteLength length;

  String get notation {
    return name + length.end;
  }

  bool get isZ {
    return name == "z";
  }

  String notationWithDotted(bool dotted) {
    if (length.dotted == dotted) return notation;
    return name + length.withDotted(dotted).end;
  }

  @override
  String toString() {
    return "NewNote(name: $name, index: $index, length: $length)";
  }
}

abstract class GlobalState {
  static final tripleting = Rx(false);

  static void init() {
    selectedNote.listen(_onSelectedNodeChanged);
  }

  static void _onSelectedNodeChanged(value) {
    GlobalState.tripleting.value = tripletHighlighted(nodeIndex: value?.index);
  }
}

/// 三连音按钮是否高亮 @w
///
/// 点击五线谱上的 note，js 传递的 noteIndex 为所有音符的 note index，包含 "z"
///
/// 而，我们这边的 virtualNotes 包含 "(3" 的标记
bool tripletHighlighted({int? nodeIndex}) {
  final _virtualNotes = virtualNotes;
  if (nodeIndex == null) {
    if (_virtualNotes.isEmpty) return false;

    final length = _virtualNotes.length;

    final sublist = _virtualNotes.sublist(max(length - 3, 0));
    return sublist.contains(kTriplet);
  }

  final notesCount = nodeIndex + 1;
  int mark = 0;
  int realIndexInVirtualNotes = 0;

  for (int i = 0; i < _virtualNotes.length; i++) {
    if (mark == notesCount) {
      realIndexInVirtualNotes = i;
      break;
    }
    if (_virtualNotes[i] != kTriplet) mark++;
  }

  final totalTripletCountInFrontOfThisIndex = _virtualNotes
      .sublist(0, realIndexInVirtualNotes)
      .where((v) => v == kTriplet)
      .length;

  final indexes = [
    nodeIndex + totalTripletCountInFrontOfThisIndex - 3,
    nodeIndex + totalTripletCountInFrontOfThisIndex - 2,
    nodeIndex + totalTripletCountInFrontOfThisIndex - 1,
  ].where((v) => v >= 0);

  for (int index in indexes) {
    if (_virtualNotes[index] == kTriplet) return true;
  }

  return false;
}

void addTripletMark() {
  final _virtualNotes = virtualNotes;
  final nodeIndex = selectedNote.value?.index;
  if (nodeIndex == null) {
    virtualNotes.add(kTriplet);
    return;
  }
  _virtualNotes.insert(nodeIndex, kTriplet);
  for (int i = nodeIndex + 1; i < _virtualNotes.length; i++) {
    if (_virtualNotes[i] == kTriplet) {
      _virtualNotes.removeAt(i);
      break;
    }
  }
}

List<String> removeTripletMark() {
  final _virtualNotes = virtualNotes;
  final nodeIndex = selectedNote.value?.index;

  if (nodeIndex == null) {
    if (_virtualNotes.isEmpty) return _virtualNotes;
    _virtualNotes.removeAt(_virtualNotes.lastIndexOf(kTriplet));
    return _virtualNotes;
  }

  final alreadyInTriplet = tripletHighlighted(nodeIndex: nodeIndex);
  assert(alreadyInTriplet);
  final notesCount = nodeIndex + 1;
  int mark = 0;
  int realIndexInVirtualNotes = 0;

  for (int i = 0; i < _virtualNotes.length; i++) {
    if (mark == notesCount) {
      realIndexInVirtualNotes = i;
      break;
    }
    if (_virtualNotes[i] != kTriplet) mark++;
  }
  final totalTripletCountInFrontOfThisIndex = _virtualNotes
      .sublist(0, realIndexInVirtualNotes)
      .where((v) => v == kTriplet)
      .length;

  final indexes = [
    nodeIndex + totalTripletCountInFrontOfThisIndex - 3,
    nodeIndex + totalTripletCountInFrontOfThisIndex - 2,
    nodeIndex + totalTripletCountInFrontOfThisIndex - 1,
  ].where((v) => v >= 0);

  assert(indexes.isNotEmpty);

  final index = indexes.firstWhere((v) => _virtualNotes[v] == kTriplet);
  _virtualNotes.removeAt(index);

  if (_virtualNotes.last == kTriplet) _virtualNotes.removeLast();

  return _virtualNotes;
}
