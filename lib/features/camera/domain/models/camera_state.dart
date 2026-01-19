import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

enum CameraStatus {
  initial,
  initializing,
  ready,
  capturing,
  error,
}

enum FaceReadiness {
  noFace,
  tooFar,
  tooClose,
  notCentered,
  ready,
}

class CameraState {
  final CameraStatus status;
  final CameraController? controller;
  final FaceReadiness faceReadiness;
  final Face? detectedFace;
  final String? errorMessage;
  
  const CameraState({
    this.status = CameraStatus.initial,
    this.controller,
    this.faceReadiness = FaceReadiness.noFace,
    this.detectedFace,
    this.errorMessage,
  });
  
  CameraState copyWith({
    CameraStatus? status,
    CameraController? controller,
    FaceReadiness? faceReadiness,
    Face? detectedFace,
    String? errorMessage,
  }) {
    return CameraState(
      status: status ?? this.status,
      controller: controller ?? this.controller,
      faceReadiness: faceReadiness ?? this.faceReadiness,
      detectedFace: detectedFace ?? this.detectedFace,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
  
  bool get isReady => faceReadiness == FaceReadiness.ready;
  bool get canCapture => status == CameraStatus.ready;
}
