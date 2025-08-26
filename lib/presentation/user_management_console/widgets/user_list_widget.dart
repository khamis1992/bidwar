import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/custom_image_widget.dart';

class UserListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final Function(Map<String, dynamic>) onUserTap;
  final Function(Map<String, dynamic>) onCreditManagement;
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const UserListWidget({
    Key? key,
    required this.users,
    required this.onUserTap,
    required this.onCreditManagement,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Users table
        Table(
          children: [
            // Header row
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[50]),
              children: [
                _buildTableHeader('User'),
                _buildTableHeader('Role'),
                _buildTableHeader('Status'),
                _buildTableHeader('Credits'),
                _buildTableHeader('Activity'),
                _buildTableHeader('Actions'),
              ],
            ),

            // User rows
            ...users.map((user) => _buildUserRow(context, user)).toList(),
          ],
        ),

        // Pagination
        if (totalPages > 1) ...[
          const SizedBox(height: 20),
          _buildPagination(),
        ],
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  TableRow _buildUserRow(BuildContext context, Map<String, dynamic> user) {
    final isVerified = user['is_verified'] == true;
    final role = user['role'] ?? 'bidder';
    final creditBalance = user['credit_balance'] ?? 0;

    return TableRow(
      children: [
        // User info cell
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: user['profile_picture_url'] != null
                    ? CustomImageWidget(
                        imageUrl: user['profile_picture_url'],
                        width: 40,
                        height: 40,
                      )
                    : Text(
                        (user['full_name'] ?? 'U')[0].toUpperCase(),
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
              const SizedBox(width: 12),

              // Name and email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user['full_name'] ?? 'Unknown User',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user['email'] ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Role cell
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getRoleColor(role).withAlpha(26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getRoleColor(role).withAlpha(77)),
            ),
            child: Text(
              role.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _getRoleColor(role),
              ),
            ),
          ),
        ),

        // Status cell
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isVerified ? Icons.verified : Icons.pending,
                size: 16,
                color: isVerified ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                isVerified ? 'Verified' : 'Unverified',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isVerified ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Credits cell
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '$creditBalance',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: creditBalance > 0 ? Colors.green[600] : Colors.grey[600],
            ),
          ),
        ),

        // Activity cell (simplified)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _formatDate(user['created_at']),
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),

        // Actions cell
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: () => onUserTap(user),
                icon: const Icon(Icons.edit, size: 18),
                tooltip: 'Edit User',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue[50],
                  foregroundColor: Colors.blue[600],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onCreditManagement(user),
                icon: const Icon(Icons.account_balance_wallet, size: 18),
                tooltip: 'Manage Credits',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green[50],
                  foregroundColor: Colors.green[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed:
              currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        ...List.generate(
          totalPages > 5 ? 5 : totalPages,
          (index) {
            int pageNum;
            if (totalPages <= 5) {
              pageNum = index + 1;
            } else {
              int start = (currentPage - 3).clamp(1, totalPages - 4);
              pageNum = start + index;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ElevatedButton(
                onPressed: pageNum == currentPage
                    ? null
                    : () => onPageChanged(pageNum),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      pageNum == currentPage ? Colors.blue : Colors.grey[100],
                  foregroundColor:
                      pageNum == currentPage ? Colors.white : Colors.grey[600],
                  minimumSize: const Size(40, 40),
                  padding: EdgeInsets.zero,
                ),
                child: Text('$pageNum'),
              ),
            );
          },
        ),
        IconButton(
          onPressed: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'seller':
        return Colors.blue;
      case 'bidder':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return 'Unknown';
    try {
      final date = DateTime.parse(dateStr.toString());
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown';
    }
  }
}