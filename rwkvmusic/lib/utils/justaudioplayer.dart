import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
// import 'package:just_audio/just_audio.dart'; //windows报错，找不到方法

class JustAudioPlayerManage {
  static final JustAudioPlayerManage _instance =
      JustAudioPlayerManage._internal();
  factory JustAudioPlayerManage() => _instance;
  late AudioPlayer audioPlayer;
  var isMP3Playing = false.obs;
  JustAudioPlayerManage._internal() {
    audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    // audioPlayer.onPlayerStateChanged.listen((state) {
    //   if (state == PlayerState.playing) {
    //     isMP3Playing.value = true;
    //   } else {
    //     isMP3Playing.value = false;
    //   }
    // });
  }

  Future<void> playAudio(String path) async {
    //方案1 使用audioplayers库
    await audioPlayer.stop();
    await audioPlayer.play(AssetSource(path));

    // //方案二 使用just_audio库
    // // await audioPlayer.setFilePath(
    // //     'assets/player/soundfont/acoustic_guitar_steel-mp3/A0.mp3');
    // await audioPlayer
    //     .setAudioSource(AudioSource.uri(Uri.parse('asset:///assets/$path')));
    // // await audioPlayer.setAudioSource(
    // //     AudioSource.uri(Uri.parse('asset:///assets/player/test.mp3')));

    // await audioPlayer.setClip(
    //     start: const Duration(seconds: 0),
    //     end: const Duration(milliseconds: 500));
    // await audioPlayer.play();
    print('playAudio');
  }

  Future<void> stopAudio() async {
    print('stopAudio');
    await audioPlayer.stop();
  }
}
