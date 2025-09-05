import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Search Filter Widget
///
/// يوفر البحث والفلترة للمزادات
/// يتبع قواعد BidWar للتصميم
class SearchFilterWidget extends StatefulWidget {
  final Function(String) onSearch;
  final Function({String? categoryId, bool? featured}) onFilterChanged;
  final List<Map<String, dynamic>> categories;

  const SearchFilterWidget({
    super.key,
    required this.onSearch,
    required this.onFilterChanged,
    required this.categories,
  });

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  final _searchController = TextEditingController();
  String? _selectedCategoryId;
  bool _showFeaturedOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search auctions...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              onPressed: _clearSearch,
                              icon: Icon(Icons.clear),
                            )
                            : null,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    if (value.isEmpty) {
                      widget.onSearch('');
                    }
                  },
                  onSubmitted: widget.onSearch,
                ),
              ),

              SizedBox(width: 3.w),

              // Filter Button
              IconButton(
                onPressed: _showFilterBottomSheet,
                icon: Icon(
                  Icons.filter_list,
                  color:
                      _hasActiveFilters()
                          ? AppTheme.primaryLight
                          : AppTheme.textSecondaryLight,
                  size: 6.w,
                ),
              ),
            ],
          ),

          // Active Filters Chips
          if (_hasActiveFilters()) ...[
            SizedBox(height: 2.h),
            _buildActiveFiltersChips(),
          ],
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChips() {
    return Wrap(
      spacing: 2.w,
      children: [
        if (_selectedCategoryId != null)
          Chip(
            label: Text(
              _getCategoryName(_selectedCategoryId!),
              style: TextStyle(fontSize: 10.sp),
            ),
            backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.1),
            deleteIcon: Icon(Icons.close, size: 4.w),
            onDeleted: () {
              setState(() {
                _selectedCategoryId = null;
              });
              _applyFilters();
            },
          ),

        if (_showFeaturedOnly)
          Chip(
            label: Text('Featured', style: TextStyle(fontSize: 10.sp)),
            backgroundColor: AppTheme.warningLight.withValues(alpha: 0.1),
            deleteIcon: Icon(Icons.close, size: 4.w),
            onDeleted: () {
              setState(() {
                _showFeaturedOnly = false;
              });
              _applyFilters();
            },
          ),
      ],
    );
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearch('');
    setState(() {});
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter Auctions',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryLight,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedCategoryId = null;
                                _showFeaturedOnly = false;
                              });
                            },
                            child: Text('Clear All'),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      // Category Filter
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryLight,
                        ),
                      ),

                      SizedBox(height: 2.h),

                      Wrap(
                        spacing: 2.w,
                        runSpacing: 1.h,
                        children: [
                          ChoiceChip(
                            label: Text('All Categories'),
                            selected: _selectedCategoryId == null,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedCategoryId =
                                    selected ? null : _selectedCategoryId;
                              });
                            },
                          ),
                          ...widget.categories.map((category) {
                            final categoryId = category['id'] as String;
                            final categoryName = category['name'] as String;

                            return ChoiceChip(
                              label: Text(categoryName),
                              selected: _selectedCategoryId == categoryId,
                              onSelected: (selected) {
                                setModalState(() {
                                  _selectedCategoryId =
                                      selected ? categoryId : null;
                                });
                              },
                            );
                          }).toList(),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      // Featured Filter
                      CheckboxListTile(
                        title: Text(
                          'Featured Auctions Only',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                        subtitle: Text(
                          'Show only highlighted auctions',
                          style: TextStyle(fontSize: 11.sp),
                        ),
                        value: _showFeaturedOnly,
                        onChanged: (value) {
                          setModalState(() {
                            _showFeaturedOnly = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),

                      SizedBox(height: 4.h),

                      // Apply Button
                      SizedBox(
                        width: double.infinity,
                        height: 6.h,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {});
                            _applyFilters();
                          },
                          child: Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
          ),
    );
  }

  void _applyFilters() {
    widget.onFilterChanged(
      categoryId: _selectedCategoryId,
      featured: _showFeaturedOnly ? true : null,
    );
  }

  bool _hasActiveFilters() {
    return _selectedCategoryId != null || _showFeaturedOnly;
  }

  String _getCategoryName(String categoryId) {
    final category = widget.categories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => {'name': 'Unknown'},
    );
    return category['name'] as String;
  }
}
