import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:sudan_passport_photo/core/constants/photo_constants.dart';

void main() {
  group('Sudan Passport Photo Logic Tests', () {
    test('Official Dimensions are correct', () {
      expect(PhotoConstants.widthMm, 35.0);
      expect(PhotoConstants.heightMm, 45.0);
    });

    test('Background Colors are correct for Sudan Standards', () {
      // Sudan Passport Red: #FF0000
      expect(PhotoConstants.sudanPassportRed, 0xFFFF0000);
      // Standard White: #FFFFFF
      expect(PhotoConstants.standardWhite, 0xFFFFFFFF);
    });

    test('Tiling Logic Calculation for A4', () {
      const String paperSize = 'A4';
      final paperDim = PhotoConstants.paperSizes[paperSize]!;
      final double paperWidth = paperDim[0] * PdfPageFormat.mm;
      final double paperHeight = paperDim[1] * PdfPageFormat.mm;
      
      final double photoWidth = PhotoConstants.widthMm * PdfPageFormat.mm;
      final double photoHeight = PhotoConstants.heightMm * PdfPageFormat.mm;
      
      const double margin = 10 * PdfPageFormat.mm;
      final double availableWidth = paperWidth - (2 * margin);
      final double availableHeight = paperHeight - (2 * margin);
      
      final int cols = (availableWidth / photoWidth).floor();
      final int rows = (availableHeight / photoHeight).floor();
      
      expect(cols, 5, reason: 'A4 should fit 5 columns of 35mm photos');
      expect(rows, 6, reason: 'A4 should fit 6 rows of 45mm photos');
    });

    test('Tiling Logic Calculation for 4x6 paper', () {
      const String paperSize = '4x6';
      final paperDim = PhotoConstants.paperSizes[paperSize]!;
      final double paperWidth = paperDim[0] * PdfPageFormat.mm;
      final double paperHeight = paperDim[1] * PdfPageFormat.mm;
      
      final double photoWidth = PhotoConstants.widthMm * PdfPageFormat.mm;
      final double photoHeight = PhotoConstants.heightMm * PdfPageFormat.mm;
      
      // Matching the logic in export_service.dart
      const double margin = 10 * PdfPageFormat.mm; 
      final double availableWidth = paperWidth - (2 * margin);
      final double availableHeight = paperHeight - (2 * margin);
      
      final int cols = (availableWidth / photoWidth).floor();
      final int rows = (availableHeight / photoHeight).floor();
      
      // 4x6 is approx 101.6 x 152.4 mm
      // 101.6 - 20 = 81.6mm -> cols = 81.6 / 35 = 2.3 -> 2
      // 152.4 - 20 = 132.4mm -> rows = 132.4 / 45 = 2.9 -> 2
      expect(cols, 2);
      expect(rows, 2);
    });
  });
}
