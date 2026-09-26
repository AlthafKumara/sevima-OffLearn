import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/features/subjects/controllers/subject_controller.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/shared/models/user_model.dart';
import 'package:mobile/shared/colour/app_color.dart';
import 'package:mobile/shared/components/error_state_widget.dart';
import 'package:mobile/shared/components/loading_overlay_widget.dart';
import 'package:mobile/shared/fonts/app_text_style.dart';
import 'package:mobile/shared/theme/app_spacing.dart';

class SubjectPage extends GetView<SubjectController> {
  const SubjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isGuru = Get.find<UserModel>().isGuru;

    return Scaffold(
      backgroundColor: AppColor.Neutral200,
      appBar: AppBar(
        title: Text(
          'Mata Pelajaran',
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
            onPressed: controller.fetchSubjects,
          ),
        ],
      ),
      floatingActionButton: isGuru
          ? FloatingActionButton(
              onPressed: () => _showAddSubjectDialog(context),
              backgroundColor: AppColor.Primary500,
              child: const Icon(Icons.add, color: AppColor.Neutral100),
            )
          : null,
      body: Stack(
        children: [
          Obx(() {
            if (controller.errorMessage.isNotEmpty &&
                controller.subjects.isEmpty) {
              return ErrorStateWidget(
                message: controller.errorMessage.value,
                onRetry: controller.fetchSubjects,
              );
            }

            if (!controller.isLoading.value && controller.subjects.isEmpty) {
              return Center(
                child: Text(
                  'Belum ada mata pelajaran.',
                  style: AppTextStyle.body2(color: AppColor.Neutral500),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.fetchSubjects,
              color: AppColor.Primary500,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                itemCount: controller.subjects.length,
                separatorBuilder: (_, i) =>
                    const SizedBox(height: AppSpacing.itemGap),
                itemBuilder: (_, index) {
                  final subject = controller.subjects[index];
                  return ListTile(
                    tileColor: AppColor.Neutral100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.borderRadiusLarge,
                      ),
                      side: const BorderSide(color: AppColor.Neutral300),
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: AppColor.Primary200,
                      child: Icon(
                        Icons.book_outlined,
                        color: AppColor.Primary600,
                      ),
                    ),
                    title: Text(
                      subject.namaSubject,
                      style: AppTextStyle.body1(
                        color: AppColor.Neutral900,
                        fontWeight: AppTextStyle.semiBold,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColor.Neutral400,
                    ),
                    onTap: () =>
                        Get.toNamed(Routes.MODULES, arguments: subject.id),
                  );
                },
              ),
            );
          }),

          Obx(
            () => controller.isLoading.value
                ? const LoadingOverlayWidget()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final textCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Mata Pelajaran'),
          content: TextField(
            controller: textCtrl,
            decoration: const InputDecoration(hintText: 'Nama Mata Pelajaran'),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () {
                final name = textCtrl.text.trim();
                if (name.isNotEmpty) {
                  final guruId = Get.find<UserModel>().id;
                  controller.createSubject(name, guruId);
                  Get.back();
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
