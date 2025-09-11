import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BattleLeaderboardWidget extends StatefulWidget {
  final Map<String, dynamic> competitor1;
  final Map<String, dynamic> competitor2;
  final int competitor1Support;
  final int competitor2Support;

  const BattleLeaderboardWidget({
    super.key,
    required this.competitor1,
    required this.competitor2,
    required this.competitor1Support,
    required this.competitor2Support,
  });

  @override
  State<BattleLeaderboardWidget> createState() =>
      _BattleLeaderboardWidgetState();
}

class _BattleLeaderboardWidgetState extends State<BattleLeaderboardWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _competitor1Animation;
  late Animation<double> _competitor2Animation;

  int _previousSupport1 = 0;
  int _previousSupport2 = 0;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _updateAnimations();
    _progressController.forward();

    _previousSupport1 = widget.competitor1Support;
    _previousSupport2 = widget.competitor2Support;
  }

  void _updateAnimations() {
    final totalSupport = widget.competitor1Support + widget.competitor2Support;
    final competitor1Percentage =
        totalSupport > 0 ? widget.competitor1Support / totalSupport : 0.5;
    final competitor2Percentage =
        totalSupport > 0 ? widget.competitor2Support / totalSupport : 0.5;

    _competitor1Animation = Tween<double>(
      begin: 0.0,
      end: competitor1Percentage,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _competitor2Animation = Tween<double>(
      begin: 0.0,
      end: competitor2Percentage,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(BattleLeaderboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.competitor1Support != _previousSupport1 ||
        widget.competitor2Support != _previousSupport2) {
      _progressController.reset();
      _updateAnimations();
      _progressController.forward();

      _previousSupport1 = widget.competitor1Support;
      _previousSupport2 = widget.competitor2Support;
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  String _getLeaderStatus() {
    if (widget.competitor1Support > widget.competitor2Support) {
      return '${widget.competitor1['full_name']} is leading!';
    } else if (widget.competitor2Support > widget.competitor1Support) {
      return '${widget.competitor2['full_name']} is leading!';
    } else {
      return 'It\'s a tie!';
    }
  }

  Color _getLeaderColor() {
    if (widget.competitor1Support > widget.competitor2Support) {
      return Colors.blue;
    } else if (widget.competitor2Support > widget.competitor1Support) {
      return Colors.purple;
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(179),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha(51),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Leader status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getLeaderColor().withAlpha(51),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getLeaderColor(),
                width: 1,
              ),
            ),
            child: Text(
              _getLeaderStatus(),
              style: TextStyle(
                color: _getLeaderColor(),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Progress bar section
          Row(
            children: [
              // Competitor 1 info
              _buildCompetitorInfo(
                widget.competitor1,
                widget.competitor1Support,
                Colors.blue,
                true,
              ),

              const SizedBox(width: 16),

              // Progress bar
              Expanded(
                flex: 3,
                child: _buildProgressBar(),
              ),

              const SizedBox(width: 16),

              // Competitor 2 info
              _buildCompetitorInfo(
                widget.competitor2,
                widget.competitor2Support,
                Colors.purple,
                false,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Support difference indicator
          _buildSupportDifference(),
        ],
      ),
    );
  }

  Widget _buildCompetitorInfo(
    Map<String, dynamic> competitor,
    int support,
    Color color,
    bool isLeft,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment:
            isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLeft) ...[
                Text(
                  support.toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              CircleAvatar(
                radius: 16,
                backgroundColor: color.withAlpha(51),
                backgroundImage: competitor['profile_picture_url'] != null
                    ? CachedNetworkImageProvider(
                        competitor['profile_picture_url'])
                    : null,
                child: competitor['profile_picture_url'] == null
                    ? Text(
                        (competitor['full_name'] ?? 'C')[0].toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              if (isLeft) ...[
                const SizedBox(width: 8),
                Text(
                  support.toString(),
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            competitor['full_name'] ?? 'Competitor',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: isLeft ? TextAlign.left : TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(51),
        borderRadius: BorderRadius.circular(4),
      ),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return Stack(
            children: [
              // Competitor 1 progress
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 8,
                  width: (MediaQuery.of(context).size.width - 164) *
                      _competitor1Animation.value,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue, Colors.lightBlue],
                    ),
                    borderRadius:
                        BorderRadius.horizontal(left: Radius.circular(4)),
                  ),
                ),
              ),

              // Competitor 2 progress (from right)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: 8,
                  width: (MediaQuery.of(context).size.width - 164) *
                      _competitor2Animation.value,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.purpleAccent],
                    ),
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(4)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSupportDifference() {
    final difference =
        (widget.competitor1Support - widget.competitor2Support).abs();
    final leader = widget.competitor1Support > widget.competitor2Support
        ? widget.competitor1['full_name']
        : widget.competitor2['full_name'];

    if (difference == 0) {
      return const Text(
        'Perfect tie! Every vote counts!',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.trending_up,
          color: _getLeaderColor(),
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '$leader leads by $difference',
          style: TextStyle(
            color: _getLeaderColor(),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
