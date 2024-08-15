import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:rwkvmusic/note_length.dart';

final inputNoteLength = Rx<NoteLength>(NoteLength.quarter);

final selectNoteLength = Rx<NoteLength?>(null);
