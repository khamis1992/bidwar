import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../controllers/create_auction_controller.dart';

/// Auction Form Widget
///
/// نموذج بيانات المزاد الأساسية
/// يتبع قواعد BidWar للتصميم والتحقق
class AuctionFormWidget extends StatefulWidget {
  final CreateAuctionController controller;
  final VoidCallback onNext;

  const AuctionFormWidget({
    super.key,
    required this.controller,
    required this.onNext,
  });

  @override
  State<AuctionFormWidget> createState() => _AuctionFormWidgetState();
}

class _AuctionFormWidgetState extends State<AuctionFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startingPriceController = TextEditingController();
  final _bidIncrementController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _titleController.text = widget.controller.title;
    _descriptionController.text = widget.controller.description;
    _startingPriceController.text = widget.controller.startingPrice > 0
        ? widget.controller.startingPrice.toString()
        : '';
    _bidIncrementController.text = widget.controller.bidIncrement > 1
        ? widget.controller.bidIncrement.toString()
        : '1';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startingPriceController.dispose();
    _bidIncrementController.dispose();
    super.dispose();
  }

  void _saveAndNext() {
    if (!_formKey.currentState!.validate()) return;

    // حفظ البيانات في Controller
    widget.controller.updateTitle(_titleController.text);
    widget.controller.updateDescription(_descriptionController.text);
    widget.controller
        .updateStartingPrice(int.parse(_startingPriceController.text));
    widget.controller
        .updateBidIncrement(int.parse(_bidIncrementController.text));

    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Auction Details',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryLight,
            ),
          ),

          SizedBox(height: 1.h),

          Text(
            'Provide basic information about your auction item',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w400,
            ),
          ),

          SizedBox(height: 4.h),

          // Title Field
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Auction Title *',
              hintText: 'Enter a descriptive title',
              prefixIcon: Icon(Icons.title),
              helperText: 'Be specific and descriptive (3-100 characters)',
            ),
            maxLength: 100,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Title is required';
              }
              if (value.trim().length < 3) {
                return 'Title must be at least 3 characters long';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),

          SizedBox(height: 3.h),

          // Description Field
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description *',
              hintText: 'Describe your item in detail',
              prefixIcon: Icon(Icons.description),
              helperText:
                  'Include condition, features, and any important details',
            ),
            maxLines: 4,
            maxLength: 1000,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Description is required';
              }
              if (value.trim().length < 10) {
                return 'Description must be at least 10 characters long';
              }
              return null;
            },
            textInputAction: TextInputAction.next,
          ),

          SizedBox(height: 3.h),

          // Price Fields Row
          Row(
            children: [
              // Starting Price
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _startingPriceController,
                  decoration: InputDecoration(
                    labelText: 'Starting Price *',
                    hintText: '0',
                    prefixText: '\$',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Starting price is required';
                    }
                    final price = int.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Enter a valid price';
                    }
                    if (price > 1000000) {
                      return 'Price too high';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
              ),

              SizedBox(width: 4.w),

              // Bid Increment
              Expanded(
                child: TextFormField(
                  controller: _bidIncrementController,
                  decoration: InputDecoration(
                    labelText: 'Bid Step *',
                    hintText: '1',
                    prefixText: '\$',
                    prefixIcon: Icon(Icons.add),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bid step required';
                    }
                    final increment = int.tryParse(value);
                    if (increment == null || increment <= 0) {
                      return 'Enter valid step';
                    }

                    final startingPrice =
                        int.tryParse(_startingPriceController.text) ?? 0;
                    if (increment > startingPrice) {
                      return 'Step too high';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Timing Section
          Text(
            'Auction Timing',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryLight,
            ),
          ),

          SizedBox(height: 2.h),

          // Start Time
          _buildDateTimeField(
            label: 'Start Time *',
            value: widget.controller.startTime,
            onTap: () => _selectStartTime(),
            icon: Icons.schedule,
          ),

          SizedBox(height: 2.h),

          // End Time
          _buildDateTimeField(
            label: 'End Time *',
            value: widget.controller.endTime,
            onTap: () => _selectEndTime(),
            icon: Icons.event,
          ),

          // Duration Display
          if (widget.controller.auctionDuration != null) ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.borderLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 4.w,
                    color: AppTheme.textSecondaryLight,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Duration: ${_formatDuration(widget.controller.auctionDuration!)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 4.h),

          // Optional Fields Section
          Text(
            'Additional Information (Optional)',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryLight,
            ),
          ),

          SizedBox(height: 2.h),

          // Condition, Brand, Model Row
          Row(
            children: [
              // Condition
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Condition',
                    hintText: 'New, Used, etc.',
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                  onChanged: widget.controller.updateCondition,
                  textInputAction: TextInputAction.next,
                ),
              ),

              SizedBox(width: 3.w),

              // Brand
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Brand',
                    hintText: 'Apple, Samsung, etc.',
                    prefixIcon: Icon(Icons.business),
                  ),
                  onChanged: widget.controller.updateBrand,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Model Field
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Model',
              hintText: 'iPhone 15, Galaxy S24, etc.',
              prefixIcon: Icon(Icons.devices),
            ),
            onChanged: widget.controller.updateModel,
            textInputAction: TextInputAction.done,
          ),

          SizedBox(height: 6.h),

          // Next Button
          SizedBox(
            width: double.infinity,
            height: 7.h,
            child: ElevatedButton.icon(
              onPressed:
                  widget.controller.canProceedToImages() ? _saveAndNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryLight,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Icons.arrow_forward, size: 5.w),
              label: Text(
                'Next: Add Images',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderLight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.textSecondaryLight,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    value != null ? _formatDateTime(value) : 'Tap to select',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: value != null
                          ? AppTheme.primaryLight
                          : AppTheme.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: AppTheme.textSecondaryLight,
              size: 6.w,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartTime() async {
    final now = DateTime.now();
    final initialDate = widget.controller.startTime ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(now) ? initialDate : now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (time == null) return;

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    widget.controller.updateStartTime(selectedDateTime);
  }

  Future<void> _selectEndTime() async {
    final startTime = widget.controller.startTime;
    if (startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select start time first'),
          backgroundColor: AppTheme.warningLight,
        ),
      );
      return;
    }

    final minEndTime = startTime.add(const Duration(minutes: 30));
    final initialDate = widget.controller.endTime ?? minEndTime;

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate.isAfter(minEndTime) ? initialDate : minEndTime,
      firstDate: minEndTime,
      lastDate: startTime.add(const Duration(days: 30)),
    );

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (time == null) return;

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // التحقق من أن وقت النهاية بعد وقت البداية
    if (selectedDateTime.isBefore(minEndTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('End time must be at least 30 minutes after start time'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
      return;
    }

    widget.controller.updateEndTime(selectedDateTime);
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (dateOnly == today) {
      dateStr = 'Today';
    } else if (dateOnly == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return '$dateStr at $timeStr';
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} day${duration.inDays != 1 ? 's' : ''} ${duration.inHours % 24} hour${(duration.inHours % 24) != 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours != 1 ? 's' : ''} ${duration.inMinutes % 60} minute${(duration.inMinutes % 60) != 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} minute${duration.inMinutes != 1 ? 's' : ''}';
    }
  }
}
