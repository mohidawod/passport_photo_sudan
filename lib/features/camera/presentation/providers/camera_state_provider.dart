import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sudan_passport_photo/core/constants/photo_constants.dart';
import 'package:sudan_passport_photo/features/camera/data/services/camera_service.dart';
import 'package:sudan_passport_photo/features/camera/domain/models/camera_state.dart';

final cameraServiceProvider = Provider((ref) => CameraService());

final cameraStateProvider = StateNotifierProvider<CameraStateNotifier, CameraState>(
  (ref) => CameraStateNotifier(ref.read(cameraServiceProvider)),
);

class CameraStateNotifier extends StateNotifier<CameraState> {
  final CameraService _cameraService;
  Timer? _autoCaptureTimer;
  
  CameraStateNotifier(this._cameraService) : super(const CameraState()) {
    _initializeCamera();
  }
  
  Future<void> _initializeCamera() async {
    state = state.copyWith(status: CameraStatus.initializing);
    
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        state = state.copyWith(
          status: CameraStatus.error,
          errorMessage: 'يجب منح إذن الكاميرا لاستخدام التطبيق',
        );
        return;
      }

      final controller = await _cameraService.initializeCamera();
      state = state.copyWith(
        status: CameraStatus.ready,
        controller: controller,
      );
      
      _startFaceDetection();
    } catch (e) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: 'فشل تشغيل الكاميرا: ${e.toString()}',
      );
    }
  }
  
  void _startFaceDetection() {
    _cameraService.startFaceDetection((readiness, face) {
      state = state.copyWith(
        faceReadiness: readiness,
        detectedFace: face,
      );
      
      // Auto-capture when ready
      if (readiness == FaceReadiness.ready && state.status == CameraStatus.ready) {
        _scheduleAutoCapture();
      } else {
        _cancelAutoCapture();
      }
    });
  }
  
  void _scheduleAutoCapture() {
    _autoCaptureTimer?.cancel();
    _autoCaptureTimer = Timer(
      const Duration(milliseconds: PhotoConstants.autoCaptureDelayMs),
      () {
        if (state.faceReadiness == FaceReadiness.ready) {
          capturePhoto();
        }
      },
    );
  }
  
  void _cancelAutoCapture() {
    _autoCaptureTimer?.cancel();
    _autoCaptureTimer = null;
  }
  
  Future<Uint8List?> capturePhoto() async {
    if (state.status != CameraStatus.ready) return null;
    
    _cancelAutoCapture();
    state = state.copyWith(status: CameraStatus.capturing);
    
    try {
      final imageBytes = await _cameraService.capturePhoto();
      state = state.copyWith(status: CameraStatus.ready);
      return imageBytes;
    } catch (e) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: 'فشل التقاط الصورة: ${e.toString()}',
      );
      return null;
    }
  }
  
  @override
  void dispose() {
    _cancelAutoCapture();
    _cameraService.dispose();
    super.dispose();
  }
}
