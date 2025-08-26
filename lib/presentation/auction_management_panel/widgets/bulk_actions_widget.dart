import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class BulkActionsWidget extends StatelessWidget {
  final int selectedCount;
  final Function(String) onBulkAction;

  const BulkActionsWidget({
    Key? key,
    required this.selectedCount,
    required this.onBulkAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      child: Row(
        children: [
          Text(
            '$selectedCount items selected',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(width: 3.w),
          // Bulk Actions
          Row(
            children: [
              _buildActionButton(
                'Set as Live',
                Icons.play_circle,
                Colors.green,
                () => onBulkAction('live'),
              ),
              SizedBox(width: 2.w),
              _buildActionButton(
                'End Auctions',
                Icons.stop_circle,
                Colors.orange,
                () => onBulkAction('ended'),
              ),
              SizedBox(width: 2.w),
              _buildActionButton(
                'Cancel',
                Icons.cancel,
                Colors.red,
                () => onBulkAction('cancelled'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
