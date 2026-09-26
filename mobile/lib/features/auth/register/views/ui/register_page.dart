import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/features/auth/register/controllers/register_controller.dart';
import 'package:mobile/shared/colour/app_color.dart';
import 'package:mobile/shared/components/custom_button_large.dart';
import 'package:mobile/shared/components/custom_text_field.dart';
import 'package:mobile/shared/components/loading_overlay_widget.dart';
import 'package:mobile/shared/fonts/app_text_style.dart';
import 'package:mobile/shared/theme/app_spacing.dart';

class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

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
                  const SizedBox(height: AppSpacing.lg),

                  // ── Branding ──────────────────────────────────────────
                  Text(
                    'Buat Akun',
                    style: AppTextStyle.heading3(
                      color: AppColor.Neutral900,
                      fontWeight: AppTextStyle.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Bergabung dengan OffLearn sekarang.',
                    style: AppTextStyle.body2(color: AppColor.Neutral500),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.lg),

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
                        // Full name
                        CustomTextfield.textFieldLarge(
                          label: 'Nama Lengkap',
                          hintText: 'Masukkan nama lengkap',
                          controller: controller.nameController,
                          isObsecureText: false,
                          prefixicon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColor.Neutral400,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

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
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Role selector
                        Text(
                          'Daftar sebagai',
                          style: AppTextStyle.body2(
                            color: AppColor.Neutral900,
                            fontWeight: AppTextStyle.medium,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Obx(
                          () => Row(
                            children: controller.roles.map((role) {
                              final isSelected =
                                  controller.selectedRole.value == role;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      controller.selectedRole.value = role,
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      right: role == controller.roles.first
                                          ? AppSpacing.sm
                                          : 0,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.sm,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColor.Primary500
                                          : AppColor.Neutral200,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.borderRadius,
                                      ),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColor.Primary500
                                            : AppColor.Neutral300,
                                      ),
                                    ),
                                    child: Text(
                                      role == 'siswa' ? 'Siswa' : 'Guru',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyle.body2(
                                        color: isSelected
                                            ? AppColor.Neutral100
                                            : AppColor.Neutral600,
                                        fontWeight: isSelected
                                            ? AppTextStyle.semiBold
                                            : AppTextStyle.regular,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Kelas field — only shown for siswa
                        Obx(
                          () => controller.showKelas
                              ? Column(
                                  children: [
                                    CustomTextfield.textFieldLarge(
                                      label: 'Kelas',
                                      hintText: 'Contoh: 5A',
                                      controller: controller.kelasController,
                                      isObsecureText: false,
                                      prefixicon: const Icon(
                                        Icons.class_outlined,
                                        color: AppColor.Neutral400,
                                      ),
                                      validator: (v) =>
                                          (v == null || v.trim().isEmpty)
                                          ? 'Kelas wajib diisi'
                                          : null,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                  ],
                                )
                              : const SizedBox.shrink(),
                        ),

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

                        // Register button
                        Obx(
                          () => CustomButtonLarge.primarylarge(
                            text: 'Daftar',
                            isLoading: controller.isLoading.value,
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.register,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ── Login link ────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: AppTextStyle.body2(color: AppColor.Neutral500),
                      ),
                      GestureDetector(
                        onTap: controller.goToLogin,
                        child: Text(
                          'Masuk',
                          style: AppTextStyle.body2(
                            color: AppColor.Primary500,
                            fontWeight: AppTextStyle.semiBold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
