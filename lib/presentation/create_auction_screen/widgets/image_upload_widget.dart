import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../controllers/create_auction_controller.dart';

/// Image Upload Widget
///
/// رفع وإدارة صور المزاد
/// يتبع قواعد BidWar للتصميم
class ImageUploadWidget extends StatefulWidget {
  final CreateAuctionController controller;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const ImageUploadWidget({
    super.key,
    required this.controller,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Text(
          'Auction Images',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryLight,
          ),
        ),

        SizedBox(height: 1.h),

        Text(
          'Add high-quality images to attract more bidders (up to 10 images)',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.textSecondaryLight,
            fontWeight: FontWeight.w400,
          ),
        ),

        SizedBox(height: 4.h),

        // Upload Area
        _buildUploadArea(),

        SizedBox(height: 4.h),

        // Selected Images Grid
        if (widget.controller.selectedImages.isNotEmpty) ...[
          Text(
            'Selected Images (${widget.controller.selectedImages.length}/10)',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryLight,
            ),
          ),
          SizedBox(height: 2.h),
          _buildImageGrid(),
          SizedBox(height: 4.h),
        ],

        // Guidelines
        _buildImageGuidelines(),

        SizedBox(height: 6.h),

        // Navigation Buttons
        Row(
          children: [
            // Previous Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.onPrevious,
                icon: Icon(Icons.arrow_back),
                label: Text('Previous'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),

            SizedBox(width: 4.w),

            // Next Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.controller.canProceedToPreview()
                    ? widget.onNext
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryLight,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(Icons.arrow_forward),
                label: Text(
                  'Preview',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: double.infinity,
        height: 25.h,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.primaryLight,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.primaryLight.withValues(alpha: 0.05),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload,
              size: 15.w,
              color: AppTheme.primaryLight,
            ),
            SizedBox(height: 2.h),
            Text(
              'Tap to select images',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryLight,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'JPG, PNG up to 5MB each',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppTheme.textSecondaryLight,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 2.w,
        childAspectRatio: 1,
      ),
      itemCount: widget.controller.selectedImages.length,
      itemBuilder: (context, index) {
        final image = widget.controller.selectedImages[index];

        return Stack(
          children: [
            // Image
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Remove Button
            Positioned(
              top: 1.w,
              right: 1.w,
              child: GestureDetector(
                onTap: () => widget.controller.removeImage(index),
                child: Container(
                  width: 6.w,
                  height: 6.w,
                  decoration: BoxDecoration(
                    color: AppTheme.errorLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 3.w,
                  ),
                ),
              ),
            ),

            // Main Image Indicator (للصورة الأولى)
            if (index == 0)
              Positioned(
                bottom: 1.w,
                left: 1.w,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: AppTheme.successLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Main',
                    style: TextStyle(
                      fontSize: 8.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildImageGuidelines() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.borderLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.tips_and_updates,
                size: 5.w,
                color: AppTheme.primaryLight,
              ),
              SizedBox(width: 2.w),
              Text(
                'Image Tips',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            '• Use high-quality, well-lit photos\n'
            '• Show multiple angles of your item\n'
            '• Include close-ups of important details\n'
            '• First image will be the main display image\n'
            '• Avoid blurry or dark images',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();

      // عرض خيارات الاختيار
      final source = await _showImageSourceDialog();
      if (source == null) return;

      if (source == ImageSource.gallery) {
        // اختيار متعدد من المعرض
        final List<XFile> images = await picker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (images.isNotEmpty) {
          // التحقق من العدد الإجمالي
          final totalImages =
              widget.controller.selectedImages.length + images.length;
          if (totalImages > 10) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cannot select more than 10 images total'),
                backgroundColor: AppTheme.warningLight,
              ),
            );
            return;
          }

          // تحويل XFile إلى File
          final List<File> imageFiles =
              images.map((xfile) => File(xfile.path)).toList();
          widget.controller.addImages(imageFiles);
        }
      } else {
        // التقاط صورة من الكاميرا
        final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (image != null) {
          // التحقق من العدد الإجمالي
          if (widget.controller.selectedImages.length >= 10) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cannot add more than 10 images'),
                backgroundColor: AppTheme.warningLight,
              ),
            );
            return;
          }

          widget.controller.addImages([File(image.path)]);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick images: $e'),
          backgroundColor: AppTheme.errorLight,
        ),
      );
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: AppTheme.primaryLight),
              title: Text('Gallery'),
              subtitle: Text('Choose from your photos'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppTheme.primaryLight),
              title: Text('Camera'),
              subtitle: Text('Take a new photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
