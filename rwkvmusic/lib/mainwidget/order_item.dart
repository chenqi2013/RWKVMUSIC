import 'package:flutter/material.dart';

class OrderItem extends StatelessWidget {
  const OrderItem(
      {super.key,
      required this.title,
      required this.deleteAction,
      required this.isShowDelete});
  final String title;
  final Function() deleteAction;
  final int isShowDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          isShowDelete == 1
              ? Row(children: [
                  const Icon(Icons.menu),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    child: const Icon(Icons.delete),
                    onTap: () {
                      deleteAction();
                    },
                  ),
                ])
              : const Icon(Icons.menu),
        ],
      ),
    );
  }
}
