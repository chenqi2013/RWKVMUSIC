import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/style/color.dart';
import 'package:flutter/src/services/text_formatter.dart';

class ContainerTextField extends StatelessWidget {
  const ContainerTextField(
      {super.key, required this.onChanged, required this.seed});
  final int seed;
  final Function(String text) onChanged;
  @override
  Widget build(BuildContext context) {
    TextEditingController controller =
        TextEditingController(text: seed.toString());
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 25.h),
      width: 480.w,
      height: 96.h,
      decoration: BoxDecoration(
        color: AppColor.color_2C2C2C,
        borderRadius: BorderRadius.circular(12.h),
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
      child: TextField(
        style: TextStyle(
            fontSize: 36.sp, // 字体大小
            color: AppColor.color_757575, // 字体颜色
            fontWeight: FontWeight.w400),
        textAlign: TextAlign.right,
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')), // 只允许输入数字
        ],
        decoration: const InputDecoration(
            // labelText: 'Please input seed value',
            // hintText: 'Enter a number',
            border: InputBorder.none),
        onChanged: (text) {
          // 当文本字段内容变化时调用
          // seed.value = int.parse(text);
          controller.text = text;
          debugPrint('Current text: $text');
          onChanged(text);
        },
      ),
    );
  }
}
