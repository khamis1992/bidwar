import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/custom_image_widget.dart';

class ProductDisplayWidget extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onEdit;

  const ProductDisplayWidget({
    Key? key,
    required this.product,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final images = product['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images.first.toString() : null;
    final retailValue = (product['retail_value'] as int? ?? 0) / 100;
    final startingPrice = (product['starting_price'] as int? ?? 0) / 100;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: imageUrl != null
                      ? CustomImageWidget(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey.shade500,
                            size: 32,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['title'] ?? 'Unknown Product',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product['brand'] != null || product['model'] != null)
                      Text(
                        '${product['brand'] ?? ''} ${product['model'] ?? ''}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Price Information
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Retail: \$${retailValue.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Starting: \$${startingPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Edit Button
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ],
          ),
          if (product['description'] != null) ...[
            const SizedBox(height: 12),
            Text(
              product['description'],
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}