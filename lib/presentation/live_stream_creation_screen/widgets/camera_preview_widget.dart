import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;

  const CameraPreviewWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Camera Preview
          CameraPreview(controller),

          // Overlay controls and indicators
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'PREPARING',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Grid overlay for composition
          Positioned.fill(
            child: CustomPaint(
              painter: GridOverlayPainter(),
            ),
          ),

          // Center focus indicator
          const Center(
            child: Icon(
              Icons.center_focus_strong,
              color: Colors.white54,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class GridOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(77)
      ..strokeWidth = 1;

    // Draw rule of thirds grid
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(2 * size.width / 3, 0),
      Offset(2 * size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, 2 * size.height / 3),
      Offset(size.width, 2 * size.height / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
