import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnhancedCameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  final Map<String, dynamic>? selectedProduct;
  final int potentialCommission;
  final double commissionRate;

  const EnhancedCameraPreviewWidget({
    Key? key,
    required this.controller,
    this.selectedProduct,
    required this.potentialCommission,
    required this.commissionRate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            child: CameraPreview(controller),
          ),
        ),

        // Product Info Overlay
        if (selectedProduct != null)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(179),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(77)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedProduct!['title'] ?? 'Product',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Retail: \$${((selectedProduct!['retail_value'] ?? 0) / 100).toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withAlpha(204),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${commissionRate.toStringAsFixed(1)}% Commission',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        // Commission Potential Overlay
        if (selectedProduct != null)
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(230),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.attach_money,
                    color: Colors.white,
                    size: 16,
                  ),
                  Text(
                    '\$${(potentialCommission / 100).toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Live Preview Badge
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withAlpha(230),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'PREVIEW',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
