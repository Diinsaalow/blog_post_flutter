// lib/app/core/controllers/navigation_controller.dart
import 'package:get/get.dart';
import '../../routes/app_pages.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;

    switch (index) {
      case 0:
        Get.offAllNamed(Routes.HOME);
        break;
      case 1:
        Get.offAllNamed(Routes.ALL_POSTS);
        break;
      case 2:
        Get.offAllNamed(Routes.FAVORITES);
        break;
      case 3:
        Get.offAllNamed(Routes.PROFILE);
        break;
    }
  }
}
