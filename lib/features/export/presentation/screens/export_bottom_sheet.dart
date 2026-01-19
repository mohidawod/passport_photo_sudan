import 'package:flutter/material.dart';
import 'package:sudan_passport_photo/core/theme/app_colors.dart';

class ExportBottomSheet extends StatefulWidget {
  final Function(String paperSize, bool inkSaving) onExportPdf;
  final VoidCallback onExportJpg;

  const ExportBottomSheet({
    super.key,
    required this.onExportPdf,
    required this.onExportJpg,
  });

  @override
  State<ExportBottomSheet> createState() => _ExportBottomSheetState();
}

class _ExportBottomSheetState extends State<ExportBottomSheet> {
  String selectedPaperSize = 'A4';
  bool inkSaving = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            const Text(
              'تجهيز الصورة للطباعة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // PDF Options section
            const Text(
              'إعدادات PDF:',
              style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            // Paper Size Row
            Row(
              children: [
                const Text('مقاس الورق:', style: TextStyle(color: AppColors.textLight)),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedPaperSize,
                    dropdownColor: AppColors.surfaceDark,
                    style: const TextStyle(color: AppColors.textLight),
                    isExpanded: true,
                    items: ['A4', '4x6', '5x7', '3x4'].map((size) {
                      return DropdownMenuItem(
                        value: size,
                        child: Text(size),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => selectedPaperSize = value);
                    },
                  ),
                ),
              ],
            ),
            
            // Ink Saving Toggle
            SwitchListTile(
              title: const Text('توفير الحبر (خطوط قص نحيفة)', 
                style: TextStyle(color: AppColors.textLight, fontSize: 14)),
              value: inkSaving,
              activeColor: AppColors.secondary,
              onChanged: (value) => setState(() => inkSaving = value),
              contentPadding: EdgeInsets.zero,
            ),
            
            const SizedBox(height: 16),

            // PDF Export Button
            _ExportOptionButton(
              icon: Icons.picture_as_pdf,
              label: 'تصدير PDF (متعدد الصور)',
              description: 'جاهز للطباعة فوراً',
              onTap: () => widget.onExportPdf(selectedPaperSize, inkSaving),
            ),
            const SizedBox(height: 12),

            // JPG Export Button
            _ExportOptionButton(
              icon: Icons.image,
              label: 'تصدير JPG (صورة واحدة)',
              description: 'صورة منفردة بجودة عالية',
              onTap: widget.onExportJpg,
            ),
            const SizedBox(height: 12),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
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

  const _ExportOptionButton({
    required this.icon,
    required this.label,
    required this.description,
    this.onTap,
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
            color: AppColors.secondary.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.2),
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
                      color: AppColors.textLight.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
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
