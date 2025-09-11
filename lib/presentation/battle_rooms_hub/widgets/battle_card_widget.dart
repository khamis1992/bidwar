import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BattleCardWidget extends StatelessWidget {
  final Map<String, dynamic> battle;
  final VoidCallback onTap;
  final VoidCallback? onShare;

  const BattleCardWidget({
    super.key,
    required this.battle,
    required this.onTap,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = battle['status'] == 'active';
    final supportA = battle['total_support_a'] ?? 0;
    final supportB = battle['total_support_b'] ?? 0;
    final totalSupport = supportA + supportB;
    final supportRatioA = totalSupport > 0 ? supportA / totalSupport : 0.5;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[900]!,
              Colors.black87,
            ],
          ),
          border: Border.all(
            color: isActive
                ? Colors.red.withAlpha(128)
                : Colors.grey.withAlpha(77),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Background split-screen preview
            Row(
              children: [
                // Competitor A side
                Expanded(
                  flex: (supportRatioA * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.withAlpha(77),
                          Colors.blue.withAlpha(26),
                        ],
                      ),
                    ),
                    child: _buildCompetitorSide(
                      battle['competitor_a'] ?? {},
                      battle['product_a'] ?? {},
                      supportA,
                      Colors.blue,
                      isLeft: true,
                    ),
                  ),
                ),
                // Competitor B side (or placeholder)
                Expanded(
                  flex: ((1 - supportRatioA) * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Colors.red.withAlpha(77),
                          Colors.red.withAlpha(26),
                        ],
                      ),
                    ),
                    child: battle['competitor_b_id'] != null
                        ? _buildCompetitorSide(
                            battle['competitor_b'] ?? {},
                            battle['product_b'] ?? {},
                            supportB,
                            Colors.red,
                            isLeft: false,
                          )
                        : _buildWaitingForOpponent(),
                  ),
                ),
              ],
            ),

            // Status badge
            Positioned(
              top: 3.w,
              left: 3.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isActive ? Colors.red : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isActive ? Colors.red : Colors.orange).withAlpha(77),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.sp,
                        ),
                      ),
                    ] else
                      Text(
                        'STARTING SOON',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.sp,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Battle title and info overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withAlpha(230),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Battle title
                    Text(
                      battle['title'] ?? 'Epic Battle',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),

                    // Battle stats
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          color: Colors.grey[400],
                          size: 16.sp,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${battle['viewer_count'] ?? 0}',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.access_time,
                          color: Colors.grey[400],
                          size: 16.sp,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          _getTimeRemaining(),
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 12.sp,
                          ),
                        ),
                        const Spacer(),
                        if (onShare != null)
                          GestureDetector(
                            onTap: onShare,
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              child: Icon(
                                Icons.share,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // VS indicator in center
            Positioned(
              top: 12.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(77),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetitorSide(Map<String, dynamic> competitor,
      Map<String, dynamic> product, int support, Color accentColor,
      {required bool isLeft}) {
    return Padding(
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment:
            isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          // Competitor avatar
          CircleAvatar(
            radius: 4.w,
            backgroundColor: accentColor.withAlpha(51),
            backgroundImage: competitor['profile_picture_url'] != null
                ? NetworkImage(competitor['profile_picture_url'])
                : null,
            child: competitor['profile_picture_url'] == null
                ? Icon(
                    Icons.person,
                    color: accentColor,
                    size: 5.w,
                  )
                : null,
          ),
          SizedBox(height: 1.h),

          // Competitor name
          Text(
            competitor['full_name'] ?? 'Competitor',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: isLeft ? TextAlign.left : TextAlign.right,
          ),

          const Spacer(),

          // Support count
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(204),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 14.sp,
                ),
                SizedBox(width: 1.w),
                Text(
                  support.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingForOpponent() {
    return Padding(
      padding: EdgeInsets.all(3.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add,
            color: Colors.grey[400],
            size: 8.w,
          ),
          SizedBox(height: 1.h),
          Text(
            'Waiting for\nOpponent',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getTimeRemaining() {
    if (battle['status'] == 'active') {
      return 'Live Now';
    }

    final scheduledStart = battle['scheduled_start'];
    if (scheduledStart != null) {
      final startTime = DateTime.parse(scheduledStart);
      final now = DateTime.now();
      final difference = startTime.difference(now);

      if (difference.isNegative) {
        return 'Started';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ${difference.inMinutes % 60}m';
      } else {
        return '${difference.inMinutes}m';
      }
    }

    return 'Soon';
  }
}
