import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // White text
        side: const BorderSide(
            color: Color.fromARGB(255, 125, 125, 125),
            width: 0.5), // White border
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8.0), // Space between icon and text
          Text(text,
              style: const TextStyle(
                color: Colors.white, // 设置文本颜色
                fontSize: 16,
              )),
        ],
      ),
    );
  }
}
