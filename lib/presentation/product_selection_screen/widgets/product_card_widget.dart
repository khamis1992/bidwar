import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/product_inventory.dart';

class ProductCardWidget extends StatelessWidget {
  final ProductInventory product;
  final VoidCallback onTap;

  const ProductCardWidget({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isAccessible = product.isAccessible ?? true;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
          border: !isAccessible
              ? Border.all(color: Colors.red.shade200, width: 1.0)
              : null,
        ),
        child: Stack(
          children: [
            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16.0)),
                      color: Colors.grey.shade100,
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16.0)),
                      child: product.primaryImage.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: product.primaryImage,
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
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade100,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey.shade400,
                                  size: 32.0,
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade100,
                              child: Icon(
                                Icons.inventory_2,
                                color: Colors.grey.shade400,
                                size: 32.0,
                              ),
                            ),
                    ),
                  ),
                ),

                // Product info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          product.title,
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: isAccessible
                                ? Colors.black
                                : Colors.grey.shade500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4.0),

                        // Brand/Model
                        if (product.brandModel.isNotEmpty)
                          Text(
                            product.brandModel,
                            style: GoogleFonts.inter(
                              fontSize: 12.0,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                        const Spacer(),

                        // Commission potential
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            product.commissionText,
                            style: GoogleFonts.inter(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Tier badge
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: _getTierColor(),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  product.requiredTier.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Featured badge
            if (product.isFeatured)
              Positioned(
                top: 8.0,
                left: 8.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'FEATURED',
                    style: GoogleFonts.inter(
                      fontSize: 9.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Lock overlay for inaccessible products
            if (!isAccessible)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(77),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 32.0,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Insufficient\nCredits',
                          style: GoogleFonts.inter(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor() {
    switch (product.requiredTier.toLowerCase()) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'platinum':
        return const Color(0xFF76D7C4);
      default:
        return Colors.grey.shade500;
    }
  }
}
