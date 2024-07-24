import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:halo/halo.dart';
import 'package:rwkvmusic/values/constantdata.dart';

const _kHeight = 40.0;

class ChordEditing extends StatelessWidget {
  const ChordEditing({super.key});

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
            width: 350,
            height: screenHeight - 100,
            decoration: BD(
                color: Color(0xFF333333).wo(0.33),
                borderRadius: 12.r,
                border: Border.all(color: kW.wo(0.33), width: 0.5)),
            child: Co(
              c: CAA.stretch,
              children: [
                12.h,
                T(
                  "Chord Editing",
                  textAlign: TextAlign.center,
                  s: TS(c: kW, s: 16, w: FW.w700),
                ),
                12.h,
                Exp(
                  child: Ro(
                    children: [
                      4.w,
                      Exp(
                        child: ListView.builder(
                          padding: EI.o(b: 4),
                          itemBuilder: (context, index) {
                            final name = kChordRoot[index];
                            return _Item(t: name);
                          },
                          itemCount: kChordRoot.length,
                        ),
                      ),
                      4.w,
                      Exp(
                        child: Co(
                          children: [
                            Exp(
                              child: ListView.builder(
                                padding: EI.o(b: 4),
                                itemBuilder: (context, index) {
                                  final name = kChordType[index];
                                  return _Item(t: name);
                                },
                                itemCount: kChordType.length,
                              ),
                            ),
                            C(
                              decoration: BD(
                                color: kCB.wo(0.5),
                                borderRadius: 2.r,
                              ),
                              height: _kHeight,
                              child: Center(
                                  child: Icon(
                                Icons.check,
                                color: kW,
                              )),
                            ),
                            6.h,
                          ],
                        ),
                      ),
                      4.w,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String t;

  const _Item({required this.t});
  @override
  Widget build(BuildContext context) {
    return C(
      margin: EI.s(v: 2),
      height: _kHeight,
      decoration: BD(color: kW.wo(0.1), borderRadius: 2.r),
      child: Center(
        child: T(
          t,
          textAlign: TextAlign.center,
          s: TS(c: kW, s: 16, w: FW.w700),
        ),
      ),
    );
  }
}
