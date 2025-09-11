import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/product_inventory.dart';
import '../../../models/user_profile.dart';
import '../../../models/creator_tier.dart';
import '../../../services/product_service.dart';

class ProductDetailModalWidget extends StatefulWidget {
  final ProductInventory product;
  final UserProfile currentUser;
  final CreatorTier currentTier;

  const ProductDetailModalWidget({
    Key? key,
    required this.product,
    required this.currentUser,
    required this.currentTier,
  }) : super(key: key);

  @override
  State<ProductDetailModalWidget> createState() =>
      _ProductDetailModalWidgetState();
}

class _ProductDetailModalWidgetState extends State<ProductDetailModalWidget> {
  bool _isSelecting = false;
  int _currentImageIndex = 0;

  bool get _canSelect {
    return (widget.product.isAccessible ?? false) &&
        widget.currentUser.creditBalance >= widget.product.minCreditRequirement;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12.0),
                width: 40.0,
                height: 4.0,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image carousel
                      _buildImageCarousel(),

                      // Product details
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and tier
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.product.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 6.0),
                                  decoration: BoxDecoration(
                                    color: _getTierColor(),
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  child: Text(
                                    widget.product.requiredTier.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8.0),

                            // Brand/Model
                            if (widget.product.brandModel.isNotEmpty)
                              Text(
                                widget.product.brandModel,
                                style: GoogleFonts.inter(
                                  fontSize: 18.0,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                            const SizedBox(height: 16.0),

                            // Commission info
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade50,
                                    Colors.green.shade25 ??
                                        Colors.green.shade50,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12.0),
                                border:
                                    Border.all(color: Colors.green.shade200),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.attach_money,
                                          color: Colors.green.shade700,
                                          size: 24.0),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        'Commission Potential',
                                        style: GoogleFonts.inter(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Retail Value:',
                                        style: GoogleFonts.inter(
                                          fontSize: 14.0,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        '${widget.product.retailValue.toString()} credits',
                                        style: GoogleFonts.inter(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4.0),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Your Commission (${widget.currentTier.commissionRateText}):',
                                        style: GoogleFonts.inter(
                                          fontSize: 14.0,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        '${ProductService.calculatePotentialCommission(widget.product.retailValue, widget.currentTier.commissionRate)} credits',
                                        style: GoogleFonts.inter(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20.0),

                            // Description
                            Text(
                              'Description',
                              style: GoogleFonts.inter(
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              widget.product.description,
                              style: GoogleFonts.inter(
                                fontSize: 14.0,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 20.0),

                            // Specifications
                            if (widget.product.specifications.isNotEmpty) ...[
                              Text(
                                'Specifications',
                                style: GoogleFonts.inter(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              _buildSpecifications(),
                              const SizedBox(height: 20.0),
                            ],

                            // Requirements
                            _buildRequirements(),

                            const SizedBox(height: 80.0), // Space for button
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Selection button
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10.0,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _canSelect && !_isSelecting ? _selectProduct : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canSelect
                          ? Colors.blue.shade600
                          : Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: _isSelecting
                        ? const SizedBox(
                            height: 20.0,
                            width: 20.0,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _canSelect
                                ? 'Select for Auction'
                                : 'Insufficient Credits',
                            style: GoogleFonts.inter(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageCarousel() {
    final images = widget.product.images;

    return Container(
      height: 300.0,
      child: images.isEmpty
          ? Container(
              color: Colors.grey.shade100,
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: 64.0,
                  color: Colors.grey.shade400,
                ),
              ),
            )
          : PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return CachedNetworkImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade100,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade100,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64.0,
                      color: Colors.grey.shade400,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSpecifications() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.product.specifications.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    '${entry.key}:',
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    entry.value.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 14.0,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRequirements() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _canSelect ? Colors.blue.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: _canSelect ? Colors.blue.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _canSelect ? Icons.check_circle : Icons.error,
                color: _canSelect ? Colors.blue.shade600 : Colors.red.shade600,
                size: 20.0,
              ),
              const SizedBox(width: 8.0),
              Text(
                'Requirements',
                style: GoogleFonts.inter(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color:
                      _canSelect ? Colors.blue.shade700 : Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          _buildRequirementRow(
            'Minimum Credits:',
            '${widget.product.minCreditRequirement.toString()} credits',
            widget.currentUser.creditBalance >=
                widget.product.minCreditRequirement,
          ),
          _buildRequirementRow(
            'Required Tier:',
            widget.product.requiredTier.toUpperCase(),
            widget.currentTier.canAccessProduct(
                widget.product.minCreditRequirement,
                widget.product.requiredTier),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String label, String value, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check : Icons.close,
            size: 16.0,
            color: isMet ? Colors.green.shade600 : Colors.red.shade600,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.0,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectProduct() async {
    if (!_canSelect || _isSelecting) return;

    setState(() {
      _isSelecting = true;
    });

    try {
      await ProductService.selectProductForAuction(
        widget.product.id,
        scheduledStartTime: DateTime.now().add(const Duration(hours: 1)),
        notes: 'Selected for live auction',
      );

      Navigator.of(context).pop(true); // Return success
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select product: $error'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      setState(() {
        _isSelecting = false;
      });
    }
  }

  Color _getTierColor() {
    switch (widget.product.requiredTier.toLowerCase()) {
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
