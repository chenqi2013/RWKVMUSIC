import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class AudioPlayerManage {
  static AudioPlayerManage _instance = AudioPlayerManage._internal();
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
    await audioPlayer
        .play(AssetSource(path))
        .then((value) => isMP3Playing.value = true);
  }
}
