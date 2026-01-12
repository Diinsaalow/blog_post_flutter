import 'package:get/get.dart';

import '../controllers/all_posts_controller.dart';

class AllPostsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AllPostsController>(
      () => AllPostsController(),
    );
  }
}
