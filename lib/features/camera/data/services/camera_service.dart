import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:sudan_passport_photo/core/constants/photo_constants.dart';
import 'package:sudan_passport_photo/features/camera/domain/models/camera_state.dart';

class CameraService {
  CameraController? _controller;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: false,
      enableClassification: false,
      enableTracking: false,
      performanceMode: FaceDetectorMode.fast,
    ),
  );
  
  bool _isDetecting = false;
  Timer? _detectionTimer;
  
  Future<CameraController> initializeCamera() async {
    final cameras = await availableCameras();
    
    // Prefer front camera for passport photos
    final camera = cameras.firstWhere(
      (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    
    await _controller!.initialize();
    return _controller!;
  }
  
  void startFaceDetection(Function(FaceReadiness, Face?) onFaceDetected) {
    _detectionTimer?.cancel();
    _scheduleNextDetection(onFaceDetected);
  }

  void _scheduleNextDetection(Function(FaceReadiness, Face?) onFaceDetected) {
    if (_controller == null) return;
    
    _detectionTimer = Timer(const Duration(milliseconds: 200), () async {
      if (_isDetecting || _controller == null || !_controller!.value.isInitialized) {
        _scheduleNextDetection(onFaceDetected);
        return;
      }
      
      _isDetecting = true;
      try {
        // Double check before taking picture
        if (_controller!.value.isTakingPicture) {
           _isDetecting = false;
           _scheduleNextDetection(onFaceDetected);
           return;
        }

        final image = await _controller!.takePicture();
        final inputImage = InputImage.fromFilePath(image.path);
        final faces = await _faceDetector.processImage(inputImage);
        
        if (faces.isEmpty) {
          onFaceDetected(FaceReadiness.noFace, null);
        } else {
          final face = faces.first;
          final readiness = _checkFaceReadiness(face);
          onFaceDetected(readiness, face);
        }
      } catch (e) {
        // Silently handle detection errors
      } finally {
        _isDetecting = false;
        // Schedule next only if timer wasn't cancelled (meaning capture hasn't started)
        if (_detectionTimer != null) {
          _scheduleNextDetection(onFaceDetected);
        }
      }
    });
  }
  
  FaceReadiness _checkFaceReadiness(Face face) {
    if (_isFaceSizeInvalid(face)) {
      return _getFaceSizeError(face);
    }
    
    if (!_isFaceCentered(face)) {
      return FaceReadiness.notCentered;
    }
    
    return FaceReadiness.ready;
  }

  bool _isFaceSizeInvalid(Face face) {
    final faceRatio = _calculateFaceRatio(face);
    return faceRatio < PhotoConstants.minFaceSize || faceRatio > PhotoConstants.maxFaceSize;
  }

  FaceReadiness _getFaceSizeError(Face face) {
    final faceRatio = _calculateFaceRatio(face);
    if (faceRatio < PhotoConstants.minFaceSize) return FaceReadiness.tooFar;
    return FaceReadiness.tooClose;
  }

  double _calculateFaceRatio(Face face) {
    final faceArea = face.boundingBox.width * face.boundingBox.height;
    final frameArea = (_controller?.value.previewSize?.width ?? 1) *
                      (_controller?.value.previewSize?.height ?? 1);
    return faceArea / frameArea;
  }

  bool _isFaceCentered(Face face) {
    final frameSize = _controller?.value.previewSize;
    if (frameSize == null) return false;

    final faceCenter = face.boundingBox.center;
    final frameCenter = Offset(frameSize.width / 2, frameSize.height / 2);
    
    final relativeDeviationX = (faceCenter.dx - frameCenter.dx).abs() / frameSize.width;
    final relativeDeviationY = (faceCenter.dy - frameCenter.dy).abs() / frameSize.height;

    return relativeDeviationX <= PhotoConstants.centerTolerance &&
           relativeDeviationY <= PhotoConstants.centerTolerance;
  }
  
  /// Captures a high-resolution photo for the passport.
  /// 
  /// Ensures no other capture operations (like face detection) are running
  /// to prevent 'Previous capture has not returned' errors.
  Future<Uint8List> capturePhoto() async {
    _ensureCameraInitialized();
    
    // Critical: Stop auto-detection loop to free up the camera resource
    stopFaceDetection();
    
    await _waitForPendingOperations();
    
    return await _performSafeCapture();
  }

  void _ensureCameraInitialized() {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera is not ready for capture');
    }
  }

  /// Waits for any ongoing face detection capture to complete.
  Future<void> _waitForPendingOperations() async {
    const maxAttempts = 10;
    int attemptCount = 0;
    
    while (_isDetecting && attemptCount < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));
      attemptCount++;
    }
    
    // Buffer time to allow native camera state to settle
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Executes the actual capture with retry logic for robustness.
  Future<Uint8List> _performSafeCapture() async {
    try {
      if (_controller!.value.isTakingPicture) {
         await Future.delayed(const Duration(milliseconds: 500));
      }
      
      final image = await _controller!.takePicture();
      return await image.readAsBytes();
    } catch (e) {
      // Recovery mechanism for stubborn camera locks
      if (e.toString().contains('Previous capture has not returned')) {
        await Future.delayed(const Duration(milliseconds: 1000));
        final image = await _controller!.takePicture();
        return await image.readAsBytes();
      }
      throw Exception('Failed to capture photo: $e');
    }
  }
  
  void stopFaceDetection() {
    _detectionTimer?.cancel();
    _detectionTimer = null;
  }
  
  void dispose() {
    stopFaceDetection();
    _faceDetector.close();
    _controller?.dispose();
    _controller = null;
  }
}
