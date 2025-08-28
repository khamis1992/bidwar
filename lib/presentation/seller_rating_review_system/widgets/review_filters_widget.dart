import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '/core/app_export.dart';

class ReviewFiltersWidget extends StatelessWidget {
  final String selectedRating;
  final String selectedSort;
  final String selectedCategory;
  final Function({String? rating, String? sort, String? category})
      onFiltersChanged;

  const ReviewFiltersWidget({
    super.key,
    required this.selectedRating,
    required this.selectedSort,
    required this.selectedCategory,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Reviews',
            style: TextStyle(
              fontSize: 16.h,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          _buildFilterRow(),
          SizedBox(height: 12.h),
          _buildCategoryFilter(),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: _buildRatingFilter(),
        ),
        SizedBox(width: 12.h),
        Expanded(
          child: _buildSortFilter(),
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating',
          style: TextStyle(
            fontSize: 12.h,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.h),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedRating,
              isExpanded: true,
              padding: EdgeInsets.symmetric(horizontal: 12.h),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Stars')),
                DropdownMenuItem(
                  value: '5',
                  child: Row(
                    children: [
                      Text('5 '),
                      Icon(Icons.star, size: 16, color: Colors.amber),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: '4',
                  child: Row(
                    children: [
                      Text('4 '),
                      Icon(Icons.star, size: 16, color: Colors.amber),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: '3',
                  child: Row(
                    children: [
                      Text('3 '),
                      Icon(Icons.star, size: 16, color: Colors.amber),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: '2',
                  child: Row(
                    children: [
                      Text('2 '),
                      Icon(Icons.star, size: 16, color: Colors.amber),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: '1',
                  child: Row(
                    children: [
                      Text('1 '),
                      Icon(Icons.star, size: 16, color: Colors.amber),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  onFiltersChanged(rating: value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSortFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sort By',
          style: TextStyle(
            fontSize: 12.h,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.h),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedSort,
              isExpanded: true,
              padding: EdgeInsets.symmetric(horizontal: 12.h),
              items: const [
                DropdownMenuItem(value: 'recent', child: Text('Most Recent')),
                DropdownMenuItem(value: 'oldest', child: Text('Oldest First')),
                DropdownMenuItem(
                    value: 'highest', child: Text('Highest Rated')),
                DropdownMenuItem(value: 'lowest', child: Text('Lowest Rated')),
                DropdownMenuItem(value: 'helpful', child: Text('Most Helpful')),
              ],
              onChanged: (value) {
                if (value != null) {
                  onFiltersChanged(sort: value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Type',
          style: TextStyle(
            fontSize: 12.h,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.h,
          runSpacing: 8.h,
          children: [
            _buildCategoryChip('all', 'All Reviews'),
            _buildCategoryChip('verified', 'Verified Only'),
            _buildCategoryChip('with_photos', 'With Photos'),
            _buildCategoryChip('with_response', 'With Response'),
            _buildCategoryChip('recent_purchases', 'Recent Buyers'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final isSelected = selectedCategory == value;

    return GestureDetector(
      onTap: () => onFiltersChanged(category: value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16.h),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.h,
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}