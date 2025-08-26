import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ProductSpecifications extends StatefulWidget {
  final Map<String, dynamic> productData;

  const ProductSpecifications({
    super.key,
    required this.productData,
  });

  @override
  State<ProductSpecifications> createState() => _ProductSpecificationsState();
}

class _ProductSpecificationsState extends State<ProductSpecifications>
    with TickerProviderStateMixin {
  bool _isDescriptionExpanded = false;
  bool _isSpecsExpanded = false;
  late AnimationController _descriptionController;
  late AnimationController _specsController;
  late Animation<double> _descriptionAnimation;
  late Animation<double> _specsAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _descriptionController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _specsController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _descriptionAnimation = CurvedAnimation(
      parent: _descriptionController,
      curve: Curves.easeInOut,
    );

    _specsAnimation = CurvedAnimation(
      parent: _specsController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _specsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product title and basic info
          _buildProductHeader(theme, colorScheme),

          SizedBox(height: 3.h),

          // Description section
          _buildDescriptionSection(theme, colorScheme),

          SizedBox(height: 2.h),

          // Specifications section
          _buildSpecificationsSection(theme, colorScheme),

          SizedBox(height: 2.h),

          // Value comparison
          _buildValueComparison(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildProductHeader(ThemeData theme, ColorScheme colorScheme) {
    final title = widget.productData['title'] as String? ?? 'Product Title';
    final condition = widget.productData['condition'] as String? ?? 'New';
    final category = widget.productData['category'] as String? ?? 'Electronics';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              _buildInfoChip(
                icon: 'category',
                label: category,
                color: colorScheme.primary,
                theme: theme,
              ),
              SizedBox(width: 3.w),
              _buildInfoChip(
                icon: condition == 'New' ? 'new_releases' : 'verified',
                label: condition,
                color: condition == 'New'
                    ? colorScheme.tertiary
                    : colorScheme.primary,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String icon,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            size: 16,
            color: color,
          ),
          SizedBox(width: 2.w),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(ThemeData theme, ColorScheme colorScheme) {
    final description = widget.productData['description'] as String? ??
        'High-quality product with excellent features and reliable performance. Perfect for everyday use with modern design and advanced functionality.';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isDescriptionExpanded = !_isDescriptionExpanded;
              });
              if (_isDescriptionExpanded) {
                _descriptionController.forward();
              } else {
                _descriptionController.reverse();
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Description',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                  ),
                ),
                AnimatedRotation(
                  turns: _isDescriptionExpanded ? 0.5 : 0,
                  duration: Duration(milliseconds: 300),
                  child: CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    size: 24,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.5,
                fontSize: 14.sp,
              ),
              maxLines: _isDescriptionExpanded ? null : 3,
              overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsSection(ThemeData theme, ColorScheme colorScheme) {
    final specifications =
        widget.productData['specifications'] as Map<String, dynamic>? ??
            {
              'Brand': 'Premium Brand',
              'Model': 'Latest Model',
              'Warranty': '1 Year',
              'Weight': '2.5 lbs',
              'Dimensions': '10" x 8" x 3"',
              'Color': 'Black',
            };

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isSpecsExpanded = !_isSpecsExpanded;
              });
              if (_isSpecsExpanded) {
                _specsController.forward();
              } else {
                _specsController.reverse();
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Specifications',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                  ),
                ),
                AnimatedRotation(
                  turns: _isSpecsExpanded ? 0.5 : 0,
                  duration: Duration(milliseconds: 300),
                  child: CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    size: 24,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Column(
              children: _isSpecsExpanded
                  ? specifications.entries
                      .map((entry) => _buildSpecificationRow(entry.key,
                          entry.value.toString(), theme, colorScheme))
                      .toList()
                  : specifications.entries
                      .take(3)
                      .map((entry) => _buildSpecificationRow(entry.key,
                          entry.value.toString(), theme, colorScheme))
                      .toList(),
            ),
          ),
          if (!_isSpecsExpanded && specifications.length > 3)
            Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Text(
                '+${specifications.length - 3} more specifications',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpecificationRow(
      String key, String value, ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              key,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueComparison(ThemeData theme, ColorScheme colorScheme) {
    final retailValue = widget.productData['retailValue'] as double? ?? 299.99;
    final currentPrice = widget.productData['currentPrice'] as double? ?? 15.47;
    final savings = retailValue - currentPrice;
    final savingsPercentage = ((savings / retailValue) * 100).round();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.tertiary.withValues(alpha: 0.1),
            colorScheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.tertiary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'trending_down',
                size: 20,
                color: colorScheme.tertiary,
              ),
              SizedBox(width: 2.w),
              Text(
                'Value Comparison',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildValueItem(
                'Retail Value',
                '\$${retailValue.toStringAsFixed(2)}',
                colorScheme.onSurface.withValues(alpha: 0.7),
                theme,
              ),
              _buildValueItem(
                'Current Price',
                '\$${currentPrice.toStringAsFixed(2)}',
                colorScheme.primary,
                theme,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.secondary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'savings',
                  size: 20,
                  color: colorScheme.secondary,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Potential Savings: \$${savings.toStringAsFixed(2)} ($savingsPercentage% off)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(
      String label, String value, Color color, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withValues(alpha: 0.8),
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
      ],
    );
  }
}
