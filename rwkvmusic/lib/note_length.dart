/// https://en.wikipedia.org/wiki/Note_value
enum NoteLength {
  whole,
  wholeDotted,
  half,
  halfDotted,
  quarter,
  quarterDotted,
  eighth,
  eighthDotted,
  sixteenth,
  sixteenthDotted,
  thirtySecond,
  thirtySecondDotted,
}

extension NoteLengthAdapter on NoteLength {
  String get britishName {
    switch (this) {
      case NoteLength.whole:
      case NoteLength.wholeDotted:
        return "semibreve";
      case NoteLength.half:
      case NoteLength.halfDotted:
        return "minim";
      case NoteLength.quarter:
      case NoteLength.quarterDotted:
        return "crotchet";
      case NoteLength.eighth:
      case NoteLength.eighthDotted:
        return "quaver";
      case NoteLength.sixteenth:
      case NoteLength.sixteenthDotted:
        return "semiquaver";
      case NoteLength.thirtySecond:
      case NoteLength.thirtySecondDotted:
        return "demisemiquaver";
    }
  }

  double get duration {
    switch (this) {
      case NoteLength.whole:
        return 1.0;
      case NoteLength.wholeDotted:
        return 1 * 1.5;
      case NoteLength.half:
        return 0.5;
      case NoteLength.halfDotted:
        return 0.5 * 1.5;
      case NoteLength.quarter:
        return 0.25;
      case NoteLength.quarterDotted:
        return 0.25 * 1.5;
      case NoteLength.eighth:
        return 0.125;
      case NoteLength.eighthDotted:
        return 0.125 * 1.5;
      case NoteLength.sixteenth:
        return 0.0625;
      case NoteLength.sixteenthDotted:
        return 0.0625 * 1.5;
      case NoteLength.thirtySecond:
        return 0.03125;
      case NoteLength.thirtySecondDotted:
        return 0.03125 * 1.5;
    }
  }

  String get end {
    switch (this) {
      case NoteLength.whole:
        return "4";
      case NoteLength.wholeDotted:
        return "6";
      case NoteLength.half:
        return "2";
      case NoteLength.halfDotted:
        return "3";
      case NoteLength.quarter:
        return "1";
      case NoteLength.quarterDotted:
        return "3/2";
      case NoteLength.eighth:
        return "1/2";
      case NoteLength.eighthDotted:
        return "3/4";
      case NoteLength.sixteenth:
        return "1/4";
      case NoteLength.sixteenthDotted:
        return "3/8";
      case NoteLength.thirtySecond:
        return "1/8";
      case NoteLength.thirtySecondDotted:
        return "3/16";
    }
  }

  NoteLength fromString(String notation) {
    if (notation.endsWith("6")) return NoteLength.wholeDotted;
    if (notation.endsWith("3")) return NoteLength.halfDotted;
    if (notation.endsWith("3/2")) return NoteLength.quarterDotted;
    if (notation.endsWith("3/4")) return NoteLength.eighthDotted;
    if (notation.endsWith("3/8")) return NoteLength.sixteenthDotted;
    if (notation.endsWith("3/16")) return NoteLength.thirtySecondDotted;
    if (notation.endsWith("1/2")) return NoteLength.eighth;
    if (notation.endsWith("2")) return NoteLength.half;
    if (notation.endsWith("1/4")) return NoteLength.sixteenth;
    if (notation.endsWith("4")) return NoteLength.whole;
    if (notation.endsWith("1/8")) return NoteLength.thirtySecond;
    return NoteLength.quarter;
  }

  NoteLength fromLength(num duration) {
    if (duration == 1.5) return NoteLength.wholeDotted;
    if (duration == 1.5 * 0.5) return NoteLength.halfDotted;
    if (duration == 1.5 * 0.25) return NoteLength.quarterDotted;
    if (duration == 1.5 * 0.125) return NoteLength.eighthDotted;
    if (duration == 1.5 * 0.0625) return NoteLength.sixteenthDotted;
    if (duration == 1.5 * 0.03125) return NoteLength.thirtySecondDotted;
    if (duration == 1.0) return NoteLength.whole;
    if (duration == 0.5) return NoteLength.half;
    if (duration == 0.25) return NoteLength.quarter;
    if (duration == 0.125) return NoteLength.eighth;
    if (duration == 0.0625) return NoteLength.sixteenth;
    if (duration == 0.03125) return NoteLength.thirtySecond;
    return NoteLength.quarter;
  }
}
