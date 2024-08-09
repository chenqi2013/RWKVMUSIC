import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rwkvmusic/mainwidget/text_item.dart';

class RadioListItem extends StatelessWidget {
  const RadioListItem(
      {super.key,
      required this.index,
      required this.title,
      required this.isSelected,
      required this.onChanged});
  final int index;
  final String title;
  final bool isSelected;
  final Function(int index) onChanged;
  @override
  Widget build(BuildContext context) {
    bool isWindowsOrMac = Platform.isWindows || Platform.isMacOS;
    return InkWell(
      onTap: () {
        onChanged(index);
      },
      child: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/${isSelected ? 'radio_select' : 'radio_unselect'}.png',
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
