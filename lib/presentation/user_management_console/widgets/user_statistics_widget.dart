import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserStatisticsWidget extends StatelessWidget {
  final Map<String, dynamic> metrics;

  const UserStatisticsWidget({
    Key? key,
    required this.metrics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.analytics_outlined, color: Colors.blue[600]),
                const SizedBox(width: 12),
                Text(
                  'User Analytics Overview',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Statistics Grid
          Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Total Users',
                  '${metrics['total_users'] ?? 0}',
                  Icons.people_outline,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Active Users',
                  '${metrics['active_users'] ?? 0}',
                  Icons.trending_up,
                  Colors.green,
                ),
                _buildStatCard(
                  'New This Month',
                  '${metrics['new_users_this_month'] ?? 0}',
                  Icons.person_add_outlined,
                  Colors.purple,
                ),
                _buildStatCard(
                  'Verified Users',
                  '${metrics['verified_users'] ?? 0}',
                  Icons.verified_user_outlined,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(26)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
