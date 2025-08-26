import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateAuctionDialog extends StatefulWidget {
  final VoidCallback onAuctionCreated;

  const CreateAuctionDialog({
    Key? key,
    required this.onAuctionCreated,
  }) : super(key: key);

  @override
  State<CreateAuctionDialog> createState() => _CreateAuctionDialogState();
}

class _CreateAuctionDialogState extends State<CreateAuctionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startingPriceController = TextEditingController();
  final _reservePriceController = TextEditingController();
  final _bidIncrementController = TextEditingController();

  DateTime? startDateTime;
  DateTime? endDateTime;
  bool isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startingPriceController.dispose();
    _reservePriceController.dispose();
    _bidIncrementController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          startDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectEndDateTime() async {
    final minDate =
        startDateTime ?? DateTime.now().add(const Duration(hours: 1));

    final date = await showDatePicker(
      context: context,
      initialDate: minDate.add(const Duration(days: 1)),
      firstDate: minDate,
      lastDate: minDate.add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          endDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _createAuction() async {
    if (!_formKey.currentState!.validate()) return;
    if (startDateTime == null || endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select start and end date/time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // TODO: Implement actual auction creation
      // For now, we'll just simulate success
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.of(context).pop();
        widget.onAuctionCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auction created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create auction: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Select Date & Time';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Create New Auction',
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1E3D),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            // Form
            Flexible(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      _buildTextField(
                        controller: _titleController,
                        label: 'Auction Title',
                        hint: 'Enter auction title',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter auction title';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                      // Description
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        hint: 'Enter auction description',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter auction description';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 2.h),
                      // Price Fields Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _startingPriceController,
                              label: 'Starting Price (\$)',
                              hint: '0.00',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: _buildTextField(
                              controller: _reservePriceController,
                              label: 'Reserve Price (\$)',
                              hint: '0.00',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: _buildTextField(
                              controller: _bidIncrementController,
                              label: 'Bid Increment (\$)',
                              hint: '1.00',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      // Date/Time Fields
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateTimeField(
                              label: 'Start Date & Time',
                              dateTime: startDateTime,
                              onTap: _selectStartDateTime,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: _buildDateTimeField(
                              label: 'End Date & Time',
                              dateTime: endDateTime,
                              onTap: _selectEndDateTime,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      // Create Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _createAuction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(
                                  'Create Auction',
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1E3D),
          ),
        ),
        SizedBox(height: 0.5.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade600),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 3.w,
              vertical: 1.5.h,
            ),
          ),
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: const Color(0xFF1A1E3D),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime? dateTime,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1A1E3D),
          ),
        ),
        SizedBox(height: 0.5.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 3.w,
              vertical: 1.5.h,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDateTime(dateTime),
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: dateTime == null
                        ? Colors.grey.shade500
                        : const Color(0xFF1A1E3D),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
