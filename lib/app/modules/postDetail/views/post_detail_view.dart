import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/post_detail_controller.dart';

class PostDetailView extends GetView<PostDetailController> {
  const PostDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Detail')),
      body: const Center(child: Text('PostDetailView')),
    );
  }
}
