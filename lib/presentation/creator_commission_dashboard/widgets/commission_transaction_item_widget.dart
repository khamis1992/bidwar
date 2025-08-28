import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CommissionTransactionItemWidget extends StatelessWidget {
  final Map<String, dynamic> earning;

  const CommissionTransactionItemWidget({
    Key? key,
    required this.earning,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auctionItem = earning['auction_items'] as Map<String, dynamic>?;
    final productSelection =
        earning['product_selections'] as Map<String, dynamic>?;
    final productInventory =
        productSelection?['product_inventory'] as Map<String, dynamic>?;

    final title = auctionItem?['title'] as String? ?? 'Unknown Item';
    final commissionAmount = earning['commission_amount'] as int? ?? 0;
    final commissionStatus =
        earning['commission_status'] as String? ?? 'unknown';
    final earnedAt = DateTime.tryParse(earning['earned_at'] as String? ?? '');
    final finalSalePrice = earning['final_sale_price'] as int? ?? 0;
    final commissionRate =
        (earning['commission_rate'] as num?)?.toDouble() ?? 0.0;

    final images = auctionItem?['images'] as List? ?? [];
    final productTitle = productInventory?['title'] as String?;
    final productBrand = productInventory?['brand'] as String?;
    final productModel = productInventory?['model'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _getStatusColor(commissionStatus).withAlpha(51),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Product image
              Container(
                width: 60.0,
                height: 60.0,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _buildProductImage(images),
              ),

              const SizedBox(width: 12.0),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productTitle ?? title,
                      style: GoogleFonts.inter(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    if (productBrand != null || productModel != null)
                      Text(
                        '${productBrand ?? ''} ${productModel ?? ''}'.trim(),
                        style: GoogleFonts.inter(
                          fontSize: 14.0,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 4.0),
                    _buildStatusBadge(commissionStatus),
                  ],
                ),
              ),

              // Commission amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+${commissionAmount.toString()}',
                    style: GoogleFonts.inter(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(commissionStatus),
                    ),
                  ),
                  Text(
                    'credits',
                    style: GoogleFonts.inter(
                      fontSize: 12.0,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12.0),

          // Transaction details
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildDetailItem(
                      'Sale Price', '${finalSalePrice.toString()} credits'),
                ),
                Container(
                  width: 1.0,
                  height: 30.0,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: _buildDetailItem(
                      'Commission Rate', '${(commissionRate * 100).toInt()}%'),
                ),
                Container(
                  width: 1.0,
                  height: 30.0,
                  color: Colors.grey.shade300,
                ),
                Expanded(
                  child: _buildDetailItem('Date', _formatDate(earnedAt)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(List images) {
    if (images.isEmpty) {
      return Icon(
        Icons.inventory_2,
        color: Colors.grey.shade400,
        size: 24.0,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: CachedNetworkImage(
        imageUrl: images.first.toString(),
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade100,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: Colors.grey.shade400,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Icon(
          Icons.image_not_supported,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withAlpha(26),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        _getStatusText(status),
        style: GoogleFonts.inter(
          fontSize: 12.0,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.0,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'processing':
        return Colors.blue.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'PAID';
      case 'pending':
        return 'PENDING';
      case 'processing':
        return 'PROCESSING';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
