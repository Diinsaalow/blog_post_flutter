// lib/app/modules/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/controllers/navigation_controller.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationController = Get.find<NavigationController>();
    navigationController.currentIndex.value = 0;

    return GetBuilder<HomeController>(
      builder: (home) {
        return Scaffold(
          appBar: home.currentTab == 0
              ? AppBar(
                  title: const Text(
                    'Blog Post',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                  elevation: 0,
                )
              : null,
          body: GetBuilder<HomeController>(
            builder: (homeController) {
              // Show loading while menus are being fetched
              if (homeController.menus.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return homeController.tabs[homeController.currentTab];
            },
          ),

          bottomNavigationBar: GetBuilder<HomeController>(
            builder: (cont) {
              // Show loading or default state if menus not loaded yet
              if (cont.menus.isEmpty) {
                return const SizedBox.shrink();
              }

              return BottomNavigationBar(
                currentIndex: cont.currentTab,
                onTap: cont.updateCurrentTab,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Theme.of(context).primaryColor,
                unselectedItemColor: Colors.grey,
                items: cont.navItems,
              );
            },
          ),
        );
      },
    );
  }
}
