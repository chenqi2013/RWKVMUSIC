import 'package:flutter/material.dart';
import 'package:halo/halo.dart';

class ChordEditing extends StatelessWidget {
  const ChordEditing({super.key});

  void _onTapAtIndex(BuildContext context, int index) async {
    Navigator.of(context).pop(index);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: 8.r,
      ),
    );
  }
}
