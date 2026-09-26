import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/features/auth/login/controllers/login_controller.dart';
import 'package:mobile/shared/colour/app_color.dart';
import 'package:mobile/shared/components/custom_button_large.dart';
import 'package:mobile/shared/components/custom_text_field.dart';
import 'package:mobile/shared/components/loading_overlay_widget.dart';
import 'package:mobile/shared/fonts/app_text_style.dart';
import 'package:mobile/shared/theme/app_spacing.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Neutral200,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xxl),

                  // ── Branding ───────────────────────────────────────────
                  const Icon(
                    Icons.school_rounded,
                    size: AppSpacing.x3l,
                    color: AppColor.Primary500,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'OffLearn',
                    style: AppTextStyle.heading2(
                      color: AppColor.Primary600,
                      fontWeight: AppTextStyle.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Belajar tanpa batas, meski tanpa sinyal.',
                    style: AppTextStyle.body2(color: AppColor.Neutral500),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Form card ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColor.Neutral100,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.borderRadiusLarge,
                      ),
                      border: Border.all(color: AppColor.Neutral300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Masuk ke Akun',
                          style: AppTextStyle.heading5(
                            color: AppColor.Neutral900,
                            fontWeight: AppTextStyle.semiBold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Email
                        CustomTextfield.textFieldLarge(
                          label: 'Email',
                          hintText: 'contoh@email.com',
                          controller: controller.emailController,
                          isObsecureText: false,
                          keyBoardType: TextInputType.emailAddress,
                          prefixicon: const Icon(
                            Icons.email_outlined,
                            color: AppColor.Neutral400,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Email tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Password
                        CustomTextfield.textFieldLarge(
                          label: 'Password',
                          hintText: '••••••••',
                          controller: controller.passwordController,
                          isObsecureText: true,
                          prefixicon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColor.Neutral400,
                          ),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Password tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Error message
                        Obx(() {
                          if (controller.errorMessage.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: Text(
                              controller.errorMessage.value,
                              style: AppTextStyle.body3(
                                color: AppColor.Danger600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }),

                        // Login button
                        Obx(
                          () => CustomButtonLarge.primarylarge(
                            text: 'Masuk',
                            isLoading: controller.isLoading.value,
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.login,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ── Register link ──────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: AppTextStyle.body2(color: AppColor.Neutral500),
                      ),
                      GestureDetector(
                        onTap: controller.goToRegister,
                        child: Text(
                          'Daftar',
                          style: AppTextStyle.body2(
                            color: AppColor.Primary500,
                            fontWeight: AppTextStyle.semiBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Loading overlay ──────────────────────────────────────────
          Obx(
            () => controller.isLoading.value
                ? const LoadingOverlayWidget()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
