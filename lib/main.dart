import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudan_passport_photo/app.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Set preferred orientations (portrait only) - Guarded for Web
    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    // Global error listener
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Global Error: $error');
      return true;
    };

    runApp(
      const ProviderScope(
        child: SudanPassportPhotoApp(),
      ),
    );
  } catch (e, stack) {
    debugPrint('Init Error: $e');
    debugPrint('Stack: $stack');
    // Fallback app if something goes horribly wrong
    runApp(MaterialApp(home: Scaffold(body: Center(child: Text('Error: $e')))));
  }
}
