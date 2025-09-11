import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import '../../services/battle_service.dart';
import '../../services/product_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/battle_preview_widget.dart';
import './widgets/battle_settings_widget.dart';
import './widgets/competitor_discovery_widget.dart';
import './widgets/create_battle_button_widget.dart';
import './widgets/product_selection_widget.dart';

class BattleCreationCompetitorInvitation extends StatefulWidget {
  const BattleCreationCompetitorInvitation({super.key});

  @override
  State<BattleCreationCompetitorInvitation> createState() =>
      _BattleCreationCompetitorInvitationState();
}

class _BattleCreationCompetitorInvitationState
    extends State<BattleCreationCompetitorInvitation>
    with TickerProviderStateMixin {
  final BattleService _battleService = BattleService();
  final ProductService _productService = ProductService();
  late TabController _tabController;
  late PageController _pageController;

  // Form data
  Map<String, dynamic>? _selectedProduct;
  Map<String, dynamic>? _selectedCompetitor;
  String _battleTitle = '';
  String _battleDescription = '';
  String? _selectedCategory;
  int _battleDuration = 30;
  int _minSupportThreshold = 100;
  DateTime _scheduledStart = DateTime.now().add(const Duration(hours: 1));
  String _invitationMessage = '';

  // UI state
  int _currentStep = 0;
  bool _isLoading = false;
  bool _showPreview = false;

  // Data
  List<Map<String, dynamic>> _availableProducts = [];
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pageController = PageController();
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait<List<Map<String, dynamic>>>([
        ProductService.getAvailableProductsForCreator().then((products) => 
          products.map((p) => p.toJson()).toList()),
        ProductService.getProductsByCategory().then((categories) => 
          categories.map((c) => c.toJson()).toList()),
      ]);

      setState(() {
        _availableProducts = results[0];
        _categories = results[1]; 
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load data: ${e.toString()}');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _tabController.animateTo(_currentStep);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _tabController.animateTo(_currentStep);
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedProduct != null &&
            _battleTitle.isNotEmpty &&
            _battleDescription.isNotEmpty;
      case 1:
        return _selectedCompetitor != null;
      case 2:
        return true; // Battle settings always valid with defaults
      case 3:
        return true; // Preview step
      default:
        return false;
    }
  }

  Future<void> _createBattle() async {
    if (!_canProceed() ||
        _selectedProduct == null ||
        _selectedCompetitor == null) {
      _showError('Please complete all required fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create battle invitation using available method
      await BattleService.createBattleInvitation(
        battleId: 'temp_battle_id', // This would need proper battle creation flow
        inviteeId: _selectedCompetitor!['id'],
        message: _invitationMessage.isNotEmpty
            ? _invitationMessage
            : 'Join me in an epic battle challenge!',
      );

      _showSuccess('Battle invitation sent!');

      // Navigate to battle room
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.battleRoomsHub,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to create battle: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: CustomAppBar(
        title: 'Create Battle',
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_currentStep == 3)
            TextButton(
              onPressed: () => setState(() => _showPreview = !_showPreview),
              child: Text(
                _showPreview ? 'Edit' : 'Preview',
                style: const TextStyle(color: Colors.orange),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            )
          : Column(
              children: [
                // Progress indicator
                Container(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: List.generate(4, (index) {
                      final isActive = index <= _currentStep;
                      final isCompleted = index < _currentStep;

                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 1.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? Colors.orange
                                        : Colors.grey[800],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              if (index < 3) SizedBox(width: 1.w),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // Step labels
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStepLabel('Product', 0),
                      _buildStepLabel('Competitor', 1),
                      _buildStepLabel('Settings', 2),
                      _buildStepLabel('Review', 3),
                    ],
                  ),
                ),

                SizedBox(height: 3.h),

                // Page content
                Expanded(
                  child: _showPreview && _currentStep == 3
                      ? BattlePreviewWidget(
                          selectedProduct: _selectedProduct!,
                          selectedCompetitor: _selectedCompetitor!,
                          battleTitle: _battleTitle,
                          battleDescription: _battleDescription,
                          battleDuration: _battleDuration,
                          scheduledStart: _scheduledStart,
                          minSupportThreshold: _minSupportThreshold,
                        )
                      : PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentStep = index);
                            _tabController.animateTo(index);
                          },
                          children: [
                            // Step 1: Product Selection
                            ProductSelectionWidget(
                              products: _availableProducts,
                              categories: _categories,
                              selectedProduct: _selectedProduct,
                              selectedCategory: _selectedCategory,
                              battleTitle: _battleTitle,
                              battleDescription: _battleDescription,
                              onProductSelected: (product) {
                                setState(() => _selectedProduct = product);
                              },
                              onCategorySelected: (categoryId) {
                                setState(() => _selectedCategory = categoryId);
                              },
                              onTitleChanged: (title) {
                                setState(() => _battleTitle = title);
                              },
                              onDescriptionChanged: (description) {
                                setState(() => _battleDescription = description);
                              },
                            ),

                            // Step 2: Competitor Discovery
                            CompetitorDiscoveryWidget(
                              selectedCompetitor: _selectedCompetitor,
                              invitationMessage: _invitationMessage,
                              onCompetitorSelected: (competitor) {
                                setState(() => _selectedCompetitor = competitor);
                              },
                              onMessageChanged: (message) {
                                setState(() => _invitationMessage = message);
                              },
                            ),

                            // Step 3: Battle Settings
                            BattleSettingsWidget(
                              battleDuration: _battleDuration,
                              minSupportThreshold: _minSupportThreshold,
                              scheduledStart: _scheduledStart,
                              onDurationChanged: (duration) {
                                setState(() => _battleDuration = duration);
                              },
                              onThresholdChanged: (threshold) {
                                setState(() => _minSupportThreshold = threshold);
                              },
                              onStartTimeChanged: (startTime) {
                                setState(() => _scheduledStart = startTime);
                              },
                            ),

                            // Step 4: Review and Create
                            Container(
                              padding: EdgeInsets.all(4.w),
                              child: Column(
                                children: [
                                  Text(
                                    'Battle Ready!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Review your battle setup and create when ready.',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 14.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 4.h),

                                  // Quick summary
                                  Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[900],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        _buildSummaryRow('Battle Title', _battleTitle),
                                        _buildSummaryRow(
                                            'Product',
                                            _selectedProduct?['title'] ?? 'Not selected'),
                                        _buildSummaryRow(
                                            'Competitor',
                                            _selectedCompetitor?['full_name'] ?? 'Not selected'),
                                        _buildSummaryRow('Duration', '$_battleDuration minutes'),
                                        _buildSummaryRow('Start Time', _formatDateTime(_scheduledStart)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),

                // Bottom navigation
                Container(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                            ),
                            child: const Text(
                              'Previous',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      if (_currentStep > 0) SizedBox(width: 4.w),
                      Expanded(
                        flex: 2,
                        child: _currentStep == 3
                            ? CreateBattleButtonWidget(
                                onPressed: _createBattle,
                                isLoading: _isLoading,
                                canProceed: _canProceed(),
                              )
                            : ElevatedButton(
                                onPressed: _canProceed() ? _nextStep : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  disabledBackgroundColor: Colors.grey[700],
                                  padding: EdgeInsets.symmetric(vertical: 2.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  _currentStep == 2 ? 'Review Battle' : 'Next',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            );
  }

  Widget _buildStepLabel(String label, int step) {
    final isActive = step <= _currentStep;
    return Text(
      label,
      style: TextStyle(
        color: isActive ? Colors.orange : Colors.grey[600],
        fontSize: 12.sp,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12.sp,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}