import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/supabase_client_provider.dart';
import '../../../features/auctions/data/datasources/auction_remote_datasource.dart';
import '../../../features/auctions/data/repositories/auction_repository_impl.dart';
import '../../../features/auctions/domain/usecases/create_auction_usecase.dart';

/// Create Auction Controller - إدارة حالة صفحة إنشاء المزاد
///
/// يدير بيانات النموذج ورفع الصور وإنشاء المزاد
/// يتبع قواعد BidWar لإدارة الحالة
class CreateAuctionController extends ChangeNotifier {
  // Dependencies
  late final CreateAuctionUseCase _createAuctionUseCase;
  late final SupabaseClient _supabaseClient;

  // Form State
  String _title = '';
  String _description = '';
  int _startingPrice = 0;
  int _bidIncrement = 1;
  DateTime? _startTime;
  DateTime? _endTime;
  String? _condition;
  String? _brand;
  String? _model;
  String? _categoryId;

  // Images
  List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];

  // Loading States
  bool _isCreating = false;
  bool _isUploadingImages = false;
  String? _errorMessage;

  // Getters
  String get title => _title;
  String get description => _description;
  int get startingPrice => _startingPrice;
  int get bidIncrement => _bidIncrement;
  DateTime? get startTime => _startTime;
  DateTime? get endTime => _endTime;
  String? get condition => _condition;
  String? get brand => _brand;
  String? get model => _model;
  String? get categoryId => _categoryId;

  List<File> get selectedImages => _selectedImages;
  List<String> get uploadedImageUrls => _uploadedImageUrls;

  bool get isCreating => _isCreating;
  bool get isUploadingImages => _isUploadingImages;
  String? get errorMessage => _errorMessage;

  // Validation
  bool get isFormValid => _validateForm();

  CreateAuctionController() {
    _initializeDependencies();
  }

  void _initializeDependencies() {
    try {
      _supabaseClient = SupabaseClientService.client;

      final auctionDataSource = AuctionRemoteDataSourceImpl();
      final auctionRepository = AuctionRepositoryImpl(
        remoteDataSource: auctionDataSource,
      );
      _createAuctionUseCase = CreateAuctionUseCase(auctionRepository);
    } catch (e) {
      _setError('Failed to initialize: $e');
    }
  }

  /// تحديث العنوان
  void updateTitle(String title) {
    _title = title.trim();
    notifyListeners();
  }

  /// تحديث الوصف
  void updateDescription(String description) {
    _description = description.trim();
    notifyListeners();
  }

  /// تحديث السعر الابتدائي
  void updateStartingPrice(int price) {
    _startingPrice = price;
    notifyListeners();
  }

  /// تحديث خطوة المزايدة
  void updateBidIncrement(int increment) {
    _bidIncrement = increment;
    notifyListeners();
  }

  /// تحديث وقت البداية
  void updateStartTime(DateTime startTime) {
    _startTime = startTime;
    notifyListeners();
  }

  /// تحديث وقت النهاية
  void updateEndTime(DateTime endTime) {
    _endTime = endTime;
    notifyListeners();
  }

  /// تحديث حالة المنتج
  void updateCondition(String? condition) {
    _condition = condition;
    notifyListeners();
  }

  /// تحديث العلامة التجارية
  void updateBrand(String? brand) {
    _brand = brand;
    notifyListeners();
  }

  /// تحديث الموديل
  void updateModel(String? model) {
    _model = model;
    notifyListeners();
  }

  /// تحديث الفئة
  void updateCategory(String? categoryId) {
    _categoryId = categoryId;
    notifyListeners();
  }

  /// إضافة صور
  void addImages(List<File> images) {
    _selectedImages.addAll(images);
    notifyListeners();
  }

  /// إزالة صورة
  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  /// مسح جميع الصور
  void clearImages() {
    _selectedImages.clear();
    _uploadedImageUrls.clear();
    notifyListeners();
  }

  /// رفع الصور إلى Supabase Storage
  Future<List<String>> uploadImages() async {
    if (_selectedImages.isEmpty) return [];

    try {
      _setUploadingImages(true);
      _uploadedImageUrls.clear();

      for (int i = 0; i < _selectedImages.length; i++) {
        final file = _selectedImages[i];
        final fileName =
            'auction_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';

        // رفع الصورة إلى bucket: auctions
        await _supabaseClient.storage.from('auctions').upload(fileName, file);

        // الحصول على URL العام
        final imageUrl =
            _supabaseClient.storage.from('auctions').getPublicUrl(fileName);

        _uploadedImageUrls.add(imageUrl);
        notifyListeners();
      }

      return _uploadedImageUrls;
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    } finally {
      _setUploadingImages(false);
    }
  }

  /// إنشاء المزاد
  Future<CreateAuctionResult> createAuction({required String sellerId}) async {
    try {
      _setCreating(true);
      _clearError();

      // التحقق من صحة النموذج
      final validationError = _validateFormDetailed();
      if (validationError != null) {
        return CreateAuctionResult.failure(validationError);
      }

      // رفع الصور أولاً
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await uploadImages();
      }

      // تحديد حالة المزاد (يتم تعيينها تلقائياً في قاعدة البيانات)
      // final auctionStatus = _determineAuctionStatus();

      // إنشاء معاملات المزاد
      final params = CreateAuctionParams.complete(
        sellerId: sellerId,
        categoryId: _categoryId,
        title: _title,
        description: _description,
        startingPrice: _startingPrice,
        bidIncrement: _bidIncrement,
        startTime: _startTime!,
        endTime: _endTime!,
        condition: _condition,
        brand: _brand,
        model: _model,
        images: imageUrls,
        featured: false, // يمكن إضافة خيار لاحقاً
      );

      // إنشاء المزاد
      final auctionId = await _createAuctionUseCase(params);

      return CreateAuctionResult.success(
        auctionId: auctionId,
        message: 'Auction created successfully!',
      );
    } catch (e) {
      return CreateAuctionResult.failure('Failed to create auction: $e');
    } finally {
      _setCreating(false);
    }
  }

  /// التحقق من صحة النموذج (أساسي)
  bool _validateForm() {
    return _title.isNotEmpty &&
        _description.isNotEmpty &&
        _startingPrice > 0 &&
        _bidIncrement > 0 &&
        _startTime != null &&
        _endTime != null &&
        _endTime!.isAfter(_startTime!);
  }

  /// التحقق من صحة النموذج (مفصل)
  String? _validateFormDetailed() {
    if (_title.isEmpty) {
      return 'Title is required';
    }

    if (_title.length < 3) {
      return 'Title must be at least 3 characters long';
    }

    if (_title.length > 100) {
      return 'Title cannot exceed 100 characters';
    }

    if (_description.isEmpty) {
      return 'Description is required';
    }

    if (_description.length < 10) {
      return 'Description must be at least 10 characters long';
    }

    if (_description.length > 1000) {
      return 'Description cannot exceed 1000 characters';
    }

    if (_startingPrice <= 0) {
      return 'Starting price must be greater than 0';
    }

    if (_startingPrice > 1000000) {
      return 'Starting price cannot exceed \$1,000,000';
    }

    if (_bidIncrement <= 0) {
      return 'Bid increment must be greater than 0';
    }

    if (_bidIncrement > _startingPrice) {
      return 'Bid increment cannot be greater than starting price';
    }

    if (_startTime == null) {
      return 'Start time is required';
    }

    if (_endTime == null) {
      return 'End time is required';
    }

    final now = DateTime.now();

    if (_startTime!.isBefore(now.subtract(const Duration(minutes: 5)))) {
      return 'Start time cannot be more than 5 minutes in the past';
    }

    if (_endTime!.isBefore(_startTime!)) {
      return 'End time must be after start time';
    }

    final duration = _endTime!.difference(_startTime!);

    if (duration.inMinutes < 30) {
      return 'Auction duration must be at least 30 minutes';
    }

    if (duration.inDays > 30) {
      return 'Auction duration cannot exceed 30 days';
    }

    if (_selectedImages.length > 10) {
      return 'Cannot upload more than 10 images';
    }

    return null; // كل شيء صحيح
  }

  /// حساب مدة المزاد
  Duration? get auctionDuration {
    if (_startTime == null || _endTime == null) return null;
    return _endTime!.difference(_startTime!);
  }

  /// التحقق من إمكانية الانتقال للخطوة التالية
  bool canProceedToImages() {
    return _title.isNotEmpty &&
        _description.isNotEmpty &&
        _startingPrice > 0 &&
        _bidIncrement > 0;
  }

  bool canProceedToPreview() {
    return canProceedToImages() && _startTime != null && _endTime != null;
  }

  /// إعادة تعيين النموذج
  void resetForm() {
    _title = '';
    _description = '';
    _startingPrice = 0;
    _bidIncrement = 1;
    _startTime = null;
    _endTime = null;
    _condition = null;
    _brand = null;
    _model = null;
    _categoryId = null;
    _selectedImages.clear();
    _uploadedImageUrls.clear();
    _clearError();
    notifyListeners();
  }

  /// تعيين حالة الإنشاء
  void _setCreating(bool creating) {
    _isCreating = creating;
    notifyListeners();
  }

  /// تعيين حالة رفع الصور
  void _setUploadingImages(bool uploading) {
    _isUploadingImages = uploading;
    notifyListeners();
  }

  /// تعيين رسالة الخطأ
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// مسح رسالة الخطأ
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

/// نتيجة إنشاء المزاد
class CreateAuctionResult {
  final bool success;
  final String message;
  final String? auctionId;

  const CreateAuctionResult({
    required this.success,
    required this.message,
    this.auctionId,
  });

  factory CreateAuctionResult.success({
    required String auctionId,
    required String message,
  }) {
    return CreateAuctionResult(
      success: true,
      message: message,
      auctionId: auctionId,
    );
  }

  factory CreateAuctionResult.failure(String message) {
    return CreateAuctionResult(
      success: false,
      message: message,
      auctionId: null,
    );
  }

  @override
  String toString() {
    return 'CreateAuctionResult(success: $success, message: $message, auctionId: $auctionId)';
  }
}
