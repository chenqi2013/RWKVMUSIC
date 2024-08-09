import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/style/color.dart';

class DropButtonList extends StatelessWidget {
  DropButtonList(
      {super.key,
      required this.items,
      required this.index,
      required this.onChanged});
  final List<String> items;
  final int index;
  final Function(int index) onChanged;
  // final List<String> items = [
  //   'Item1',
  //   'Item2',
  //   'Item3',
  //   'Item4',
  //   'Item5',
  //   'Item6',
  //   'Item7',
  //   'Item8',
  // ];
  var selectedValue = ''.obs;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Row(
          children: [
            // Icon(
            //   Icons.list,
            //   size: 16,
            //   color: Colors.yellow,
            // ),
            SizedBox(
              width: 8.w,
            ),
            Expanded(
              child: Text(
                'Select Item',
                style: TextStyle(
                  fontSize: 39.sp,
                  fontWeight: FontWeight.w700,
                  // color: Colors.yellow,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        items: items
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 39.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
            .toList(),
        value: items[index],
        onChanged: (value) {
          selectedValue.value = value!;
          debugPrint('selectedValue==${selectedValue.value}');
          onChanged(items.indexOf(value));
        },
        buttonStyleData: ButtonStyleData(
          height: isWindowsOrMac ? 90.h : 80.h,
          width: 185.w,
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 26.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11.w),
            border: Border.all(
              color: Colors.black26,
            ),
            color: AppColor.color_494949,
          ),
          elevation: 1,
        ),
        iconStyleData: IconStyleData(
          icon: SvgPicture.asset(
            'assets/images/ic_arrowdown.svg',
            width: 28.w,
            height: 21.h,
          ),
          iconSize: 28.w,
          // iconEnabledColor: Colors.yellow,
          // iconDisabledColor: Colors.grey,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 465.h,
          width: 185.w,
          decoration: const BoxDecoration(
            // borderRadius: BorderRadius.circular(14),
            color: AppColor.color_323232,
          ),
          // offset: const Offset(-20, 0),
          scrollbarTheme: ScrollbarThemeData(
            // radius: const Radius.circular(40),
            // thickness: MaterialStateProperty.all(6),
            thumbVisibility: WidgetStateProperty.all(true),
          ),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: isWindowsOrMac ? 90.h : 60.h,
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 26.w),
        ),
      ),
    );
  }
}
