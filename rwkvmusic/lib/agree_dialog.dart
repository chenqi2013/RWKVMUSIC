import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showAgreementDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // 禁止点击外部关闭弹窗
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("用户协议"),
        content: SingleChildScrollView(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.black87, fontSize: 16),
              children: [
                TextSpan(text: "请阅读并同意我们的 "),
                TextSpan(
                  text: "用户协议",
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // 用户协议点击处理
                      _openUserAgreement();
                    },
                ),
                TextSpan(text: " 和 "),
                TextSpan(
                  text: "隐私政策",
                  style: TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // 隐私政策点击处理
                      _openPrivacyPolicy();
                    },
                ),
                TextSpan(text: " 以继续使用本应用。"),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text("不同意", style: TextStyle(color: Colors.red)),
            onPressed: () {
              // 点击不同意，退出应用
              _exitApp(context);
            },
          ),
          TextButton(
            child: Text("同意", style: TextStyle(color: Colors.blue)),
            onPressed: () {
              // 点击同意，关闭弹窗
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _openUserAgreement() {
  // 打开用户协议页面
  print("打开用户协议");
}

void _openPrivacyPolicy() {
  // 打开隐私政策页面
  print("打开隐私政策");
}

void _exitApp(BuildContext context) {
  Navigator.of(context).pop();
  // 退出应用的处理逻辑
  print("退出应用");
  SystemNavigator.pop();
}
