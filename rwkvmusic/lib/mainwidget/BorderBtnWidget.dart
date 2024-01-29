import 'package:flutter/material.dart';

Widget creatBottomBtn(String text, VoidCallback onPressed) {
  return InkWell(
    onTap: () {
      // 按钮被点击时执行的操作
        onPressed();
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        // color: Colors.blue, // 设置背景色
        borderRadius: BorderRadius.circular(8), // 设置圆角
        border: Border.all(color: Color(0xff6d6d6d), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.white, // 设置文本颜色
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(
            Icons.arrow_drop_down_sharp,
            color: Colors.white, // 设置图标颜色
          ),
        ],
      ),
    ),
  );
}
