import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearch;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search auctions...',
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[600],
            size: 20.sp,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: Colors.grey[600],
                    size: 20.sp,
                  ),
                  onPressed: () {
                    controller.clear();
                    onSearch('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          filled: true,
          fillColor: Colors.white,
        ),
        onSubmitted: onSearch,
        onChanged: (value) {
          // Debounced search could be implemented here
          if (value.isEmpty) {
            onSearch('');
          }
        },
      ),
    );
  }
}
