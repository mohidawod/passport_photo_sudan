import 'dart:io' as io;
import 'package:flutter/foundation.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sudan_passport_photo/core/constants/photo_constants.dart';
import 'package:sudan_passport_photo/features/export/data/services/local_storage_service.dart';

class ExportService {
  final LocalStorageService _storageService;

  ExportService(this._storageService);

  /// Export image as PDF with tiling support for different paper sizes
  Future<io.File?> exportToPdf({

    required Uint8List imageBytes,
    required String filename,
    String paperSize = 'A4',
    bool inkSaving = true,
  }) async {
    try {
      final pdf = pw.Document();
      final paperDim = PhotoConstants.paperSizes[paperSize] ?? PhotoConstants.paperSizes['A4']!;
      final double paperWidth = paperDim[0] * PdfPageFormat.mm;
      final double paperHeight = paperDim[1] * PdfPageFormat.mm;
      
      final double photoWidth = PhotoConstants.widthMm * PdfPageFormat.mm;
      final double photoHeight = PhotoConstants.heightMm * PdfPageFormat.mm;
      
      // Calculate how many photos fit
      // Margin of 10mm around the paper
      final double margin = 10 * PdfPageFormat.mm;
      final double availableWidth = paperWidth - (2 * margin);
      final double availableHeight = paperHeight - (2 * margin);
      
      final int cols = (availableWidth / photoWidth).floor();
      final int rows = (availableHeight / photoHeight).floor();
      final int photosPerPage = cols * rows;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(paperWidth, paperHeight),
          margin: pw.EdgeInsets.all(margin),
          build: (context) {
            return pw.GridView(
              crossAxisCount: cols,
              childAspectRatio: photoWidth / photoHeight,
              children: List.generate(photosPerPage, (index) {
                return pw.Container(
                  width: photoWidth,
                  height: photoHeight,
                  decoration: inkSaving ? pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.grey300,
                      width: 0.5,
                    ),
                  ) : null,
                  child: pw.Image(
                    pw.MemoryImage(imageBytes),
                    fit: pw.BoxFit.cover,
                  ),
                );
              }),
            );
          },
        ),
      );

      if (kIsWeb) {
        // On web, we could trigger a download here using dart:html
        // For now, we return null to avoid dart:io crash
        return null;
      }

      final downloadsDir = await _storageService.getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('فشل الوصول إلى مجلد التنزيلات');
      }

      final file = io.File('${downloadsDir.path}/$filename.pdf');
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      throw Exception('فشل تصدير PDF: ${e.toString()}');
    }
  }


  /// Export image as JPG
  Future<io.File?> exportToJpg({
    required Uint8List imageBytes,
    required String filename,
  }) async {
    try {
      if (kIsWeb) return null;

      final downloadsDir = await _storageService.getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('فشل الوصول إلى مجلد التنزيلات');
      }

      final file = io.File('${downloadsDir.path}/$filename.jpg');
      await file.writeAsBytes(imageBytes);

      return file;
    } catch (e) {
      throw Exception('فشل تصدير JPG: ${e.toString()}');
    }
  }


  /// Generate unique filename
  String generateFilename({String prefix = 'passport_photo'}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp';
  }

  /// Get file size in MB
  double getFileSizeMB(Uint8List bytes) {
    return bytes.length / (1024 * 1024);
  }
}
