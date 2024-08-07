import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:halo/halo.dart';
import 'package:rwkvmusic/gen/assets.gen.dart';

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

  Size get assetSize {
    switch (this) {
      case ChangeNoteKey.whole:
        return Size(8, 8);
      case ChangeNoteKey.quarterZ:
        return Size(20, 20);
      case ChangeNoteKey.eighthZ:
        return Size(20, 20);
      case ChangeNoteKey.wholeZ:
        return Size(6, 6);
      case ChangeNoteKey.halfZ:
        return Size(6, 6);
      default:
        return Size(32, 32);
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
    return ClipRRect(
      borderRadius: 8.r,
      child: C(
          decoration: BD(
            color: Color(0xFF222222),
          ),
          constraints: BoxConstraints(
            maxHeight: _kContainerHeight,
            minHeight: _kContainerHeight,
          ),
          width: screenWidth,
          child: Ro(
            m: MAA.center,
            children: [
              5.w,
              ...ChangeNoteKey.values.indexMap((index, k) {
                Widget child = C();
                final assetName = k.assetName;
                if (assetName != null) {
                  child = Center(
                    child: SvgPicture.asset(
                      assetName,
                      width: k.assetSize.width,
                      height: k.assetSize.height,
                    ),
                  );
                }
                if (k == ChangeNoteKey.randomGroove) {
                  child = Center(
                      child: T(
                    "Random\nGroove",
                    textAlign: TextAlign.center,
                    s: TS(
                      w: FW.w500,
                      s: 10,
                    ),
                  ));
                }
                if (k == ChangeNoteKey.delete) {
                  child = Center(
                      child: T(
                    "Delete",
                    s: TS(w: FW.w500, s: 16),
                  ));
                }

                return _Button(
                  child,
                  index,
                  () {
                    onTapAtIndex(context, k);
                  },
                  k == ChangeNoteKey.delete
                      ? () {
                          onLongPress(context, k);
                        }
                      : null,
                  _kButtonHeight,
                  k == ChangeNoteKey.delete ? 78 : _kButtonHeight,
                  color: k == ChangeNoteKey.delete ? Color(0xFFFF6666) : null,
                );
              }).widgetJoin(
                (_) => 4.w,
              ),
              5.w,
            ],
          )),
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

  const _Button(
    this.child,
    this.index,
    this.onTap,
    this.onLongPress,
    this.height,
    this.width, {
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
            height: _kButtonHeight * (tapped ? 0.9 : 1),
            width: widget.width * (tapped ? 0.9 : 1),
            decoration: BD(
              color: widget.color ?? kW,
              borderRadius: 4.r,
            ),
            child: Transform.scale(
              scale: tapped ? 0.9 : 1,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
