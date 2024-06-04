import 'dart:convert';

class ABCHead {
  static const String headContent = "L:1/4\n"
      "M:4/4\n"
      "K:C\n";
  static const String headContentForEmpty = "L:1/8\n"
      "M:4/4\n"
      "K:C\n"
      "\"C\"";

  static String getABCWithInstrument(String? content, int instrumentType) {
    return "%%MIDI program $instrumentType\\n$content";
  }

  static String modifyABCWithInstrument(String content, int instrumentType) {
    String result = content
        .replaceAll('MIDI program 0', 'MIDI program $instrumentType')
        .replaceAll('MIDI program 40', 'MIDI program $instrumentType')
        .replaceAll('MIDI program 79', 'MIDI program $instrumentType')
        .replaceAll('MIDI program 42', 'MIDI program $instrumentType')
        .replaceAll('MIDI program 25', 'MIDI program $instrumentType');

    return result;
  }

  static String appendTempoParam(String abc, int tempo) {
    // String tempoConfig = "Q:$tempo";
    // if (abc.contains("Q:")) {
    //   return abc.replaceAll(RegExp(r"Q:\d+"), tempoConfig);
    // } else {
    return abc;
    // return "$tempoConfig\n$abc";
    // }
  }

  static String base64AbcString(String event) {
    // print('base64AbcString before11--$event');
    String result =
        event.replaceAll('setAbcString("', '').replaceAll('",false)', ''); //%%
    // print('base64AbcString before22--$result');
    String encodedString = base64.encode(utf8.encode(result));
    // debugPrint("Encoded setAbcString: $encodedString");
    String base64AbcString = "setAbcString('$encodedString',false)";
    // print("base64AbcString: $encodedString");
    return base64AbcString;
  }

  static String base64abctoEvents(String playAbcString) {
    String result = playAbcString
        .replaceAll('setAbcString("', '')
        .replaceAll('",false)', '');
    // print('replace==$result');
    String encodedString = base64.encode(utf8.encode(result));
    // print("Encoded string: $encodedString");
    String base64abctoEvents = "ABCtoEvents('$encodedString',false)";
    print("base64abctoEvents: $encodedString");
    return base64abctoEvents;
  }

  static int insertMeasureLinePosition(
      String timeSignatures, String noteLengths) {
    if (timeSignatures == '2/4' && noteLengths == '1/4') {
      return 2;
    } else if (timeSignatures == '2/4' && noteLengths == '1/8') {
      return 4;
    } else if (timeSignatures == '2/4' && noteLengths == '1/16') {
      return 8;
    } else if (timeSignatures == '3/4' && noteLengths == '1/4') {
      return 3;
    } else if (timeSignatures == '3/4' && noteLengths == '1/8') {
      return 6;
    } else if (timeSignatures == '3/4' && noteLengths == '1/16') {
      return 12;
    } else if (timeSignatures == '4/4' && noteLengths == '1/4') {
      return 4;
    } else if (timeSignatures == '4/4' && noteLengths == '1/8') {
      return 8;
    } else if (timeSignatures == '4/4' && noteLengths == '1/16') {
      return 16;
    } else if (timeSignatures == '3/8' && noteLengths == '1/4') {
      return 1;
    } else if (timeSignatures == '3/8' && noteLengths == '1/8') {
      return 3;
    } else if (timeSignatures == '3/8' && noteLengths == '1/16') {
      return 6;
    } else if (timeSignatures == '6/8' && noteLengths == '1/4') {
      return 3;
    } else if (timeSignatures == '6/8' && noteLengths == '1/8') {
      return 6;
    } else if (timeSignatures == '6/8' && noteLengths == '1/16') {
      return 12;
    }

    return 4;
  }
}
