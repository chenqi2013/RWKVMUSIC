import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerManage {
  static final AudioPlayerManage _instance = AudioPlayerManage._internal();
  factory AudioPlayerManage() => _instance;
  late AudioPlayer audioPlayer;
  var isMP3Playing = false.obs;
  AudioPlayerManage._internal() {
    audioPlayer = AudioPlayer();
    // audioPlayer.onPlayerStateChanged.listen((state) {
    //   if (state == PlayerState.playing) {
    //     isMP3Playing.value = true;
    //   } else {
    //     isMP3Playing.value = false;
    //   }
    // });
  }

  Future<void> playAudio(String path) async {
    // await audioPlayer.resume();
    // await audioPlayer.play(AssetSource(path), mode: PlayerMode.mediaPlayer);
    await audioPlayer.setClip(
        start: const Duration(seconds: 0), end: const Duration(seconds: 1));
    await audioPlayer.play();
    print('playAudio');
  }

  Future<void> stopAudio() async {
    print('stopAudio');
    await audioPlayer.pause();
  }
}
