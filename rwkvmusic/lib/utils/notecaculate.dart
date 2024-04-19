class NoteCaculate {
  static final NoteCaculate _instance = NoteCaculate._internal();
  factory NoteCaculate() => _instance;
  NoteCaculate._internal() {
    print('_internal');
  }
  var noteMap = {};
  var defaultNoteLength = "1/4";
  int getNoteLengthIndex(String note, int index) {
    String realNote = noteMap[index] ?? note;
    switch (defaultNoteLength) {
      case "1/4":
        {
          if (realNote.contains("/2")) {
            return 1;
          } else if (realNote.contains("/4")) {
            return 2;
          } else {
            return 0;
          }
        }
        break;
      case "1/8":
        {
          if (realNote.contains("/2")) {
            return 2;
          } else if (realNote.contains("2")) {
            return 0;
          } else {
            return 1;
          }
        }
        break;
      case "1/16":
        {
          if (realNote.contains("4")) {
            return 0;
          } else if (realNote.contains("2")) {
            return 1;
          } else {
            return 2;
          }
        }
        break;
      default:
        return 0;
    }
  }

  String calculateNewNoteByLength(String note, String newNoteLength) {
    String defaultNoteLength =
        '1/4'; //_settingStateFlow.value.defaultNoteLength;
    String newNote = note;
    switch (defaultNoteLength) {
      case "1/4":
        {
          switch (newNoteLength) {
            case "1/4":
              {
                // do nothing
              }
              break;
            case "1/8":
              {
                newNote = "$note/2";
              }
              break;
            case "1/16":
              {
                newNote = "$note/4";
              }
              break;
          }
        }
        break;
      case "1/8":
        {
          switch (newNoteLength) {
            case "1/4":
              {
                newNote = "${note}2";
              }
              break;
            case "1/8":
              {
                // do nothing
              }
              break;
            case "1/16":
              {
                newNote = "$note/2";
              }
              break;
          }
        }
        break;
      case "1/16":
        {
          switch (newNoteLength) {
            case "1/4":
              {
                newNote = "${note}4";
              }
              break;
            case "1/8":
              {
                newNote = "${note}2";
              }
              break;
            case "1/16":
              {
                // do nothing
              }
              break;
          }
        }
        break;
    }
    print(
        "calculateNewNoteByLength: note=$note, defaultNoteLength=$defaultNoteLength, newNoteLength=$newNoteLength, newNote=$newNote");
    return newNote;
  }
}
