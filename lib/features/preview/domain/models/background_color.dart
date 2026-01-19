import 'package:flutter/material.dart';

enum BackgroundColor {
  white(Color(0xFFFFFFFF), 'أبيض'),
  red(Color(0xFFDC143C), 'أحمر');
  
  final Color color;
  final String nameAr;
  
  const BackgroundColor(this.color, this.nameAr);
}
