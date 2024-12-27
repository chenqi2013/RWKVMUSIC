import 'dart:async';
import 'package:fraction/fraction.dart';

/// MIDI 音高到 ABC 记谱的完整映射表。
/// MIDI 21-108 -> 常见 ABC 记谱写法
final Map<int, String> MIDI_PITCH_TO_ABC = (() {
  final map = <int, String>{};
  const noteString = 'A,,,, ^A,,,, B,,,, C,,, ^C,,, D,,, ^D,,, E,,, F,,, ^F,,, '
      'G,,, ^G,,, A,,, ^A,,, B,,, C,, ^C,, D,, ^D,, E,, F,, ^F,, '
      'G,, ^G,, A,, ^A,, B,, C, ^C, D, ^D, E, F, ^F, G, ^G, A, ^A, '
      'B, C ^C D ^D E F ^F G ^G A ^A B c ^c d ^d e f ^f g ^g a ^a b '
      'c\' ^c\' d\' ^d\' e\' f\' ^f\' g\' ^g\' a\' ^a\' b\' c\'\' ^c\'\' d\'\' ^d\'\' '
      'e\'\' f\'\' ^f\'\' g\'\' ^g\'\' a\'\' ^a\'\' b\'\' c\'\'\'';
  final noteArray = noteString.split(' ');

  // MIDI 21~108  共 88 个键
  for (var i = 0; i < 88; i++) {
    final noteNumber = 21 + i;
    map[noteNumber] = noteArray[i];
  }
  return map;
})();

/// 定义节拍符号相对于“全音符=1”的数值
const Map<String, double> NOTE_LENGTHS = {
  '1/4': 0.25,
  '1/8': 0.125,
  '1/16': 0.0625,
  '1/32': 0.03125,
};

/// 用于将 MIDI 事件转换为 ABC 记谱的转换器。
/// 不考虑音符间的休止符，但保留“强制关闭上一个音符”的逻辑。
class MidiToABCConverter33 {
  final double bpm; // 每分钟节拍数
  final String timeSignature; // 拍号，如 "4/4"
  final String precision; // 音符最小精度，如 "1/16"
  final double tolerance; // 容忍度，比如 0.1 表示 ±10%

  /// 正在被按下但尚未抬起的音符 { pitch: startTimeInSec }
  final Map<int, double> activeNotes = {};

  /// 已处理好的音符片段（如 `C`, `D2`, `^F/2` 等），最终拼接成 ABC 记谱
  /// 如果你需要保留这些，可以, 否则可以 remove it.
  final List<String> processedNotes = [];

  late final double precisionDuration; // 用户指定精度对应的秒数
  late final double toleranceTime; // 容忍时长

  MidiToABCConverter33({
    this.bpm = 120,
    this.timeSignature = '4/4',
    this.precision = '1/16',
    this.tolerance = 0.1,
  }) {
    precisionDuration = _getDurationFromPrecision();
    toleranceTime = precisionDuration * tolerance;
  }

  /// 根据用户设定的精度，计算对应的时长（秒）。
  double _getDurationFromPrecision() {
    final quarterNoteDuration = 60.0 / bpm; // 四分音符时长(秒)
    final precisionInWhole = NOTE_LENGTHS[precision] ?? 0.0625;
    // 例如 1/16 = 0.0625(相对全音符)
    // 相对于四分音符(0.25)的倍数
    final precisionRatio = precisionInWhole / 0.25;
    return quarterNoteDuration * precisionRatio;
  }

  /// 处理单条 MIDI 事件: [status, pitch, timestampMs]
  /// - status = 144 (Note On), 128 (Note Off)
  /// - pitch  = MIDI 音高
  /// - timestampMs = 触发的时间戳，单位毫秒
  ///
  /// 返回本次事件中结束的音符的 ABC 记谱字符串（可能为空）
  String processMidiEvent(List<dynamic> event) {
    final status = event[0] as int;
    final pitch = event[1] as int;
    final timestampMs = event[2] as num;
    final timestampSec = timestampMs / 1000.0;

    // List to collect note strings that end in this event
    final List<String> endedNotes = [];

    if (status == 144) {
      // Note On: 先强制关闭所有还未关闭的音符
      for (final activePitch in activeNotes.keys.toList()) {
        final endedNote = _forceEndNote(activePitch, timestampSec);
        if (endedNote != null) {
          endedNotes.add(endedNote);
        }
      }
      // 再记录新的音符开始时间
      activeNotes[pitch] = timestampSec;
    } else if (status == 128) {
      // Note Off
      if (activeNotes.containsKey(pitch)) {
        final startTime = activeNotes.remove(pitch)!;
        final endedNote = _handleNote(pitch, startTime, timestampSec);
        if (endedNote != null) {
          endedNotes.add(endedNote);
        }
      }
    }

    // Concatenate all ended notes with spaces
    final output = endedNotes.join(' ');

    // Only return the new notes without the header
    if (output.isNotEmpty) {
      print(output); // Optionally keep this if you want to print in real-time
    }

    return output;
  }

  /// 强制结束某个音符（当新的 Note On 出现时调用，避免上一个音符拖得太长）
  ///
  /// 返回结束的音符的 ABC 记谱字符串或 null
  String? _forceEndNote(int pitch, double endTime) {
    final startTime = activeNotes.remove(pitch);
    if (startTime != null) {
      return _handleNote(pitch, startTime, endTime);
    }
    return null;
  }

  /// 计算音符时长，并生成相应的 ABC 片段
  ///
  /// 返回生成的 ABC 记谱字符串或 null
  String? _handleNote(int pitch, double startTime, double endTime) {
    final duration = endTime - startTime;
    // 如果时长 < 精度*tolerance，则直接忽略
    if (duration < precisionDuration * tolerance) {
      return null;
    }

    final noteLenStr = _calculateNoteLength(duration);
    if (noteLenStr == null) {
      return null;
    }
    // MIDI -> ABC 音名
    final abcPitch = MIDI_PITCH_TO_ABC[pitch] ?? 'C';
    final noteStr = '$abcPitch$noteLenStr';
    processedNotes.add(noteStr); // Optional: Keep if you need the full list
    return noteStr;
  }

  /// 将实际时长映射为 ABC 记谱中的时值表示（可能是整数或分数）
  String? _calculateNoteLength(double durationSec) {
    // 1个四分音符时长
    final quarterNoteDur = 60.0 / bpm;
    // 当前音符等于多少个四分音符
    final numQuarterNotes = durationSec / quarterNoteDur;

    // 与用户指定的最小粒度对比，并做四舍五入
    final precisionRatio = (NOTE_LENGTHS[precision] ?? 0.0625) / 0.25;
    final units = numQuarterNotes / precisionRatio;
    var unitsRounded = units.round();
    if (unitsRounded < 1) unitsRounded = 1;

    // 最终换算回 "全音符=1" 的比例
    final finalInWhole = unitsRounded * precisionRatio;
    // fraction 包中的方法，可限制分母最大值
    final frac = Fraction.fromDouble(finalInWhole).reduce();

    // 下面模仿之前 Python 里的输出规则
    // 如果 frac == 1 => 四分音符 => 返回空串表示默认时值
    if (frac.numerator == frac.denominator) {
      return '';
    }
    // 如果分母=1 => 整数倍 => 直接返回分子
    else if (frac.denominator == 1) {
      return '${frac.numerator}';
    }
    // 否则输出 "x/y"，并且若 x=1 则输出 "/y"
    else {
      if (frac.numerator == 1) {
        return '/${frac.denominator}';
      } else {
        return '${frac.numerator}/${frac.denominator}';
      }
    }
  }

  /// 输出当前的 ABC 记谱（不再需要，因为 we're only outputting the latest note)
  // String outputAbcNotation() {
  //   final header = generateAbcHeader();
  //   final body = processedNotes.join(' ');
  //   final abcNotation = header + body;
  //   print(abcNotation);
  //   return body;
  // }
}

/// 主函数示例
Future<void> midiDataToABCConverter33(List<List<dynamic>> midiEvents) async {
  final converter = MidiToABCConverter33(
    bpm: 120,
    precision: '1/16',
    tolerance: 0.1,
  );

  // 准备模拟的 MIDI 事件列表
  final midiEventsList = <List<dynamic>>[
    // [status, pitch, timestampMs]
    [144, 59, 1127], // Note On
    [128, 59, 1202], // Note Off
    [144, 57, 1608], // Note On
    [128, 57, 1837], // Note Off
    [144, 55, 2722], // Note On
    // 模拟还没Off，就来了一个新Note On(55->53)，将触发强制关闭
    [144, 53, 3307], // Note On -> force_end_note(55)
    [128, 53, 3398], // Note Off(53)
    [128, 55, 3600], // 迟到的Off(55) -> 已被强制关闭，不再重复处理
  ];

  // 模拟实时处理
  for (final event in midiEventsList) {
    final output = converter.processMidiEvent(event);
    if (output.isNotEmpty) {
      // Here you can handle the output as needed, e.g., collect it or send to another system
      // For demonstration, it's already printed inside processMidiEvent
    }
    // 这里故意 sleep 20ms, 模拟“稍后才来的下一个 MIDI 事件”
    // await Future.delayed(const Duration(milliseconds: 20));
  }
}
