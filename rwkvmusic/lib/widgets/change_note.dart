import 'package:flutter/material.dart';
import 'package:halo/halo.dart';

enum _Key {
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
  const ChangeNote({super.key});

  void _onTapAtIndex(BuildContext context, _Key key) async {
    // TODO: implementation
  }

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
              ..._Key.values.indexMap((index, k) {
                return GD(
                  onTap: () {
                    _onTapAtIndex(context, k);
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
