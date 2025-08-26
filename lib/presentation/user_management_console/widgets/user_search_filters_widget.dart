import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserSearchFiltersWidget extends StatelessWidget {
  final String searchQuery;
  final String roleFilter;
  final String statusFilter;
  final String sortBy;
  final bool ascending;
  final Function({
    String? search,
    String? role,
    String? status,
    String? sort,
    bool? isAscending,
  }) onFiltersChanged;

  const UserSearchFiltersWidget({
    Key? key,
    required this.searchQuery,
    required this.roleFilter,
    required this.statusFilter,
    required this.sortBy,
    required this.ascending,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search & Filters',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Search and filters row
          Row(
            children: [
              // Search field
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users by name or email...',
                    hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    onFiltersChanged(search: value);
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Role filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: roleFilter,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    labelStyle: GoogleFonts.inter(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'all',
                        child: Text('All Roles', style: GoogleFonts.inter())),
                    DropdownMenuItem(
                        value: 'admin',
                        child: Text('Admin', style: GoogleFonts.inter())),
                    DropdownMenuItem(
                        value: 'seller',
                        child: Text('Seller', style: GoogleFonts.inter())),
                    DropdownMenuItem(
                        value: 'bidder',
                        child: Text('Bidder', style: GoogleFonts.inter())),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onFiltersChanged(role: value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Status filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: statusFilter,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: GoogleFonts.inter(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'all',
                        child: Text('All Status', style: GoogleFonts.inter())),
                    DropdownMenuItem(
                        value: 'verified',
                        child: Text('Verified', style: GoogleFonts.inter())),
                    DropdownMenuItem(
                        value: 'unverified',
                        child: Text('Unverified', style: GoogleFonts.inter())),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onFiltersChanged(status: value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Sort options
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: sortBy,
                  decoration: InputDecoration(
                    labelText: 'Sort By',
                    labelStyle: GoogleFonts.inter(color: Colors.grey[600]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'created_at',
                        child: Text('Join Date', style: GoogleFonts.inter())),
                    DropdownMenuItem(
                        value: 'full_name',
                        child: Text('Name', style: GoogleFonts.inter())),
                    DropdownMenuItem(
                        value: 'email',
                        child: Text('Email', style: GoogleFonts.inter())),
                    DropdownMenuItem(
                        value: 'credit_balance',
                        child: Text('Credits', style: GoogleFonts.inter())),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onFiltersChanged(sort: value);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Sort direction toggle
              IconButton(
                onPressed: () {
                  onFiltersChanged(isAscending: !ascending);
                },
                icon: Icon(
                  ascending
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                ),
                tooltip: ascending ? 'Sort Descending' : 'Sort Ascending',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
