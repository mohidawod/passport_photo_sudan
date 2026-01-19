import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalStorageService {
  /// Get temporary directory for storing images during processing
  Future<io.Directory?> getTempDirectory() async {
    if (kIsWeb) return null;
    return await getTemporaryDirectory();
  }

  /// Get downloads directory for saving exported files
  Future<io.Directory?> getDownloadsDirectory() async {
    if (kIsWeb) return null; // Web uses browser downloads, not file system paths
    
    if (!kIsWeb && io.Platform.isAndroid) {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('لم يتم منح إذن التخزين');
      }

      // For Android, use external storage
      final directory = await getExternalStorageDirectory();
      if (directory == null) return null;

      final downloadsPath = '${directory.path.split('Android')[0]}Download';
      final downloadsDir = io.Directory(downloadsPath);

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      return downloadsDir;
    } else if (!kIsWeb) {
      return await getDownloadsDirectory();
    }
    return null;
  }


  /// Save temporary image
  Future<io.File?> saveTempImage(Uint8List imageBytes, String filename) async {
    if (kIsWeb) return null;
    final tempDir = await getTempDirectory();
    if (tempDir == null) return null;
    final file = io.File('${tempDir.path}/$filename');
    await file.writeAsBytes(imageBytes);
    return file;
  }

  /// Delete temporary files
  Future<void> clearTempFiles() async {
    if (kIsWeb) return;
    try {
      final tempDir = await getTempDirectory();
      if (tempDir == null) return;
      final files = tempDir.listSync();

      for (var file in files) {
        if (file is io.File && file.path.endsWith('.jpg')) {
          await file.delete();
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Delete specific file
  Future<void> deleteFile(String filePath) async {
    if (kIsWeb) return;
    try {
      final file = io.File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Check available storage space (in MB)
  Future<double> getAvailableSpace() async {
    if (kIsWeb) return 500.0; // Simulated
    try {
      // This is a simplified check - in production, use platform-specific APIs
      return 1000.0; // Return 1GB as default
    } catch (e) {
      return 0.0;
    }
  }
}

