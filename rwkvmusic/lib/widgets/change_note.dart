import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_connect/http/src/request/request.dart';
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
        return null;
      case ChangeNoteKey.wholeZ:
        return null;
      case ChangeNoteKey.halfZ:
        return null;
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
      default:
        return Size(32, 32);
    }
  }
}

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
          height: 60,
          width: screenWidth,
          child: Ro(
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
                  child = C(
                    decoration: BD(color: kCR.wo(0.5)),
                    child: Center(
                        child: T(
                      "Delete",
                      s: TS(w: FW.w500, s: 16),
                    )),
                  );
                }
                return GD(
                  onTap: () {
                    onTapAtIndex(context, k);
                  },
                  onLongPress: () {
                    onLongPress(context, k);
                  },
                  child: C(
                    height: 50,
                    width: k == ChangeNoteKey.delete ? 78 : 50,
                    decoration: BD(color: kW, borderRadius: 4.r),
                    child: child,
                  ),
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
