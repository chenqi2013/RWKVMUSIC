import 'dart:math';
import 'dart:core';

import 'key_convert.dart';

List parseAbc(String abcNotation) {
  Map<String, String> header = {
    'L': '1/4',
    'M': '4/4',
    'K': 'C',
  };
  List<String> notes = [];
  List<String> lines = abcNotation.trim().split('\n');

  for (String line in lines) {
    if (line.startsWith('L:')) {
      header['L'] = line.split(':')[1].trim();
    } else if (line.startsWith('M:')) {
      header['M'] = line.split(':')[1].trim();
    } else if (line.startsWith('K:')) {
      header['K'] = line.split(':')[1].trim();
    } else {
      // 更新正则表达式，支持连音符号 (3、(5 等
      RegExp regExp = RegExp(
          r'''(?:[^\"]|\"[^\"]*\")*?(\([2-9][0-9]*|[\-]?[\^_=]?[A-Ga-gz][,\']*[\d/]*)''');

      Iterable<Match> matches = regExp.allMatches(line);

      notes.addAll(matches.map((match) => match.group(1)!));
    }
  }

  return [header, notes];
}

Map<String, dynamic> parseNoteLength(String note, [Fraction? tupletRatio]) {
  tupletRatio ??= Fraction(1, 1);
  RegExp regExp = RegExp(r'''([\-]?[\^_=]?[A-Ga-gz][,\']*)(\d+)?(/(\d+)?)?''');
  Match? match = regExp.firstMatch(note);
  if (match == null) {
    return {
      'note': note,
      'length': Fraction(1, 1) * tupletRatio,
    };
  }

  String noteChar = match.group(1)!;
  String numerator = match.group(2) ?? '1';
  String denominator = match.group(4) ?? (match.group(3) != null ? '2' : '1');
  Fraction noteLength =
      Fraction(int.parse(numerator), int.parse(denominator)) * tupletRatio;

  return {
    'note': noteChar,
    'length': noteLength,
  };
}

Fraction calculateBarLength(String meter, String length) {
  List<String> parts = meter.split('/');
  int beats = int.parse(parts[0]);
  int beatType = int.parse(parts[1]);
  Fraction unitLength = Fraction.fromString(length);

  return Fraction(beats, beatType) / unitLength;
}

List<String> splitNoteLength(String noteChar, Fraction noteLength) {
  List<String> splitNotes = [];
  if (noteLength.denominator == 2 && noteLength.numerator >= 5) {
    int integerPart = noteLength.numerator ~/ noteLength.denominator;
    // int remainder = noteLength.numerator - 2* integerPart;
    splitNotes.add('$noteChar$integerPart');
    splitNotes.add('-${noteChar}1/2');
  } else if (noteLength.denominator == 4 && noteLength.numerator >= 5) {
    int integerPart = noteLength.numerator ~/ noteLength.denominator;
    int remainderNumerator = noteLength.numerator - integerPart * 4;
    splitNotes.add('$noteChar$integerPart');
    splitNotes.add('-$noteChar$remainderNumerator/4');
  } else {
    splitNotes.add('$noteChar$noteLength');
  }
  return splitNotes;
}

List<List<String>> checkAndSplitNotes(List<List<String>> bars) {
  List<List<String>> newBars = [];
  for (List<String> bar in bars) {
    List<String> newBar = [];
    for (String note in bar) {
      // 检查是否为连音符号
      if (RegExp(r'\(\d+').hasMatch(note)) {
        newBar.add(note);
        continue;
      }
      var parsedNote = parseNoteLength(note);
      String noteChar = parsedNote['note'];
      Fraction noteLength = parsedNote['length'];

      List<String> splitNotes = splitNoteLength(noteChar, noteLength);
      newBar.addAll(splitNotes);
    }
    newBars.add(newBar);
  }
  return newBars;
}

List<List<String>> divideIntoBars(List<String> notes, Fraction barLength) {
  Fraction currentLength = Fraction(0, 1);
  List<String> bar = [];
  List<List<String>> bars = [];

  int tupletCount = 0;
  int tupletNotes = 0;
  Fraction tupletRatio = Fraction(1, 1);

  int i = 0;
  while (i < notes.length) {
    String note = notes[i];

    // 检查是否为连音符号
    Match? tupletMatch = RegExp(r'\((\d+)').firstMatch(note);
    if (tupletMatch != null) {
      tupletNotes = int.parse(tupletMatch.group(1)!);
      tupletCount = tupletNotes;
      // 计算连音组的倍率，例如三连音倍率为 2/3
      tupletRatio = Fraction(tupletNotes - 1, tupletNotes);
      bar.add(note); // 保留连音符号
      i += 1;
      continue;
    }

    // 解析音符，考虑连音倍率
    var parsedNote = parseNoteLength(note, tupletRatio);
    String noteChar = parsedNote['note'];
    Fraction noteLength = parsedNote['length'];

    // 如果在连音组内，更新计数
    if (tupletCount > 0) {
      tupletCount -= 1;
      if (tupletCount == 0) {
        tupletRatio = Fraction(1, 1); // 重置倍率
      }
    }

    // 检查是否需要拆分音符以适应小节长度
    if (currentLength + noteLength > barLength) {
      Fraction remainingLength = barLength - currentLength;
      if (remainingLength > Fraction(0, 1)) {
        // 将音符拆分，前一部分放入当前小节
        bar.add('$noteChar$remainingLength');
        // 使用连音线连接跨小节的音符
        String nextNote = '-$noteChar${noteLength - remainingLength}';
        notes.insert(i + 1, nextNote);
      } else {
        // 当前小节已满，音符全部放入下一小节
        notes.insert(i + 1, note);
      }
      bars.add(bar);
      bar = [];
      currentLength = Fraction(0, 1);
    } else {
      bar.add(note);
      currentLength += noteLength;
    }

    if (currentLength == barLength) {
      bars.add(bar);
      bar = [];
      currentLength = Fraction(0, 1);
    }

    i += 1;
  }

  if (bar.isNotEmpty) {
    bars.add(bar);
  }

  // 调用检查和拆分函数
  return checkAndSplitNotes(bars);
}

String formatBars(Map<String, String> header, List<List<String>> bars) {
  String formattedAbc = 'L:${header['L']}\nM:${header['M']}\n';
  for (int i = 0; i < bars.length; i++) {
    String barStr = '';
    for (String token in bars[i]) {
      // 检查是否为连音符号
      if (RegExp(r'\(\d+').hasMatch(token)) {
        barStr += token; // 连音符号直接添加，不加空格
      } else {
        barStr += ' $token';
      }
    }
    formattedAbc += barStr.trim();
    if (i < bars.length - 1) {
      formattedAbc += ' |';
    }
  }
  return formattedAbc.trim();
}

//修改后的formatBarsTest
String formatBarsTest(Map<String, String> header, List<List<String>> bars) {
  String formattedAbc = "L:${header['L']}\nM:${header['M']}\n|";

  for (List<String> bar in bars) {
    List<String> accidentalNotes = []; // 储存带有升降号的音符
    List<String> newBar = [];

    for (String note in bar) {
      // 检查是否为连音符号
      if (RegExp(r'\(\d+').hasMatch(note)) {
        newBar.add(note);
        continue;
      }
      var parsedNote = parseNoteLength(note);
      String noteChar = parsedNote['note'];
      Fraction noteLength = parsedNote['length'];

      // 提取音符字母部分和升降号部分
      RegExp accidentalRegex = RegExp(r'''[\^_=]?[A-Ga-gz][,\']*''');
      RegExp baseNoteRegex = RegExp(r'''[\=]?[A-Ga-gz][,\']*''');
      String accidental = accidentalRegex.firstMatch(noteChar)!.group(0)!;
      String baseNote = baseNoteRegex.firstMatch(noteChar)!.group(0)!;

      // 检查数组中是否已有相同的音符
      String? matchedNote = accidentalNotes.firstWhere((x) => x == baseNote,
          orElse: () => 'null');
      if (matchedNote != 'null') {
        // 如果当前音符不带升降号
        if (accidental == baseNote) {
          if (noteChar.startsWith('-')) {
            newBar.add('-=$accidental$noteLength');
          } else {
            newBar.add('=$note');
          }
          accidentalNotes.remove(matchedNote);
        }
        // 如果当前音符带还原号
        else if (accidental.startsWith('=')) {
          newBar.add(note);
          accidentalNotes.remove(matchedNote);
        }
        // 如果当前音符带升降号
        else {
          newBar.add(note);
          accidentalNotes.remove(matchedNote);
          accidentalNotes.add(baseNote);
        }
      } else {
        if (accidental != baseNote) {
          accidentalNotes.add(baseNote);
        }
        newBar.add(note);
      }
    }

    formattedAbc += newBar.join(' ');
    formattedAbc += ' |';
  }

  return formattedAbc.substring(0, formattedAbc.length - 2);
}

//修改后的formatBars1
String formatBars1(Map<String, String> header, List<List<String>> bars) {
  String formattedAbc =
      "L:${header['L']}\nM:${header['M']}\nK:${header['K']}\n|";

  // 从 keytone_to_truetone 字典中提取当前调性的音符转换规则
  String? keytone = header['K'];
  keytone = shortToKey[keytone] ?? keytone;
  Map<String, String> conversionDict = keytoneToTruetone[keytone] ?? {};

  for (List<String> bar in bars) {
    List<String> newBar = [];
    List<String> accidentalNotes = []; // 储存已还原的音符

    for (String note in bar) {
      // 检查是否为连音符号
      if (RegExp(r'\(\d+').hasMatch(note)) {
        newBar.add(note);
        continue;
      }
      var parsedNote = parseNoteLength(note);
      String noteChar = parsedNote['note'];
      String noteLength = parsedNote['length'].toString();

      if (noteLength == '1') {
        noteLength = '';
      } else if (noteLength == '1/2') {
        noteLength = '/';
      }

      // 提取音符字母部分和升降号部分
      RegExp accidentalRegex = RegExp(r'''(-?)([\^_=]?)([A-Ga-g][,\']*)''');
      Match? accidentalMatch = accidentalRegex.firstMatch(noteChar);
      if (accidentalMatch == null) {
        continue;
      }
      String accidental = accidentalMatch.group(2)!;
      String baseNote = accidentalMatch.group(3)!;
      String? notev = RegExp(r'[A-Ga-g]').firstMatch(noteChar)?.group(0);

      String? matchedNote =
          accidentalNotes.firstWhere((x) => x == baseNote, orElse: () => '');

      if (accidental == baseNote || accidental == '') {
        // 如果没有临时变音记号，需要根据调性进行转换
        String correctedNoteChar =
            noteChar.replaceFirst(notev!, conversionDict[notev] ?? notev);
        newBar.add(correctedNoteChar + noteLength);
        accidentalNotes.remove(matchedNote);
      } else if (accidental.startsWith('=')) {
        newBar.add(noteChar + noteLength);
        accidentalNotes.remove(matchedNote);
      } else {
        newBar.add(noteChar + noteLength);
        accidentalNotes.remove(matchedNote);
        accidentalNotes.add(baseNote);
      }
    }

    formattedAbc += '${newBar.join(' ')} |';
  }

  return formattedAbc.substring(0, formattedAbc.length - 1).trim();
}

String splitMeasureAbc(String abcNotation) {
  var result = parseAbc(abcNotation);
  var header = result[0];
  List<String> notes = result[1];
  Fraction barLength = calculateBarLength(header['M'], header['L']);
  List<List<String>> bars = divideIntoBars(notes, barLength);
  return formatBarsTest(header, bars);
}

String splitMeasureAbc_end(String abcNotation) {
  var result = parseAbc(abcNotation);
  var header = result[0];
  List<String> notes = result[1];
  Fraction barLength = calculateBarLength(header['M'], header['L']);
  List<List<String>> bars = divideIntoBars(notes, barLength);
  return formatBars1(header, bars);
}

String formatNotes(Map<String, String> header, List<String> notes) {
  String formattedAbc =
      'L:${header['L']}\nM:${header['M']}\nK:${header['K']}\n';
  formattedAbc += notes.join(' ');
  return formattedAbc.trim();
}

List<String> randomizeNoteLengthsList(List<String> notes) {
  List<String> noteLengths = ['1', '/', '2', '3/2', '3', '4', '3/4'];
  List<double> weights = [0.65, 0.7, 0.7, 0.65, 0.3, 0.2, 0.4];
  Random random = Random();
  List<String> randomizedNotes = [];

  for (String note in notes) {
    var parsedNote = parseNoteLength(note);
    String noteChar = parsedNote['note'];
    String randomLength = noteLengths[random.nextInt(weights.length)];
    randomizedNotes.add('$noteChar$randomLength');
  }

  return randomizedNotes;
}

String randomizeMeter() {
  List<String> meters = ['3/4', '4/4', '2/4', '3/8', '6/8'];
  Random random = Random();
  return meters[random.nextInt(meters.length)];
}

String randomizeAbc(String abcNotation) {
  var result = parseAbc(abcNotation);
  var header = result[0];
  List<String> notes = result[1];

  header['M'] = randomizeMeter();
  notes = randomizeNoteLengthsList(notes);

  return splitMeasureAbc(formatNotes(header, notes));
}

class Fraction {
  final int numerator;
  final int denominator;

  Fraction(int numerator, [int denominator = 1])
      : numerator = numerator,
        denominator = denominator != 0
            ? denominator
            : (throw ArgumentError('Denominator cannot be zero'));

  Fraction.fromString(String str)
      : numerator = _parseNumerator(str),
        denominator = _parseDenominator(str);

  static int _parseNumerator(String str) {
    if (str.contains('/')) {
      return int.parse(str.split('/')[0]);
    } else if (str.contains('.')) {
      return (double.parse(str) * pow(10, str.split('.')[1].length)).round();
    } else {
      return int.parse(str);
    }
  }

  static int _parseDenominator(String str) {
    if (str.contains('/')) {
      return int.parse(str.split('/')[1]);
    } else if (str.contains('.')) {
      return pow(10, str.split('.')[1].length).toInt();
    } else {
      return 1;
    }
  }

  Fraction operator +(Fraction other) {
    int newNumerator =
        numerator * other.denominator + other.numerator * denominator;
    int newDenominator = denominator * other.denominator;
    return Fraction(newNumerator, newDenominator)._normalize();
  }

  Fraction operator -(Fraction other) {
    int newNumerator =
        numerator * other.denominator - other.numerator * denominator;
    int newDenominator = denominator * other.denominator;
    return Fraction(newNumerator, newDenominator)._normalize();
  }

  Fraction operator *(Fraction other) {
    int newNumerator = numerator * other.numerator;
    int newDenominator = denominator * other.denominator;
    return Fraction(newNumerator, newDenominator)._normalize();
  }

  Fraction operator /(Fraction other) {
    if (other.numerator == 0) throw ArgumentError('Division by zero');
    int newNumerator = numerator * other.denominator;
    int newDenominator = denominator * other.numerator;
    return Fraction(newNumerator, newDenominator)._normalize();
  }

  bool operator >(Fraction other) {
    return numerator * other.denominator > other.numerator * denominator;
  }

  Fraction _normalize() {
    int gcd = _gcd(numerator.abs(), denominator.abs());
    int newNumerator = numerator ~/ gcd;
    int newDenominator = denominator ~/ gcd;
    if (newDenominator < 0) {
      newNumerator = -newNumerator;
      newDenominator = -newDenominator;
    }
    return Fraction(newNumerator, newDenominator);
  }

  int _gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  @override
  String toString() {
    if (denominator == 1) {
      return '$numerator';
    } else {
      return '$numerator/$denominator';
    }
  }

  double toDouble() => numerator / denominator;

  Fraction abs() => Fraction(numerator.abs(), denominator.abs());

  Fraction operator -() => Fraction(-numerator, denominator);

  Fraction round() => Fraction((numerator / denominator).round());

  @override
  bool operator ==(Object other) {
    if (other is Fraction) {
      return numerator == other.numerator && denominator == other.denominator;
    } else {
      return false;
    }
  }

  @override
  int get hashCode => numerator.hashCode ^ denominator.hashCode;
}
