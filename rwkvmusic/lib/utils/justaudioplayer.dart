// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart'; //windows报错，找不到方法
import 'package:soundpool/soundpool.dart';

class JustAudioPlayerManage {
  static final JustAudioPlayerManage _instance =
      JustAudioPlayerManage._internal();
  factory JustAudioPlayerManage() => _instance;
  late AudioPlayer audioPlayer;
  var isMP3Playing = false.obs;
  Soundpool? pool;
  int? streamId;
  JustAudioPlayerManage._internal() {
    pool = Soundpool.fromOptions(options: SoundpoolOptions.kDefault);
    // audioPlayer = AudioPlayer();
    // // audioPlayer.onPlayerStateChanged.listen((state) {
    // //   if (state == PlayerState.playing) {
    // //     isMP3Playing.value = true;
    // //   } else {
    // //     isMP3Playing.value = false;
    // //   }
    // // });
  }

  Future<void> playAudio(String path) async {
    // //方案1 使用audioplayers库
    // await audioPlayer.resume();
    // await audioPlayer.play(AssetSource(path), mode: PlayerMode.mediaPlayer);

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

    // 方案三-------低延时播放，，，//"assets/player/soundfont/acoustic_grand_piano-mp3/A3.mp3"
    debugPrint('path===$path');
    int soundId =
        await rootBundle.load('assets/$path').then((ByteData soundData) {
      return pool!.load(soundData);
    });
    streamId = await pool!.play(soundId);
    debugPrint('streamId=$streamId');
    debugPrint('playAudio');
  }

  Future<void> stopAudio() async {
    // await audioPlayer.pause();
    if (streamId != null) {
      await pool!.stop(streamId!);
    }
    debugPrint('stopAudio');
  }
}
