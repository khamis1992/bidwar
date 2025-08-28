import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnhancedGoLiveButtonWidget extends StatelessWidget {
  final bool isLoading;
  final bool isEnabled;
  final Map<String, dynamic>? selectedProduct;
  final bool cameraReady;
  final bool agoraReady;
  final bool commissionTermsAccepted;
  final VoidCallback onPressed;

  const EnhancedGoLiveButtonWidget({
    Key? key,
    required this.isLoading,
    required this.isEnabled,
    this.selectedProduct,
    required this.cameraReady,
    required this.agoraReady,
    required this.commissionTermsAccepted,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pre-Stream Checklist',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        // Checklist Items
        _buildChecklistItem(
          'Product Selected',
          selectedProduct != null,
          selectedProduct != null
              ? selectedProduct!['title'] ?? 'Product selected'
              : 'Please select a product to stream',
        ),
        _buildChecklistItem(
          'Camera Ready',
          cameraReady,
          cameraReady
              ? 'Camera initialized and ready'
              : 'Initializing camera...',
        ),
        _buildChecklistItem(
          'Network Connection',
          agoraReady,
          agoraReady ? 'Live streaming ready' : 'Setting up connection...',
        ),
        _buildChecklistItem(
          'Commission Terms',
          commissionTermsAccepted,
          commissionTermsAccepted
              ? 'Terms accepted'
              : 'Please accept commission terms',
        ),

        const SizedBox(height: 20),

        // Go Live Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isEnabled && !isLoading ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isEnabled ? Colors.red.shade600 : Colors.grey.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isEnabled ? 4 : 0,
              shadowColor: Colors.red.withAlpha(77),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.videocam,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'GO LIVE',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 12),

        if (!isEnabled)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.orange.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Complete all checklist items to go live',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildChecklistItem(
      String title, bool isComplete, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isComplete ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isComplete ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isComplete ? Colors.green : Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isComplete ? Icons.check : Icons.radio_button_unchecked,
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isComplete
                        ? Colors.green.shade700
                        : Colors.grey.shade700,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: isComplete
                        ? Colors.green.shade600
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
