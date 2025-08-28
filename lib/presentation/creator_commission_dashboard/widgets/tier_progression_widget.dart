import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/user_profile.dart';
import '../../../models/creator_tier.dart';

class TierProgressionWidget extends StatelessWidget {
  final UserProfile currentUser;
  final CreatorTier currentTier;

  const TierProgressionWidget({
    Key? key,
    required this.currentUser,
    required this.currentTier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: _getCurrentTierColor().withAlpha(26),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Icon(
                  _getTierIcon(currentTier.tierName),
                  color: _getCurrentTierColor(),
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Tier',
                      style: GoogleFonts.inter(
                        fontSize: 14.0,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      currentTier.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: _getCurrentTierColor(),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  currentTier.commissionRateText,
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20.0),

          // Progress to next tier
          if (currentTier.maxCreditRequirement != null) ...[
            _buildProgressToNextTier(),
          ] else ...[
            _buildMaxTierReached(),
          ],

          const SizedBox(height: 16.0),

          // Tier benefits
          _buildTierBenefits(),
        ],
      ),
    );
  }

  Widget _buildProgressToNextTier() {
    final nextTierCredit = currentTier.maxCreditRequirement! + 1;
    final currentProgress =
        currentUser.creditBalance - currentTier.minCreditRequirement;
    final totalNeeded =
        currentTier.maxCreditRequirement! - currentTier.minCreditRequirement;
    final progressPercentage = (currentProgress / totalNeeded).clamp(0.0, 1.0);
    final creditsNeeded = nextTierCredit - currentUser.creditBalance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress to ${_getNextTierName()}',
              style: GoogleFonts.inter(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Colors.black,
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
          valueColor: AlwaysStoppedAnimation<Color>(_getCurrentTierColor()),
          minHeight: 8.0,
        ),
        const SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current: ${currentUser.creditBalance.toString()} credits',
              style: GoogleFonts.inter(
                fontSize: 12.0,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '${creditsNeeded.toString()} credits needed',
              style: GoogleFonts.inter(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: _getCurrentTierColor(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaxTierReached() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade400,
            Colors.amber.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 24.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maximum Tier Reached!',
                  style: GoogleFonts.inter(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'You have achieved the highest creator tier',
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    color: Colors.white.withAlpha(230),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierBenefits() {
    final features = currentTier.features;
    final maxProducts = currentTier.maxProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tier Benefits',
          style: GoogleFonts.inter(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8.0),
        if (maxProducts != null)
          _buildBenefitItem(
            Icons.inventory_2,
            'Product Access',
            maxProducts == -1
                ? 'Unlimited products'
                : 'Up to $maxProducts products',
          ),
        if (features.isNotEmpty)
          ...features
              .take(3)
              .map((feature) => _buildBenefitItem(
                    _getFeatureIcon(feature),
                    _getFeatureTitle(feature),
                    _getFeatureDescription(feature),
                  ))
              .toList(),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16.0,
            color: _getCurrentTierColor(),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 12.0,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCurrentTierColor() {
    switch (currentTier.tierName.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFF708090);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFF76D7C4);
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getTierIcon(String tierName) {
    switch (tierName.toLowerCase()) {
      case 'bronze':
        return Icons.workspace_premium;
      case 'silver':
        return Icons.military_tech;
      case 'gold':
        return Icons.emoji_events;
      case 'platinum':
        return Icons.diamond;
      default:
        return Icons.star;
    }
  }

  String _getNextTierName() {
    switch (currentTier.tierName.toLowerCase()) {
      case 'bronze':
        return 'Silver';
      case 'silver':
        return 'Gold';
      case 'gold':
        return 'Platinum';
      default:
        return 'Next Tier';
    }
  }

  IconData _getFeatureIcon(String feature) {
    if (feature.contains('analytics')) return Icons.analytics;
    if (feature.contains('support')) return Icons.support_agent;
    if (feature.contains('featured')) return Icons.star;
    if (feature.contains('premium')) return Icons.diamond;
    if (feature.contains('early')) return Icons.access_time;
    return Icons.check_circle;
  }

  String _getFeatureTitle(String feature) {
    if (feature.contains('analytics')) return 'Analytics';
    if (feature.contains('support')) return 'Priority Support';
    if (feature.contains('featured')) return 'Featured Placement';
    if (feature.contains('premium')) return 'Premium Products';
    if (feature.contains('early')) return 'Early Access';
    return feature.replaceAll('_', ' ').toUpperCase();
  }

  String _getFeatureDescription(String feature) {
    if (feature.contains('basic')) return 'Basic performance insights';
    if (feature.contains('advanced')) return 'Detailed analytics and trends';
    if (feature.contains('premium')) return 'Professional analytics suite';
    if (feature.contains('full')) return 'Complete analytics dashboard';
    if (feature.contains('standard')) return 'Standard customer support';
    if (feature.contains('priority')) return 'Priority customer support';
    if (feature.contains('dedicated')) return 'Dedicated account manager';
    if (feature.contains('vip')) return 'VIP customer support';
    return 'Enhanced feature access';
  }
}
