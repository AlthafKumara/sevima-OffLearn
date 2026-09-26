import 'package:flutter/material.dart';
import 'package:mobile/shared/colour/app_color.dart';
import 'package:mobile/shared/fonts/app_text_style.dart';
import 'package:mobile/shared/models/module_model.dart';
import 'package:mobile/shared/theme/app_spacing.dart';

/// Feature-specific card widget for a single [ModuleModel] in the list.
class ModuleCardWidget extends StatelessWidget {
  final ModuleModel module;
  final VoidCallback? onTap;

  const ModuleCardWidget({super.key, required this.module, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPublished = module.status == 'published';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColor.Neutral100,
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusLarge),
          border: Border.all(color: AppColor.Neutral300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: urutan + status badge
            Row(
              children: [
                if (module.urutan != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.Primary200,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.borderRadius,
                      ),
                    ),
                    child: Text(
                      'Bab ${module.urutan}',
                      style: AppTextStyle.body3(
                        color: AppColor.Primary600,
                        fontWeight: AppTextStyle.semiBold,
                      ),
                    ),
                  ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isPublished
                        ? AppColor.Success500.withValues(alpha: 0.15)
                        : AppColor.Warning400.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.borderRadius,
                    ),
                  ),
                  child: Text(
                    isPublished ? 'Published' : 'Draft',
                    style: AppTextStyle.body4(
                      color: isPublished
                          ? AppColor.Success600
                          : AppColor.Warning600,
                      fontWeight: AppTextStyle.semiBold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Title
            Text(
              module.judul,
              style: AppTextStyle.body1(
                color: AppColor.Neutral900,
                fontWeight: AppTextStyle.semiBold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (module.targetKelas != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: AppSpacing.iconSize * 0.75,
                    color: AppColor.Neutral500,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    module.targetKelas!,
                    style: AppTextStyle.body3(color: AppColor.Neutral500),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
