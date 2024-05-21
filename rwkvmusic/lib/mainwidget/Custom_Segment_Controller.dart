import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/style/color.dart';

class CustomSegmentControl11 extends StatelessWidget {
  CustomSegmentControl11({super.key, required this.callBack, this.segments});
  final segments;
  var selectedIndex = 0.obs;
  final Function(int) callBack;
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 50,
      decoration: BoxDecoration(
        color: AppColor.color_2C2C2C,
        borderRadius: BorderRadius.circular(14.h),
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
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: selectedIndex.value == index
                        ? AppColor.color_494949
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  child: Text(
                    segments[index],
                    style: TextStyle(
                      color: selectedIndex.value == index
                          ? AppColor.color_ffffff
                          : AppColor.color_FF757575,
                      fontWeight: FontWeight.bold,
                      fontSize: 39.sp,
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
