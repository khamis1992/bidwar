import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserActionsDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final Function(String) onRoleChanged;
  final Function(bool) onVerificationChanged;
  final Function(String, String) onSendNotification;

  const UserActionsDialog({
    Key? key,
    required this.user,
    required this.onRoleChanged,
    required this.onVerificationChanged,
    required this.onSendNotification,
  }) : super(key: key);

  @override
  State<UserActionsDialog> createState() => _UserActionsDialogState();
}

class _UserActionsDialogState extends State<UserActionsDialog> {
  String selectedRole = 'bidder';
  bool isVerified = false;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedRole = widget.user['role'] ?? 'bidder';
    isVerified = widget.user['is_verified'] == true;
  }

  @override
  void dispose() {
    titleController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      (widget.user['full_name'] ?? 'U')[0].toUpperCase(),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user['full_name'] ?? 'Unknown User',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.user['email'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Role Management Section
                    _buildSection(
                      'Role Management',
                      Icons.admin_panel_settings,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Role: ${selectedRole.toUpperCase()}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: selectedRole,
                            decoration: InputDecoration(
                              labelText: 'Select New Role',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'bidder',
                                child:
                                    Text('Bidder', style: GoogleFonts.inter()),
                              ),
                              DropdownMenuItem(
                                value: 'seller',
                                child:
                                    Text('Seller', style: GoogleFonts.inter()),
                              ),
                              DropdownMenuItem(
                                value: 'admin',
                                child:
                                    Text('Admin', style: GoogleFonts.inter()),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedRole = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: selectedRole != widget.user['role']
                                ? () {
                                    widget.onRoleChanged(selectedRole);
                                    Navigator.of(context).pop();
                                  }
                                : null,
                            child:
                                Text('Update Role', style: GoogleFonts.inter()),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Verification Section
                    _buildSection(
                      'Account Verification',
                      Icons.verified_user,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Switch(
                                value: isVerified,
                                onChanged: (value) {
                                  setState(() {
                                    isVerified = value;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isVerified
                                    ? 'Verified Account'
                                    : 'Unverified Account',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: isVerified !=
                                    (widget.user['is_verified'] == true)
                                ? () {
                                    widget.onVerificationChanged(isVerified);
                                    Navigator.of(context).pop();
                                  }
                                : null,
                            child: Text('Update Verification',
                                style: GoogleFonts.inter()),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Send Notification Section
                    _buildSection(
                      'Send Notification',
                      Icons.notifications_outlined,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: titleController,
                            decoration: InputDecoration(
                              labelText: 'Notification Title',
                              hintText: 'Enter notification title...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: messageController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: 'Message',
                              hintText: 'Enter your message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: titleController.text.isNotEmpty &&
                                    messageController.text.isNotEmpty
                                ? () {
                                    widget.onSendNotification(
                                      titleController.text,
                                      messageController.text,
                                    );
                                    Navigator.of(context).pop();
                                  }
                                : null,
                            child: Text('Send Notification',
                                style: GoogleFonts.inter()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}
