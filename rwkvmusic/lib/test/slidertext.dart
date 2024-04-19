import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SliderText extends StatelessWidget {
  SliderText(
      {super.key,
      required this.divisionCount,
      required this.divisionList,
      required this.changeValue});
  late int divisionCount;
  late List<String> divisionList;
  late Function(double value) changeValue;
  late var sliderValue = 0.3.obs;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderTheme(
          data: const SliderThemeData(
              // disabledActiveTrackColor: Colors.deepOrange.withOpacity(0.8),
              // disabledInactiveTrackColor: Colors.grey,
              // disabledThumbColor: Colors.grey,
              // disabledActiveTickMarkColor: Colors.deepOrange.withOpacity(0.8),
              // disabledInactiveTickMarkColor: Colors.yellow.withOpacity(0.8),
              tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 8.0),
              trackHeight: 8.0),
          child: Obx(() => Slider(
              value: sliderValue.value,
              divisions: divisionCount,
              onChanged: (value) {
                sliderValue.value = value;
                changeValue(value);
              })),
        ),
        divisionList.isNotEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: divisionList.map((text) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                }).toList(),
              )
            : const SizedBox(
                width: 0,
              ),
      ],
    );
  }
}
