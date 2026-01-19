import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:sudan_passport_photo/features/processing/data/services/image_processing_service.dart';

final imageProcessingServiceProvider = Provider((ref) => ImageProcessingService());

final processingStateProvider = StateNotifierProvider<ProcessingStateNotifier, ProcessingState>(
  (ref) => ProcessingStateNotifier(ref.read(imageProcessingServiceProvider)),
);

class ProcessingState {
  final bool isProcessing;
  final double progress;
  final String? errorMessage;
  final Uint8List? processedImage;

  const ProcessingState({
    this.isProcessing = false,
    this.progress = 0.0,
    this.errorMessage,
    this.processedImage,
  });

  ProcessingState copyWith({
    bool? isProcessing,
    double? progress,
    String? errorMessage,
    Uint8List? processedImage,
  }) {
    return ProcessingState(
      isProcessing: isProcessing ?? this.isProcessing,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      processedImage: processedImage ?? this.processedImage,
    );
  }
}

class ProcessingStateNotifier extends StateNotifier<ProcessingState> {
  final ImageProcessingService _processingService;

  ProcessingStateNotifier(this._processingService) : super(const ProcessingState());

  Future<Uint8List?> processImage({
    required Uint8List imageBytes,
    required Color backgroundColor,
  }) async {
    state = state.copyWith(isProcessing: true, progress: 0.0);

    try {
      // Simulate progress updates
      state = state.copyWith(progress: 0.3);

      final processedBytes = await _processingService.processImage(
        rawImageBytes: imageBytes,
        targetBackgroundColor: backgroundColor,
      );

      state = state.copyWith(progress: 1.0);

      state = state.copyWith(
        isProcessing: false,
        processedImage: processedBytes,
      );

      return processedBytes;
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const ProcessingState();
  }
}
