import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:rwkvmusic/note_length.dart';

/// 输入 note 时匹配的时值
final inputNoteLength = Rx<NoteLength>(NoteLength.quarter);

final selectedNote = Rx<NewNote?>(null);

class NewNote {
  late final String name;
  late final int index;
  late final NoteLength length;

  String get notation {
    return name + this.length.end;
  }

  bool get isZ {
    return name == "z";
  }

  String notationWithDotted(bool dotted) {
    if (this.length.dotted == dotted) return notation;
    return name + this.length.withDotted(dotted).end;
  }
}
