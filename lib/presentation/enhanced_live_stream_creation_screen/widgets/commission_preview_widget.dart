import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommissionPreviewWidget extends StatelessWidget {
  final int retailValue;
  final double commissionRate;
  final int potentialCommission;
  final String userTier;

  const CommissionPreviewWidget({
    Key? key,
    required this.retailValue,
    required this.commissionRate,
    required this.potentialCommission,
    required this.userTier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final retailValueFormatted = (retailValue / 100).toStringAsFixed(2);
    final commissionFormatted = (potentialCommission / 100).toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade50,
            Colors.orange.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monetization_on,
                color: Colors.orange.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Commission Preview',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
              const Spacer(),
              _buildTierBadge(),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Product Value',
                  '\$$retailValueFormatted',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  'Your Rate',
                  '${commissionRate.toStringAsFixed(1)}%',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  'Potential Earn',
                  '\$$commissionFormatted',
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(179),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.orange.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Commission calculated on final sale price. Payment processed within 24 hours of auction completion.',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBadge() {
    Color badgeColor;
    switch (userTier) {
      case 'platinum':
        badgeColor = Colors.purple;
        break;
      case 'gold':
        badgeColor = Colors.amber.shade600;
        break;
      case 'silver':
        badgeColor = Colors.grey.shade600;
        break;
      default:
        badgeColor = Colors.brown;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        userTier.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
