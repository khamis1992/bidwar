import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/creator_tier.dart';

class TierFilterWidget extends StatelessWidget {
  final List<CreatorTier> tiers;
  final String? selectedTier;
  final Function(String?) onTierChanged;

  const TierFilterWidget({
    Key? key,
    required this.tiers,
    required this.selectedTier,
    required this.onTierChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // All tiers chip
        _buildFilterChip(
          'All Tiers',
          selectedTier == null,
          () => onTierChanged(null),
          null,
          Colors.grey.shade600,
        ),

        const SizedBox(width: 8.0),

        // Individual tier chips
        ...tiers
            .map((tier) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _buildFilterChip(
                    tier.displayName,
                    selectedTier == tier.tierName,
                    () => onTierChanged(tier.tierName),
                    _getTierIcon(tier.tierName),
                    _getTierColor(tier.tierName),
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    IconData? icon,
    Color tierColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? tierColor : Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: tierColor,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16.0,
                color: isSelected ? Colors.white : tierColor,
              ),
              const SizedBox(width: 6.0),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : tierColor,
              ),
            ),
          ],
        ),
      ),
    );
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

  Color _getTierColor(String tierName) {
    switch (tierName.toLowerCase()) {
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
}
