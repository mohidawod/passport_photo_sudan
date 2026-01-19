# Flutter Specific
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ML Kit Face Detection
-keep class com.google.mlkit.vision.face.** { *; }
-keep class com.google.android.gms.vision.face.** { *; }

# ML Kit Subject Segmentation
-keep class com.google.mlkit.vision.segmentation.** { *; }

# Google Play Services
-keep class com.google.android.gms.** { *; }

# Image processing
-keep class com.dexteriv.flutter_image_compress.** { *; }

# Suppress warnings from Flutter Play Store Split Application
-dontwarn com.google.android.play.core.**
