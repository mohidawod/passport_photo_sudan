class PhotoConstants {
  PhotoConstants._();
  
  // Passport Photo Dimensions (35x45mm at 300 DPI)
  static const double widthMm = 35.0;
  static const double heightMm = 45.0;
  static const int dpi = 300;
  
  // Calculated pixel dimensions
  static const int widthPx = 413; // (35mm / 25.4) * 300 DPI
  static const int heightPx = 531; // (45mm / 25.4) * 300 DPI
  
  // Face detection thresholds
  static const double minFaceSize = 0.3; // 30% of frame
  static const double maxFaceSize = 0.7; // 70% of frame
  static const double centerTolerance = 0.1; // 10% deviation allowed
  
  // Processing settings
  static const int jpegQuality = 95;
  static const int processingTimeout = 5000; // milliseconds
  
  // Auto-capture delay
  static const int autoCaptureDelayMs = 1000; // 1 second after ready
}
