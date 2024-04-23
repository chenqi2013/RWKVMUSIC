import 'package:flutter/material.dart';

class PromptAddClose extends StatelessWidget {
  const PromptAddClose({super.key, required this.onPressed});
  final Function(int type) onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            const Text('Prompts'),
            TextButton(
              onPressed: () {
                onPressed(0);
              },
              child: const Icon(Icons.add),
            ),
          ]),
          TextButton(
            onPressed: () {
              onPressed(1);
            },
            child: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}
