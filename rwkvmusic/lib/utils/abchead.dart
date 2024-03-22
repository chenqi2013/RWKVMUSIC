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

  static String appendTempoParam(String abc, int tempo) {
    String tempoConfig = "Q:$tempo";
    if (abc.contains("Q:")) {
      return abc.replaceAll(RegExp(r"Q:\d+"), tempoConfig);
    } else {
      return abc;
      // return "$tempoConfig\n$abc";
    }
  }
}
