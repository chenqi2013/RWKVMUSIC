import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/agreeement_policy_page.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/mainwidget/text_btn.dart';
import 'package:rwkvmusic/mainwidget/text_item.dart';
import 'package:rwkvmusic/store/config.dart';
import 'package:rwkvmusic/style/color.dart';

void showAgreementDialog(BuildContext context) {
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
                  text: 'User Agreement',
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
                      TextSpan(text: "Please read and agree to our "),
                      TextSpan(
                        text: "user agreement",
                        style: TextStyle(
                            color: AppColor.color_A1D632,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // 用户协议点击处理

                            _openUserAgreement();
                          },
                      ),
                      TextSpan(text: " and "),
                      TextSpan(
                        text: "privacy policy",
                        style: TextStyle(
                            color: AppColor.color_A1D632,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // 隐私政策点击处理
                            _openPrivacyPolicy();
                          },
                      ),
                      TextSpan(text: " to continue using this application."),
                    ],
                  ),
                ).marginOnly(top: 24.h),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextBtn(
                        width: isWindowsOrMac ? 500.w : 500.w,
                        height: isWindowsOrMac ? 113.h : 104.h,
                        onPressed: () async {
                          // 点击不同意，退出应用
                          _exitApp(context);
                        },
                        text: 'Disagree',
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
                        onPressed: () {
                          // 点击同意，关闭弹窗
                          isVisibleWebview.value = true;
                          ConfigStore.to.saveAlreadyOpen();
                          Navigator.of(context).pop();
                        },
                        text: 'Agree',
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

void _openUserAgreement() {
  // 打开用户协议页面
  print("打开用户协议");
  Get.to(AgreementPolicyPage(
    type: 0,
  ));
}

void _openPrivacyPolicy() {
  // 打开隐私政策页面
  print("打开隐私政策");
  Get.to(AgreementPolicyPage(
    type: 1,
  ));
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
