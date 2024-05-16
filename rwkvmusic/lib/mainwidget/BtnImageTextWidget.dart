import 'package:flutter/material.dart';

Widget createButtonImageWithText(
    String text, Image icondata, VoidCallback onPressed) {
  return InkWell(
    onTap: () {
      onPressed();
    },
    child: Container(
      // width: 80,

      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      decoration: BoxDecoration(
        // color: Colors.blue, // 设置背景色
        borderRadius: BorderRadius.circular(8), // 设置圆角
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 25,
            height: 25,
            child: icondata,
          ),
          // Icon(
          //   icondata,
          //   color: Colors.white, // 设置图标颜色
          // ),
          const SizedBox(height: 0),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white, // 设置文本颜色
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}
