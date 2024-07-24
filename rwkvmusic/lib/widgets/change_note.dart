import 'package:flutter/material.dart';
import 'package:halo/halo.dart';

class ChangeNote extends StatelessWidget {
  const ChangeNote({super.key});

  void _onTapAtIndex(BuildContext context, int index) async {
    Navigator.of(context).pop(index);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: 8.r,
        child: C(
          decoration: BD(
            color: Color(0xFFEEEEEE),
          ),
          height: 60,
          width: screenWidth,
          child: ListView.builder(
            padding: EI.o(l: 4),
            scrollDirection: Axis.horizontal,
            itemCount: 12,
            itemBuilder: (context, index) {
              return SB(
                height: 60,
                width: 60,
                child: Center(
                  child: GD(
                    onTap: () {
                      _onTapAtIndex(context, index);
                    },
                    child: C(
                      decoration: BD(
                        color: kW,
                        borderRadius: 4.r,
                      ),
                      height: 48,
                      width: 54,
                      child: Center(
                        child: T(
                          "♩",
                          s: TS(s: 32),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
