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
}
