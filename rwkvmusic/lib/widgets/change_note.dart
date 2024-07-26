import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:halo/halo.dart';

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
                return GD(
                  onTap: () {
                    onTapAtIndex(context, k);
                  },
                  onLongPress: () {
                    onLongPress(context, k);
                  },
                  child: C(
                    height: 50,
                    width: 50,
                    decoration: BD(color: kW, borderRadius: 4.r),
                    child: Center(
                        child: T(
                      k.name,
                      s: TS(s: 8),
                    )),
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
