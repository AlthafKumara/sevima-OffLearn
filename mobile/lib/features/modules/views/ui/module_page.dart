import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/features/modules/controllers/module_controller.dart';
import 'package:mobile/features/modules/views/components/module_card_widget.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/shared/colour/app_color.dart';
import 'package:mobile/shared/components/custom_text_field.dart';
import 'package:mobile/shared/components/error_state_widget.dart';
import 'package:mobile/shared/components/loading_overlay_widget.dart';
import 'package:mobile/shared/fonts/app_text_style.dart';
import 'package:mobile/shared/theme/app_spacing.dart';
import 'package:mobile/shared/models/user_model.dart';

class ModulePage extends GetView<ModuleController> {
  const ModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Neutral200,
      appBar: AppBar(
        title: Text(
          'Modul Belajar',
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
            onPressed: controller.fetchModules,
          ),
        ],
      ),
      floatingActionButton: Get.find<UserModel>().isGuru
          ? FloatingActionButton(
              onPressed: () => _showAddModuleDialog(context),
              backgroundColor: AppColor.Primary500,
              child: const Icon(Icons.add, color: AppColor.Neutral100),
            )
          : null,
      body: Stack(
        children: [
          Column(
            children: [
              // ── Filter / Search bar ─────────────────────────────────────
              Container(
                color: AppColor.Neutral100,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding,
                  0,
                  AppSpacing.pagePadding,
                  AppSpacing.md,
                ),
                child: _FilterBar(),
              ),

              // ── Module list ─────────────────────────────────────────────
              Expanded(
                child: Obx(() {
                  if (controller.errorMessage.isNotEmpty &&
                      controller.modules.isEmpty) {
                    return ErrorStateWidget(
                      message: controller.errorMessage.value,
                      onRetry: controller.fetchModules,
                    );
                  }

                  if (!controller.isLoading.value &&
                      controller.modules.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada modul tersedia.',
                        style: AppTextStyle.body2(color: AppColor.Neutral500),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.fetchModules,
                    color: AppColor.Primary500,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.pagePadding),
                      itemCount: controller.modules.length,
                      separatorBuilder: (_, i) =>
                          const SizedBox(height: AppSpacing.itemGap),
                      itemBuilder: (_, index) {
                        final module = controller.modules[index];
                        return ModuleCardWidget(
                          module: module,
                          onTap: () => Get.toNamed(
                            Routes.MODULE_DETAIL,
                            arguments: module.id,
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),

          // ── Loading overlay ──────────────────────────────────────────────
          Obx(
            () => controller.isLoading.value
                ? const LoadingOverlayWidget()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  void _showAddModuleDialog(BuildContext context) {
    final subjectId = Get.arguments as String?;
    if (subjectId == null) {
      Get.snackbar(
        'Error',
        'Buka dari Mata Pelajaran terlebih dahulu untuk menambah modul.',
      );
      return;
    }

    final judulCtrl = TextEditingController();
    final kontenCtrl = TextEditingController();
    final kelasCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Modul'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: judulCtrl,
                  decoration: const InputDecoration(hintText: 'Judul Modul'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: kontenCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Konten / Materi',
                  ),
                  maxLines: 3,
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
                final judul = judulCtrl.text.trim();
                final konten = kontenCtrl.text.trim();
                final kelas = kelasCtrl.text.trim();

                if (judul.isNotEmpty && konten.isNotEmpty && kelas.isNotEmpty) {
                  final guruId = Get.find<UserModel>().id;
                  controller.createModule(
                    subjectId: subjectId,
                    judul: judul,
                    konten: konten,
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

/// Internal filter bar — kelas text field + apply button.
class _FilterBar extends GetView<ModuleController> {
  final TextEditingController _kelasCtrl = TextEditingController();

  _FilterBar();

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
            validator: (_) => null, // no validation required for filter
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        ElevatedButton(
          onPressed: () {
            final kelas = _kelasCtrl.text.trim();
            controller.fetchModules(
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
