import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halo/halo.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/style/style.dart';
import 'package:rwkvmusic/values/constantdata.dart';

class TimeChanging extends StatelessWidget {
  const TimeChanging({super.key});

  void _onTapAtIndex(BuildContext context, int index) async {
    Navigator.of(context).pop(index);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Dialog(
      backgroundColor: kC,
      child: ClipRRect(
        borderRadius: 12.r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: C(
            width: 100,
            height: screenHeight - 100,
            decoration: BD(
                color: const Color(0xFF333333).wo(0.33),
                borderRadius: 12.r,
                border: Border.all(color: kW.wo(0.33), width: 0.5)),
            child: Co(
              c: CAA.stretch,
              children: [
                12.h,
                const T(
                  "Time Changing",
                  textAlign: TextAlign.center,
                  s: TS(c: kW, s: 16, w: FW.w700),
                ),
                12.h,
                ...timeSignatures.indexMap((index, value) {
                  return Exp(
                    child: GD(
                      onTap: () {
                        _onTapAtIndex(context, index);
                      },
                      child: Obx(() {
                        final timeSignatureValue = timeSignature.value;
                        final highlight = timeSignatureValue == index;
                        return C(
                          margin: const EI.s(h: 4, v: 2),
                          decoration: BD(
                            color: kW.wo(0.1),
                            border: highlight
                                ? Border.all(
                                    color: AppColor.color_A1D632, width: 2)
                                : Border.all(color: kW.wo(0.1)),
                            borderRadius: 8.r,
                          ),
                          child: Center(
                            child: T(
                              value,
                              textAlign: TextAlign.center,
                              s: const TS(c: kW, s: 16, w: FW.w700),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
                8.h,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
