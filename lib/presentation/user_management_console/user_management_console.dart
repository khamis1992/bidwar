import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/admin_user_service.dart';
import './widgets/credit_management_dialog.dart';
import './widgets/user_actions_dialog.dart';
import './widgets/user_list_widget.dart';
import './widgets/user_search_filters_widget.dart';
import './widgets/user_statistics_widget.dart';

class UserManagementConsole extends StatefulWidget {
  const UserManagementConsole({Key? key}) : super(key: key);

  @override
  State<UserManagementConsole> createState() => _UserManagementConsoleState();
}

class _UserManagementConsoleState extends State<UserManagementConsole> {
  // Data variables
  List<Map<String, dynamic>> users = [];
  Map<String, dynamic>? userMetrics;
  bool isLoading = true;
  String? error;

  // Filter and pagination variables
  int currentPage = 1;
  final int itemsPerPage = 20;
  int totalPages = 1;
  String searchQuery = '';
  String roleFilter = 'all';
  String statusFilter = 'all';
  String sortBy = 'created_at';
  bool ascending = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadUserMetrics();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await AdminUserService.getAllUsers(
        page: currentPage,
        limit: itemsPerPage,
        searchQuery: searchQuery.isEmpty ? null : searchQuery,
        roleFilter: roleFilter,
        statusFilter: statusFilter,
        sortBy: sortBy,
        ascending: ascending,
      );

      setState(() {
        users = response['data']?.cast<Map<String, dynamic>>() ?? [];
        totalPages = response['total_pages'] ?? 1;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserMetrics() async {
    try {
      final metrics = await AdminUserService.getUserActivityMetrics();
      setState(() {
        userMetrics = metrics;
      });
    } catch (e) {
      // Handle error silently, metrics are not critical
    }
  }

  void _onFiltersChanged({
    String? search,
    String? role,
    String? status,
    String? sort,
    bool? isAscending,
  }) {
    setState(() {
      searchQuery = search ?? searchQuery;
      roleFilter = role ?? roleFilter;
      statusFilter = status ?? statusFilter;
      sortBy = sort ?? sortBy;
      ascending = isAscending ?? ascending;
      currentPage = 1; // Reset to first page when filters change
    });
    _loadUserData();
  }

  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
    _loadUserData();
  }

  void _showUserActions(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => UserActionsDialog(
        user: user,
        onRoleChanged: (newRole) {
          _updateUserRole(user['id'], newRole);
        },
        onVerificationChanged: (isVerified) {
          _updateUserVerification(user['id'], isVerified);
        },
        onSendNotification: (title, message) {
          _sendNotification(user['id'], title, message);
        },
      ),
    );
  }

  void _showCreditManagement(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => CreditManagementDialog(
        user: user,
        onCreditAdjustment: (amount, description) {
          _adjustUserCredits(user['id'], amount, description);
        },
      ),
    );
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    try {
      await AdminUserService.updateUserRole(userId, newRole);
      _loadUserData(); // Refresh data
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User role updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update role: $e')),
      );
    }
  }

  Future<void> _updateUserVerification(String userId, bool isVerified) async {
    try {
      await AdminUserService.updateUserVerification(userId, isVerified);
      _loadUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isVerified
              ? 'User verified successfully'
              : 'User verification removed'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update verification: $e')),
      );
    }
  }

  Future<void> _adjustUserCredits(
      String userId, int amount, String description) async {
    try {
      await AdminUserService.adjustUserCredits(userId, amount, description);
      _loadUserData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credit balance updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to adjust credits: $e')),
      );
    }
  }

  Future<void> _sendNotification(
      String userId, String title, String message) async {
    try {
      await AdminUserService.sendUserNotification(userId, title, message);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification sent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send notification: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'User Management Console',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadUserData();
              _loadUserMetrics();
            },
          ),
        ],
      ),
      body: isLoading && users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading users',
                        style: GoogleFonts.inter(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error!,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User Statistics Section
                      if (userMetrics != null) ...[
                        UserStatisticsWidget(metrics: userMetrics!),
                        const SizedBox(height: 24),
                      ],

                      // Search and Filters Section
                      UserSearchFiltersWidget(
                        searchQuery: searchQuery,
                        roleFilter: roleFilter,
                        statusFilter: statusFilter,
                        sortBy: sortBy,
                        ascending: ascending,
                        onFiltersChanged: _onFiltersChanged,
                      ),
                      const SizedBox(height: 24),

                      // Users List Section
                      Container(
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
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFE5E7EB)),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Users (${users.length} of ${totalPages * itemsPerPage})',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (isLoading)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                ],
                              ),
                            ),

                            // Users List
                            UserListWidget(
                              users: users,
                              onUserTap: _showUserActions,
                              onCreditManagement: _showCreditManagement,
                              currentPage: currentPage,
                              totalPages: totalPages,
                              onPageChanged: _onPageChanged,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
