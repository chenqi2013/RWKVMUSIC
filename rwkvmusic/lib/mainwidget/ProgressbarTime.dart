import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget ProgressbarTime(double _currentSliderValue) {
  return Row(children: [
    // 播放进度条
    Slider(
      value: _currentSliderValue,
      min: 0.0,
      max: 1.0,
      onChanged: (value) {
        // setState(() {
        _currentSliderValue = value;
        // _currentTime = Duration(seconds: (_totalDuration.inSeconds * value).round());
        // });
      },
    ),

    // 时间显示
    Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatDuration(Duration(seconds: 0))),
            Text(formatDuration(Duration(seconds: 20))),
          ],
        ))
  ]);
}

String formatDuration(Duration duration) {
  int minutes = duration.inMinutes;
  int seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
