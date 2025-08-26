import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation item data for bottom navigation
class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Custom Bottom Navigation Bar implementing Contemporary Competitive Minimalism
/// for the auction application with clear visual hierarchy and trust elements
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double elevation;

  // Hardcoded navigation items for auction app
  static const List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.gavel_outlined,
      activeIcon: Icons.gavel,
      label: 'Auctions',
      route: '/auction-browse-screen',
    ),
    BottomNavItem(
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
      label: 'Watchlist',
      route: '/watchlist-screen',
    ),
    BottomNavItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      label: 'Credits',
      route: '/credit-management-screen',
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profile',
      route: '/user-profile-screen',
    ),
  ];

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == currentIndex;

              return Expanded(
                child: _BottomNavButton(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => _handleTap(context, index),
                  selectedColor: selectedItemColor ?? colorScheme.primary,
                  unselectedColor: unselectedItemColor ??
                      colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, int index) {
    HapticFeedback.lightImpact();

    if (onTap != null) {
      onTap!(index);
    } else {
      // Default navigation behavior
      final route = _navItems[index].route;
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
    }
  }
}

/// Individual bottom navigation button with animation and feedback
class _BottomNavButton extends StatefulWidget {
  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const _BottomNavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  State<_BottomNavButton> createState() => _BottomNavButtonState();
}

class _BottomNavButtonState extends State<_BottomNavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isSelected) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(_BottomNavButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.isSelected ? widget.selectedColor : widget.unselectedColor;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with selection animation
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(4),
                    decoration: widget.isSelected
                        ? BoxDecoration(
                            color: widget.selectedColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: Icon(
                      widget.isSelected
                          ? widget.item.activeIcon
                          : widget.item.icon,
                      size: 24,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Label with fade animation
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      widget.item.label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Specialized bottom bar variants for different contexts
class CustomAuctionBottomBar extends CustomBottomBar {
  const CustomAuctionBottomBar({
    super.key,
    required super.currentIndex,
    super.onTap,
  });
}

/// Floating bottom bar variant for special auction moments
class CustomFloatingBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final bool showBidButton;
  final VoidCallback? onBidTap;
  final String? bidAmount;

  const CustomFloatingBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.showBidButton = false,
    this.onBidTap,
    this.bidAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Navigation items (condensed)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: CustomBottomBar._navItems
                      .take(3)
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = index == currentIndex;

                    return _CompactNavButton(
                      item: item,
                      isSelected: isSelected,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (onTap != null) {
                          onTap!(index);
                        } else {
                          Navigator.pushNamed(context, item.route);
                        }
                      },
                      selectedColor: colorScheme.primary,
                      unselectedColor:
                          colorScheme.onSurface.withValues(alpha: 0.6),
                    );
                  }).toList(),
                ),
              ),

              // Bid button if enabled
              if (showBidButton) ...[
                const SizedBox(width: 16),
                _BidButton(
                  onTap: onBidTap ??
                      () {
                        HapticFeedback.mediumImpact();
                        Navigator.pushNamed(context, '/auction-detail-screen');
                      },
                  amount: bidAmount,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact navigation button for floating bottom bar
class _CompactNavButton extends StatelessWidget {
  final BottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  const _CompactNavButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: isSelected
            ? BoxDecoration(
                color: selectedColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Icon(
          isSelected ? item.activeIcon : item.icon,
          size: 24,
          color: isSelected ? selectedColor : unselectedColor,
        ),
      ),
    );
  }
}

/// Specialized bid button for active auctions
class _BidButton extends StatelessWidget {
  final VoidCallback onTap;
  final String? amount;

  const _BidButton({
    required this.onTap,
    this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.gavel,
              size: 20,
              color: colorScheme.onSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              amount != null ? 'Bid $amount' : 'Place Bid',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}