import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class DiscoveryModesWidget extends StatelessWidget {
  final String selectedMode;
  final Function(String) onModeChanged;

  const DiscoveryModesWidget({
    Key? key,
    required this.selectedMode,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modes = [
      DiscoveryMode(
        id: 'similar_to_watched',
        title: 'Similar to Watched',
        description: 'Items like those you\'ve viewed',
        icon: Icons.preview,
        color: Colors.blue,
      ),
      DiscoveryMode(
        id: 'trending_now',
        title: 'Trending Now',
        description: 'Popular auctions right now',
        icon: Icons.trending_up,
        color: Colors.orange,
      ),
      DiscoveryMode(
        id: 'ending_soon',
        title: 'Ending Soon',
        description: 'Last chance to bid',
        icon: Icons.schedule,
        color: Colors.red,
      ),
      DiscoveryMode(
        id: 'new_sellers',
        title: 'New Sellers',
        description: 'Fresh items from new sellers',
        icon: Icons.store,
        color: Colors.green,
      ),
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discovery Modes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[900],
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: modes.map((mode) => _buildModeCard(mode)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(DiscoveryMode mode) {
    final isSelected = selectedMode == mode.id;

    return Container(
      width: 160.h,
      margin: EdgeInsets.only(right: 12.h),
      child: GestureDetector(
        onTap: () => onModeChanged(mode.id),
        child: Container(
          padding: EdgeInsets.all(16.h),
          decoration: BoxDecoration(
            color: isSelected ? mode.color.withAlpha(26) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12.h),
            border: Border.all(
              color: isSelected ? mode.color : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.h),
                    decoration: BoxDecoration(
                      color: isSelected ? mode.color : Colors.grey[400],
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                    child: Icon(mode.icon, color: Colors.white, size: 16),
                  ),
                  const Spacer(),
                  if (isSelected)
                    Icon(Icons.check_circle, color: mode.color, size: 20),
                ],
              ),
              SizedBox(height: 12),
              Text(
                mode.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? mode.color : Colors.grey[900],
                ),
              ),
              SizedBox(height: 4),
              Text(
                mode.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiscoveryMode {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  DiscoveryMode({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
