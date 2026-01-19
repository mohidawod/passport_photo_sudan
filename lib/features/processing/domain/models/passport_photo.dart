import 'dart:typed_data';
import 'package:sudan_passport_photo/features/preview/domain/models/background_color.dart';

class PassportPhoto {
  final String id;
  final Uint8List originalImage;
  final Uint8List? processedImage;
  final BackgroundColor backgroundColor;
  final DateTime capturedAt;
  final bool isProcessing;
  
  PassportPhoto({
    required this.id,
    required this.originalImage,
    this.processedImage,
    this.backgroundColor = BackgroundColor.white,
    required this.capturedAt,
    this.isProcessing = false,
  });
  
  PassportPhoto copyWith({
    Uint8List? processedImage,
    BackgroundColor? backgroundColor,
    bool? isProcessing,
  }) {
    return PassportPhoto(
      id: id,
      originalImage: originalImage,
      processedImage: processedImage ?? this.processedImage,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      capturedAt: capturedAt,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
