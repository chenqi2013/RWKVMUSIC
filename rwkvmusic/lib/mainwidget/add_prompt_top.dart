import 'package:flutter/material.dart';

class AddPromptTop extends StatelessWidget {
  const AddPromptTop({super.key, required this.onPressed});
  final Function(int type) onPressed;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Add Prompt',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  onPressed(0);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () {
                  onPressed(1);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
