import 'package:flutter/material.dart';

class ResetEdit extends StatelessWidget {
  const ResetEdit({super.key, required this.onPressed});
  final Function(int type) onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              onPressed(0);
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () {
              onPressed(1);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}
