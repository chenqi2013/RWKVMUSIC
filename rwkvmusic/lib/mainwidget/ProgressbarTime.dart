import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget ProgressbarTime(RxDouble currentSliderValue, RxDouble totalTime) {
  return Row(children: [
    // 播放进度条
    SliderTheme(
      data: SliderThemeData(
        activeTrackColor: Colors.black, // 进度颜色
        inactiveTrackColor: Colors.white, // 未选中的轨道颜色
        thumbColor: Colors.white, // 圆点颜色
        overlayColor: Colors.white.withOpacity(0.3), // 圆点覆盖颜色
        valueIndicatorColor: Colors.white, // 数值指示器颜色
        valueIndicatorTextStyle:
            const TextStyle(color: Colors.white), // 数值指示器文本样式
      ),
      child: Slider(
        value: currentSliderValue.value,
        min: 0.0,
        max: 1.0,
        onChanged: (value) {
          currentSliderValue.value = value;
        },
      ),
    ),
    // 时间显示
    Text(
      formatDuration(Duration(
          seconds:
              (totalTime.value / 1000.0 * currentSliderValue.value).toInt())),
      style: const TextStyle(color: Colors.white),
    ),
  ]);
}

String formatDuration(Duration duration) {
  int minutes = duration.inMinutes;
  int seconds = duration.inSeconds % 60;
  // print('second==$seconds');
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
