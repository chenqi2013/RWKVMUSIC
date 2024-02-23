// 堆栈类
class Stack {
  // 单例模式固定格式
  Stack._();

  // 单例模式固定格式
  static Stack? _instance;

  // 单例模式固定格式
  static Stack getInstance() {
    if (_instance == null) {
      _instance = Stack._();
    }
    return _instance!;
  }

  // 存放数据的堆栈
  var dataStack = [];

  // 添加数据
  void add(dynamic data) {
    if (!dataStack.contains(data)) {
      dataStack.add(data);
    }
  }

  // 移除数据
  void remove(dynamic data) {
    dataStack.remove(data);
  }
}

// 程序入口
main(List<String> args) {
  // 添加数据到堆栈中
  Stack.getInstance().add('1');
  Stack.getInstance().add('2');
  Stack.getInstance().add('3');
  print(Stack.getInstance().dataStack);
  // 移除堆栈中的数据
  Stack.getInstance().remove('3');
  print(Stack.getInstance().dataStack);
}
