import 'package:flutter_test/flutter_test.dart';
import 'package:sudan_passport_photo/core/constants/photo_constants.dart';

void main() {
  group('PhotoConstants Tests', () {
    test('Photo dimensions are correct', () {
      expect(PhotoConstants.widthMm, 35.0);
      expect(PhotoConstants.heightMm, 45.0);
      expect(PhotoConstants.widthPx, 413);
      expect(PhotoConstants.heightPx, 531);
    });

    test('DPI is 300', () {
      expect(PhotoConstants.dpi, 300);
    });

    test('Face detection thresholds are valid', () {
      expect(PhotoConstants.minFaceSize, greaterThan(0));
      expect(PhotoConstants.maxFaceSize, lessThan(1));
      expect(PhotoConstants.minFaceSize, lessThan(PhotoConstants.maxFaceSize));
    });

    test('JPEG quality is between 0 and 100', () {
      expect(PhotoConstants.jpegQuality, greaterThanOrEqualTo(0));
      expect(PhotoConstants.jpegQuality, lessThanOrEqualTo(100));
    });
  });
}
