import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AuctionTableWidget extends StatefulWidget {
  final List<Map<String, dynamic>> auctions;
  final List<String> selectedIds;
  final Function(List<String>) onSelectionChanged;
  final Function(String, String) onUpdateStatus;
  final Function(String) onDelete;

  const AuctionTableWidget({
    Key? key,
    required this.auctions,
    required this.selectedIds,
    required this.onSelectionChanged,
    required this.onUpdateStatus,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<AuctionTableWidget> createState() => _AuctionTableWidgetState();
}

class _AuctionTableWidgetState extends State<AuctionTableWidget> {
  bool selectAll = false;

  void _toggleSelectAll() {
    setState(() {
      selectAll = !selectAll;
      if (selectAll) {
        widget.onSelectionChanged(
          widget.auctions.map((auction) => auction['id'] as String).toList(),
        );
      } else {
        widget.onSelectionChanged([]);
      }
    });
  }

  void _toggleSelection(String id) {
    final newSelection = List<String>.from(widget.selectedIds);
    if (newSelection.contains(id)) {
      newSelection.remove(id);
    } else {
      newSelection.add(id);
    }
    widget.onSelectionChanged(newSelection);

    setState(() {
      selectAll = newSelection.length == widget.auctions.length;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'live':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'ended':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.auctions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 2.h),
            Text(
              'No auctions found',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Create your first auction to get started',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Table Header
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              // Select All Checkbox
              SizedBox(
                width: 40,
                child: Checkbox(
                  value: selectAll,
                  onChanged: (value) => _toggleSelectAll(),
                  activeColor: Colors.blue.shade600,
                ),
              ),
              // Product Column
              Expanded(
                flex: 3,
                child: Text(
                  'Product',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              // Seller Column
              Expanded(
                flex: 2,
                child: Text(
                  'Seller',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              // Status Column
              Expanded(
                child: Text(
                  'Status',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              // Current Bid Column
              Expanded(
                child: Text(
                  'Current Bid',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              // End Time Column
              Expanded(
                flex: 2,
                child: Text(
                  'End Time',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              // Actions Column
              SizedBox(
                width: 100,
                child: Text(
                  'Actions',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Table Body
        Expanded(
          child: ListView.builder(
            itemCount: widget.auctions.length,
            itemBuilder: (context, index) {
              final auction = widget.auctions[index];
              final isSelected = widget.selectedIds.contains(auction['id']);

              return Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _toggleSelection(auction['id']),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      child: Row(
                        children: [
                          // Checkbox
                          SizedBox(
                            width: 40,
                            child: Checkbox(
                              value: isSelected,
                              onChanged: (value) =>
                                  _toggleSelection(auction['id']),
                              activeColor: Colors.blue.shade600,
                            ),
                          ),
                          // Product Info
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                // Product Image
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade100,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child:
                                        _buildProductImage(auction['images']),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                // Product Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        auction['title'] ?? 'Untitled Auction',
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1A1E3D),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        'Starting: \$${auction['starting_price'] ?? '0'}',
                                        style: GoogleFonts.inter(
                                          fontSize: 12.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Seller Info
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  auction['user_profiles']?['full_name'] ??
                                      'Unknown Seller',
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1A1E3D),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  auction['user_profiles']?['email'] ??
                                      'No email',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Status
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: 0.5.h),
                              decoration: BoxDecoration(
                                color: _getStatusColor(auction['status'])
                                    .withAlpha(26),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _getStatusColor(auction['status'])
                                      .withAlpha(77),
                                ),
                              ),
                              child: Text(
                                (auction['status'] as String).toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(auction['status']),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          // Current Bid
                          Expanded(
                            child: Text(
                              '\$${auction['current_highest_bid'] ?? '0'}',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade600,
                              ),
                            ),
                          ),
                          // End Time
                          Expanded(
                            flex: 2,
                            child: Text(
                              _formatDateTime(auction['end_time']),
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                          // Actions
                          SizedBox(
                            width: 100,
                            child: Row(
                              children: [
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Colors.grey.shade600,
                                    size: 20,
                                  ),
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'live':
                                      case 'ended':
                                      case 'cancelled':
                                        widget.onUpdateStatus(
                                            auction['id'], value);
                                        break;
                                      case 'delete':
                                        _showDeleteConfirmation(auction);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'live',
                                      child: Text('Mark as Live'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'ended',
                                      child: Text('Mark as Ended'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'cancelled',
                                      child: Text('Cancel Auction'),
                                    ),
                                    const PopupMenuDivider(),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(dynamic images) {
    if (images == null) {
      return Icon(
        Icons.image_not_supported,
        color: Colors.grey.shade400,
        size: 24,
      );
    }

    List<dynamic> imageList = [];
    if (images is List) {
      imageList = images;
    } else if (images is String) {
      try {
        // Try to parse as JSON array
        imageList = [images];
      } catch (e) {
        imageList = [images];
      }
    }

    if (imageList.isEmpty) {
      return Icon(
        Icons.image_not_supported,
        color: Colors.grey.shade400,
        size: 24,
      );
    }

    final firstImage = imageList.first.toString();
    if (firstImage.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: firstImage,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Icon(
          Icons.broken_image,
          color: Colors.grey.shade400,
          size: 24,
        ),
      );
    }

    return Icon(
      Icons.image,
      color: Colors.grey.shade400,
      size: 24,
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> auction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Auction',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${auction['title']}"? This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDelete(auction['id']);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
