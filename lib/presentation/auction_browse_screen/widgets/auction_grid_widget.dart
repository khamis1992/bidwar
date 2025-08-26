import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/auction_item.dart';
import './auction_card_widget.dart';

class AuctionGridWidget extends StatelessWidget {
  final List<AuctionItem> auctions;
  final Function(AuctionItem) onAuctionTap;

  const AuctionGridWidget({
    super.key,
    required this.auctions,
    required this.onAuctionTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(2.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(),
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
        childAspectRatio: 0.75,
      ),
      itemCount: auctions.length,
      itemBuilder: (context, index) {
        final auction = auctions[index];
        return AuctionCardWidget(
          auction: auction,
          onTap: () => onAuctionTap(auction),
        );
      },
    );
  }

  int _getCrossAxisCount() {
    // Responsive grid based on screen width
    final screenWidth = 100.w;
    if (screenWidth > 80) {
      return 3; // Tablet landscape
    } else if (screenWidth > 60) {
      return 2; // Tablet portrait / large phone landscape
    } else {
      return 2; // Phone portrait
    }
  }
}
