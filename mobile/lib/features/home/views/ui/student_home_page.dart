import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/routes/app_routes.dart';
import 'package:mobile/shared/colour/app_color.dart';
import 'package:mobile/shared/components/custom_button_large.dart';
import 'package:mobile/shared/fonts/app_text_style.dart';
import 'package:mobile/shared/models/user_model.dart';
import 'package:mobile/shared/theme/app_spacing.dart';

/// Home page for siswa (students).
/// Shows quick-access tiles to modules, quizzes, and offline sync.
class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  UserModel get _user => Get.arguments as UserModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.Neutral200,
      appBar: AppBar(
        title: Text(
          'OffLearn',
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
            icon: const Icon(Icons.logout_rounded, color: AppColor.Neutral600),
            tooltip: 'Logout',
            onPressed: () => Get.offAllNamed(Routes.LOGIN),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Greeting card ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColor.Primary500, AppColor.Primary600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  AppSpacing.borderRadiusLarge,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${_user.name ?? 'Siswa'} 👋',
                    style: AppTextStyle.heading4(
                      color: AppColor.Neutral100,
                      fontWeight: AppTextStyle.semiBold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _user.kelas != null
                        ? 'Kelas ${_user.kelas}'
                        : 'Selamat belajar hari ini!',
                    style: AppTextStyle.body2(color: AppColor.Primary200),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            // ── Menu grid ────────────────────────────────────────────────
            Text(
              'Menu Belajar',
              style: AppTextStyle.body1(
                color: AppColor.Neutral900,
                fontWeight: AppTextStyle.semiBold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.15,
              children: [
                _MenuTile(
                  icon: Icons.book_outlined,
                  label: 'Modul Belajar',
                  color: AppColor.Primary500,
                  onTap: () => Get.toNamed(Routes.MODULES),
                ),
                _MenuTile(
                  icon: Icons.quiz_outlined,
                  label: 'Kuis',
                  color: AppColor.Warning500,
                  onTap: () => Get.toNamed(Routes.QUIZZES),
                ),
                _MenuTile(
                  icon: Icons.subject_outlined,
                  label: 'Mata Pelajaran',
                  color: AppColor.Success500,
                  onTap: () => Get.toNamed(Routes.SUBJECTS),
                ),
                _MenuTile(
                  icon: Icons.cloud_download_outlined,
                  label: 'Unduh Konten',
                  color: AppColor.Info500,
                  onTap: () => Get.toNamed(Routes.SYNC),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColor.Neutral100,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLarge),
          border: Border.all(color: AppColor.Neutral300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: AppSpacing.iconSize),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyle.body2(
                color: AppColor.Neutral900,
                fontWeight: AppTextStyle.semiBold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
