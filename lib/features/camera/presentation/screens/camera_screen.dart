import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:sudan_passport_photo/core/theme/app_colors.dart';
import 'package:sudan_passport_photo/features/camera/domain/models/camera_state.dart';
import 'package:sudan_passport_photo/features/camera/presentation/providers/camera_state_provider.dart';
import 'package:sudan_passport_photo/features/camera/presentation/widgets/face_guidance_overlay.dart';
import 'package:sudan_passport_photo/features/camera/presentation/widgets/readiness_indicator.dart';
import 'package:sudan_passport_photo/features/preview/presentation/screens/preview_screen.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraStateProvider);
    
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('صورة جواز السفر السوداني'),
      ),
      body: SafeArea(
        child: _buildBody(context, ref, cameraState),
      ),
    );
  }
  
  Widget _buildBody(BuildContext context, WidgetRef ref, CameraState state) {
    switch (state.status) {
      case CameraStatus.initial:
      case CameraStatus.initializing:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.secondary),
              SizedBox(height: 16),
              Text(
                'جاري تشغيل الكاميرا...',
                style: TextStyle(color: AppColors.textLight),
              ),
            ],
          ),
        );
        
      case CameraStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage ?? 'حدث خطأ',
                  style: const TextStyle(color: AppColors.textLight),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
        
      case CameraStatus.ready:
      case CameraStatus.capturing:
        return _buildCameraView(context, ref, state);
    }
  }
  
  Widget _buildCameraView(BuildContext context, WidgetRef ref, CameraState state) {
    if (state.controller == null) {
      return const SizedBox.shrink();
    }
    
    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: CameraPreview(state.controller!),
        ),
        
        // Face guidance overlay
        Positioned.fill(
          child: FaceGuidanceOverlay(
            faceReadiness: state.faceReadiness,
          ),
        ),
        
        // Readiness indicator (top-right)
        Positioned(
          top: 16,
          right: 16,
          child: ReadinessIndicator(
            faceReadiness: state.faceReadiness,
          ),
        ),
        
        // Manual capture button (bottom-center)
        if (state.status == CameraStatus.ready)
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.large(
                onPressed: () => _capturePhoto(context, ref),
                backgroundColor: AppColors.contrast,
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ),
          ),
        
        // Capturing indicator
        if (state.status == CameraStatus.capturing)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.white,
            ),
          ),
      ],
    );
  }
  
  Future<void> _capturePhoto(BuildContext context, WidgetRef ref) async {
    final imageBytes = await ref.read(cameraStateProvider.notifier).capturePhoto();
    
    if (imageBytes != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PreviewScreen(capturedImage: imageBytes),
        ),
      );
    }
  }
}
