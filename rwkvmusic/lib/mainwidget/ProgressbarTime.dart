import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

Widget ProgressbarTime(RxDouble currentSliderValue, RxDouble totalTime,
    VoidCallback onPressed, bool isPlay) {
  String imgName = isPlay ? 'ic_stop' : 'ic_play';
  return Stack(
    children: [
      SvgPicture.asset(
        'assets/images/playerbg.svg',
        height: 113.h,
        fit: BoxFit.cover,
      ),
      Positioned(
        left: 26.w, // 将Text放置在左侧
        right: 26.w,
        top: 0,
        bottom: 0, // 垂直居中的位置
        child: Align(
          alignment: Alignment.center,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            SvgPicture.asset(
              'assets/images/ic_music.svg',
              width: 48.w,
              height: 53.h,
              fit: BoxFit.cover,
            ),
            // 时间显示
            Text(
              formatDuration(Duration(seconds: totalTime.value ~/ 1000.0)),
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 36.sp),
            ),
            // 播放进度条
            // SliderTheme(
            //   data: SliderThemeData(
            //     activeTrackColor: Colors.black, // 进度颜色
            //     inactiveTrackColor: Colors.white, // 未选中的轨道颜色
            //     thumbColor: Colors.white, // 圆点颜色
            //     overlayColor: Colors.white.withOpacity(0.3), // 圆点覆盖颜色
            //     valueIndicatorColor: Colors.white, // 数值指示器颜色
            //     valueIndicatorTextStyle:
            //         const TextStyle(color: Colors.white), // 数值指示器文本样式
            //   ),
            //   child:
            Slider(
              allowedInteraction: SliderInteraction.tapOnly,
              activeColor: Colors.white,
              inactiveColor: Colors.black,
              thumbColor: Colors.white,
              value: currentSliderValue.value,
              min: 0.0,
              max: 1.0,
              onChanged: (value) {
                // currentSliderValue.value = value;
              },
            ),
            // ),
            // 时间显示
            Text(
              formatDuration(Duration(
                  seconds: (totalTime.value / 1000.0 * currentSliderValue.value)
                      .toInt())),
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 36.sp),
            ),

            InkWell(
                onTap: () {
                  // 按钮被点击时执行的操作
                  onPressed();
                },
                child: SvgPicture.asset(
                  'assets/images/$imgName.svg',
                  width: 50.w,
                  height: 56.h,
                  fit: BoxFit.cover,
                )),
          ]),
        ),
      ),
    ],
  );
}

String formatDuration(Duration duration) {
  int minutes = duration.inMinutes;
  int seconds = duration.inSeconds % 60;
  // print('second==$seconds');
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
