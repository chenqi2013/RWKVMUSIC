import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class AudioPlayerManage {
  static final AudioPlayerManage _instance = AudioPlayerManage._internal();
  factory AudioPlayerManage() => _instance;
  late AudioPlayer audioPlayer;
  var isMP3Playing = false.obs;
  AudioPlayerManage._internal() {
    audioPlayer = AudioPlayer();
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        isMP3Playing.value = true;
      } else {
        isMP3Playing.value = false;
      }
    });
  }

  Future<void> playAudio(String path) async {
    audioPlayer.resume();
    audioPlayer
        .play(AssetSource(path))
        .then((value) => isMP3Playing.value = true);
  }

  Future<void> stopAudio() async {
    print('pause audio');
    audioPlayer.pause();
  }
}
