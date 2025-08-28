import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/user_profile.dart';
import '../../../models/creator_tier.dart';

class TierIndicatorWidget extends StatelessWidget {
  final UserProfile user;
  final CreatorTier currentTier;

  const TierIndicatorWidget({
    Key? key,
    required this.user,
    required this.currentTier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getTierColor().withAlpha(26),
            _getTierColor().withAlpha(13),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: _getTierColor().withAlpha(51),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Credit Balance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance',
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${user.creditBalance.toString()} credits',
                    style: GoogleFonts.inter(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              // Tier badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: _getTierColor(),
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: _getTierColor().withAlpha(77),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  currentTier.displayName,
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          // Commission rate highlight
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Colors.green.shade200,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Colors.green.shade600,
                  size: 20.0,
                ),
                const SizedBox(width: 8.0),
                Text(
                  'Earn ${currentTier.commissionRateText} commission on each sale',
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16.0),

          // Progress to next tier (if applicable)
          if (currentTier.maxCreditRequirement != null) _buildTierProgress(),
        ],
      ),
    );
  }

  Widget _buildTierProgress() {
    final nextTierCredit = currentTier.maxCreditRequirement! + 1;
    final currentProgress =
        user.creditBalance - currentTier.minCreditRequirement;
    final totalNeeded =
        currentTier.maxCreditRequirement! - currentTier.minCreditRequirement;
    final progressPercentage = (currentProgress / totalNeeded).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress to next tier',
              style: GoogleFonts.inter(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '${(progressPercentage * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        LinearProgressIndicator(
          value: progressPercentage,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(_getTierColor()),
          minHeight: 6.0,
        ),
        const SizedBox(height: 4.0),
        Text(
          '${(nextTierCredit - user.creditBalance).toString()} more credits needed',
          style: GoogleFonts.inter(
            fontSize: 12.0,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Color _getTierColor() {
    switch (currentTier.tierName.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFF76D7C4);
      default:
        return Colors.grey.shade500;
    }
  }
}
