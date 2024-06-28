import 'dart:ffi';


abstract class JsCallback {
  void onEvents(String? events);
  void onStartPlay(bool isUserClick, Long duration);
  void onPausePlay();
  void onResumePlay();
  void onPlayFinish();
  void onCountPromptNoteNumber(Int count);
  void onClickNote(String note, Int index);
}
