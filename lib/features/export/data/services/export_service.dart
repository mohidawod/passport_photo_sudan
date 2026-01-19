import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sudan_passport_photo/core/constants/photo_constants.dart';
import 'package:sudan_passport_photo/features/export/data/services/local_storage_service.dart';

class ExportService {
  final LocalStorageService _storageService;

  ExportService(this._storageService);

  /// Export image as PDF
  Future<File> exportToPdf({
    required Uint8List imageBytes,
    required String filename,
  }) async {
    try {
      // Create PDF document
      final pdf = pw.Document();

      // Add page with passport photo
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            PhotoConstants.widthMm * PdfPageFormat.mm,
            PhotoConstants.heightMm * PdfPageFormat.mm,
          ),
          build: (context) {
            return pw.Center(
              child: pw.Image(
                pw.MemoryImage(imageBytes),
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );

      // Save to downloads
      final downloadsDir = await _storageService.getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('فشل الوصول إلى مجلد التنزيلات');
      }

      final file = File('${downloadsDir.path}/$filename.pdf');
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      throw Exception('فشل تصدير PDF: ${e.toString()}');
    }
  }

  /// Export image as JPG
  Future<File> exportToJpg({
    required Uint8List imageBytes,
    required String filename,
  }) async {
    try {
      final downloadsDir = await _storageService.getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('فشل الوصول إلى مجلد التنزيلات');
      }

      final file = File('${downloadsDir.path}/$filename.jpg');
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
