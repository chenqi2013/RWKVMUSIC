import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/mainwidget/border_bottom_btn.dart';
import 'package:rwkvmusic/mainwidget/text_btn.dart';
import 'package:rwkvmusic/mainwidget/text_item.dart';
import 'package:rwkvmusic/style/style.dart';
import 'package:rwkvmusic/values/colors.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _controller = TextEditingController();
  final RxInt currentLength = 0.obs;
  final int _maxLength = 1000;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      setState(() {
        currentLength.value = _controller.text.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('FeedBack'),
      // ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: Get.height,
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.all(Radius.circular(30.w)),
            color: Colors.transparent,
            image: const DecorationImage(
              image:
                  AssetImage('assets/images/backgroundbg.jpg'), // 替换为你的背景图片路径
              fit: BoxFit.cover,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 115.w, vertical: 48.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  TextItem(text: 'FeedBack').marginOnly(left: 26.w)
                ],
              ).marginOnly(left: 20.w, top: 20.h),
              SizedBox(
                height: 32.h,
              ),
              Container(
                height: 400.h,
                decoration: BoxDecoration(
                  color: AppColor.color_202324,
                  borderRadius: BorderRadius.all(Radius.circular(20.w)),
                ),
                padding: EdgeInsets.only(bottom: 30.h),
                child: TextField(
                  controller: _controller,
                  maxLength: _maxLength,
                  maxLines: null,
                  expands: true,
                  style: TextStyle(fontSize: 40.sp, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Please input your opinions or suggestions",
                    hintStyle: TextStyle(fontSize: 40.sp, color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20.h), // 设置上下左右间距
                    counterText: "${currentLength.value}/$_maxLength",
                    counterStyle: TextStyle(
                      fontSize: 40.sp,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextBtn(
                  width: isWindowsOrMac ? 500.w : 500.w,
                  height: isWindowsOrMac ? 113.h : 80.h,
                  onPressed: () async {
                    debugPrint('提交反馈');
                    if (_controller.text.isEmpty) {
                      Fluttertoast.showToast(
                          msg: "Please input your opinions or suggestions.");
                    } else {
                      Fluttertoast.showToast(
                          msg:
                              "Thank you, we have received your suggestions and feedback.");
                    }
                  },
                  text: 'Submit',
                ),
              ).marginOnly(top: 60.h),
            ],
          ),
        ),
      ),
    );
  }
}
