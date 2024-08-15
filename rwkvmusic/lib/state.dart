import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:rwkvmusic/note_length.dart';

/// 输入 note 时匹配的时值
final inputNoteLength = Rx<NoteLength>(NoteLength.quarter);

/// 当前正在被选择的节点的时值
final selectNoteLength = Rx<NoteLength?>(null);
