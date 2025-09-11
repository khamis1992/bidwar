import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CategoryFilterWidget extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  const CategoryFilterWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 6.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCategoryChip(
                label: 'All',
                icon: Icons.apps,
                isSelected: selectedCategory == null,
                onTap: () => onCategorySelected(null),
              ),
              ...categories.map((category) => _buildCategoryChip(
                    label: category['name'],
                    icon: category['icon'] ?? Icons.category,
                    isSelected: selectedCategory == category['id'],
                    onTap: () => onCategorySelected(category['id']),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 3.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.grey[800],
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? Colors.orange : Colors.grey[700]!,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[400],
                size: 18.sp,
              ),
              SizedBox(width: 2.w),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
