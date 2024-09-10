import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/mainwidget/text_btn.dart';
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
      appBar: AppBar(
        title: Text('意见反馈'),
      ),
      body: Container(
        margin: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('*反馈内容'),
            SizedBox(
              height: 400.h,
              child: TextField(
                controller: _controller,
                maxLength: _maxLength,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  labelText: "请输入您的意见或建议",
                  counterText: "${currentLength.value}/$_maxLength",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey), // 边框颜色为红色
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey), // 聚焦时边框颜色为红色
                  ),
                ),
              ),
            ),
            Center(
              child: TextBtn(
                width: isWindowsOrMac ? 500.w : 500.w,
                height: isWindowsOrMac ? 113.h : 80.h,
                onPressed: () async {
                  debugPrint('提交反馈');
                },
                text: '提交',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
