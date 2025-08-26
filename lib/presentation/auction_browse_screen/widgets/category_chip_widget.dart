import 'package:flutter/material.dart';


class CategoryChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const CategoryChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: Theme.of(context).colorScheme.primary.withAlpha(51),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Colors.grey[100],
      elevation: isSelected ? 2 : 0,
      pressElevation: 4,
      labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}