import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudan_passport_photo/core/theme/app_colors.dart';
import 'package:sudan_passport_photo/features/preview/domain/models/background_color.dart' as bg;
import 'package:sudan_passport_photo/features/preview/presentation/widgets/background_selector.dart';
import 'package:sudan_passport_photo/features/processing/presentation/providers/processing_state_provider.dart';
import 'package:sudan_passport_photo/features/export/presentation/providers/export_state_provider.dart';
import 'package:sudan_passport_photo/features/export/presentation/screens/export_bottom_sheet.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  final Uint8List capturedImage;
  
  const PreviewScreen({
    super.key,
    required this.capturedImage,
  });
  
  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  bg.BackgroundColor selectedBackground = bg.BackgroundColor.white;
  Uint8List? processedImage;
  bool isInitialProcessing = true;
  
  @override
  void initState() {
    super.initState();
    // Process image on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processImage();
    });
  }
  
  Future<void> _processImage() async {
    final result = await ref.read(processingStateProvider.notifier).processImage(
      imageBytes: widget.capturedImage,
      backgroundColor: selectedBackground.color,
    );
    
    if (result != null) {
      setState(() {
        processedImage = result;
        isInitialProcessing = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final processingState = ref.watch(processingStateProvider);
    final exportState = ref.watch(exportStateProvider);
    
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('معاينة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // Image preview
            Expanded(
              child: Center(
                child: processingState.isProcessing || isInitialProcessing
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: AppColors.secondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'جاري معالجة الصورة...',
                            style: TextStyle(
                              color: AppColors.textLight.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: selectedBackground.color,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 16,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: processedImage != null
                              ? Image.memory(
                                  processedImage!,
                                  fit: BoxFit.contain,
                                )
                              : Image.memory(
                                  widget.capturedImage,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Background selector
            if (!processingState.isProcessing && !isInitialProcessing)
              BackgroundSelector(
                selectedBackground: selectedBackground,
                onBackgroundChanged: (bg.BackgroundColor newBackground) async {
                  setState(() {
                    selectedBackground = newBackground;
                  });
                  await _processImage();
                },
              ),
            
            const SizedBox(height: 24),
            
            // Export button
            if (!processingState.isProcessing && !isInitialProcessing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: exportState.isExporting ? null : _showExportOptions,
                  child: exportState.isExporting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Text('تصدير الصورة'),
                ),
              ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportBottomSheet(
        onExportPdf: () => _exportImage(ExportFormat.pdf),
        onExportJpg: () => _exportImage(ExportFormat.jpg),
      ),
    );
  }
  
  Future<void> _exportImage(ExportFormat format) async {
    if (processedImage == null) return;
    
    if (!mounted) return;
    Navigator.pop(context); // Close bottom sheet
    
    final file = format == ExportFormat.pdf
        ? await ref.read(exportStateProvider.notifier).exportAsPdf(processedImage!)
        : await ref.read(exportStateProvider.notifier).exportAsJpg(processedImage!);
    
    if (!mounted) return;
    
    if (file != null) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الملف في: ${file.path}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'حسناً',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      
      // Navigate back to camera
      Navigator.of(context).pop();
    } else {
      // Show error message
      final errorMessage = ref.read(exportStateProvider).errorMessage ?? 'فشل التصدير';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

