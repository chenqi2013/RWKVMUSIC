import 'dart:math';
import 'package:fraction/fraction.dart'; // 引入 fraction 包 // 隐藏原 fraction 包

String getNoteName(int noteNumber) {
  const noteString =
      "A,,,, ^A,,,, B,,,, C,,, ^C,,, D,,, ^D,,, E,,, F,,, ^F,,, G,,, ^G,,, A,,, ^A,,, B,,, C,, ^C,, D,, ^D,, E,, F,, ^F,, G,, ^G,, A,, ^A,, B,, C, ^C, D, ^D, E, F, ^F, G, ^G, A, ^A, B, C ^C D ^D E F ^F G ^G A ^A B c ^c d ^d e f ^f g ^g a ^a b c' ^c' d' ^d' e' f' ^f' g' ^g' a' ^a' b' c'' ^c'' d'' ^d'' e'' f'' ^f'' g'' ^g'' a'' ^a'' b'' c'''";
  final noteArray = noteString.split(" ");
  final noteIndex = (noteNumber - 21) % 88;
  return noteArray[noteIndex];
}

// 定义节拍符号与时值的映射（以全音符为1）
Map<String, double> NOTE_LENGTHS = {
  "1/4": 0.25,
  "1/8": 0.125,
  "1/16": 0.0625,
  "1/32": 0.03125,
};

class MidiDataToABCConverter {
  late int bpm;
  late String timeSignature;
  late String precision;
  late double tolerance;
  Map<int, Map<String, dynamic>> activeNotes = {};
  List<String> processedNotes = [];
  late double precisionDuration;
  late double toleranceTime;
  double previousEndTime = 0;
  late String header;

  MidiDataToABCConverter(
      {this.bpm = 120,
      this.timeSignature = "4/4",
      this.precision = "1/16",
      this.tolerance = 0.1}) {
    precisionDuration = getDurationFromPrecision();
    toleranceTime = precisionDuration * tolerance;
    header = generateAbcHeader();
  }

  double getDurationFromPrecision() {
    double quarterNoteDuration = 60 / bpm; // 四分音符的时值（秒）
    double precisionRatio = NOTE_LENGTHS[precision]! / 0.25;
    return quarterNoteDuration * precisionRatio;
  }

  String generateAbcHeader() {
    return "L:1/4\nM:$timeSignature\nQ:1/4=$bpm\n";
  }

  String processMidiEvent(List<int> event) {
    int status = event[0];
    int pitch = event[1];
    double timestamp = event[2] / 1000.0; // 转换为秒

    if (status == 144) {
      // Note On
      if (activeNotes.isNotEmpty) {
        for (int activePitch in List.from(activeNotes.keys)) {
          forceEndNote(activePitch, timestamp);
        }
      }
      activeNotes[pitch] = {"start_time": timestamp, "forced_end": false};
      handleRest(previousEndTime, timestamp);
    } else if (status == 128) {
      // Note Off
      if (activeNotes.containsKey(pitch)) {
        Map<String, dynamic> noteInfo = activeNotes.remove(pitch)!;
        handleNote(pitch, noteInfo["start_time"], timestamp);
        previousEndTime = timestamp;
      }
    }

    return outputAbcNotation();
  }

  void forceEndNote(int pitch, double timestamp) {
    Map<String, dynamic> noteInfo = activeNotes.remove(pitch)!;
    noteInfo["forced_end"] = true;
    handleNote(pitch, noteInfo["start_time"], timestamp);
    previousEndTime = timestamp;
  }

  void handleNote(int pitch, double startTime, double endTime) {
    double duration = endTime - startTime;
    if (duration < precisionDuration * tolerance) return; // 忽略过短的音符

    String? noteLength = calculateNoteLength(duration);
    if (noteLength == null) return;

    String abcPitch = getNoteName(pitch);
    String noteStr = "$abcPitch$noteLength";
    processedNotes.add(noteStr);
  }

  void handleRest(double previousEndTime, double currentStartTime) {
    double restDuration = currentStartTime - previousEndTime;
    if (restDuration >= precisionDuration - toleranceTime) {
      String restLength = calculateNoteLength(restDuration) ?? "";
      processedNotes.add("z$restLength");
    }
  }

  String? calculateNoteLength(double duration) {
    double quarterNoteDuration = 60 / bpm;
    double units = duration / quarterNoteDuration;
    double precisionRatio = NOTE_LENGTHS[precision]! / 0.25;
    units /= precisionRatio;

    // 四舍五入到最近的整数
    int unitsRounded = units.round();
    unitsRounded = max(unitsRounded, 1);
    double noteLength = unitsRounded * precisionRatio;
    // 5.375, 5.75. 4.5 测试数据
    // noteLength = 4.5;

    // 使用 fraction 包将 noteLength 转换为分数
    Fraction fractionNoteLength = Fraction.fromDouble(noteLength).reduce();

    String lengthStr;
    if (fractionNoteLength.denominator == 1) {
      // 分母为1，说明是整数
      if (fractionNoteLength.numerator == 1) {
        // 1代表四分音符无标记
        lengthStr = "";
      } else {
        // 大于1的整数，以数字形式表示
        lengthStr = "${fractionNoteLength.numerator}";
      }
    } else {
      // 分子/分母形式
      if (fractionNoteLength.numerator == 1) {
        // 分子为1，只显示 /分母
        lengthStr = "/${fractionNoteLength.denominator}";
      } else {
        // 一般分数形式
        lengthStr =
            "${fractionNoteLength.numerator}/${fractionNoteLength.denominator}";
      }
    }

    return lengthStr;
  }

  String outputAbcNotation() {
    String abcBody = processedNotes.join(' ');
    String abcNotation = header + abcBody;
    return abcBody;
  }
}
