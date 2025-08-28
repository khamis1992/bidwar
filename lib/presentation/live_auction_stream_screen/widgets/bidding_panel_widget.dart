import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BiddingPanelWidget extends StatefulWidget {
  final int currentBid;
  final TextEditingController bidController;
  final VoidCallback onPlaceBid;
  final VoidCallback onClose;

  const BiddingPanelWidget({
    Key? key,
    required this.currentBid,
    required this.bidController,
    required this.onPlaceBid,
    required this.onClose,
  }) : super(key: key);

  @override
  State<BiddingPanelWidget> createState() => _BiddingPanelWidgetState();
}

class _BiddingPanelWidgetState extends State<BiddingPanelWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();

    // Set initial bid value
    widget.bidController.text = (widget.currentBid + 50).toString();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _incrementBid(int amount) {
    final currentBidAmount =
        int.tryParse(widget.bidController.text) ?? widget.currentBid;
    widget.bidController.text = (currentBidAmount + amount).toString();
  }

  void _submitBid() {
    HapticFeedback.mediumImpact();
    widget.onPlaceBid();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: Colors.black54,
          child: GestureDetector(
            onTap: () {}, // Prevent closing when tapping the panel
            child: SlideTransition(
              position: _slideAnimation,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(77),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            const Icon(
                              Icons.gavel,
                              color: Colors.blue,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Place Your Bid',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: widget.onClose,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Current bid info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Current Highest Bid:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '\$${widget.currentBid}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Bid amount input
                        const Text(
                          'Your Bid Amount',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Text(
                              '\$',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: widget.bidController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: '0',
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Quick bid buttons
                        const Text(
                          'Quick Increment',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: _QuickBidButton(
                                label: '+\$25',
                                onTap: () => _incrementBid(25),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _QuickBidButton(
                                label: '+\$50',
                                onTap: () => _incrementBid(50),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _QuickBidButton(
                                label: '+\$100',
                                onTap: () => _incrementBid(100),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Place bid button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              final bidAmount =
                                  int.tryParse(widget.bidController.text);
                              if (bidAmount != null &&
                                  bidAmount > widget.currentBid) {
                                _submitBid();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.gavel, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'PLACE BID',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Warning text
                        const SizedBox(height: 12),
                        const Text(
                          'By placing a bid, you agree to purchase this item if you win.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickBidButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickBidButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blue[700],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
