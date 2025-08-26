import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class AuctionFiltersWidget extends StatelessWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;

  const AuctionFiltersWidget({
    Key? key,
    required this.searchQuery,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search auctions, products, or sellers...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 1.5.h,
                  ),
                ),
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: const Color(0xFF1A1E3D),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          // Filter Buttons
          Row(
            children: [
              _buildFilterButton(
                'Category',
                Icons.category,
                () {
                  // TODO: Implement category filter
                },
              ),
              SizedBox(width: 2.w),
              _buildFilterButton(
                'Date Range',
                Icons.date_range,
                () {
                  // TODO: Implement date range filter
                },
              ),
              SizedBox(width: 2.w),
              _buildFilterButton(
                'Price Range',
                Icons.attach_money,
                () {
                  // TODO: Implement price range filter
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.grey.shade600,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
