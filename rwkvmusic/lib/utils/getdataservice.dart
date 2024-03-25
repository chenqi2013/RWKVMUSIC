import 'package:get/get.dart';

class MyService extends GetxService {
  var count = 2.obs; // 使用.obs扩展来监听变量的变化
}

class MyBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(MyService());
  }
}
