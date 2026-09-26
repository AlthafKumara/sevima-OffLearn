import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sevima Hackaton',
      home: Scaffold(
        body: Center(child: Text('Offlearn Mobile App Setup Complete')),
      )
    );
  }
}