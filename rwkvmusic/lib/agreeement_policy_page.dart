import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/mainwidget/border_bottom_btn.dart';
import 'package:rwkvmusic/mainwidget/text_item.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

class AgreementPolicyPage extends StatelessWidget {
  WebViewControllerPlus? controllerPiano;

  AgreementPolicyPage({super.key, required this.type});
  int type;

  @override
  Widget build(BuildContext context) {
    String url = 'http://www.baidu.com';
    if (type == 1) {
      url = 'https://www.rwkvos.com/';
    }
    controllerPiano = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    controllerPiano?.loadRequest(Uri.parse(url));
    return Scaffold(
      body: Container(
        width: double.infinity,
        // height: Get.height,
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.all(Radius.circular(30.w)),
          color: Colors.transparent,
          image: const DecorationImage(
            image: AssetImage('assets/images/backgroundbg.jpg'), // 替换为你的背景图片路径
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: 115.w, vertical: 28.h),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              BorderBottomBtn(
                width: isWindowsOrMac ? 123.h : 96.h,
                height: isWindowsOrMac ? 123.h : 96.h,
                text: '',
                icon: SvgPicture.asset(
                  'assets/images/white_back.svg',
                  width: isWindowsOrMac ? 61.w : 52.w,
                  height: isWindowsOrMac ? 61.h : 52.h,
                ),
                onPressed: () {
                  Get.back();
                },
              ),
              TextItem(text: type == 1 ? 'privacy policy' : 'user agreement')
                  .marginOnly(left: 26.w)
            ],
          ).marginOnly(left: 20.w, top: 20.h),
          Expanded(
            child: WebViewWidget(
              controller: controllerPiano!,
            ).marginOnly(top: 30.h),
          ),
        ]),
      ),
    );
  }
}
