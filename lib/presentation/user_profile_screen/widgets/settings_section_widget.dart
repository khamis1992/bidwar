import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SettingsSectionWidget extends StatefulWidget {
  final Map<String, bool> settings;
  final Function(String, bool) onSettingChanged;

  const SettingsSectionWidget({
    super.key,
    required this.settings,
    required this.onSettingChanged,
  });

  @override
  State<SettingsSectionWidget> createState() => _SettingsSectionWidgetState();
}

class _SettingsSectionWidgetState extends State<SettingsSectionWidget> {
  late Map<String, bool> _currentSettings;

  @override
  void initState() {
    super.initState();
    _currentSettings = Map.from(widget.settings);
  }

  void _updateSetting(String key, bool value) {
    setState(() {
      _currentSettings[key] = value;
    });
    widget.onSettingChanged(key, value);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Settings",
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Notification Settings
          _SettingsGroup(
            title: "Notifications",
            children: [
              _SettingsTile(
                icon: 'notifications',
                title: "Push Notifications",
                subtitle: "Receive auction updates and alerts",
                value: _currentSettings["pushNotifications"] ?? true,
                onChanged: (value) =>
                    _updateSetting("pushNotifications", value),
              ),
              _SettingsTile(
                icon: 'volume_up',
                title: "Sound Effects",
                subtitle: "Play sounds for bids and wins",
                value: _currentSettings["soundEffects"] ?? true,
                onChanged: (value) => _updateSetting("soundEffects", value),
              ),
              _SettingsTile(
                icon: 'vibration',
                title: "Haptic Feedback",
                subtitle: "Feel vibrations for interactions",
                value: _currentSettings["hapticFeedback"] ?? true,
                onChanged: (value) => _updateSetting("hapticFeedback", value),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Appearance Settings
          _SettingsGroup(
            title: "Appearance",
            children: [
              _SettingsTile(
                icon: 'dark_mode',
                title: "Dark Theme",
                subtitle: "Switch to dark mode",
                value: _currentSettings["darkTheme"] ?? false,
                onChanged: (value) => _updateSetting("darkTheme", value),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Account Management
          _SettingsGroup(
            title: "Account",
            children: [
              _AccountTile(
                icon: 'lock',
                title: "Change Password",
                subtitle: "Update your account password",
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showChangePasswordDialog(context);
                },
              ),
              _AccountTile(
                icon: 'email',
                title: "Update Email",
                subtitle: "Change your email address",
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showUpdateEmailDialog(context);
                },
              ),
              _AccountTile(
                icon: 'fingerprint',
                title: "Biometric Authentication",
                subtitle: "Use Face ID or fingerprint",
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showBiometricSetupDialog(context);
                },
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Logout Button
          Container(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showLogoutDialog(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red),
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'logout',
                    color: Colors.red,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    "Logout",
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm New Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Password updated successfully")),
              );
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showUpdateEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Update Email"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: "New Email Address",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Email updated successfully")),
              );
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showBiometricSetupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Biometric Authentication"),
        content: Text(
            "Enable biometric authentication for quick and secure access to your account."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Biometric authentication enabled")),
              );
            },
            child: Text("Enable"),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout from your account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login-screen',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AccountTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.5),
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }
}
