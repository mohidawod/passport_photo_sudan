import 'package:flutter/material.dart';
import 'package:sudan_passport_photo/core/theme/app_colors.dart';
import 'package:sudan_passport_photo/features/camera/domain/models/camera_state.dart';

class FaceGuidanceOverlay extends StatelessWidget {
  final FaceReadiness faceReadiness;
  
  const FaceGuidanceOverlay({
    super.key,
    required this.faceReadiness,
  });
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final ovalWidth = size.width * 0.7;
    final ovalHeight = size.height * 0.5;
    
    return Stack(
      children: [
        // Semi-transparent background outside oval
        CustomPaint(
          size: size,
          painter: _OvalMaskPainter(
            ovalWidth: ovalWidth,
            ovalHeight: ovalHeight,
          ),
        ),
        
        // Oval border
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: ovalWidth,
            height: ovalHeight,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getBorderColor(),
                width: 4,
              ),
            ),
          ),
        ),
        
        // Hint text
        Positioned(
          bottom: 100,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getHintText(),
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getBorderColor() {
    switch (faceReadiness) {
      case FaceReadiness.ready:
        return AppColors.success;
      case FaceReadiness.noFace:
      case FaceReadiness.tooFar:
      case FaceReadiness.tooClose:
      case FaceReadiness.notCentered:
        return AppColors.warning;
    }
  }
  
  String _getHintText() {
    switch (faceReadiness) {
      case FaceReadiness.noFace:
        return 'ضع وجهك في الإطار';
      case FaceReadiness.tooFar:
        return 'اقترب قليلاً';
      case FaceReadiness.tooClose:
        return 'ابتعد قليلاً';
      case FaceReadiness.notCentered:
        return 'وسط الوجه';
      case FaceReadiness.ready:
        return 'جاهز للالتقاط';
    }
  }
}

class _OvalMaskPainter extends CustomPainter {
  final double ovalWidth;
  final double ovalHeight;
  
  _OvalMaskPainter({
    required this.ovalWidth,
    required this.ovalHeight,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;
    
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: ovalWidth,
        height: ovalHeight,
      ))
      ..fillType = PathFillType.evenOdd;
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
