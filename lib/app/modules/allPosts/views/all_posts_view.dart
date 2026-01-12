import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/all_posts_controller.dart';

class AllPostsView extends GetView<AllPostsController> {
  const AllPostsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AllPostsView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AllPostsView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
