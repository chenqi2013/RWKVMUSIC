import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rwkvmusic/style/color.dart';

class ContainerLine extends StatelessWidget {
  const ContainerLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(width: 2.w, color: AppColor.color_AFAFAF),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.94),
            blurRadius: 0,
            spreadRadius: 0,
            offset: const Offset(
              0.0,
              2,
            ),
          ),
        ],
      ),
    );
  }
}
