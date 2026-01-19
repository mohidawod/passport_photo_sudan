import 'package:flutter/material.dart';
import 'package:sudan_passport_photo/core/theme/app_colors.dart';
import 'package:sudan_passport_photo/features/preview/domain/models/background_color.dart' as bg;

class BackgroundSelector extends StatelessWidget {
  final bg.BackgroundColor selectedBackground;
  final ValueChanged<bg.BackgroundColor> onBackgroundChanged;
  
  const BackgroundSelector({
    super.key,
    required this.selectedBackground,
    required this.onBackgroundChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBackgroundOption(bg.BackgroundColor.white),
          const SizedBox(width: 32),
          _buildBackgroundOption(bg.BackgroundColor.red),
        ],
      ),
    );
  }
  
  Widget _buildBackgroundOption(bg.BackgroundColor backgroundColor) {
    final isSelected = selectedBackground == backgroundColor;
    
    return GestureDetector(
      onTap: () => onBackgroundChanged(backgroundColor),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: backgroundColor.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.secondary : AppColors.textLight.withValues(alpha: 0.3),
                width: isSelected ? 4 : 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            backgroundColor.nameAr,
            style: TextStyle(
              color: isSelected ? AppColors.secondary : AppColors.textLight,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
