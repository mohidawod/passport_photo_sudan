import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudan_passport_photo/core/theme/app_colors.dart';
import 'package:sudan_passport_photo/features/export/presentation/providers/export_state_provider.dart';

class ExportBottomSheet extends ConsumerWidget {
  final VoidCallback onExportPdf;
  final VoidCallback onExportJpg;

  const ExportBottomSheet({
    super.key,
    required this.onExportPdf,
    required this.onExportJpg,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportState = ref.watch(exportStateProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'اختر صيغة التصدير',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // PDF Export Button
            _ExportOptionButton(
              icon: Icons.picture_as_pdf,
              label: 'تصدير PDF',
              description: 'ملف PDF بحجم 35×45 مم',
              onTap: exportState.isExporting ? null : onExportPdf,
              isLoading: exportState.isExporting && exportState.format == ExportFormat.pdf,
            ),
            const SizedBox(height: 16),

            // JPG Export Button
            _ExportOptionButton(
              icon: Icons.image,
              label: 'تصدير JPG',
              description: 'صورة بجودة عالية',
              onTap: exportState.isExporting ? null : onExportJpg,
              isLoading: exportState.isExporting && exportState.format == ExportFormat.jpg,
            ),
            const SizedBox(height: 16),

            // Cancel Button
            TextButton(
              onPressed: exportState.isExporting ? null : () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: AppColors.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback? onTap;
  final bool isLoading;

  const _ExportOptionButton({
    required this.icon,
    required this.label,
    required this.description,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.secondary.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.secondary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: AppColors.textLight.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.secondary,
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.secondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
