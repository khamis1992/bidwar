import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onCreateBattle;
  final VoidCallback onViewInvitations;
  final VoidCallback onJoinRandom;

  const QuickActionsWidget({
    super.key,
    required this.onCreateBattle,
    required this.onViewInvitations,
    required this.onJoinRandom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_circle_outline,
                label: 'Create Battle',
                description: 'Start your own',
                color: Colors.orange,
                onTap: onCreateBattle,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildActionButton(
                icon: Icons.mail_outline,
                label: 'Invitations',
                description: 'Check pending',
                color: Colors.blue,
                onTap: onViewInvitations,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildActionButton(
                icon: Icons.shuffle,
                label: 'Join Random',
                description: 'Feeling lucky?',
                color: Colors.purple,
                onTap: onJoinRandom,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withAlpha(77),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: color.withAlpha(51),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 6.w,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
