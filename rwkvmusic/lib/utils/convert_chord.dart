import 'dart:math';
import 'dart:core';

const List<int> MAJOR_SCALE = [0, 2, 4, 5, 7, 9, 11];
const List<int> MINOR_SCALE = [0, 2, 3, 5, 7, 8, 10];

const Map<String, int> NOTE_TO_SEMITONE = {
  'C': 0,
  '^C': 1,
  '_C': -1,
  '=C': 0,
  'D': 2,
  '^D': 3,
  '_D': 1,
  '=D': 2,
  'E': 4,
  '^E': 5,
  '_E': 3,
  '=E': 4,
  'F': 5,
  '^F': 6,
  '_F': 4,
  '=F': 5,
  'G': 7,
  '^G': 8,
  '_G': 6,
  '=G': 7,
  'A': 9,
  '^A': 10,
  '_A': 8,
  '=A': 9,
  'B': 11,
  '^B': 0,
  '_B': 10,
  '=B': 11,
  'c': 0,
  '^c': 1,
  '_c': -1,
  '=c': 0,
  'd': 2,
  '^d': 3,
  '_d': 1,
  '=d': 2,
  'e': 4,
  '^e': 5,
  '_e': 3,
  '=e': 4,
  'f': 5,
  '^f': 6,
  '_f': 4,
  '=f': 5,
  'g': 7,
  '^g': 8,
  '_g': 6,
  '=g': 7,
  'a': 9,
  '^a': 10,
  '_a': 8,
  '=a': 9,
  'b': 11,
  '^b': 0,
  '_b': 10,
  '=b': 11,
};

const Map<int, String> SEMITONE_TO_NOTE = {
  0: 'C',
  1: '^C',
  2: 'D',
  3: '^D',
  4: 'E',
  5: 'F',
  6: '^F',
  7: 'G',
  8: '^G',
  9: 'A',
  10: '^A',
  11: 'B'
};

String convertAccidentals(String note) {
  if (note.contains('##')) {
    note = '^^${note[0]}';
  } else if (note.contains('bb')) {
    note = '__${note[0]}';
  } else if (note.contains('#')) {
    note = '^${note[0]}';
  } else if (note.contains('b')) {
    note = '_${note[0]}';
  }
  return note;
}

String convertBack(String note) {
  if (note.contains('^')) {
    note = '${note[note.length - 1]}#';
  } else if (note.contains('_')) {
    note = '${note[note.length - 1]}b';
  }
  return note;
}

class Tonic {
  String name = '';
  int semitone = 0;

  Tonic(String name) {
    this.name = convertBack(name);
    semitone = NOTE_TO_SEMITONE[convertAccidentals(name)]!;
  }

  Tonic transpose(int interval) {
    int newSemitone = (semitone + interval) % 12;
    String newName = SEMITONE_TO_NOTE[newSemitone]!;
    return Tonic(newName);
  }
}

class Key {
  Tonic tonic;
  String mode;

  Key(String tonic, String mode)
      : tonic = Tonic(tonic),
        mode = mode;

  @override
  String toString() {
    return '${tonic.name} ${mode[0].toUpperCase()}${mode.substring(1)}';
  }
}

List<int> abcToPitches(String abcString) {
  RegExp notePattern = RegExp(r'[_^=]?[A-Ga-g]');
  Iterable<Match> matches = notePattern.allMatches(abcString);
  List<int> pitches =
      matches.map((match) => NOTE_TO_SEMITONE[match.group(0)]!).toList();
  return pitches;
}

Map<int, int> computeHistogram(List<int> pitches) {
  Map<int, int> histogram = {};
  for (int pitch in pitches) {
    if (!histogram.containsKey(pitch)) {
      histogram[pitch] = 0;
    }
    histogram[pitch] = histogram[pitch]! + 1;
  }
  return histogram;
}

int calculateKeyScore(Map<int, int> histogram, List<int> scaleTemplate) {
  int maxScore = 0;
  int bestKey = 0;
  for (int tonic = 0; tonic < 12; tonic++) {
    int score = scaleTemplate.fold(
        0, (sum, interval) => sum + (histogram[(tonic + interval) % 12] ?? 0));
    if (score > maxScore) {
      maxScore = score;
      bestKey = tonic;
    }
  }
  return bestKey;
}

Key analyzeKey(String abcString) {
  RegExp keyPattern = RegExp(r'K:([A-Ga-g][#b]?m?)');
  Match? keyMatch = keyPattern.firstMatch(abcString);

  if (keyMatch != null) {
    String tonic = keyMatch.group(1)!;
    String mode = tonic.toLowerCase().endsWith('m') ? 'minor' : 'major';
    tonic = mode == 'minor' ? tonic.substring(0, tonic.length - 1) : tonic;
    return Key(tonic, mode);
  }

  List<int> pitches = abcToPitches(abcString);
  Map<int, int> histogram = computeHistogram(pitches);

  int majorKey = calculateKeyScore(histogram, MAJOR_SCALE);
  int minorKey = calculateKeyScore(histogram, MINOR_SCALE);

  String majorKeyName = NOTE_TO_SEMITONE.keys
      .firstWhere((key) => NOTE_TO_SEMITONE[key] == majorKey);
  String minorKeyName = NOTE_TO_SEMITONE.keys
      .firstWhere((key) => NOTE_TO_SEMITONE[key] == minorKey);

  if ((histogram[majorKey] ?? 0) >= (histogram[minorKey] ?? 0)) {
    return Key(majorKeyName.toUpperCase(), 'major');
  } else {
    return Key(minorKeyName.toUpperCase(), 'minor');
  }
}

List<Map<String, dynamic>> analyzeNotes(String abcNotation) {
  List<String> lines = abcNotation.trim().split('\n');
  double defaultNoteLength = 1.0;

  for (String line in lines) {
    if (line.startsWith('L:')) {
      List<String> lengthParts = line.split(':')[1].trim().split('/');
      defaultNoteLength =
          (int.parse(lengthParts[0]) / int.parse(lengthParts[1])) / 0.25;
    }
  }

  RegExp notePattern = RegExp(r'''([_^=]?[A-Ga-gzZ])([\',]*)?(\d*\/?\d*)?''');
  List<Map<String, dynamic>> notes = [];
  double offset = 0;

  for (String line in lines) {
    if (line.startsWith('X:') ||
        line.startsWith('T:') ||
        line.startsWith('L:') ||
        line.startsWith('M:') ||
        line.startsWith('K:') ||
        line.startsWith('Q:')) {
      continue;
    }

    Iterable<Match> matches = notePattern.allMatches(line);
    for (Match match in matches) {
      String pitch = match.group(1)!;
      String? octaveModifier = match.group(2);
      String? lengthStr = match.group(3);

      double noteLength = defaultNoteLength;
      if (lengthStr != null && lengthStr.isNotEmpty) {
        if (lengthStr.contains('/')) {
          List<String> lengthParts = lengthStr.split('/');
          noteLength = lengthParts.length == 1
              ? defaultNoteLength / 2
              : (int.parse(lengthParts[0]) / int.parse(lengthParts[1])) *
                  defaultNoteLength;
        } else {
          noteLength = int.parse(lengthStr) * defaultNoteLength;
        }
      }

      if (pitch.toLowerCase() == 'z') {
        pitch = 'rest';
      }
      // else {
      //   int octaveShift = 0;
      //   if (octaveModifier != null) {
      //     if (pitch.toLowerCase() == pitch) {
      //       octaveShift = 1;
      //     }
      //     octaveShift += "'".allMatches(octaveModifier).length;
      //     octaveShift -= ",".allMatches(octaveModifier).length;
      //   }
      //   pitch = pitch.toUpperCase() + "'" * octaveShift;
      // }

      notes.add({
        'pitch': pitch,
        'offset': offset,
        'quarterLength': noteLength,
      });
      offset += noteLength;
    }
  }
  return notes;
}

List<int> getTopIndices(Map<int, double> scoreDict, int n) {
  List<MapEntry<int, double>> sortedEntries = scoreDict.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sortedEntries.take(n).map((entry) => entry.key).toList();
}

Map<int, List<int>> generateChordMaps(Key keySignature) {
  if (keySignature.mode == 'major') {
    return {
      1: [0, 4, 7],
      2: [2, 5, 9],
      3: [4, 7, 11],
      4: [5, 9, 0],
      5: [7, 11, 2],
      6: [9, 0, 4],
      7: [11, 2, 5]
    };
  } else if (keySignature.mode == 'minor') {
    return {
      6: [0, 3, 7],
      7: [2, 5, 8],
      1: [3, 7, 10],
      2: [5, 8, 0],
      3: [7, 10, 2],
      4: [8, 0, 3],
      5: [10, 2, 5]
    };
  } else {
    throw ArgumentError('Unsupported mode');
  }
}

Map<int, String> generateChordNames(Key keySignature) {
  Tonic tonic = keySignature.tonic;

  if (keySignature.mode == 'major') {
    return {
      1: tonic.name,
      2: '${tonic.transpose(2).name}m',
      3: '${tonic.transpose(4).name}m',
      4: tonic.transpose(5).name,
      5: tonic.transpose(7).name,
      6: '${tonic.transpose(9).name}m',
      7: '${tonic.transpose(11).name}dim'
    };
  } else if (keySignature.mode == 'minor') {
    return {
      6: '${tonic.name}m',
      7: '${tonic.transpose(2).name}dim',
      1: tonic.transpose(3).name,
      2: '${tonic.transpose(5).name}m',
      3: '${tonic.transpose(7).name}m',
      4: tonic.transpose(8).name,
      5: tonic.transpose(10).name
    };
  } else {
    throw ArgumentError('Unsupported mode');
  }
}

List<dynamic> analyzeChords(
    List<List<List<String>>> notesByMeasure,
    Map<int, List<int>> chordMap,
    Map<int, String> chordNames,
    Key keySignature,
    String M) {
  const int chordBegin = 1;
  const int chordEnd = 7;
  const double BIAS = 1.0;
  Map<int, Map<int, double>> scoreProg0 = {
    1: {1: 24, 2: 2, 3: 2, 4: 20, 5: 24, 6: 35, 7: 2},
    2: {1: 35, 2: 2, 3: 1, 4: 4, 5: 86, 6: 4, 7: 1},
    3: {1: 40, 2: 5, 3: 0, 4: 85, 5: 20, 6: 8, 7: 1},
    4: {1: 20, 2: 1, 3: 1, 4: 1, 5: 76, 6: 1, 7: 1},
    5: {1: 70, 2: 1, 3: 2, 4: 13, 5: 1, 6: 14, 7: 1},
    6: {1: 5, 2: 25, 3: 1, 4: 49, 5: 39, 6: 1, 7: 1},
    7: {1: 70, 2: 1, 3: 1, 4: 1, 5: 20, 6: 10, 7: 1}
  };

  for (int c1 = chordBegin; c1 <= chordEnd; c1++) {
    double totalSum =
        scoreProg0[c1]!.values.fold(0, (sum, score) => sum + (score + BIAS));
    scoreProg0[c1] = scoreProg0[c1]!
        .map((c2, score) => MapEntry(c2, log((score + BIAS) / totalSum)));
  }

  int chordLen = notesByMeasure.length;
  List<String> out = List<String>.filled(chordLen, chordNames[chordBegin]!);

  List<Map<int, double>> score = List.generate(chordLen, (_) => {});
  for (int i = 0; i < chordLen; i++) {
    if (i == 0) {
      score[i] = {1: 0.6, 2: 0.2, 3: 0.1, 4: 0.5, 5: 0.4, 6: 0.3, 7: 0.05};
    } else {
      score[i] = {1: 0.4, 2: 0.2, 3: 0.1, 4: 0.5, 5: 0.6, 6: 0.3, 7: 0.1};
    }
  }

  List<List<int>> candidate = List.generate(chordLen, (_) => []);

  Map<String, List<double>> beatWeights = {
    '2/4': [0.2, 0.1],
    '3/4': [0.2, 0, 0],
    '4/4': [0.2, 0, 0.1, 0],
    '3/8': [0.2, 0, 0],
    '6/8': [0.2, 0, 0, 0.1, 0, 0],
    '12/8': [0.2, 0, 0, 0.1, 0, 0, 0.2, 0, 0, 0.1, 0, 0]
  };

  List<double> additionWeights = beatWeights[M]!;
  List<double> deductionWeights = beatWeights[M]!;

  for (int i = 0; i < chordLen; i++) {
    for (int c = chordBegin; c <= chordEnd; c++) {
      for (int beatIndex = 0;
          beatIndex < notesByMeasure[i].length;
          beatIndex++) {
        List<String> beat = notesByMeasure[i][beatIndex];
        bool containsChordNote = beat.any((n) =>
            (NOTE_TO_SEMITONE[n]! - keySignature.tonic.semitone) % 12 ==
            chordMap[c]![0]);
        bool containsRootNote = beat.any((n) =>
            (NOTE_TO_SEMITONE[n]! - keySignature.tonic.semitone) % 12 ==
            chordMap[c]![0]);

        if (containsChordNote) {
          score[i][c] = (score[i][c] ?? 0) + 1;
          if (containsRootNote) {
            score[i][c] = (score[i][c] ?? 0) +
                additionWeights[beatIndex % additionWeights.length];
          }
        } else {
          score[i][c] = (score[i][c] ?? 0) -
              deductionWeights[beatIndex % deductionWeights.length];
        }
      }
    }
    candidate[i] = getTopIndices(score[i], 2);
  }

  double bestScore = -1e10;
  String bestPlan = '';
  for (int i = 0; i < pow(2, chordLen); i++) {
    String plan = i.toRadixString(2).padLeft(chordLen, '0');
    double sumScore = 0;
    for (int j = 0; j < chordLen; j++) {
      int c1 = candidate[j][int.parse(plan[j])];
      sumScore += (score[j][c1] ?? 0) * 0.5;
      if (j < chordLen - 1) {
        int c2 = candidate[j + 1][int.parse(plan[j + 1])];
        sumScore += scoreProg0[c1]![c2]!;
      }
    }
    if (sumScore > bestScore) {
      bestScore = sumScore;
      bestPlan = plan;
    }
  }

  for (int i = 0; i < chordLen; i++) {
    out[i] = chordNames[candidate[i][int.parse(bestPlan[i])]]!;
  }

  return out;
}

List<List<List<String>>> extractNotesAndMeasures(String abcNotation) {
  List<List<List<String>>> notesByMeasure = [];

  List<String> lines = abcNotation.split('\n');
  String M = '4/4';
  for (String line in lines) {
    if (line.startsWith('M:') &&
        RegExp(r'\d').hasMatch(line) &&
        line.contains('/')) {
      M = line.split(':')[1].trim();
    }
  }

  Map<String, double> beatDurations = {
    '2/4': 1,
    '3/4': 1,
    '4/4': 1,
    '3/8': 0.5,
    '6/8': 0.5,
    '12/8': 0.5
  };
  Map<String, int> beatsPerMeasure = {
    '2/4': 2,
    '3/4': 3,
    '4/4': 4,
    '3/8': 3,
    '6/8': 6,
    '12/8': 12
  };

  double beatDuration = beatDurations[M]!;
  int numBeats = beatsPerMeasure[M]!;

  List<Map<String, dynamic>> allNotes = analyzeNotes(abcNotation);
  List<List<String>> beats = [];

  for (Map<String, dynamic> n in allNotes) {
    int startBeat = (n['offset'] / beatDuration).floor();
    int endBeat =
        ((n['offset'] + n['quarterLength']) / beatDuration).ceil() - 1;
    endBeat = max(endBeat, 0);

    for (int beatIndex = startBeat; beatIndex <= endBeat; beatIndex++) {
      while (beats.length <= beatIndex) {
        beats.add([]);
      }
      if (n['pitch'] != 'rest') {
        beats[beatIndex].add(n['pitch']);
      }
    }
  }

  for (int i = 0; i < beats.length; i += numBeats) {
    List<List<String>> measure =
        beats.sublist(i, min(i + numBeats, beats.length));
    while (measure.length < numBeats) {
      measure.add([]);
    }
    notesByMeasure.add(measure);
  }

  return notesByMeasure;
}

List<dynamic> generateChordAbcNotation(String abcNotation) {
  Key keySignature = analyzeKey(abcNotation);
  Map<int, List<int>> chordMap = generateChordMaps(keySignature);
  Map<int, String> chordNames = generateChordNames(keySignature);
  List<List<List<String>>> notesByMeasure =
      extractNotesAndMeasures(abcNotation);

  return [
    analyzeChords(notesByMeasure, chordMap, chordNames, keySignature, '4/4'),
    keySignature
  ];
}

void main() {
  String abcNotation = """L:1/4
M:4/4
Q: 90
z z z A/B/ d3/2-e/ ^f/^c/ B/4^c/4B/4A/4 B3 d/e/ ^f3/2-a/ b/d/ e/4^f/4 g/ ^f3 ^f/a/ b3/2 a/ b""";

  List<dynamic> chords = generateChordAbcNotation(abcNotation);
  print(chords);
}
