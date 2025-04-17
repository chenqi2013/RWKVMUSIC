import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/style/color.dart';

class PlayProgressBar extends StatelessWidget {
  PlayProgressBar(
      {super.key,
      required this.currentSliderValue,
      required this.totalTime,
      required this.onPressed,
      required this.isPlay});
  final RxDouble currentSliderValue;
  final RxDouble totalTime;
  final VoidCallback onPressed;
  bool isPlay;
  @override
  Widget build(BuildContext context) {
    String imgName = isPlay ? 'ic_stop' : 'ic_play';

    return Obx(
      () => Container(
        padding: EdgeInsets.only(left: 15.w, top: 5.h, bottom: 5.h),
        width: isWindowsOrMac ? 1163.w : 984.w,
        height: isWindowsOrMac ? 113.h : 96.h,
        decoration: BoxDecoration(
          color: AppColor.color_2C2C2C,
          borderRadius: BorderRadius.circular(isWindowsOrMac ? 14.h : 12.h),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(.25),
              blurRadius: 1,
              spreadRadius: 0,
              offset: const Offset(
                2,
                2,
              ),
            ),
            const BoxShadow(
              color: Colors.black,
              blurRadius: 1,
              spreadRadius: 0,
              offset: Offset(
                -2,
                -2,
              ),
            ),
          ],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          SvgPicture.asset(
            'assets/images/ic_music.svg',
            width: isWindowsOrMac ? 48.w : 40.w,
            height: isWindowsOrMac ? 53.h : 44.h,
            fit: BoxFit.cover,
          ),
          // 时间显示
          Text(
            formatDuration(Duration(seconds: totalTime.value ~/ 1000.0)),
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
                fontSize: isWindowsOrMac ? 36.sp : 30.sp),
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
          SizedBox(
            width: isWindowsOrMac ? 639.w : 541.w,
            child: Slider(
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
                fontSize: isWindowsOrMac ? 36.sp : 30.sp),
          ),
          GestureDetector(
            onTap: () {
              onPressed();
            },
            child: SizedBox(
              width: 70.w,
              height: 80.h,
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/$imgName.svg',
                  width: isWindowsOrMac ? 50.w : 42.w,
                  height: isWindowsOrMac ? 56.h : 48.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }
}

// Widget ProgressbarTime() {
// return Stack(
//   children: [
//     SvgPicture.asset(
//       'assets/images/playerbg.svg',
//       height: 113.h,
//       fit: BoxFit.cover,
//     ),
//     Positioned(
//       left: 26.w, // 将Text放置在左侧
//       right: 26.w,
//       top: 0,
//       bottom: 0, // 垂直居中的位置
//       child: Align(
//         alignment: Alignment.center,
//         child:
//            ,
//       ),
//     ),
//   ],
// );
// }

String formatDuration(Duration duration) {
  int minutes = duration.inMinutes;
  int seconds = duration.inSeconds % 60;
  // print('second==$seconds');
  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}
