import 'package:flutter/material.dart';
import 'package:sudan_passport_photo/features/camera/domain/models/camera_state.dart';

class ReadinessIndicator extends StatelessWidget {
  final FaceReadiness faceReadiness;
  
  const ReadinessIndicator({
    super.key,
    required this.faceReadiness,
  });
  
  @override
  Widget build(BuildContext context) {
    final isReady = faceReadiness == FaceReadiness.ready;
    
    // Minimalist Design:
    // Status & Feedback: "✔️ جاهز" OR "⚠️ غير مناسب" only.
    // Visuals: Grayscale base + Icons.
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87, // Neutral dark background for high contrast text
        borderRadius: BorderRadius.circular(4), // Simple, not too rounded
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icons provide the color hint subtly if needed, or keep monochrome
          Text(
            isReady ? '✔️' : '⚠️', 
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            isReady ? 'جاهز' : 'غير مناسب',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500, // Medium weight for clarity
            ),
          ),
        ],
      ),
    );
  }
}
