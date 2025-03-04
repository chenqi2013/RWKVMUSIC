import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/mainwidget/container_textfield.dart';
import 'package:rwkvmusic/mainwidget/text_btn.dart';
import 'package:rwkvmusic/mainwidget/text_item.dart';
import 'package:rwkvmusic/style/color.dart';
import 'package:rwkvmusic/widgets/toast.dart';

void showStartPwdDialog(BuildContext context, Function(bool success) callBack) {
  String? pwd;
  showDialog(
    context: context,
    barrierDismissible: false, // 禁止点击外部关闭弹窗
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(30.w)),
              color: Colors.transparent,
              image: const DecorationImage(
                image:
                    AssetImage('assets/images/backgroundbg.jpg'), // 替换为你的背景图片路径
                fit: BoxFit.cover,
              ),
            ),
            width: isWindowsOrMac ? 1400.w : 1200.w,
            // height: isWindowsOrMac ? 1000.h : 910.h,
            padding: EdgeInsets.symmetric(
                horizontal: isWindowsOrMac ? 60.w : 40.w,
                vertical: isWindowsOrMac ? 40.h : 60.h),
            child: Column(
              children: [
                TextItem(
                  text: 'Password',
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                ),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 39.sp,
                        fontWeight: FontWeight.w400),
                    children: [
                      TextSpan(
                          text:
                              "Enter the startup password to use it normally"),
                    ],
                  ),
                ).marginOnly(top: 24.h),
                ContainerTextField(
                    seed: 0,
                    onChanged: (String text) {
                      // 当文本字段内容变化时调用
                      pwd = text;
                      debugPrint('Current text: $pwd');
                    }).marginOnly(top: 48.h),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextBtn(
                        width: isWindowsOrMac ? 500.w : 500.w,
                        height: isWindowsOrMac ? 113.h : 104.h,
                        onPressed: () async {
                          _exitApp(context);
                        },
                        text: 'Cancel',
                        linearColorStart: AppColor.color_805353,
                        linearColorEnd: AppColor.color_5E1E1E,
                      ),
                      SizedBox(
                        width: 30.w,
                      ),
                      TextBtn(
                        width: isWindowsOrMac ? 500.w : 500.w,
                        height: isWindowsOrMac ? 113.h : 104.h,
                        textColor: AppColor.color_A1D632,
                        onPressed: () async {
                          // 点击同意，关闭弹窗
                          if (pwd != null && pwd == 'lks2025') {
                            callBack(true);
                            Navigator.of(context).pop();
                          } else {
                            if (isWindowsOrMac) {
                              Get.snackbar('',
                                  'Please enter the correct startup password',
                                  colorText: Colors.red);
                            } else {
                              toastInfo(
                                  msg:
                                      'Please enter the correct startup password');
                            }
                          }
                        },
                        text: 'Confirm',
                      ),
                    ],
                  ),
                ).marginOnly(top: 76.h),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _exitApp(BuildContext context) {
  Navigator.of(context).pop();
  // 退出应用的处理逻辑
  print("退出应用");
  if (Platform.isAndroid) {
    SystemNavigator.pop();
  } else {
    exit(0);
  }
}
