import 'dart:typed_data';

class MidiToABCConverter {
  static const TAG = "MidiToABCConverter";

  Uint8List sendNoteOn(int noteNumber) {
    final byteArray = Uint8List(3);
    byteArray[0] = 0x90;
    byteArray[1] = noteNumber & 0xFF;
    byteArray[2] = 0;
    return byteArray;
  }

  Uint8List sendNoteOff(int noteNumber) {
    final byteArray = Uint8List(3);
    byteArray[0] = 0x80;
    byteArray[1] = noteNumber & 0xFF;
    byteArray[2] = 0;
    return byteArray;
  }

  List<dynamic> midiToABC(Uint8List midiData, bool needRaiseKey) {
    print("$TAG midiToABC: $midiData");
    final abcStringBuilder = StringBuffer();
    var currentTime = 0;
    var currentNote = "";
    var i = 0;
    var notePosition = 0;

    while (i < midiData.length) {
      final statusByte = midiData[i] & 0xFF;
      final eventType = statusByte >> 4;

      switch (eventType) {
        case 0x08: // Note Off
          var noteNumber = midiData[i + 1] & 0xFF;
          if (needRaiseKey) {
            noteNumber += 12;
          }
          currentNote = getNoteName(noteNumber);
          notePosition = noteNumber;
          i += 3;
          break;
        case 0x09: // Note On
          var noteNumber = midiData[i + 1] & 0xFF;
          if (needRaiseKey) {
            noteNumber += 12;
          }
          print("noteNumber=$noteNumber");
          notePosition = noteNumber;
          currentNote = getNoteName(noteNumber);
          abcStringBuilder.write(currentNote);
          i += 3;
          break;
        // 处理其他MIDI事件类型
        default:
          // 其他事件类型的处理逻辑
          i++;
          break;
      }

      // 更新时间戳，这是一个简单的示例，需要根据实际情况更新
      currentTime += 1;
    }

    return [abcStringBuilder.toString(), notePosition];
  }

  String getNoteName(int noteNumber) {
    //note names by abc
    const noteString =
        "A,,,, ^A,,,, B,,,, C,,, ^C,,, D,,, ^D,,, E,,, F,,, ^F,,, G,,, ^G,,, A,,, ^A,,, B,,, C,, ^C,, D,, ^D,, E,, F,, ^F,, G,, ^G,, A,, ^A,, B,, C, ^C, D, ^D, E, F, ^F, G, ^G, A, ^A, B, C ^C D ^D E F ^F G ^G A ^A B c ^c d ^d e f ^f g ^g a ^a b c' ^c' d' ^d' e' f' ^f' g' ^g' a' ^a' b' c'' ^c'' d'' ^d'' e'' f'' ^f'' g'' ^g'' a'' ^a'' b'' c'''";
    final noteArray = noteString.split(" ");
    final noteIndex = (noteNumber - 21) % 88;
    print("noteNumber=$noteNumber noteIndex=$noteIndex");
    return noteArray[noteIndex];
  }

  String getNoteMp3Path(int noteNumber) {
    final noteNames = [
      "C",
      "Db",
      "D",
      "Eb",
      "E",
      "F",
      "Gb",
      "G",
      "Ab",
      "A",
      "Bb",
      "B"
    ];
    final noteIndex = noteNumber % 12;
    final octave = (noteNumber ~/ 12) - 1;
    return "${noteNames[noteIndex]}$octave.mp3";
  }

  String durationToABC(double duration) {
    final durationSymbols = ["1", "2", "4", "8", "16", "32", "64", "128"];
    const maxDuration = 1.0; // 根据实际需求调整
    for (var i = 0; i < durationSymbols.length; i++) {
      final durationValue = 1.0 / (1 << i);
      if (duration <= maxDuration * durationValue) {
        return durationSymbols[i];
      }
    }
    return durationSymbols.last;
  }
}
