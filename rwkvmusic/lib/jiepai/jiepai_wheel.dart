import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rwkvmusic/values/constantdata.dart';
import 'package:wheel_picker/wheel_picker.dart';

class JiePaiWheelPicker extends StatefulWidget {
  JiePaiWheelPicker(
      {super.key, required this.leftWheelIndex, required this.rightWheelIndex});
  int leftWheelIndex;
  int rightWheelIndex;
  @override
  State<JiePaiWheelPicker> createState() => _JiePaiWheelPickerState();
}

class _JiePaiWheelPickerState extends State<JiePaiWheelPicker> {
  late final wheelLeft = WheelPickerController(
    itemCount: 8,
    initialIndex: widget.leftWheelIndex,
  );
  late final wheelRight = WheelPickerController(
    itemCount: 5,
    initialIndex: widget.rightWheelIndex,
    mounts: [wheelLeft],
  );

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 26.0, height: 1.5);
    final wheelStyle = WheelPickerStyle(
      itemExtent: textStyle.fontSize! * textStyle.height!, // Text height
      squeeze: 1.25,
      diameterRatio: .8,
      surroundingOpacity: .25,
      magnification: 1.2,
    );

    Widget itemLeft(BuildContext context, int index) {
      return Text("${index + 1}", style: textStyle);
    }

    Widget itemRight(BuildContext context, int index) {
      return Text(listJiepai[index], style: textStyle);
    }

    final wheels = <Widget>[
      for (final wheelController in [wheelLeft, wheelRight])
        Expanded(
          child: WheelPicker(
            builder: wheelController == wheelLeft ? itemLeft : itemRight,
            controller: wheelController,
            looping: false,
            style: wheelStyle,
            selectedIndexColor: Colors.black,
            onIndexChanged: (index) {
              if (wheelController == wheelLeft) {
                widget.leftWheelIndex = index;
              } else {
                widget.rightWheelIndex = index;
              }
              setState(() {});
            },
          ),
        ),
    ];

    return Container(
      height: 290,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _centerBar(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                ...wheels,
                // const SizedBox(width: 6.0),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '取消',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff333333)),
                    ),
                  ),
                  Text(
                    '${widget.leftWheelIndex + 1}/${listJiepai[widget.rightWheelIndex]}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff333333)),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context,
                          [widget.leftWheelIndex, widget.rightWheelIndex]);
                    },
                    child: const Text(
                      '确定',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff333333)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Don't forget to dispose the controllers at the end.
    wheelLeft.dispose();
    wheelRight.dispose();
    super.dispose();
  }

  Widget _centerBar(BuildContext context) {
    return Center(
      child: Container(
        height: 38.0,
        decoration: BoxDecoration(
          color: const Color(0xFFC3C9FA).withAlpha(26),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
