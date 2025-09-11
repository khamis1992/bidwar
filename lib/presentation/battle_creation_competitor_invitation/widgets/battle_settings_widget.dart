import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class BattleSettingsWidget extends StatelessWidget {
  final int battleDuration;
  final int minSupportThreshold;
  final DateTime scheduledStart;
  final Function(int) onDurationChanged;
  final Function(int) onThresholdChanged;
  final Function(DateTime) onStartTimeChanged;

  const BattleSettingsWidget({
    super.key,
    required this.battleDuration,
    required this.minSupportThreshold,
    required this.scheduledStart,
    required this.onDurationChanged,
    required this.onThresholdChanged,
    required this.onStartTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Battle Configuration',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Configure the rules and timing for your epic battle',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 4.h),

          // Battle Duration
          _buildSettingSection(
            'Battle Duration',
            'How long will the battle last?',
            _buildDurationSelector(),
          ),

          SizedBox(height: 4.h),

          // Start Time
          _buildSettingSection(
            'Start Time',
            'When should the battle begin?',
            _buildStartTimeSelector(context),
          ),

          SizedBox(height: 4.h),

          // Support Threshold
          _buildSettingSection(
            'Minimum Support Goal',
            'Support needed to declare a winner',
            _buildThresholdSelector(),
          ),

          SizedBox(height: 4.h),

          // Advanced Settings
          _buildAdvancedSettings(),
        ],
      ),
    );
  }

  Widget _buildSettingSection(
      String title, String description, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          description,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 2.h),
        content,
      ],
    );
  }

  Widget _buildDurationSelector() {
    final durations = [15, 30, 45, 60];

    return Column(
      children: [
        // Duration chips
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: durations.map((duration) {
            final isSelected = battleDuration == duration;
            return GestureDetector(
              onTap: () => onDurationChanged(duration),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange : Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey[600]!,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$duration',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[400],
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'min',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[400],
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 2.h),

        // Duration slider
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custom Duration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    '$battleDuration minutes',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Slider(
                value: battleDuration.toDouble(),
                min: 15,
                max: 120,
                divisions: 21,
                activeColor: Colors.orange,
                inactiveColor: Colors.grey[700],
                onChanged: (value) => onDurationChanged(value.round()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartTimeSelector(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Quick time options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickTimeChip('Now', DateTime.now()),
              _buildQuickTimeChip(
                  '1 Hour', DateTime.now().add(const Duration(hours: 1))),
              _buildQuickTimeChip(
                  '2 Hours', DateTime.now().add(const Duration(hours: 2))),
              _buildQuickTimeChip(
                  'Tomorrow', DateTime.now().add(const Duration(days: 1))),
            ],
          ),
          SizedBox(height: 2.h),

          // Custom time picker
          InkWell(
            onTap: () => _showDateTimePicker(context),
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[600]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.orange, size: 18.sp),
                      SizedBox(width: 3.w),
                      Text(
                        'Custom Time',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatDateTime(scheduledStart),
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 14.sp,
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

  Widget _buildQuickTimeChip(String label, DateTime time) {
    final isSelected =
        scheduledStart.difference(time).abs() < const Duration(minutes: 1);
    return GestureDetector(
      onTap: () => onStartTimeChanged(time),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[600]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildThresholdSelector() {
    final thresholds = [50, 100, 200, 500];

    return Column(
      children: [
        // Threshold chips
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: thresholds.map((threshold) {
            final isSelected = minSupportThreshold == threshold;
            return GestureDetector(
              onTap: () => onThresholdChanged(threshold),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange : Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey[600]!,
                  ),
                ),
                child: Text(
                  '$threshold',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[400],
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 2.h),

        // Threshold slider
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Custom Threshold',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                  Text(
                    '$minSupportThreshold support',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Slider(
                value: minSupportThreshold.toDouble(),
                min: 50,
                max: 1000,
                divisions: 19,
                activeColor: Colors.orange,
                inactiveColor: Colors.grey[700],
                onChanged: (value) => onThresholdChanged(value.round()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),

          // Battle rules preview
          _buildRuleItem('⚔️', 'TikTok-style split screen battle'),
          _buildRuleItem('👥', 'Viewers support their favorite competitor'),
          _buildRuleItem('🏆', 'Most support wins the battle'),
          _buildRuleItem('💰', 'Winner gets commission rewards'),
          _buildRuleItem('⏱️', 'Real-time battle progress'),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String emoji, String rule) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16.sp)),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              rule,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDateTimePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: scheduledStart,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.orange,
              surface: Colors.grey,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && context.mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(scheduledStart),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.orange,
                surface: Colors.grey,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        onStartTimeChanged(dateTime);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inMinutes < 5) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
