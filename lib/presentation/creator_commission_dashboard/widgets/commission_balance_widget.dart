import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/creator_tier.dart';

class CommissionBalanceWidget extends StatelessWidget {
  final int totalEarnings;
  final int pendingCommissions;
  final CreatorTier currentTier;

  const CommissionBalanceWidget({
    Key? key,
    required this.totalEarnings,
    required this.pendingCommissions,
    required this.currentTier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo.shade600,
            Colors.indigo.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.shade200,
            blurRadius: 16.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with tier badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Commission Balance',
                style: GoogleFonts.inter(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withAlpha(230),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Text(
                  '${currentTier.displayName} • ${currentTier.commissionRateText}',
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          // Total earnings
          Text(
            '${totalEarnings.toString()} credits',
            style: GoogleFonts.inter(
              fontSize: 36.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 8.0),

          // Pending commissions
          if (pendingCommissions > 0)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.hourglass_bottom,
                    color: Colors.white,
                    size: 16.0,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    '${pendingCommissions.toString()} credits pending',
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20.0),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to withdrawal screen
                  },
                  icon: const Icon(Icons.account_balance, size: 18.0),
                  label: Text(
                    'Withdraw',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.indigo.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12.0),
              ElevatedButton.icon(
                onPressed: () {
                  // Show detailed breakdown
                },
                icon: const Icon(Icons.analytics, size: 18.0),
                label: Text(
                  'Details',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withAlpha(51),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
