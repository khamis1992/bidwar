import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/product_inventory.dart';

class CategoryFilterWidget extends StatelessWidget {
  final List<ProductInventory> products;
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;

  const CategoryFilterWidget({
    Key? key,
    required this.products,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get unique categories from products
    final categories = products
        .where((product) => product.categoryName != null)
        .map((product) => product.categoryName!)
        .toSet()
        .toList();

    categories.sort();

    return Row(
      children: [
        // All categories chip
        _buildFilterChip(
          'All',
          selectedCategory == null,
          () => onCategoryChanged(null),
          Icons.apps,
        ),

        const SizedBox(width: 8.0),

        // Individual category chips
        ...categories
            .map((category) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _buildFilterChip(
                    category,
                    selectedCategory == category,
                    () => onCategoryChanged(category),
                    _getCategoryIcon(category),
                  ),
                ))
            .toList(),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: isSelected ? Colors.blue.shade600 : Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.0,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electronics':
        return Icons.electrical_services;
      case 'fashion':
        return Icons.checkroom;
      case 'home':
      case 'home & garden':
        return Icons.home;
      case 'luxury':
        return Icons.diamond;
      case 'automotive':
        return Icons.directions_car;
      case 'sports':
        return Icons.sports_soccer;
      case 'art':
      case 'art & collectibles':
        return Icons.palette;
      default:
        return Icons.category;
    }
  }
}
