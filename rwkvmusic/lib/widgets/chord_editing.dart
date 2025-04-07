import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:halo/halo.dart';

const _kHeight = 40.0;

final selectedChordIndex = (-1).obs;
final selectedChordRoot = ChordRoot.C.obs;
final selectedChordType = ChordType.major.obs;

enum ChordRoot {
  C,
  cSharp,
  D,
  dSharp,
  E,
  F,
  fSharp,
  G,
  gSharp,
  A,
  aSharp,
  B,
}

extension ChordRootValue on ChordRoot {
  String get abcNotationValue {
    switch (this) {
      case ChordRoot.C:
        return "C";
      case ChordRoot.cSharp:
        return "C#";
      case ChordRoot.D:
        return "D";
      case ChordRoot.dSharp:
        return "D#";
      case ChordRoot.E:
        return "E";
      case ChordRoot.F:
        return "F";
      case ChordRoot.fSharp:
        return "F#";
      case ChordRoot.G:
        return "G";
      case ChordRoot.gSharp:
        return "G#";
      case ChordRoot.A:
        return "A";
      case ChordRoot.aSharp:
        return "A#";
      case ChordRoot.B:
        return "B";
    }
  }
}

enum ChordType {
  major,
  minor,
  dim,
  dominant7,
}

extension ChordTypeValue on ChordType {
  String get abcNotationValue {
    switch (this) {
      case ChordType.major:
        return "";
      case ChordType.minor:
        return "m";
      case ChordType.dim:
        return "dim";
      case ChordType.dominant7:
        return "7";
    }
  }

  String get displayValue {
    switch (this) {
      case ChordType.major:
        return "Major";
      case ChordType.minor:
        return "minor";
      case ChordType.dim:
        return "dim";
      case ChordType.dominant7:
        return "Dominant7";
    }
  }
}

(ChordRoot, ChordType) calculateRootAndType(String m) {
  ChordRoot root = ChordRoot.C;
  ChordType type = ChordType.major;
  for (final rootV in ChordRoot.values) {
    if (m.startsWith(rootV.abcNotationValue)) root = rootV;
  }
  for (final typeV in ChordType.values) {
    if (m.endsWith(typeV.abcNotationValue)) type = typeV;
  }
  return (root, type);
}

class ChordEditing extends StatelessWidget {
  const ChordEditing({super.key});

  void _onTapRoot(BuildContext context, int index) {
    selectedChordRoot.value = ChordRoot.values[index];
  }

  void _onTapType(BuildContext context, int index) {
    selectedChordType.value = ChordType.values[index];
  }

  void _onTapOK(BuildContext context) async {
    Navigator.of(context).pop("ok");
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
                color: const Color(0xFF333333).wo(0.33),
                borderRadius: 12.r,
                border: Border.all(color: kW.wo(0.33), width: 0.5)),
            child: Co(
              c: CAA.stretch,
              children: [
                12.h,
                T(
                  "Chord Editing".tr,
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
                          padding: const EI.o(b: 4),
                          itemBuilder: (context, index) {
                            return Obx(
                              () {
                                final root = ChordRoot.values[index];
                                final name = root.abcNotationValue;
                                final _selectedChordRoot =
                                    selectedChordRoot.value;
                                final highlighted = _selectedChordRoot == root;
                                return GD(
                                  onTap: () {
                                    _onTapRoot(context, index);
                                  },
                                  child: _Item(
                                    t: name,
                                    highlighted: highlighted,
                                  ),
                                );
                              },
                            );
                          },
                          itemCount: ChordRoot.values.length,
                        ),
                      ),
                      4.w,
                      Exp(
                        child: Co(
                          children: [
                            Exp(
                              child: ListView.builder(
                                padding: const EI.o(b: 4),
                                itemBuilder: (context, index) {
                                  return Obx(
                                    () {
                                      final type = ChordType.values[index];
                                      final name = type.displayValue;
                                      final _selectedChordType =
                                          selectedChordType.value;
                                      final highlighted =
                                          _selectedChordType == type;
                                      return GD(
                                        onTap: () {
                                          _onTapType(context, index);
                                        },
                                        child: _Item(
                                          t: name,
                                          highlighted: highlighted,
                                        ),
                                      );
                                    },
                                  );
                                },
                                itemCount: ChordType.values.length,
                              ),
                            ),
                            Ro(
                              children: [
                                Exp(
                                  flex: 3,
                                  child: GD(
                                    onTap: () {
                                      _onTapOK(context);
                                    },
                                    child: C(
                                      decoration: BD(
                                        color: kCB.wo(0.5),
                                        borderRadius: 2.r,
                                      ),
                                      height: _kHeight,
                                      child: const Center(
                                          child: Icon(
                                        Icons.check,
                                        color: kW,
                                      )),
                                    ),
                                  ),
                                ),
                                4.w,
                                Exp(
                                  flex: 2,
                                  child: GD(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: C(
                                      decoration: BD(
                                        color: kW.wo(0.5),
                                        borderRadius: 2.r,
                                      ),
                                      height: _kHeight,
                                      child: const Center(
                                          child: Icon(
                                        Icons.close,
                                        color: kW,
                                      )),
                                    ),
                                  ),
                                ),
                              ],
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
  final bool highlighted;

  const _Item({required this.t, required this.highlighted});
  @override
  Widget build(BuildContext context) {
    return C(
      margin: const EI.s(v: 2),
      height: _kHeight,
      decoration:
          BD(color: highlighted ? kCB.wo(0.5) : kW.wo(0.1), borderRadius: 2.r),
      child: Center(
        child: T(
          t,
          textAlign: TextAlign.center,
          s: const TS(c: kW, s: 16, w: FW.w700),
        ),
      ),
    );
  }
}
