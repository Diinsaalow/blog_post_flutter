import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/core/services/api_service.dart';
import 'app/data/repositories/auth_repository.dart';
import 'app/data/repositories/post_repository.dart';
import 'app/data/repositories/comment_repository.dart';
import 'app/core/controllers/navigation_controller.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Initialize and register all services (permanent = true means they stay in memory)
  Get.put(ApiService(), permanent: true);
  Get.put(AuthRepository(), permanent: true);
  Get.put(PostRepository(), permanent: true);
  Get.put(CommentRepository(), permanent: true);
  Get.put(NavigationController(), permanent: true);

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BLOGGIES",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    ),
  );
}
