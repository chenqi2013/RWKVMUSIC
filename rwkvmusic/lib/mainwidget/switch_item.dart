import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rwkvmusic/style/color.dart';

class SwitchItem extends StatelessWidget {
  SwitchItem({super.key, required this.value, required this.onChanged});
  bool value;
  final Function(bool isSelected) onChanged;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        value = !value;
        onChanged(value);
      },
      child: Container(
        child: SvgPicture.asset(
          'assets/images/${value ? 'switchon' : 'switchoff'}.svg',
          width: 147.w,
          height: 78.w,
        ),
      ),
    );
  }
}
