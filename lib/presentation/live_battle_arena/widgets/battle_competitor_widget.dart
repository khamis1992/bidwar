import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BattleCompetitorWidget extends StatefulWidget {
  final Map<String, dynamic> competitor;
  final Map<String, dynamic> product;
  final int supportCount;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLeft;

  const BattleCompetitorWidget({
    super.key,
    required this.competitor,
    required this.product,
    required this.supportCount,
    required this.isSelected,
    required this.onTap,
    required this.isLeft,
  });

  @override
  State<BattleCompetitorWidget> createState() => _BattleCompetitorWidgetState();
}

class _BattleCompetitorWidgetState extends State<BattleCompetitorWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _supportController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _supportAnimation;

  int _previousSupportCount = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _supportController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _supportAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _supportController,
      curve: Curves.elasticOut,
    ));

    _previousSupportCount = widget.supportCount;

    if (widget.isSelected) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BattleCompetitorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger support animation when count increases
    if (widget.supportCount > _previousSupportCount) {
      _supportController.forward().then((_) {
        _supportController.reset();
      });
    }
    _previousSupportCount = widget.supportCount;

    // Handle selection animation
    if (widget.isSelected && !oldWidget.isSelected) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _supportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isSelected ? _pulseAnimation.value : 1.0,
            child: Stack(
              children: [
                // Background gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: widget.isLeft
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      end: widget.isLeft
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      colors: widget.isSelected
                          ? [
                              Colors.blue.withAlpha(77),
                              Colors.purple.withAlpha(77),
                            ]
                          : [
                              Colors.black.withAlpha(179),
                              Colors.black.withAlpha(128),
                            ],
                    ),
                  ),
                ),

                // Main content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Competitor profile section
                      _buildCompetitorProfile(),

                      const SizedBox(height: 16),

                      // Product showcase
                      Expanded(
                        child: _buildProductShowcase(),
                      ),

                      const SizedBox(height: 16),

                      // Support count display
                      _buildSupportDisplay(),
                    ],
                  ),
                ),

                // Selection indicator
                if (widget.isSelected)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                    ),
                  ),

                // Support animation overlay
                AnimatedBuilder(
                  animation: _supportAnimation,
                  builder: (context, child) {
                    if (_supportAnimation.value == 0) return const SizedBox();

                    return Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.yellow.withOpacity(
                            0.3 * (1 - _supportAnimation.value),
                          ),
                        ),
                        child: Center(
                          child: Transform.scale(
                            scale: 0.5 + (_supportAnimation.value * 1.5),
                            child: Opacity(
                              opacity: 1 - _supportAnimation.value,
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 100,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompetitorProfile() {
    return Row(
      mainAxisAlignment:
          widget.isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (!widget.isLeft) ...[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.competitor['full_name'] ?? 'Competitor',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.end,
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],

        // Profile picture
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[800],
          backgroundImage: widget.competitor['profile_picture_url'] != null
              ? CachedNetworkImageProvider(
                  widget.competitor['profile_picture_url'])
              : null,
          child: widget.competitor['profile_picture_url'] == null
              ? Text(
                  (widget.competitor['full_name'] ?? 'C')[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),

        if (widget.isLeft) ...[
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.competitor['full_name'] ?? 'Competitor',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProductShowcase() {
    final images = widget.product['images'] as List?;
    final productImage = images?.isNotEmpty == true ? images!.first : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(51),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                ),
                child: productImage != null
                    ? CachedNetworkImage(
                        imageUrl: productImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image_not_supported,
                          color: Colors.white54,
                          size: 50,
                        ),
                      )
                    : const Icon(
                        Icons.shopping_bag,
                        color: Colors.white54,
                        size: 60,
                      ),
              ),
            ),

            // Product info
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.product['title'] ?? 'Product',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${widget.product['starting_price']?.toString() ?? '0'}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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

  Widget _buildSupportDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            widget.supportCount.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Support',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
