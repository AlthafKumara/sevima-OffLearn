import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/features/quizzes/controllers/quiz_detail_controller.dart';
import 'package:mobile/shared/colour/app_color.dart';
import 'package:mobile/shared/components/custom_button_large.dart';
import 'package:mobile/shared/components/error_state_widget.dart';
import 'package:mobile/shared/components/loading_overlay_widget.dart';
import 'package:mobile/shared/fonts/app_text_style.dart';
import 'package:mobile/shared/models/quiz_model.dart';
import 'package:mobile/shared/theme/app_spacing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizDetailPage extends GetView<QuizDetailController> {
  const QuizDetailPage({super.key});

  String get _currentUserId =>
      Supabase.instance.client.auth.currentSession?.user.id ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Neutral200,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.quiz.value?.namaQuiz ?? 'Kuis',
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
            // ── Error state ─────────────────────────────────────────────
            if (controller.errorMessage.isNotEmpty &&
                controller.quiz.value == null) {
              return ErrorStateWidget(
                message: controller.errorMessage.value,
                onRetry: () {
                  final id = Get.arguments as String?;
                  if (id != null) controller.fetchQuiz(id);
                },
              );
            }

            final quiz = controller.quiz.value;
            if (quiz == null) return const SizedBox.shrink();

            // ── Submit result ────────────────────────────────────────────
            if (controller.submitResult.isNotEmpty) {
              return _ResultView(result: controller.submitResult.value);
            }

            return Column(
              children: [
                // ── Questions list ────────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.pagePadding),
                    itemCount: quiz.questions.length,
                    separatorBuilder: (_, i) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, index) {
                      final question = quiz.questions[index];
                      return _QuestionCard(
                        index: index,
                        question: question,
                        selectedOptionId:
                            controller.selectedAnswers[question.id],
                        onOptionSelected: (optId) =>
                            controller.selectAnswer(question.id, optId),
                      );
                    },
                  ),
                ),

                // ── Submit button ─────────────────────────────────────────
                Obx(() {
                  final answered = controller.selectedAnswers.length;
                  final total = quiz.questions.length;

                  return Container(
                    color: AppColor.Neutral100,
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.pagePadding,
                      AppSpacing.md,
                      AppSpacing.pagePadding,
                      AppSpacing.pagePadding +
                          MediaQuery.of(context).padding.bottom,
                    ),
                    child: Column(
                      children: [
                        // Progress info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$answered / $total dijawab',
                              style: AppTextStyle.body3(
                                color: AppColor.Neutral500,
                              ),
                            ),
                            if (controller.errorMessage.isNotEmpty)
                              Flexible(
                                child: Text(
                                  controller.errorMessage.value,
                                  style: AppTextStyle.body3(
                                    color: AppColor.Danger500,
                                  ),
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButtonLarge.primarylarge(
                            text: 'Kumpulkan Jawaban',
                            isLoading: controller.isSubmitting.value,
                            onPressed: controller.isComplete
                                ? () => controller.submitAttempt(_currentUserId)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
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

// ── Question card widget ─────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final int index;
  final QuizQuestionModel question;
  final String? selectedOptionId;
  final ValueChanged<String> onOptionSelected;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selectedOptionId,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColor.Neutral100,
        borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLarge),
        border: Border.all(color: AppColor.Neutral300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number + text
          Text(
            '${index + 1}. ${question.pertanyaan}',
            style: AppTextStyle.body1(
              color: AppColor.Neutral900,
              fontWeight: AppTextStyle.semiBold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Options
          ...question.opsi.map((option) {
            final isSelected = selectedOptionId == option.id;
            return GestureDetector(
              onTap: () => onOptionSelected(option.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.Primary200 : AppColor.Neutral200,
                  borderRadius: BorderRadius.circular(AppSpacing.borderRadius),
                  border: Border.all(
                    color: isSelected
                        ? AppColor.Primary500
                        : AppColor.Neutral300,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected
                          ? AppColor.Primary500
                          : AppColor.Neutral400,
                      size: AppSpacing.iconSize,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        option.teksOpsi,
                        style: AppTextStyle.body2(
                          color: isSelected
                              ? AppColor.Primary600
                              : AppColor.Neutral900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Result screen ────────────────────────────────────────────────────────────

class _ResultView extends StatelessWidget {
  final String result;
  const _ResultView({required this.result});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              size: AppSpacing.x3l,
              color: AppColor.Success500,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              result,
              style: AppTextStyle.heading4(
                color: AppColor.Neutral900,
                fontWeight: AppTextStyle.semiBold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: CustomButtonLarge.outlinelarge(
                text: 'Kembali ke Daftar Kuis',
                onPressed: Get.back,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
