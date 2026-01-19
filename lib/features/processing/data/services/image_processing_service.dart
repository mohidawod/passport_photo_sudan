import 'dart:io' as io;
import 'package:flutter/foundation.dart'; // For compute
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sudan_passport_photo/core/constants/photo_constants.dart';

class ImageProcessingService {
  final SubjectSegmenter? _segmenter = kIsWeb ? null : SubjectSegmenter(
    options: SubjectSegmenterOptions(
      enableForegroundConfidenceMask: true,
      enableForegroundBitmap: false,
      enableMultipleSubjects: SubjectResultOptions(
        enableConfidenceMask: true,
        enableSubjectBitmap: false,
      ),
    ),
  );

  /// Process image: resize to passport size and apply background color
  /// Processes the raw image bytes to create a passport-ready photo.
  /// 
  /// Steps:
  /// 1. Native resize to reduce memory footprint.
  /// 2. AI background removal.
  /// 3. Image enhancement (brightness/contrast) using an Isolate.
  Future<Uint8List> processImage({
    required Uint8List rawImageBytes,
    required Color targetBackgroundColor,
  }) async {
    try {
      final resizedBytes = await _nativeResize(rawImageBytes);
      final decodedImage = _decodeImage(resizedBytes);
      final standardizedImage = _standardizeDimensions(decodedImage);
      
      final segmentedImage = await _removeBackground(standardizedImage, targetBackgroundColor);
      
      // On Web, compute/isolates might have different behavior or limitations
      // but usually simple compute works if the function is top-level/static.
      return await compute(
        _enhanceAndEncode, 
        _EnhanceData(segmentedImage, PhotoConstants.jpegQuality)
      );
    } catch (e) {
      debugPrint('Image Processing Error: $e');
      throw Exception('Failed to process image: $e');
    }
  }

  /// Resizes image natively to minimize memory usage before decoding.
  Future<Uint8List> _nativeResize(Uint8List bytes) async {
    // flutter_image_compress handles web automatically
    return await FlutterImageCompress.compressWithList(
      bytes,
      minHeight: PhotoConstants.heightPx,
      minWidth: PhotoConstants.widthPx,
      quality: 90,
      format: CompressFormat.jpeg,
    );
  }

  /// Decodes bytes into an image object.
  img.Image _decodeImage(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Failed to decode image bytes');
    return image;
  }

  /// Ensures image exactly matches passport dimensions.
  img.Image _standardizeDimensions(img.Image image) {
    return img.copyResize(
      image,
      width: PhotoConstants.widthPx,
      height: PhotoConstants.heightPx,
      interpolation: img.Interpolation.linear,
    );
  }

  // Static function for isolate
  static Uint8List _enhanceAndEncode(_EnhanceData data) {
    // Enhance
    var enhanced = img.adjustColor(
      data.image,
      contrast: 1.1,
      brightness: 1.05,
    );
    
    // Encode
    return Uint8List.fromList(img.encodeJpg(enhanced, quality: data.quality));
  }

  /// Remove background using ML Kit Subject Segmentation with alpha blending for smoother edges
  Future<img.Image> _removeBackground(img.Image image, Color backgroundColor) async {
    // Fallback for web or unsupported platforms
    if (kIsWeb || _segmenter == null) {
      debugPrint('Background removal skip: Not supported on this platform');
      // For web, we just return the image as is for now
      // Alternatively, we could fill the background if it's already a certain color, 
      // but without segmentation, we can't reliably detect the person.
      return image; 
    }

    try {
      // 1. Save temp file for ML Kit
      final tempDir = await getTemporaryDirectory();
      final tempFile = io.File('${tempDir.path}/segment_temp.jpg');
      await tempFile.writeAsBytes(img.encodeJpg(image));

      // 2. Run Segmentation
      final inputImage = InputImage.fromFilePath(tempFile.path);
      final mask = await _segmenter.processImage(inputImage);
      
      // Clean up temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      if (mask.foregroundConfidenceMask == null) {
        return image; // Segmentation failed, return original
      }

      // 3. Process pixels with alpha blending
      final confidences = mask.foregroundConfidenceMask!;
      
      // Create a copy of the original image to work on
      final resultImage = img.Image.from(image);

      final bgColorR = backgroundColor.red;
      final bgColorG = backgroundColor.green;
      final bgColorB = backgroundColor.blue;

      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final int index = y * image.width + x;
          if (index >= confidences.length) continue;

          double confidence = confidences[index];

          // Alpha blending: 
          // result = (foreground * confidence) + (background * (1 - confidence))
          if (confidence < 1.0) {
            final pixel = image.getPixel(x, y);
            
            // Extract components
            final r = pixel.r;
            final g = pixel.g;
            final b = pixel.b;

            // Blend colors
            final newR = (r * confidence + bgColorR * (1.0 - confidence)).round();
            final newG = (g * confidence + bgColorG * (1.0 - confidence)).round();
            final newB = (b * confidence + bgColorB * (1.0 - confidence)).round();

            resultImage.setPixelRgb(x, y, newR, newG, newB);
          }
        }
      }

      return resultImage;
    } catch (e) {
      debugPrint('Segmentation error: $e');
      return image;
    }
  }



  /// Resize image to specific dimensions
  Future<Uint8List> resizeImage({
    required Uint8List imageBytes,
    required int width,
    required int height,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('فشل فك تشفير الصورة');
    }

    final resized = img.copyResize(
      image,
      width: width,
      height: height,
      interpolation: img.Interpolation.cubic,
    );

    final jpegBytes = img.encodeJpg(resized, quality: PhotoConstants.jpegQuality);
    return Uint8List.fromList(jpegBytes);
  }

  /// Compress image
  Future<Uint8List> compressImage({
    required Uint8List imageBytes,
    int quality = 90,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('فشل فك تشفير الصورة');
    }

    final jpegBytes = img.encodeJpg(image, quality: quality);
    return Uint8List.fromList(jpegBytes);
  }
  
  void dispose() {
    _segmenter?.close();
  }
}


class _EnhanceData {
  final img.Image image;
  final int quality;

  _EnhanceData(this.image, this.quality);
}
