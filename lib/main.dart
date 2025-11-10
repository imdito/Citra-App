import 'package:citra_app/image_processing_View.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Gunakan GetMaterialApp
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Image Processor',
      home: ImageProcessingView(), // Langsung ke screen Anda
      // Jika Anda menggunakan GetX routes, Anda bisa setup bindings di sini
    );
  }
}
