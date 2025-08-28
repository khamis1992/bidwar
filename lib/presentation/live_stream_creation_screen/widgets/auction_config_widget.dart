import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AuctionConfigWidget extends StatelessWidget {
  final List<dynamic> userAuctions;
  final String? selectedAuctionId;
  final Function(String?, Map<String, dynamic>?) onAuctionSelected;

  const AuctionConfigWidget({
    Key? key,
    required this.userAuctions,
    required this.selectedAuctionId,
    required this.onAuctionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Auction Item',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (userAuctions.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Text(
                'No active auctions available',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: userAuctions.asMap().entries.map((entry) {
                final index = entry.key;
                final auction = entry.value;
                final isSelected = selectedAuctionId == auction['id'];
                final images = auction['images'] as List<dynamic>? ?? [];
                final firstImage =
                    images.isNotEmpty ? images[0] as String : null;

                return InkWell(
                  onTap: () => onAuctionSelected(auction['id'], auction),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[50] : Colors.transparent,
                      border: index > 0
                          ? Border(top: BorderSide(color: Colors.grey[300]!))
                          : null,
                      borderRadius: index == 0
                          ? const BorderRadius.vertical(
                              top: Radius.circular(12))
                          : index == userAuctions.length - 1
                              ? const BorderRadius.vertical(
                                  bottom: Radius.circular(12))
                              : null,
                    ),
                    child: Row(
                      children: [
                        // Auction item image
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: firstImage != null
                              ? CachedNetworkImage(
                                  imageUrl: firstImage,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                )
                              : const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 30,
                                ),
                        ),

                        const SizedBox(width: 16),

                        // Auction details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                auction['title'] ?? 'Untitled Auction',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Starting: \$${auction['starting_price']?.toString() ?? '0'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Status: ${auction['status']?.toString().toUpperCase() ?? 'UNKNOWN'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: auction['status'] == 'live'
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Selection indicator
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
