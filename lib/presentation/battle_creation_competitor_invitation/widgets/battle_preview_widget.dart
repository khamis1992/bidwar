import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BattlePreviewWidget extends StatelessWidget {
  final Map<String, dynamic> selectedProduct;
  final Map<String, dynamic> selectedCompetitor;
  final String battleTitle;
  final String battleDescription;
  final int battleDuration;
  final DateTime scheduledStart;
  final int minSupportThreshold;

  const BattlePreviewWidget({
    super.key,
    required this.selectedProduct,
    required this.selectedCompetitor,
    required this.battleTitle,
    required this.battleDescription,
    required this.battleDuration,
    required this.scheduledStart,
    required this.minSupportThreshold,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview Header
          Text(
            'Battle Preview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'This is how your battle will look to viewers',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 4.h),

          // Battle Card Preview
          Container(
            height: 35.h,
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
                color: Colors.red.withAlpha(128),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Split screen preview
                Row(
                  children: [
                    // Your side (left)
                    Expanded(
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
                        child: _buildCompetitorPreview(
                          'You',
                          selectedProduct,
                          Colors.blue,
                          isLeft: true,
                        ),
                      ),
                    ),
                    // Competitor side (right)
                    Expanded(
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
                        child: _buildCompetitorPreview(
                          selectedCompetitor['full_name'] ?? 'Competitor',
                          null, // Competitor will select their product
                          Colors.red,
                          isLeft: false,
                        ),
                      ),
                    ),
                  ],
                ),

                // Status badge
                Positioned(
                  top: 3.w,
                  left: 3.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withAlpha(77),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      'STARTING SOON',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ),

                // VS indicator
                Positioned(
                  top: 15.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(2.5.w),
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
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ),

                // Battle info overlay
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
                      children: [
                        Text(
                          battleTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.grey[400],
                              size: 16.sp,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '$battleDuration minutes',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.people,
                              color: Colors.grey[400],
                              size: 16.sp,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '0 viewers',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Battle Details
          _buildDetailSection('Battle Details', [
            _buildDetailRow('Title', battleTitle),
            _buildDetailRow('Description', battleDescription),
            _buildDetailRow('Duration', '$battleDuration minutes'),
            _buildDetailRow('Start Time', _formatDateTime(scheduledStart)),
            _buildDetailRow(
                'Support Goal', '$minSupportThreshold support needed'),
          ]),

          SizedBox(height: 3.h),

          // Your Product
          _buildDetailSection('Your Product', [
            _buildDetailRow('Product', selectedProduct['title'] ?? 'No title'),
            _buildDetailRow(
                'Value', '\$${selectedProduct['retail_value'] ?? 0}'),
            _buildDetailRow(
                'Condition', selectedProduct['condition'] ?? 'Unknown'),
          ]),

          SizedBox(height: 3.h),

          // Competitor Info
          _buildDetailSection('Your Opponent', [
            _buildDetailRow(
                'Name', selectedCompetitor['full_name'] ?? 'Unknown'),
            _buildDetailRow('Level', _getCompetitorLevel()),
            _buildDetailRow('Product', 'To be selected'),
          ]),

          SizedBox(height: 3.h),

          // Battle Rules
          _buildDetailSection('Battle Rules', [
            _buildRuleItem('⚔️', 'TikTok-style split screen format'),
            _buildRuleItem('👥', 'Viewers support their favorite competitor'),
            _buildRuleItem(
                '💰', 'Support costs credits, competitors earn commissions'),
            _buildRuleItem('🏆', 'Competitor with most support wins'),
            _buildRuleItem('⏱️', 'Real-time battle progress and animations'),
            _buildRuleItem('📱', 'Optimized for mobile viewing experience'),
          ]),
        ],
      ),
    );
  }

  Widget _buildCompetitorPreview(
      String name, Map<String, dynamic>? product, Color accentColor,
      {required bool isLeft}) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment:
            isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          // Avatar placeholder
          CircleAvatar(
            radius: 5.w,
            backgroundColor: accentColor.withAlpha(77),
            child: Icon(
              Icons.person,
              color: accentColor,
              size: 6.w,
            ),
          ),
          SizedBox(height: 2.h),

          // Name
          Text(
            name,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
            textAlign: isLeft ? TextAlign.left : TextAlign.right,
          ),

          const Spacer(),

          // Product preview
          if (product != null)
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_bag,
                    color: accentColor,
                    size: 5.w,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    product['title'] ?? 'Product',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          else
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(77),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withAlpha(128)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    color: Colors.grey[400],
                    size: 5.w,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Choosing...',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30.w,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String emoji, String rule) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16.sp)),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              rule,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inMinutes < 5) {
      return 'Starting now';
    } else if (difference.inHours < 1) {
      return 'Starting in ${difference.inMinutes} minutes';
    } else if (difference.inHours < 24) {
      return 'Starting in ${difference.inHours} hours';
    } else {
      return 'Starting ${dateTime.day}/${dateTime.month} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _getCompetitorLevel() {
    final credits = selectedCompetitor['credit_balance'] ?? 0;
    if (credits > 10000) return 'Pro Level';
    if (credits > 5000) return 'Advanced';
    if (credits > 1000) return 'Intermediate';
    return 'Beginner';
  }
}
