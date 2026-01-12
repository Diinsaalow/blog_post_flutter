import 'package:blog_post_flutter/app/modules/allPosts/controllers/all_posts_controller.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.put<AllPostsController>(AllPostsController(), permanent: true);
  }
}
