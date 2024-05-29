import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rwkvmusic/mainwidget/text_item.dart';
import 'package:rwkvmusic/style/color.dart';
import 'package:rwkvmusic/values/colors.dart';

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
              width: 60.w,
              height: 60.w,
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
