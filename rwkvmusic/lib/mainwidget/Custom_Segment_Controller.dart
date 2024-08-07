import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/style/color.dart';

class CustomSegmentControl extends StatelessWidget {
  CustomSegmentControl(
      {super.key,
      required this.callBack,
      required this.selectedIndex,
      this.segments});
  final segments;
  var selectedIndex = 0.obs;
  final Function(int) callBack;
  @override
  Widget build(BuildContext context) {
    bool isWindowsOrMac = Platform.isWindows || Platform.isMacOS;
    var width = isWindowsOrMac ? 605.w : 535.w;

    return Container(
      // height: 50,
      decoration: BoxDecoration(
        color: AppColor.color_2C2C2C,
        borderRadius: BorderRadius.circular(isWindowsOrMac ? 14.h : 7.h),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(.25),
            blurRadius: 1.18,
            spreadRadius: 0,
            offset: const Offset(
              2.36,
              2.36,
            ),
          ),
          const BoxShadow(
            color: Colors.black,
            blurRadius: 1.18,
            spreadRadius: 0,
            offset: Offset(
              -2.36,
              -2.36,
            ),
          ),
        ],
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(0), //手机端需要设置，否则会有边距
        scrollDirection: Axis.horizontal,
        itemCount: segments.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              // setState(() {
              selectedIndex.value = index;
              callBack(index);
              // });
            },
            child: Obx(() => Container(
                  width: width / 2,
                  alignment: Alignment.center,
                  // padding: EdgeInsets.symmetric(
                  //     horizontal: isWindowsOrMac ? 25.w : 20.w),
                  decoration: BoxDecoration(
                    color: selectedIndex.value == index
                        ? AppColor.color_494949
                        : Colors.transparent,
                    borderRadius:
                        BorderRadius.circular(isWindowsOrMac ? 10.w : 8.w),
                  ),
                  child: Text(
                    segments[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // backgroundColor: Colors.red,
                      color: selectedIndex.value == index
                          ? AppColor.color_ffffff
                          : AppColor.color_757575,
                      fontWeight: FontWeight.bold,
                      fontSize: isWindowsOrMac ? 39.sp : 33.sp,
                    ),
                  ),
                )),
          );
        },
      ),
    );
  }
}

// class CustomSegmentControl extends StatefulWidget {
//   final List<String> segments;

//   const CustomSegmentControl({super.key, required this.segments});

//   @override
//   _CustomSegmentControlState createState() => _CustomSegmentControlState();
// }

// class _CustomSegmentControlState extends State<CustomSegmentControl> {
//   int selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       // height: 50,
//       decoration: BoxDecoration(
//         color: AppColor.color_2C2C2C,
//         borderRadius: BorderRadius.circular(14.h),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.white.withOpacity(.25),
//             blurRadius: 1.18,
//             spreadRadius: 0,
//             offset: const Offset(
//               2.36,
//               2.36,
//             ),
//           ),
//           const BoxShadow(
//             color: Colors.black,
//             blurRadius: 1.18,
//             spreadRadius: 0,
//             offset: Offset(
//               -2.36,
//               -2.36,
//             ),
//           ),
//         ],
//       ),
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: widget.segments.length,
//         itemBuilder: (BuildContext context, int index) {
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedIndex = index;
//               });
//             },
//             child: Container(
//               alignment: Alignment.center,
//               padding: EdgeInsets.symmetric(horizontal: 20.w),
//               decoration: BoxDecoration(
//                 color: selectedIndex == index
//                     ? AppColor.color_494949
//                     : Colors.transparent,
//                 borderRadius: BorderRadius.circular(10.w),
//               ),
//               child: Text(
//                 widget.segments[index],
//                 style: TextStyle(
//                   color: selectedIndex == index
//                       ? AppColor.color_ffffff
//                       : AppColor.color_FF757575,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 39.sp,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
