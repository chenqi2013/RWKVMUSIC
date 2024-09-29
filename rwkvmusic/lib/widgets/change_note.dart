import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:halo/halo.dart';
import 'package:rwkvmusic/gen/assets.gen.dart';
import 'package:rwkvmusic/main.dart';
import 'package:rwkvmusic/note_length.dart';
import 'package:rwkvmusic/state.dart';
import 'package:rwkvmusic/style/color.dart';

enum ChangeNoteKey {
  whole,
  half,
  quarter,
  eighth,
  sixteenth,
  thirtySecond,
  dottodNote,
  wholeZ,
  halfZ,
  quarterZ,
  eighthZ,
  sixteenthZ,
  mergedZ,
  randomGroove,
  transposeDown,
  transpose,
  transposeUp,
  delete;

  bool get isMain =>
      this != ChangeNoteKey.wholeZ &&
      this != ChangeNoteKey.halfZ &&
      this != ChangeNoteKey.quarterZ &&
      this != ChangeNoteKey.eighthZ &&
      this != ChangeNoteKey.sixteenthZ;

  String? get iconImage {
    switch (this) {
      case ChangeNoteKey.whole:
        return Assets.images.changeNode.whole;
      case ChangeNoteKey.half:
        return Assets.images.changeNode.half;
      case ChangeNoteKey.quarter:
        return Assets.images.changeNode.quarter;
      case ChangeNoteKey.eighth:
        return Assets.images.changeNode.eighth;
      case ChangeNoteKey.sixteenth:
        return Assets.images.changeNode.sixteenth;
      case ChangeNoteKey.thirtySecond:
        return Assets.images.changeNode.thirtySecond;
      case ChangeNoteKey.dottodNote:
        return Assets.images.changeNode.dottodNote;
      case ChangeNoteKey.wholeZ:
        return Assets.images.changeNode.wholeZ;
      case ChangeNoteKey.halfZ:
        return Assets.images.changeNode.halfZ;
      case ChangeNoteKey.quarterZ:
        return Assets.images.changeNode.quarterZ;
      case ChangeNoteKey.eighthZ:
        return Assets.images.changeNode.eighthZ;
      case ChangeNoteKey.sixteenthZ:
        return Assets.images.changeNode.sixteenthZ;
      default:
        return null;
    }
  }

  Widget get bgWidget {
    switch (this) {
      case ChangeNoteKey.delete:
        return Center(child: Assets.images.changeNode.btnD.image());
      case ChangeNoteKey.randomGroove:
        return Center(child: Assets.images.changeNode.btnW.image());
      case ChangeNoteKey.transposeDown:
        return Center(child: Assets.images.changeNode.tl.image());
      case ChangeNoteKey.transpose:
        return Obx(
          () => Positioned.fill(
            child: C(
              decoration: BD(color: kB),
              child: Center(
                child: T(
                  gloableTranspose.value.toString(),
                  s: TS(w: FW.w900, s: 14 * _kButtonHeight / 48.0, c: kW),
                ),
              ),
            ),
          ),
        );
      case ChangeNoteKey.transposeUp:
        return Center(child: Assets.images.changeNode.tr.image());

      default:
        return Center(child: Assets.images.changeNode.btn.image());
    }
  }

  Size get assetSize {
    switch (this) {
      case ChangeNoteKey.whole:
        return const Size(8, 8);
      case ChangeNoteKey.quarterZ:
        return const Size(20, 20);
      case ChangeNoteKey.eighthZ:
        return const Size(20, 20);
      case ChangeNoteKey.wholeZ:
        return const Size(6, 6);
      case ChangeNoteKey.halfZ:
        return const Size(6, 6);
      default:
        return const Size(32, 32);
    }
  }

  double get widthModifier {
    switch (this) {
      case ChangeNoteKey.randomGroove:
      case ChangeNoteKey.delete:
        return 1.55;
      default:
        return 1;
    }
  }

  Widget get leftWidget {
    switch (this) {
      case ChangeNoteKey.delete:
        return 0.w;
      case ChangeNoteKey.transposeDown:
      case ChangeNoteKey.transpose:
        return 0.w;
      default:
        return 4.w;
    }
  }
}

double _kButtonHeight = 48.0;
double _kContainerHeight = 52.0;
const _kKeysDesignWidth = 787.0;

final _latestButtonClickPosition = Rx<Offset?>(null);

final _expandedZSelections = RxBool(false);

final gloableTranspose = Rx<int>(0);

final _kAvailableTranspose = [
  -7,
  -6,
  -5,
  -4,
  -3,
  -2,
  -1,
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7
];

final showSelectStopSoHideWebviewInDesktop = false.obs;

class ChangeNote extends StatelessWidget {
  final void Function(BuildContext context, ChangeNoteKey key) onTapKey;
  final void Function(BuildContext context, ChangeNoteKey key) onLongPress;
  final void Function(BuildContext context, int value) onTapTranspose;

  const ChangeNote({
    super.key,
    required this.onTapKey,
    required this.onLongPress,
    required this.onTapTranspose,
  });

  void _onTapKey(BuildContext context, ChangeNoteKey key) async {
    switch (key) {
      case ChangeNoteKey.mergedZ:
        _expandedZSelections.value = true;
        if (isWindowsOrMac) {
          showSelectStopSoHideWebviewInDesktop.value = true;
        }
        final result = await showDialog<ChangeNoteKey?>(
          context: context,
          builder: (context) => _ZSelections(),
        );
        if (isWindowsOrMac) {
          showSelectStopSoHideWebviewInDesktop.value = false;
        }
        _expandedZSelections.value = false;
        if (result != null) {
          latestUsedRest.value = result;
          if (context.mounted) onTapKey(context, result);
        }
        break;
      case ChangeNoteKey.wholeZ:
      case ChangeNoteKey.halfZ:
      case ChangeNoteKey.quarterZ:
      case ChangeNoteKey.eighthZ:
      case ChangeNoteKey.sixteenthZ:
        break;
      case ChangeNoteKey.transposeUp:
        gloableTranspose.value = gloableTranspose.value + 1;
        onTapTranspose(context, gloableTranspose.value);
        break;
      case ChangeNoteKey.transposeDown:
        gloableTranspose.value = gloableTranspose.value - 1;
        onTapTranspose(context, gloableTranspose.value);
        break;
      case ChangeNoteKey.transpose:
        if (kDebugMode) print("💬 Deal with it");
        final result = await showConfirmationDialog<int>(
          builder: (context, dialog) {
            return SB(
              width: 300,
              child: dialog,
            );
          },
          initialSelectedActionKey: gloableTranspose.value,
          context: context,
          title: "Transpose",
          message: "Enter the number of semitones to transpose",
          actions: _kAvailableTranspose
              .map((e) => AlertDialogAction(key: e, label: e.toString()))
              .toList(),
        );
        if (result != null) {
          gloableTranspose.value = result;
        }
        if (context.mounted) onTapTranspose(context, gloableTranspose.value);
        break;
      default:
        onTapKey(context, key);
        break;
    }
  }

  void _onLongPress(BuildContext context, ChangeNoteKey key) {
    switch (key) {
      default:
        onLongPress(context, key);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = MediaQuery.of(context).padding;

    final availableWidth = screenWidth -
        max(padding.left, ScreenUtil().setWidth(85)) -
        max(padding.right, ScreenUtil().setWidth(85));

    if (availableWidth >= _kKeysDesignWidth) {
      _kButtonHeight = 48.0;
      _kContainerHeight = 52.0;
    } else {
      _kButtonHeight = 48.0 * availableWidth / _kKeysDesignWidth - 1;
      _kContainerHeight = 52.0 * availableWidth / _kKeysDesignWidth - 1;
    }

    return Theme(
      data: ThemeData.dark(),
      child: Obx(() {
        final inputNoteLengthV = inputNoteLength.value;
        final selectedNoteV = selectedNote.value;

        return ClipRRect(
          borderRadius: 8.r,
          child: C(
              decoration: const BD(color: kC),
              constraints: BoxConstraints(
                maxHeight: _kContainerHeight,
                minHeight: _kContainerHeight,
              ),
              width: screenWidth,
              child: Center(
                child: ListView(
                  padding: EI.o(l: padding.left, r: padding.right),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                    5.w,
                    ...ChangeNoteKey.values
                        .where((k) => k.isMain)
                        .indexMap((index, k) {
                      return Obx(
                        () {
                          final latestUsedRestV = latestUsedRest.value;
                          final expandedZSelectionsV =
                              _expandedZSelections.value;
                          return _KeyWrapper(
                            onTapAtIndex: _onTapKey,
                            onLongPress: _onLongPress,
                            context: context,
                            k: k,
                            inputNoteLengthV: inputNoteLengthV,
                            index: index,
                            selectedNote: selectedNoteV,
                          );
                        },
                      );
                    }).widgetJoin(
                      (index) => ChangeNoteKey.values
                          .where((k) => k.isMain)
                          .elementAt(index)
                          .leftWidget,
                    ),
                    5.w,
                  ],
                ),
              )),
        );
      }),
    );
  }
}

class _KeyWrapper extends StatelessWidget {
  const _KeyWrapper({
    required this.onTapAtIndex,
    required this.onLongPress,
    required this.context,
    required this.k,
    required this.inputNoteLengthV,
    required this.index,
    required this.selectedNote,
  });

  final void Function(BuildContext context, ChangeNoteKey key) onTapAtIndex;
  final void Function(BuildContext context, ChangeNoteKey key) onLongPress;
  final BuildContext context;
  final ChangeNoteKey k;
  final NoteLength inputNoteLengthV;
  final int index;
  final NewNote? selectedNote;

  @override
  Widget build(BuildContext context) {
    Widget child = C();

    final isMergedZ = k == ChangeNoteKey.mergedZ;

    final assetName = isMergedZ ? latestUsedRest.value.iconImage : k.iconImage;

    if (assetName != null) {
      final assetWidth = isMergedZ
          ? (latestUsedRest.value.assetSize.width * _kButtonHeight / 48.0)
          : k.assetSize.width * _kButtonHeight / 48.0;
      final assetHeight = isMergedZ
          ? (latestUsedRest.value.assetSize.height * _kButtonHeight / 48.0)
          : k.assetSize.height * _kButtonHeight / 48.0;

      child = Center(
        child: SvgPicture.asset(
          assetName,
          width: assetWidth,
          height: assetHeight,
          color: kW,
        ),
      );
    }

    if (k == ChangeNoteKey.randomGroove) {
      final Shader linearGradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFFEBFEC1),
          Color(0xFFA1D632),
        ],
      ).createShader(Rect.fromLTWH(
        0.0,
        0.0,
        _kButtonHeight * 1.55,
        _kButtonHeight,
      ));
      child = Center(
          child: T(
        "Random\nGroove",
        textAlign: TextAlign.center,
        s: TS(
            w: FW.w900,
            s: 14 * _kButtonHeight / 48.0,
            foreground: Paint()..shader = linearGradient,
            shadows: [
              Shadow(
                color: kB.wo(0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]),
      ));
    }

    if (k == ChangeNoteKey.delete) {
      final Shader linearGradient = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0xFFFFFFFF),
          Color(0xFF999999),
        ],
      ).createShader(Rect.fromLTWH(
        0.0,
        0.0,
        _kButtonHeight * 1.55,
        _kButtonHeight,
      ));
      child = Center(
          child: T(
        "Delete",
        s: TS(
            w: FW.w900,
            s: 14 * _kButtonHeight / 48.0,
            foreground: Paint()..shader = linearGradient,
            shadows: [
              Shadow(
                color: kB.wo(0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]),
      ));
    }

    final svg = k.bgWidget;

    Widget highlight = C();
    final highlighted = Positioned.fill(
      child: C(
        decoration: BD(
          color: kW.wo(0.2),
          borderRadius: 4.r,
          boxShadow: [
            BoxShadow(color: kW.wo(0.2), blurRadius: 10),
          ],
        ),
      ),
    );

    switch (inputNoteLengthV) {
      case NoteLength.whole:
      case NoteLength.wholeDotted:
        if (k == ChangeNoteKey.whole) highlight = highlighted;
        break;
      case NoteLength.half:
      case NoteLength.halfDotted:
        if (k == ChangeNoteKey.half) highlight = highlighted;
        break;
      case NoteLength.quarter:
      case NoteLength.quarterDotted:
        if (k == ChangeNoteKey.quarter) highlight = highlighted;
        break;
      case NoteLength.eighth:
      case NoteLength.eighthDotted:
        if (k == ChangeNoteKey.eighth) highlight = highlighted;
        break;
      case NoteLength.sixteenth:
      case NoteLength.sixteenthDotted:
        if (k == ChangeNoteKey.sixteenth) highlight = highlighted;
        break;
      case NoteLength.thirtySecond:
      case NoteLength.thirtySecondDotted:
        if (k == ChangeNoteKey.thirtySecond) highlight = highlighted;
        break;
    }

    switch (inputNoteLengthV) {
      case NoteLength.wholeDotted:
        if (k == ChangeNoteKey.dottodNote) highlight = highlighted;
      case NoteLength.halfDotted:
        if (k == ChangeNoteKey.dottodNote) highlight = highlighted;
      case NoteLength.quarterDotted:
        if (k == ChangeNoteKey.dottodNote) highlight = highlighted;
      case NoteLength.eighthDotted:
        if (k == ChangeNoteKey.dottodNote) highlight = highlighted;
      case NoteLength.sixteenthDotted:
        if (k == ChangeNoteKey.dottodNote) highlight = highlighted;
      case NoteLength.thirtySecondDotted:
        if (k == ChangeNoteKey.dottodNote) highlight = highlighted;
      default:
        break;
    }

    Widget selectedHighlight = C();

    final selectedHighlighted = Positioned(
        right: 4,
        top: 4,
        child: C(
          width: 6,
          height: 6,
          decoration: BD(
            color: AppColor.color_A1D632,
            borderRadius: 4.r,
            boxShadow: [
              BoxShadow(color: AppColor.color_A1D632, blurRadius: 10),
            ],
          ),
        ));

    if (k == ChangeNoteKey.mergedZ && _expandedZSelections.value) {
      highlight = highlighted;
    }

    final selectedNote = this.selectedNote;
    if (selectedNote != null) {
      final selectedNoteLengthV = selectedNote.length;
      final isZ = selectedNote.isZ;
      switch (selectedNoteLengthV) {
        case NoteLength.whole:
        case NoteLength.wholeDotted:
          if (k == ChangeNoteKey.whole && !isZ) {
            selectedHighlight = selectedHighlighted;
          }
          if (k == ChangeNoteKey.wholeZ && isZ) {
            selectedHighlight = selectedHighlighted;
          }
          break;
        case NoteLength.half:
        case NoteLength.halfDotted:
          if (k == ChangeNoteKey.half && !isZ) {
            selectedHighlight = selectedHighlighted;
          }
          if (k == ChangeNoteKey.halfZ && isZ) {
            selectedHighlight = selectedHighlighted;
          }
          break;
        case NoteLength.quarter:
        case NoteLength.quarterDotted:
          if (k == ChangeNoteKey.quarter && !isZ) {
            selectedHighlight = selectedHighlighted;
          }
          if (k == ChangeNoteKey.quarterZ && isZ) {
            selectedHighlight = selectedHighlighted;
          }
          break;
        case NoteLength.eighth:
        case NoteLength.eighthDotted:
          if (k == ChangeNoteKey.eighth && !isZ) {
            selectedHighlight = selectedHighlighted;
          }
          if (k == ChangeNoteKey.eighthZ && isZ) {
            selectedHighlight = selectedHighlighted;
          }
          break;
        case NoteLength.sixteenth:
        case NoteLength.sixteenthDotted:
          if (k == ChangeNoteKey.sixteenth && !isZ) {
            selectedHighlight = selectedHighlighted;
          }
          if (k == ChangeNoteKey.sixteenthZ && isZ) {
            selectedHighlight = selectedHighlighted;
          }
          break;
        case NoteLength.thirtySecond:
        case NoteLength.thirtySecondDotted:
          if (k == ChangeNoteKey.thirtySecond && !isZ) {
            selectedHighlight = selectedHighlighted;
          }
          break;
      }

      switch (selectedNoteLengthV) {
        case NoteLength.wholeDotted:
          if (k == ChangeNoteKey.dottodNote) {
            selectedHighlight = selectedHighlighted;
          }
        case NoteLength.halfDotted:
          if (k == ChangeNoteKey.dottodNote) {
            selectedHighlight = selectedHighlighted;
          }
        case NoteLength.quarterDotted:
          if (k == ChangeNoteKey.dottodNote) {
            selectedHighlight = selectedHighlighted;
          }
        case NoteLength.eighthDotted:
          if (k == ChangeNoteKey.dottodNote) {
            selectedHighlight = selectedHighlighted;
          }
        case NoteLength.sixteenthDotted:
          if (k == ChangeNoteKey.dottodNote) {
            selectedHighlight = selectedHighlighted;
          }
        case NoteLength.thirtySecondDotted:
          if (k == ChangeNoteKey.dottodNote) {
            selectedHighlight = selectedHighlighted;
          }
        default:
          break;
      }
    }

    return _Button(
      index: index,
      onTap: () {
        onTapAtIndex(context, k);
      },
      onLongPress: k == ChangeNoteKey.delete
          ? () {
              onLongPress(context, k);
            }
          : null,
      height: _kButtonHeight,
      width: k.widthModifier * _kButtonHeight,
      color: k == ChangeNoteKey.delete ? const Color(0xFFFF6666) : null,
      child: Stack(
        children: [
          svg,
          child,
          highlight,
          selectedHighlight,
          if (_expandedZSelections.value && k == ChangeNoteKey.mergedZ)
            Positioned(
              bottom: 0 + 4,
              right: 0 + 4,
              child: SizedBox(
                width: _kMarkSize,
                height: _kMarkSize,
                child: CustomPaint(
                  size: Size(_kMarkSize, _kMarkSize), // The size of the canvas
                  painter: _TrianglePainter(expanded: true),
                ),
              ),
            ),
          if (k == ChangeNoteKey.mergedZ && !_expandedZSelections.value)
            Positioned(
              bottom: 1 + 4,
              right: 0 + 4,
              child: SB(
                width: _kMarkSize,
                height: _kMarkSize,
                child: CustomPaint(
                  size: Size(_kMarkSize, _kMarkSize), // The size of the canvas
                  painter: _TrianglePainter(expanded: false),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

const _kMarkSize = 6.0;

class _Button extends StatefulWidget {
  final Widget child;
  final int index;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final double height;
  final double width;
  final Color? color;

  const _Button({
    required this.width,
    required this.child,
    required this.index,
    required this.height,
    this.onTap,
    this.onLongPress,
    this.color,
  });

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> {
  bool tapped = false;

  final globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GD(
      key: globalKey,
      onTapDown: (_) {
        setState(() {
          tapped = true;
        });
      },
      onTapCancel: () async {
        await HF.wait(100);
        setState(() {
          tapped = false;
        });
      },
      onTapUp: (details) async {
        await HF.wait(100);
        setState(() {
          tapped = false;
        });
      },
      onTap: () {
        _latestButtonClickPosition.value = getPosition(globalKey);
        widget.onTap?.call();
      },
      onLongPress: widget.onLongPress,
      child: SB(
        height: _kButtonHeight,
        width: widget.width,
        child: Center(
          child: AnimatedContainer(
            duration: 100.ms,
            curve: Curves.easeOutCirc,
            height: _kButtonHeight * (tapped ? 0.97 : 1),
            width: widget.width * (tapped ? 0.97 : 1),
            decoration: BD(
              boxShadow: [
                BoxShadow(
                  color: kB.wo(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Transform.scale(
              scale: tapped ? 0.97 : 1,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class _ZSelections extends StatelessWidget {
  const _ZSelections();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final position = _latestButtonClickPosition.value;
        final top = (position?.dy ?? 0) + _kContainerHeight;
        final left = (position?.dx ?? 0) - _kContainerHeight * 2 + 4 * 2;
        return Stack(
          children: [
            Positioned(
              top: top,
              left: left,
              child: C(
                decoration: BD(
                  color: kB,
                  borderRadius: 8.r,
                  border: Border.all(color: kW.wo(0.33), width: 0.5),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color(0xFF494949),
                      Color(0xFF323232),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kB.wo(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                height: _kContainerHeight + 10,
                width: (_kContainerHeight * 5) + (4 * 4) + 10,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 5),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final key = ChangeNoteKey.values
                        .where((k) => !k.isMain)
                        .elementAt(index);
                    final svg = key.bgWidget;

                    final child = Center(
                      child: SvgPicture.asset(
                        key.iconImage!,
                        width: key.assetSize.width * _kButtonHeight / 48.0,
                        height: key.assetSize.height * _kButtonHeight / 48.0,
                        color: kW,
                      ),
                    );

                    return GD(
                      onTap: () {
                        Navigator.of(context).pop(key);
                      },
                      child: C(
                        width: _kContainerHeight,
                        height: _kContainerHeight,
                        decoration: BD(
                          boxShadow: [
                            BoxShadow(
                              color: kB.wo(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            svg,
                            child,
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return 4.w;
                  },
                  itemCount:
                      ChangeNoteKey.values.where((k) => !k.isMain).length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Offset getPosition(GlobalKey key) {
  final RenderBox renderBox =
      key.currentContext!.findRenderObject() as RenderBox;
  final position = renderBox.localToGlobal(Offset.zero);
  return position;
}

class _TrianglePainter extends CustomPainter {
  final bool expanded;

  _TrianglePainter({required this.expanded});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kW // Triangle color
      ..style = PaintingStyle.fill; // You can also use stroke for an outline

    // Create the path to define the triangle
    final path = Path();

    if (!expanded) {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    }
    path.close(); // Close the path to form the triangle

    // Draw the path on the canvas
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Return true if the painter needs to be repainted
  }
}
