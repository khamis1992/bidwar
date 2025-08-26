import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget implementing Contemporary Competitive Minimalism
/// for the auction application with trust-building elements and clear hierarchy
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool showNotificationBadge;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final bool showSearchAction;
  final VoidCallback? onSearchTap;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.showSearchAction = false,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? colorScheme.onSurface,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: theme.brightness,
      ),
      leading: leading ??
          (showBackButton && Navigator.of(context).canPop()
              ? IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 20,
                    color: foregroundColor ?? colorScheme.onSurface,
                  ),
                  onPressed: onBackPressed ??
                      () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                )
              : null),
      actions: _buildActions(context),
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    List<Widget> actionWidgets = [];

    // Add search action if enabled
    if (showSearchAction) {
      actionWidgets.add(
        IconButton(
          icon: Icon(
            Icons.search,
            size: 24,
            color: foregroundColor ?? colorScheme.onSurface,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            if (onSearchTap != null) {
              onSearchTap!();
            } else {
              // Default search navigation
              Navigator.pushNamed(context, '/auction-browse-screen');
            }
          },
        ),
      );
    }

    // Add notification action with badge if enabled
    if (showNotificationBadge) {
      actionWidgets.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: foregroundColor ?? colorScheme.onSurface,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (onNotificationTap != null) {
                    onNotificationTap!();
                  } else {
                    // Default notification navigation
                    Navigator.pushNamed(context, '/user-profile-screen');
                  }
                },
              ),
              if (notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      notificationCount > 99
                          ? '99+'
                          : notificationCount.toString(),
                      style: GoogleFonts.inter(
                        color: colorScheme.onSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Add custom actions if provided
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return actionWidgets.isNotEmpty ? actionWidgets : null;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Specialized AppBar variants for different auction app sections
class CustomAuctionAppBar extends CustomAppBar {
  const CustomAuctionAppBar({
    super.key,
    required super.title,
    super.showNotificationBadge = true,
    super.notificationCount = 0,
    super.showSearchAction = true,
  });
}

class CustomProfileAppBar extends CustomAppBar {
  const CustomProfileAppBar({
    super.key,
    required super.title,
    super.showBackButton = false,
    super.actions,
  });
}

class CustomDetailAppBar extends CustomAppBar {
  final VoidCallback? onWatchlistTap;
  final bool isWatchlisted;

  const CustomDetailAppBar({
    super.key,
    required super.title,
    this.onWatchlistTap,
    this.isWatchlisted = false,
  });

  @override
  List<Widget>? _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return [
      IconButton(
        icon: Icon(
          isWatchlisted ? Icons.favorite : Icons.favorite_border,
          size: 24,
          color: isWatchlisted
              ? colorScheme.secondary
              : (foregroundColor ?? colorScheme.onSurface),
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          if (onWatchlistTap != null) {
            onWatchlistTap!();
          } else {
            Navigator.pushNamed(context, '/watchlist-screen');
          }
        },
      ),
      IconButton(
        icon: Icon(
          Icons.share_outlined,
          size: 24,
          color: foregroundColor ?? colorScheme.onSurface,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          // Share functionality would be implemented here
        },
      ),
      const SizedBox(width: 8),
    ];
  }
}
