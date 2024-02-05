import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:on_popup_window_widget/on_popup_window_widget.dart';
import 'package:on_process_button_widget/on_process_button_widget.dart';

void main(List<String> args) {
  runApp(const MyApp3());
}

class MyApp3 extends StatelessWidget {
  const MyApp3({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: MainWidget(),
      ),
    );
  }
}

class MainWidget extends StatelessWidget {
  MainWidget({super.key});

  final List<String> lan = [
    "Bangle",
    "English",
    "Spanish",
    "French",
    "German",
    "Chinese",
    "Hindi",
    "Arabic",
    "Russian",
    "Portuguese",
    "Japanese",
    "Italian",
  ];

  List<Widget> children(BuildContext context) {
    List<Widget> res = lan
        .map(
          (e) => Text(e),
        )
        .toList();

    return res + res;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //! Responsive
        OnProcessButtonWidget(
          expanded: false,
          onTap: () => showDialog(
            context: context,
            builder: (context) => OnPopupWindowWidget(
              title: const Text("Please select your Language"),
              footer: const OnProcessButtonWidget(
                  expanded: false, child: Text("Okay")),
              child: Column(children: children(context)),
            ),
          ),
          child: const Text("Press here"),
        ),
      ],
    );
  }
}
