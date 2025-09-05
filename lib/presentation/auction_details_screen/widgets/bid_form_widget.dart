import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../features/auctions/domain/entities/auction_entity.dart';

/// Bid Form Widget
///
/// فورم لإدخال مبلغ المزايدة مع التحقق
/// يتبع قواعد BidWar للتصميم
class BidFormWidget extends StatefulWidget {
  final AuctionEntity auction;
  final bool isLoading;
  final Function(int) onPlaceBid;

  const BidFormWidget({
    super.key,
    required this.auction,
    required this.isLoading,
    required this.onPlaceBid,
  });

  @override
  State<BidFormWidget> createState() => _BidFormWidgetState();
}

class _BidFormWidgetState extends State<BidFormWidget>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _bidController = TextEditingController();

  late AnimationController _shakeAnimationController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeBidAmount();
  }

  void _setupAnimations() {
    _shakeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _shakeAnimationController,
        curve: Curves.elasticIn,
      ),
    );
  }

  void _initializeBidAmount() {
    // تعيين الحد الأدنى للمزايدة كقيمة افتراضية
    _bidController.text = widget.auction.nextMinimumBid.toString();
  }

  @override
  void dispose() {
    _bidController.dispose();
    _shakeAnimationController.dispose();
    super.dispose();
  }

  void _submitBid() {
    if (!_formKey.currentState!.validate()) {
      _shakeAnimationController.forward().then((_) {
        _shakeAnimationController.reverse();
      });
      return;
    }

    final bidAmount = int.tryParse(_bidController.text) ?? 0;
    widget.onPlaceBid(bidAmount);
  }

  void _setBidToMinimum() {
    setState(() {
      _bidController.text = widget.auction.nextMinimumBid.toString();
    });
  }

  void _incrementBid() {
    final currentBid =
        int.tryParse(_bidController.text) ?? widget.auction.nextMinimumBid;
    final newBid = currentBid + widget.auction.bidIncrement;

    setState(() {
      _bidController.text = newBid.toString();
    });
  }

  void _decrementBid() {
    final currentBid =
        int.tryParse(_bidController.text) ?? widget.auction.nextMinimumBid;
    final newBid = (currentBid - widget.auction.bidIncrement).clamp(
      widget.auction.nextMinimumBid,
      999999999,
    );

    setState(() {
      _bidController.text = newBid.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryLight.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.gavel,
                        color: AppTheme.primaryLight,
                        size: 5.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Place Your Bid',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryLight,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Minimum Bid Info
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.borderLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Minimum bid:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.textSecondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '\$${widget.auction.nextMinimumBid}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.primaryLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Bid Amount Input
                  Row(
                    children: [
                      // Decrement Button
                      IconButton(
                        onPressed: widget.isLoading ? null : _decrementBid,
                        icon: Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.borderLight,
                          foregroundColor: AppTheme.primaryLight,
                        ),
                      ),

                      // Bid Input Field
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: TextFormField(
                            controller: _bidController,
                            decoration: InputDecoration(
                              labelText: 'Bid Amount',
                              prefixText: '\$',
                              hintText: 'Enter bid amount',
                              suffixIcon: IconButton(
                                onPressed: _setBidToMinimum,
                                icon: Icon(Icons.refresh),
                                tooltip: 'Set to minimum',
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a bid amount';
                              }

                              final bidAmount = int.tryParse(value);
                              if (bidAmount == null) {
                                return 'Please enter a valid number';
                              }

                              if (bidAmount < widget.auction.nextMinimumBid) {
                                return 'Minimum bid is \$${widget.auction.nextMinimumBid}';
                              }

                              if (bidAmount > 10000000) {
                                return 'Bid amount too high';
                              }

                              return null;
                            },
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryLight,
                            ),
                          ),
                        ),
                      ),

                      // Increment Button
                      IconButton(
                        onPressed: widget.isLoading ? null : _incrementBid,
                        icon: Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: AppTheme.primaryLight,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Quick Bid Buttons
                  Text(
                    'Quick Bid Options',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 1.h),

                  Wrap(
                    spacing: 2.w,
                    children: [
                      _buildQuickBidChip(widget.auction.nextMinimumBid),
                      _buildQuickBidChip(
                        widget.auction.nextMinimumBid +
                            widget.auction.bidIncrement,
                      ),
                      _buildQuickBidChip(
                        widget.auction.nextMinimumBid +
                            (widget.auction.bidIncrement * 2),
                      ),
                      _buildQuickBidChip(
                        widget.auction.nextMinimumBid +
                            (widget.auction.bidIncrement * 5),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 7.h,
                    child: ElevatedButton.icon(
                      onPressed: widget.isLoading ? null : _submitBid,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryLight,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      icon:
                          widget.isLoading
                              ? SizedBox(
                                width: 5.w,
                                height: 5.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Icon(Icons.gavel, size: 5.w),
                      label: Text(
                        widget.isLoading ? 'Placing Bid...' : 'Place Bid',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Bid Information
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.borderLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 4.w,
                              color: AppTheme.textSecondaryLight,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Bidding Information',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 1.h),

                        Text(
                          '• Bid increment: \$${widget.auction.bidIncrement}\n'
                          '• Your bid must be at least \$${widget.auction.nextMinimumBid}\n'
                          '• Bids are binding and cannot be cancelled',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppTheme.textSecondaryLight,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickBidChip(int amount) {
    final isSelected = int.tryParse(_bidController.text) == amount;

    return GestureDetector(
      onTap: () {
        setState(() {
          _bidController.text = amount.toString();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppTheme.primaryLight
                  : AppTheme.borderLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryLight : AppTheme.borderLight,
            width: 1,
          ),
        ),
        child: Text(
          '\$${amount}',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.primaryLight,
          ),
        ),
      ),
    );
  }
}
