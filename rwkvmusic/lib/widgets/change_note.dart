import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:halo/halo.dart';
import 'package:rwkvmusic/gen/assets.gen.dart';
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
  randomGroove,
  delete,
}

extension _FindAssets on ChangeNoteKey {
  String? get assetName {
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
      case ChangeNoteKey.randomGroove:
        return null;
      case ChangeNoteKey.delete:
        return null;
    }
  }

  AssetGenImage get bgImage {
    switch (this) {
      case ChangeNoteKey.delete:
        return Assets.images.changeNode.btnD;
      case ChangeNoteKey.randomGroove:
        return Assets.images.changeNode.btnW;
      default:
        return Assets.images.changeNode.btn;
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
}

const _kButtonHeight = 48.0;
const _kContainerHeight = 52.0;

class ChangeNote extends StatelessWidget {
  final void Function(BuildContext context, ChangeNoteKey key) onTapAtIndex;
  final void Function(BuildContext context, ChangeNoteKey key) onLongPress;

  const ChangeNote({
    super.key,
    required this.onTapAtIndex,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Obx(() {
      final inputNoteLengthV = inputNoteLength.value;
      final selectedNoteV = selectedNote.value;

      return ClipRRect(
        borderRadius: 8.r,
        child: C(
            decoration: const BD(color: kC),
            constraints: const BoxConstraints(
              maxHeight: _kContainerHeight,
              minHeight: _kContainerHeight,
            ),
            width: screenWidth,
            child: Center(
              child: ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: [
                  5.w,
                  ...ChangeNoteKey.values.indexMap((index, k) {
                    return _buildKey(
                      context: context,
                      k: k,
                      inputNoteLengthV: inputNoteLengthV,
                      index: index,
                      selectedNote: selectedNoteV,
                    );
                  }).widgetJoin(
                    (_) => 4.w,
                  ),
                  5.w,
                ],
              ),
            )),
      );
    });
  }

  Widget _buildKey({
    required BuildContext context,
    required ChangeNoteKey k,
    required NoteLength inputNoteLengthV,
    required int index,
    NewNote? selectedNote,
  }) {
    Widget child = C();
    final assetName = k.assetName;
    if (assetName != null) {
      child = Center(
        child: SvgPicture.asset(
          assetName,
          width: k.assetSize.width,
          height: k.assetSize.height,
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
      ).createShader(const Rect.fromLTWH(
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
            s: 14,
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
      ).createShader(const Rect.fromLTWH(
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
            s: 14,
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

    final svg = Center(
      child: k.bgImage.image(),
    );

    Widget highlight = C();
    final highlighted = Positioned(
      top: 4,
      left: 4,
      child: C(
        width: 6,
        height: 6,
        decoration: BD(
          color: kCR,
          borderRadius: 4.r,
          boxShadow: [
            BoxShadow(color: kCR, blurRadius: 10),
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

    if (selectedNote != null) {
      final selectedNoteLengthV = selectedNote.length;
      final isZ = selectedNote.isZ;
      switch (selectedNoteLengthV) {
        case NoteLength.whole:
        case NoteLength.wholeDotted:
          if (k == ChangeNoteKey.whole && !isZ)
            selectedHighlight = selectedHighlighted;
          if (k == ChangeNoteKey.wholeZ && isZ)
            selectedHighlight = selectedHighlighted;
          break;
        case NoteLength.half:
        case NoteLength.halfDotted:
          if (k == ChangeNoteKey.half && !isZ)
            selectedHighlight = selectedHighlighted;
          if (k == ChangeNoteKey.halfZ && isZ)
            selectedHighlight = selectedHighlighted;
          break;
        case NoteLength.quarter:
        case NoteLength.quarterDotted:
          if (k == ChangeNoteKey.quarter && !isZ)
            selectedHighlight = selectedHighlighted;
          if (k == ChangeNoteKey.quarterZ && isZ)
            selectedHighlight = selectedHighlighted;
          break;
        case NoteLength.eighth:
        case NoteLength.eighthDotted:
          if (k == ChangeNoteKey.eighth && !isZ)
            selectedHighlight = selectedHighlighted;
          if (k == ChangeNoteKey.eighthZ && isZ)
            selectedHighlight = selectedHighlighted;
          break;
        case NoteLength.sixteenth:
        case NoteLength.sixteenthDotted:
          if (k == ChangeNoteKey.sixteenth && !isZ)
            selectedHighlight = selectedHighlighted;
          if (k == ChangeNoteKey.sixteenthZ && isZ)
            selectedHighlight = selectedHighlighted;
          break;
        case NoteLength.thirtySecond:
        case NoteLength.thirtySecondDotted:
          if (k == ChangeNoteKey.thirtySecond && !isZ)
            selectedHighlight = selectedHighlighted;
          break;
      }

      switch (selectedNoteLengthV) {
        case NoteLength.wholeDotted:
          if (k == ChangeNoteKey.dottodNote)
            selectedHighlight = selectedHighlighted;
        case NoteLength.halfDotted:
          if (k == ChangeNoteKey.dottodNote)
            selectedHighlight = selectedHighlighted;
        case NoteLength.quarterDotted:
          if (k == ChangeNoteKey.dottodNote)
            selectedHighlight = selectedHighlighted;
        case NoteLength.eighthDotted:
          if (k == ChangeNoteKey.dottodNote)
            selectedHighlight = selectedHighlighted;
        case NoteLength.sixteenthDotted:
          if (k == ChangeNoteKey.dottodNote)
            selectedHighlight = selectedHighlighted;
        case NoteLength.thirtySecondDotted:
          if (k == ChangeNoteKey.dottodNote)
            selectedHighlight = selectedHighlighted;
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
      width: (k == ChangeNoteKey.delete || k == ChangeNoteKey.randomGroove)
          ? _kButtonHeight * 1.55
          : _kButtonHeight,
      color: k == ChangeNoteKey.delete ? const Color(0xFFFF6666) : null,
      child: Stack(
        children: [
          svg,
          child,
          highlight,
          selectedHighlight,
        ],
      ),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    print(tapped);
    return GD(
      onTapDown: (_) {
        setState(() {
          tapped = true;
        });
      },
      onTapCancel: () async {
        await wait(100);
        setState(() {
          tapped = false;
        });
      },
      onTapUp: (details) async {
        await wait(100);
        setState(() {
          tapped = false;
        });
      },
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: SB(
        height: _kButtonHeight,
        width: widget.width,
        child: Center(
          child: AnimatedContainer(
            duration: 100.ms,
            curve: Curves.easeOutCirc,
            height: _kButtonHeight * (tapped ? 0.95 : 1),
            width: widget.width * (tapped ? 0.95 : 1),
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
              scale: tapped ? 0.95 : 1,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
