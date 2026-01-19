import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudan_passport_photo/features/export/data/services/export_service.dart';
import 'package:sudan_passport_photo/features/export/data/services/local_storage_service.dart';

final localStorageServiceProvider = Provider((ref) => LocalStorageService());

final exportServiceProvider = Provider((ref) {
  return ExportService(ref.read(localStorageServiceProvider));
});

final exportStateProvider = StateNotifierProvider<ExportStateNotifier, ExportState>(
  (ref) => ExportStateNotifier(ref.read(exportServiceProvider)),
);

enum ExportFormat { pdf, jpg }

class ExportState {
  final bool isExporting;
  final ExportFormat? format;
  final File? exportedFile;
  final String? errorMessage;

  const ExportState({
    this.isExporting = false,
    this.format,
    this.exportedFile,
    this.errorMessage,
  });

  ExportState copyWith({
    bool? isExporting,
    ExportFormat? format,
    File? exportedFile,
    String? errorMessage,
  }) {
    return ExportState(
      isExporting: isExporting ?? this.isExporting,
      format: format ?? this.format,
      exportedFile: exportedFile ?? this.exportedFile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ExportStateNotifier extends StateNotifier<ExportState> {
  final ExportService _exportService;

  ExportStateNotifier(this._exportService) : super(const ExportState());

  Future<File?> exportAsPdf(Uint8List imageBytes) async {
    state = state.copyWith(isExporting: true, format: ExportFormat.pdf);

    try {
      final filename = _exportService.generateFilename();
      final file = await _exportService.exportToPdf(
        imageBytes: imageBytes,
        filename: filename,
      );

      state = state.copyWith(
        isExporting: false,
        exportedFile: file,
      );

      return file;
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  Future<File?> exportAsJpg(Uint8List imageBytes) async {
    state = state.copyWith(isExporting: true, format: ExportFormat.jpg);

    try {
      final filename = _exportService.generateFilename();
      final file = await _exportService.exportToJpg(
        imageBytes: imageBytes,
        filename: filename,
      );

      state = state.copyWith(
        isExporting: false,
        exportedFile: file,
      );

      return file;
    } catch (e) {
      state = state.copyWith(
        isExporting: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  void reset() {
    state = const ExportState();
  }
}
