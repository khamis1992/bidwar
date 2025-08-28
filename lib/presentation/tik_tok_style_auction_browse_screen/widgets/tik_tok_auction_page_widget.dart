import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sizer/sizer.dart';

import '../../../models/auction_item.dart';

class TikTokAuctionPageWidget extends StatefulWidget {
  final AuctionItem auction;
  final VoidCallback? onDoubleTap;

  const TikTokAuctionPageWidget({
    super.key,
    required this.auction,
    this.onDoubleTap,
  });

  @override
  State<TikTokAuctionPageWidget> createState() =>
      _TikTokAuctionPageWidgetState();
}

class _TikTokAuctionPageWidgetState extends State<TikTokAuctionPageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;
  bool _showHeart = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.elasticOut,
    ));

    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showHeart = false);
        _heartAnimationController.reset();
      }
    });
  }

  void _handleDoubleTap() {
    setState(() => _showHeart = true);
    _heartAnimationController.forward();
    widget.onDoubleTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image with gradient overlay
            _buildBackgroundImage(),

            // Gradient overlays for better text readability
            _buildGradientOverlays(),

            // Double-tap heart animation
            if (_showHeart) _buildHeartAnimation(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return CachedNetworkImage(
      imageUrl: widget.auction.mainImage,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey.shade900,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                size: 60.sp,
                color: Colors.white54,
              ),
              SizedBox(height: 2.h),
              Text(
                widget.auction.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade900,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: 60.sp,
                color: Colors.white54,
              ),
              SizedBox(height: 2.h),
              Text(
                widget.auction.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 1.h),
              Text(
                'Image not available',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlays() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(77), // Top
            Colors.transparent, // Middle
            Colors.transparent, // Middle
            Colors.black.withAlpha(179), // Bottom
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildHeartAnimation() {
    return Center(
      child: AnimatedBuilder(
        animation: _heartAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _heartAnimation.value,
            child: Opacity(
              opacity: 1.0 - (_heartAnimation.value - 0.2).clamp(0.0, 1.0),
              child: Icon(
                Icons.favorite,
                size: 100.sp,
                color: Colors.red,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }
}
