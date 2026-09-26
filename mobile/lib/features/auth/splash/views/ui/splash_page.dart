import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/features/auth/splash/controllers/splash_controller.dart';
import 'package:mobile/shared/colour/app_color.dart';
import 'package:mobile/shared/fonts/app_text_style.dart';
import 'package:mobile/shared/theme/app_spacing.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: AppSpacing.x3l, color: Colors.blue),
            const SizedBox(height: AppSpacing.md),
            Text(
              'OffLearn',
              style: AppTextStyle.heading1(color: AppColor.Primary600),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
