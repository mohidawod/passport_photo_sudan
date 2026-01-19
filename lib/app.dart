import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudan_passport_photo/core/theme/app_theme.dart';
import 'package:sudan_passport_photo/features/camera/presentation/screens/camera_screen.dart';

class SudanPassportPhotoApp extends ConsumerWidget {
  const SudanPassportPhotoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'صورة جواز السفر السوداني',
      debugShowCheckedModeBanner: false,
      
      // RTL Configuration
      locale: const Locale('ar', 'SD'),
      supportedLocales: const [
        Locale('ar', 'SD'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Theme
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.dark, // Default to dark mode
      
      // Home
      home: const CameraScreen(),
    );
  }
}
