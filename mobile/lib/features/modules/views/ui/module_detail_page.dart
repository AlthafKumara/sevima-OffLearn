import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/features/modules/controllers/module_detail_controller.dart';
import 'package:mobile/shared/colour/app_color.dart';
import 'package:mobile/shared/components/error_state_widget.dart';
import 'package:mobile/shared/components/loading_overlay_widget.dart';
import 'package:mobile/shared/fonts/app_text_style.dart';
import 'package:mobile/shared/theme/app_spacing.dart';

class ModuleDetailPage extends GetView<ModuleDetailController> {
  const ModuleDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Neutral200,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.module.value?.judul ?? 'Detail Modul',
            style: AppTextStyle.heading5(
              color: AppColor.Neutral900,
              fontWeight: AppTextStyle.semiBold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        backgroundColor: AppColor.Neutral100,
        surfaceTintColor: AppColor.Neutral100,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColor.Neutral900,
          ),
          onPressed: Get.back,
        ),
      ),
      body: Stack(
        children: [
          Obx(() {
            if (controller.errorMessage.isNotEmpty &&
                controller.module.value == null) {
              return ErrorStateWidget(
                message: controller.errorMessage.value,
                onRetry: () {
                  final id = Get.arguments as String?;
                  if (id != null) controller.fetchModule(id);
                },
              );
            }

            final mod = controller.module.value;
            if (mod == null) return const SizedBox.shrink();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Meta badges ────────────────────────────────────────
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (mod.urutan != null)
                        _Badge(
                          label: 'Bab ${mod.urutan}',
                          bgColor: AppColor.Primary200,
                          textColor: AppColor.Primary600,
                        ),
                      if (mod.targetKelas != null)
                        _Badge(
                          label: mod.targetKelas!,
                          bgColor: AppColor.Neutral250,
                          textColor: AppColor.Neutral600,
                        ),
                      _Badge(
                        label: mod.status ?? 'draft',
                        bgColor: mod.status == 'published'
                            ? AppColor.Success500.withValues(alpha: 0.15)
                            : AppColor.Warning400.withValues(alpha: 0.2),
                        textColor: mod.status == 'published'
                            ? AppColor.Success600
                            : AppColor.Warning600,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ── Title ──────────────────────────────────────────────
                  Text(
                    mod.judul,
                    style: AppTextStyle.heading4(
                      color: AppColor.Neutral900,
                      fontWeight: AppTextStyle.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Content ────────────────────────────────────────────
                  if (mod.konten != null && mod.konten!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      decoration: BoxDecoration(
                        color: AppColor.Neutral100,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.borderRadiusLarge,
                        ),
                        border: Border.all(color: AppColor.Neutral300),
                      ),
                      child: Text(
                        mod.konten!,
                        style: AppTextStyle.body1(color: AppColor.Neutral900),
                      ),
                    )
                  else
                    Center(
                      child: Text(
                        'Konten belum tersedia.',
                        style: AppTextStyle.body2(color: AppColor.Neutral400),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.sectionGap),
                ],
              ),
            );
          }),

          // ── Loading overlay ────────────────────────────────────────────
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

class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      child: Text(
        label,
        style: AppTextStyle.body3(
          color: textColor,
          fontWeight: AppTextStyle.semiBold,
        ),
      ),
    );
  }
}
