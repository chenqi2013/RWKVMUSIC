import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ReorderableListView Example'),
        ),
        body: const ReorderableListViewExample(),
      ),
    );
  }
}

class ReorderableListViewExample extends StatefulWidget {
  const ReorderableListViewExample({super.key});

  @override
  _ReorderableListViewExampleState createState() =>
      _ReorderableListViewExampleState();
}

class _ReorderableListViewExampleState
    extends State<ReorderableListViewExample> {
  final bool _isSortingEnabled = true;
  final List<String> _items = List.generate(100, (index) => 'Item $index');

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !_isSortingEnabled, // 根据_isSortingEnabled决定是否禁用手势拖动
      child: ReorderableListView(
        physics: _isSortingEnabled
            ? const AlwaysScrollableScrollPhysics()
            : const ClampingScrollPhysics(), //
        onReorder: _isSortingEnabled
            ? (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final String item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
              }
            : (oldIndex, newIndex) {},
        children: _items.map((item) {
          return ListTile(
            key: Key(item),
            title: Text(item),
          );
        }).toList(), // 如果排序被禁用，则将回调设置为null
      ),
    );
  }
}
