import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rwkvmusic/mainwidget/text_item.dart';

class CheckBoxItem extends StatelessWidget {
  CheckBoxItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onChanged,
    this.width,
  });
  final String title;
  bool isSelected;
  double? width;
  final Function(bool isSelected) onChanged;
  @override
  Widget build(BuildContext context) {
    bool isWindowsOrMac = Platform.isWindows || Platform.isMacOS;
    return InkWell(
      onTap: () {
        isSelected = !isSelected;
        onChanged(isSelected);
      },
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/${isSelected ? 'checkon' : 'checkoff'}.svg',
            width: width ?? (isWindowsOrMac ? 60.w : 40.w),
            // height: isWindowsOrMac ? 60.w : 40.w,
          ),
          if (title.isNotEmpty)
            SizedBox(
              width: 30.w,
            ),
          if (title.isNotEmpty)
            TextItem(
              text: title,
            )
        ],
      ),
    );
  }
}
