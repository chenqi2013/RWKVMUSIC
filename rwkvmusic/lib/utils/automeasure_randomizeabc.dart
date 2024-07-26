import 'dart:math';
import 'dart:core';

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
      // Dart 正则表达式，相当于 Python 的 re.findall
      RegExp regExp = RegExp(
          r'''(?:[^\"]|\"[^\"]*\")*?([\-]?[\^_=]?[A-Ga-gz][,\']*[\d/]*)''');

      // 使用 allMatches 方法查找所有匹配项
      Iterable<Match> matches = regExp.allMatches(line);

      // 提取匹配的音符事件并存储到列表中
      notes = matches.map((match) => match.group(1)!).toList();
    }
  }

  return [header, notes];
}

Map<String, dynamic> parseNoteLength(String note) {
  RegExp regExp = RegExp(r'''([\-]?[\^_=]?[A-Ga-gz][,\']*)(\d+)?(/(\d+)?)?''');
  Match? match = regExp.firstMatch(note);
  if (match == null) {
    return {
      'note': note,
      'length': Fraction(1, 1),
    };
  }

  String noteChar = match.group(1)!;
  String numerator = match.group(2) ?? '1';
  String denominator = match.group(4) ?? (match.group(3) != null ? '2' : '1');

  return {
    'note': noteChar,
    'length': Fraction(int.parse(numerator), int.parse(denominator)),
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

  for (String note in notes) {
    var parsedNote = parseNoteLength(note);
    String noteChar = parsedNote['note'];
    Fraction noteLength = parsedNote['length'];

    if (currentLength + noteLength > barLength) {
      Fraction remainingLength = barLength - currentLength;
      bar.add('$noteChar$remainingLength');
      bars.add(bar);
      Fraction partLength = noteLength - remainingLength;

      while (partLength > barLength) {
        bar = ['-$noteChar$barLength'];
        bars.add(bar);
        partLength -= barLength;
      }

      bar = ['-$noteChar$partLength'];
      currentLength = partLength;
    } else {
      bar.add(note);
      currentLength += noteLength;
    }

    if (currentLength == barLength) {
      bars.add(bar);
      bar = [];
      currentLength = Fraction(0, 1);
    }
  }

  if (bar.isNotEmpty) {
    bars.add(bar);
  }

  return checkAndSplitNotes(bars);
}

String formatBars(Map<String, String> header, List<List<String>> bars) {
  String formattedAbc = 'L:${header['L']}\nM:${header['M']}\n';
  for (int i = 0; i < bars.length; i++) {
    formattedAbc += bars[i].join(' ');
    if (i < bars.length - 1) {
      formattedAbc += ' |';
    }
  }
  return formattedAbc.trim();
}

String formatBars_1(Map<String, String> header, List<List<String>> bars) {
  String formattedAbc =
      'L:${header['L']}\nM:${header['M']}\nK:${header['K']}\n';
  for (int i = 0; i < bars.length; i++) {
    formattedAbc += bars[i].join(' ');
    if (i < bars.length - 1) {
      formattedAbc += ' |';
    }
  }
  return formattedAbc.trim();
}

String splitMeasureAbc(String abcNotation) {
  var result = parseAbc(abcNotation);
  var header = result[0];
  List<String> notes = result[1];
  Fraction barLength = calculateBarLength(header['M'], header['L']);
  List<List<String>> bars = divideIntoBars(notes, barLength);
  return formatBars(header, bars);
}

String splitMeasureAbc_end(String abcNotation) {
  var result = parseAbc(abcNotation);
  var header = result[0];
  List<String> notes = result[1];
  Fraction barLength = calculateBarLength(header['M'], header['L']);
  List<List<String>> bars = divideIntoBars(notes, barLength);
  return formatBars_1(header, bars);
}

String formatNotes(Map<String, String> header, List<String> notes) {
  String formattedAbc =
      'L:${header['L']}\nM:${header['M']}\nK:${header['K']}\n';
  formattedAbc += notes.join(' ');
  return formattedAbc.trim();
}

List<String> randomizeNoteLengths(List<String> notes) {
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
  notes = randomizeNoteLengths(notes);

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
