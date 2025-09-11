import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FeaturedBattleWidget extends StatelessWidget {
  final Map<String, dynamic> battle;
  final VoidCallback onTap;

  const FeaturedBattleWidget({
    super.key,
    required this.battle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final supportA = battle['total_support_a'] ?? 0;
    final supportB = battle['total_support_b'] ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 75.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange.withAlpha(204),
              Colors.red.withAlpha(204),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withAlpha(77),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(26),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.5.w, vertical: 0.8.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'FEATURED',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
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
                            SizedBox(width: 1.w),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Battle title
                  Text(
                    battle['title'] ?? 'Epic Battle',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16.sp,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),

                  // Competitors preview
                  Row(
                    children: [
                      _buildCompetitorPreview(
                        battle['competitor_a'] ?? {},
                        supportA,
                        Colors.blue,
                      ),
                      SizedBox(width: 3.w),
                      Container(
                        padding: EdgeInsets.all(1.5.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(230),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          'VS',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      _buildCompetitorPreview(
                        battle['competitor_b'] ?? {},
                        supportB,
                        Colors.red,
                      ),
                      const Spacer(),
                      // Viewer count
                      Column(
                        children: [
                          Icon(
                            Icons.visibility,
                            color: Colors.white.withAlpha(204),
                            size: 16.sp,
                          ),
                          Text(
                            '${battle['viewer_count'] ?? 0}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetitorPreview(
    Map<String, dynamic> competitor,
    int support,
    Color accentColor,
  ) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 3.5.w,
              backgroundColor: Colors.white.withAlpha(51),
              backgroundImage: competitor['profile_picture_url'] != null
                  ? NetworkImage(competitor['profile_picture_url'])
                  : null,
              child: competitor['profile_picture_url'] == null
                  ? Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 4.w,
                    )
                  : null,
            ),
            if (support > 0)
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: EdgeInsets.all(0.5.w),
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Text(
                    support.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 8.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
