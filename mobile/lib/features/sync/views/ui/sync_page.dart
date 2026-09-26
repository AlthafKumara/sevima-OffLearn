import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/features/sync/controllers/sync_controller.dart';
import 'package:mobile/shared/colour/app_color.dart';
import 'package:mobile/shared/components/custom_button_large.dart';
import 'package:mobile/shared/components/custom_text_field.dart';
import 'package:mobile/shared/components/loading_overlay_widget.dart';
import 'package:mobile/shared/fonts/app_text_style.dart';
import 'package:mobile/shared/theme/app_spacing.dart';

class SyncPage extends GetView<SyncController> {
  const SyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Neutral200,
      appBar: AppBar(
        title: Text(
          'Unduh Konten',
          style: AppTextStyle.heading5(
            color: AppColor.Neutral900,
            fontWeight: AppTextStyle.semiBold,
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Description card ──────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: AppColor.Primary200,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.borderRadiusLarge,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.cloud_download_outlined,
                        color: AppColor.Primary600,
                        size: AppSpacing.iconSize,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Unduh semua modul dan kuis agar bisa diakses '
                          'tanpa koneksi internet.',
                          style: AppTextStyle.body2(color: AppColor.Primary600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sectionGap),

                // ── Kelas filter ──────────────────────────────────────────
                Text(
                  'Filter Kelas (Opsional)',
                  style: AppTextStyle.body2(
                    color: AppColor.Neutral900,
                    fontWeight: AppTextStyle.semiBold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                CustomTextfield.textFieldLarge(
                  hintText: 'Contoh: Kelas 5',
                  controller: controller.kelasFilterCtrl,
                  isObsecureText: false,
                  prefixicon: const Icon(
                    Icons.school_outlined,
                    color: AppColor.Neutral400,
                  ),
                  validator: (_) => null,
                ),
                const SizedBox(height: AppSpacing.sectionGap),

                // ── Download button ───────────────────────────────────────
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: CustomButtonLarge.primarylarge(
                      text: 'Unduh Sekarang',
                      isLoading: controller.isLoading.value,
                      prefixicon: controller.isLoading.value
                          ? null
                          : const Icon(
                              Icons.download_rounded,
                              color: AppColor.Neutral100,
                            ),
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.downloadContent,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // ── Status messages ───────────────────────────────────────
                Obx(() {
                  if (controller.errorMessage.isNotEmpty) {
                    return _StatusMessage(
                      message: controller.errorMessage.value,
                      isError: true,
                    );
                  }
                  if (controller.successMessage.isNotEmpty) {
                    return _StatusMessage(
                      message: controller.successMessage.value,
                      isError: false,
                    );
                  }
                  return const SizedBox.shrink();
                }),

                const SizedBox(height: AppSpacing.sectionGap),

                // ── Downloaded summary ────────────────────────────────────
                Obx(() {
                  if (controller.downloadedModules.isEmpty &&
                      controller.downloadedQuizzes.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return _DownloadSummary(
                    moduleCount: controller.downloadedModules.length,
                    quizCount: controller.downloadedQuizzes.length,
                  );
                }),
              ],
            ),
          ),

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

// ── Status message widget ─────────────────────────────────────────────────────

class _StatusMessage extends StatelessWidget {
  final String message;
  final bool isError;
  const _StatusMessage({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final bg = isError
        ? AppColor.Danger500.withValues(alpha: 0.1)
        : AppColor.Success500.withValues(alpha: 0.1);
    final fg = isError ? AppColor.Danger600 : AppColor.Success600;
    final icon = isError ? Icons.error_outline : Icons.check_circle_outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: AppSpacing.iconSize),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: AppTextStyle.body2(color: fg)),
          ),
        ],
      ),
    );
  }
}

// ── Download summary widget ───────────────────────────────────────────────────

class _DownloadSummary extends StatelessWidget {
  final int moduleCount;
  final int quizCount;
  const _DownloadSummary({required this.moduleCount, required this.quizCount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Konten Tersimpan',
          style: AppTextStyle.body1(
            color: AppColor.Neutral900,
            fontWeight: AppTextStyle.semiBold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                icon: Icons.book_outlined,
                label: '$moduleCount Modul',
                color: AppColor.Primary500,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _SummaryTile(
                icon: Icons.quiz_outlined,
                label: '$quizCount Kuis',
                color: AppColor.Warning500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColor.Neutral100,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLarge),
        border: Border.all(color: AppColor.Neutral300),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppSpacing.iconSize),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyle.body2(
              color: AppColor.Neutral900,
              fontWeight: AppTextStyle.semiBold,
            ),
          ),
        ],
      ),
    );
  }
}
