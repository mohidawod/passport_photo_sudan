import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalStorageService {
  /// Get temporary directory for storing images during processing
  Future<Directory> getTempDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Get downloads directory for saving exported files
  Future<Directory?> getDownloadsDirectory() async {
    if (Platform.isAndroid) {
      // Request storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('لم يتم منح إذن التخزين');
      }

      // For Android, use external storage
      final directory = await getExternalStorageDirectory();
      if (directory == null) return null;

      final downloadsPath = '${directory.path.split('Android')[0]}Download';
      final downloadsDir = Directory(downloadsPath);

      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      return downloadsDir;
    } else {
      return await getDownloadsDirectory();
    }
  }

  /// Save temporary image
  Future<File> saveTempImage(Uint8List imageBytes, String filename) async {
    final tempDir = await getTempDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(imageBytes);
    return file;
  }

  /// Delete temporary files
  Future<void> clearTempFiles() async {
    try {
      final tempDir = await getTempDirectory();
      final files = tempDir.listSync();

      for (var file in files) {
        if (file is File && file.path.endsWith('.jpg')) {
          await file.delete();
        }
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Delete specific file
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Check available storage space (in MB)
  Future<double> getAvailableSpace() async {
    try {
      // This is a simplified check - in production, use platform-specific APIs
      return 1000.0; // Return 1GB as default
    } catch (e) {
      return 0.0;
    }
  }
}
