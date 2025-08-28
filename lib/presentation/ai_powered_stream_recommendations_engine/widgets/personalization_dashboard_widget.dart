import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class PersonalizationDashboardWidget extends StatefulWidget {
  final Map<String, dynamic> userPreferences;
  final Function(Map<String, dynamic>) onPreferencesUpdated;

  const PersonalizationDashboardWidget({
    Key? key,
    required this.userPreferences,
    required this.onPreferencesUpdated,
  }) : super(key: key);

  @override
  State<PersonalizationDashboardWidget> createState() =>
      _PersonalizationDashboardWidgetState();
}

class _PersonalizationDashboardWidgetState
    extends State<PersonalizationDashboardWidget> {
  late Map<String, dynamic> _localPreferences;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _localPreferences = Map<String, dynamic>.from(widget.userPreferences);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.all(16.h),
            children: [
              _buildCategoryPreferences(),
              SizedBox(height: 24),
              _buildPriceRange(),
              SizedBox(height: 24),
              _buildTimePreferences(),
              SizedBox(height: 24),
              _buildNotificationSettings(),
              SizedBox(height: 24),
              _buildRecommendationFrequency(),
              SizedBox(height: 24),
              _buildDiscoverySettings(),
            ],
          ),
        ),
        if (_hasChanges)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetChanges,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                SizedBox(width: 12.h),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryPreferences() {
    final categoryPrefs =
        _localPreferences['category_preferences'] as Map<String, dynamic>? ??
            {};
    final categories = [
      'Electronics',
      'Art & Collectibles',
      'Automotive',
      'Fashion',
      'Home & Garden',
      'Sports',
      'Books & Media',
      'Jewelry'
    ];

    return _buildSection(
      title: 'Category Preferences',
      subtitle: 'Adjust how much you\'re interested in each category',
      child: Column(
        children: categories.map((category) {
          final key = category
              .toLowerCase()
              .replaceAll(' ', '_')
              .replaceAll('&', 'and');
          final currentValue = _getPreferenceValue(categoryPrefs[key]);

          return Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.h, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPreferenceColor(currentValue).withAlpha(26),
                        borderRadius: BorderRadius.circular(12.h),
                      ),
                      child: Text(
                        _getPreferenceLabel(currentValue),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _getPreferenceColor(currentValue),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.h),
                  ),
                  child: Slider(
                    value: currentValue,
                    min: 0.0,
                    max: 3.0,
                    divisions: 3,
                    activeColor: _getPreferenceColor(currentValue),
                    onChanged: (value) {
                      setState(() {
                        final updatedCategoryPrefs =
                            Map<String, dynamic>.from(categoryPrefs);
                        updatedCategoryPrefs[key] = _getPreferenceString(value);
                        _localPreferences['category_preferences'] =
                            updatedCategoryPrefs;
                        _hasChanges = true;
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceRange() {
    final minPrice = (_localPreferences['price_range_min'] as int?) ?? 0;
    final maxPrice = (_localPreferences['price_range_max'] as int?) ?? 1000000;

    return _buildSection(
      title: 'Price Range',
      subtitle: 'Set your preferred price range for recommendations',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Min Price',
                    prefixText: '\$',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: minPrice.toString()),
                  onChanged: (value) {
                    final parsed = int.tryParse(value) ?? 0;
                    setState(() {
                      _localPreferences['price_range_min'] = parsed;
                      _hasChanges = true;
                    });
                  },
                ),
              ),
              SizedBox(width: 12.h),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Max Price',
                    prefixText: '\$',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.h),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: maxPrice.toString()),
                  onChanged: (value) {
                    final parsed = int.tryParse(value) ?? 1000000;
                    setState(() {
                      _localPreferences['price_range_max'] = parsed;
                      _hasChanges = true;
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Current range: \$${minPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} - \$${maxPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePreferences() {
    final preferredTimes =
        (_localPreferences['preferred_times'] as List?) ?? [];
    final timeOptions = ['Morning', 'Afternoon', 'Evening', 'Night'];

    return _buildSection(
      title: 'Preferred Times',
      subtitle: 'When do you usually browse auctions?',
      child: Wrap(
        spacing: 8.h,
        runSpacing: 8,
        children: timeOptions.map((time) {
          final isSelected = preferredTimes.contains(time.toLowerCase());
          return FilterChip(
            label: Text(time),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                final updatedTimes = List.from(preferredTimes);
                if (selected) {
                  updatedTimes.add(time.toLowerCase());
                } else {
                  updatedTimes.remove(time.toLowerCase());
                }
                _localPreferences['preferred_times'] = updatedTimes;
                _hasChanges = true;
              });
            },
            selectedColor: Colors.blue.withAlpha(51),
            checkmarkColor: Colors.blue,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    final notificationSettings =
        _localPreferences['notification_settings'] as Map<String, dynamic>? ??
            {};

    return _buildSection(
      title: 'Notifications',
      subtitle: 'Control when you receive recommendation notifications',
      child: Column(
        children: [
          _buildSwitchTile(
            'New Recommendations',
            'Get notified when new items match your preferences',
            notificationSettings['new_recommendations'] as bool? ?? true,
            (value) {
              setState(() {
                final updated = Map<String, dynamic>.from(notificationSettings);
                updated['new_recommendations'] = value;
                _localPreferences['notification_settings'] = updated;
                _hasChanges = true;
              });
            },
          ),
          _buildSwitchTile(
            'Price Drops',
            'Alert me when items in my watchlist drop in price',
            notificationSettings['price_drops'] as bool? ?? true,
            (value) {
              setState(() {
                final updated = Map<String, dynamic>.from(notificationSettings);
                updated['price_drops'] = value;
                _localPreferences['notification_settings'] = updated;
                _hasChanges = true;
              });
            },
          ),
          _buildSwitchTile(
            'Ending Soon',
            'Remind me about auctions ending soon',
            notificationSettings['ending_soon'] as bool? ?? true,
            (value) {
              setState(() {
                final updated = Map<String, dynamic>.from(notificationSettings);
                updated['ending_soon'] = value;
                _localPreferences['notification_settings'] = updated;
                _hasChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationFrequency() {
    final frequency =
        _localPreferences['recommendation_frequency'] as String? ?? 'medium';

    return _buildSection(
      title: 'Recommendation Frequency',
      subtitle: 'How often should we update your recommendations?',
      child: Column(
        children: ['low', 'medium', 'high'].map((level) {
          return RadioListTile<String>(
            title: Text(_getFrequencyLabel(level)),
            subtitle: Text(_getFrequencyDescription(level)),
            value: level,
            groupValue: frequency,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _localPreferences['recommendation_frequency'] = value;
                  _hasChanges = true;
                });
              }
            },
            activeColor: Colors.blue,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDiscoverySettings() {
    final discoveryEnabled =
        _localPreferences['discovery_mode_enabled'] as bool? ?? true;

    return _buildSection(
      title: 'Discovery Mode',
      subtitle: 'Help us suggest items outside your usual preferences',
      child: _buildSwitchTile(
        'Enable Discovery',
        'Show recommendations for items you might not normally consider',
        discoveryEnabled,
        (value) {
          setState(() {
            _localPreferences['discovery_mode_enabled'] = value;
            _hasChanges = true;
          });
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.h),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
      ],
    );
  }

  void _saveChanges() {
    widget.onPreferencesUpdated(_localPreferences);
    setState(() {
      _hasChanges = false;
    });
  }

  void _resetChanges() {
    setState(() {
      _localPreferences = Map<String, dynamic>.from(widget.userPreferences);
      _hasChanges = false;
    });
  }

  double _getPreferenceValue(dynamic value) {
    switch (value) {
      case 'critical':
        return 3.0;
      case 'high':
        return 2.0;
      case 'medium':
        return 1.0;
      case 'low':
      default:
        return 0.0;
    }
  }

  String _getPreferenceString(double value) {
    switch (value.round()) {
      case 3:
        return 'critical';
      case 2:
        return 'high';
      case 1:
        return 'medium';
      case 0:
      default:
        return 'low';
    }
  }

  String _getPreferenceLabel(double value) {
    switch (value.round()) {
      case 3:
        return 'Critical';
      case 2:
        return 'High';
      case 1:
        return 'Medium';
      case 0:
      default:
        return 'Low';
    }
  }

  Color _getPreferenceColor(double value) {
    switch (value.round()) {
      case 3:
        return Colors.red.shade600;
      case 2:
        return Colors.orange.shade600;
      case 1:
        return Colors.blue.shade600;
      case 0:
      default:
        return Colors.grey.shade500;
    }
  }

  String _getFrequencyLabel(String frequency) {
    switch (frequency) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return 'Medium';
    }
  }

  String _getFrequencyDescription(String frequency) {
    switch (frequency) {
      case 'high':
        return 'Update recommendations every hour';
      case 'medium':
        return 'Update recommendations every 6 hours';
      case 'low':
        return 'Update recommendations daily';
      default:
        return 'Update recommendations every 6 hours';
    }
  }
}