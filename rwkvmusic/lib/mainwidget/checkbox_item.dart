import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rwkvmusic/mainwidget/text_item.dart';

class CheckBoxItem extends StatelessWidget {
  CheckBoxItem(
      {super.key,
      required this.title,
      required this.isSelected,
      required this.onChanged});
  final String title;
  bool isSelected;
  final Function(bool isSelected) onChanged;
  @override
  Widget build(BuildContext context) {
    bool isWindowsOrMac = Platform.isWindows || Platform.isMacOS;
    return InkWell(
      onTap: () {
        isSelected = !isSelected;
        onChanged(isSelected);
      },
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/${isSelected ? 'checkon' : 'checkoff'}.svg',
              width: isWindowsOrMac ? 60.w : 40.w,
              height: isWindowsOrMac ? 60.w : 40.w,
            ),
            SizedBox(
              width: 30.w,
            ),
            TextItem(
              text: title,
            )
          ],
        ),
      ),
    );
  }
}
