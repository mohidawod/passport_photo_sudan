import 'package:flutter/material.dart';

enum BackgroundColor {
  white(Color(0xFFFFFFFF), 'خلفية بيضاء (للبطاقات/الهوية)'),
  red(Color(0xFFFF0000), 'خلفية حمراء (جواز سوداني رسمي)');
  
  final Color color;
  final String nameAr;
  
  const BackgroundColor(this.color, this.nameAr);
}

