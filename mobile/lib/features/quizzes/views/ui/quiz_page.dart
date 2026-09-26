import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/features/quizzes/controllers/quiz_controller.dart';
import 'package:mobile/features/quizzes/views/components/quiz_card_widget.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/shared/colour/app_color.dart';
import 'package:mobile/shared/components/custom_text_field.dart';
import 'package:mobile/shared/components/error_state_widget.dart';
import 'package:mobile/shared/components/loading_overlay_widget.dart';
import 'package:mobile/shared/fonts/app_text_style.dart';
import 'package:mobile/shared/theme/app_spacing.dart';
import 'package:mobile/shared/models/user_model.dart';

class QuizPage extends GetView<QuizController> {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Neutral200,
      appBar: AppBar(
        title: Text(
          'Kuis',
          style: AppTextStyle.heading5(
            color: AppColor.Neutral900,
            fontWeight: AppTextStyle.semiBold,
          ),
        ),
        backgroundColor: AppColor.Neutral100,
        surfaceTintColor: AppColor.Neutral100,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColor.Primary500),
            tooltip: 'Refresh',
            onPressed: controller.fetchQuizzes,
          ),
        ],
      ),
      floatingActionButton: Get.find<UserModel>().isGuru
          ? FloatingActionButton(
              onPressed: () => _showAddQuizDialog(context),
              backgroundColor: AppColor.Primary500,
              child: const Icon(Icons.add, color: AppColor.Neutral100),
            )
          : null,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Filter bar ─────────────────────────────────────────────
              Container(
                color: AppColor.Neutral100,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  0,
                  AppSpacing.pagePadding,
                  AppSpacing.md,
                ),
                child: _QuizFilterBar(),
              ),

              // ── Quiz list ──────────────────────────────────────────────
              Expanded(
                child: Obx(() {
                  if (controller.errorMessage.isNotEmpty &&
                      controller.quizzes.isEmpty) {
                    return ErrorStateWidget(
                      message: controller.errorMessage.value,
                      onRetry: controller.fetchQuizzes,
                    );
                  }

                  if (!controller.isLoading.value &&
                      controller.quizzes.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada kuis tersedia.',
                        style: AppTextStyle.body2(color: AppColor.Neutral500),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.fetchQuizzes,
                    color: AppColor.Primary500,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.pagePadding),
                      itemCount: controller.quizzes.length,
                      separatorBuilder: (_, i) =>
                          const SizedBox(height: AppSpacing.itemGap),
                      itemBuilder: (_, index) {
                        final quiz = controller.quizzes[index];
                        return QuizCardWidget(
                          quiz: quiz,
                          onTap: () => Get.toNamed(
                            Routes.QUIZ_DETAIL,
                            arguments: quiz.id,
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
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

  void _showAddQuizDialog(BuildContext context) {
    final argSubjectId = Get.arguments as String?;
    final subjectIdCtrl = TextEditingController(text: argSubjectId ?? '');
    final namaCtrl = TextEditingController();
    final kelasCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Kuis'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (argSubjectId == null) ...[
                  TextField(
                    controller: subjectIdCtrl,
                    decoration: const InputDecoration(
                      hintText: 'ID Mata Pelajaran (UUID)',
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                TextField(
                  controller: namaCtrl,
                  decoration: const InputDecoration(hintText: 'Nama Kuis'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: kelasCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Target Kelas (misal: 5A)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final subjectId = subjectIdCtrl.text.trim();
                final nama = namaCtrl.text.trim();
                final kelas = kelasCtrl.text.trim();

                if (subjectId.isNotEmpty &&
                    nama.isNotEmpty &&
                    kelas.isNotEmpty) {
                  final guruId = Get.find<UserModel>().id;
                  controller.createQuiz(
                    subjectId: subjectId,
                    namaQuiz: nama,
                    targetKelas: kelas,
                    guruId: guruId,
                  );
                  Get.back();
                } else {
                  Get.snackbar('Error', 'Harap isi semua kolom');
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}

class _QuizFilterBar extends GetView<QuizController> {
  final TextEditingController _kelasCtrl = TextEditingController();

  _QuizFilterBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: CustomTextfield.textFieldRounded(
            hintText: 'Filter kelas (misal: Kelas 5)',
            controller: _kelasCtrl,
            isObsecureText: false,
            prefixicon: const Icon(
              Icons.filter_list_rounded,
              color: AppColor.Neutral400,
            ),
            validator: (_) => null,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        ElevatedButton(
          onPressed: () {
            final kelas = _kelasCtrl.text.trim();
            controller.fetchQuizzes(
              targetKelas: kelas.isNotEmpty ? kelas : null,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.Primary500,
            foregroundColor: AppColor.Neutral100,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
            ),
          ),
          child: const Icon(Icons.search_rounded),
        ),
      ],
    );
  }
}
