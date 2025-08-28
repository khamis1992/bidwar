import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/live_stream_service.dart';
import '../../services/supabase_service.dart';
import '../live_auction_stream_screen/live_auction_stream_screen.dart';
import '../product_selection_screen/product_selection_screen.dart';
import './widgets/commission_preview_widget.dart';
import './widgets/enhanced_camera_preview_widget.dart';
import './widgets/enhanced_go_live_button_widget.dart';
import './widgets/product_display_widget.dart';
import './widgets/stream_config_widget.dart';

class EnhancedLiveStreamCreationScreen extends StatefulWidget {
  const EnhancedLiveStreamCreationScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedLiveStreamCreationScreen> createState() =>
      _EnhancedLiveStreamCreationScreenState();
}

class _EnhancedLiveStreamCreationScreenState
    extends State<EnhancedLiveStreamCreationScreen> {
  // Camera variables
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  int _currentCameraIndex = 0;

  // Agora variables
  RtcEngine? _agoraEngine;
  bool _isAgoraInitialized = false;

  // Form variables
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Product selection variables
  Map<String, dynamic>? _selectedProduct;
  String? _selectedProductId;
  Map<String, dynamic>? _userProfile;
  String _userTier = 'bronze';
  double _commissionRate = 10.0;
  int _potentialCommission = 0;

  // Stream configuration
  String _selectedDuration = '30min';
  String _startingPriceMode = 'auto'; // auto, custom
  int _customStartingPrice = 0;
  int _bidIncrement = 100; // in cents
  bool _acceptCommissionTerms = false;

  // UI state
  bool _isLoading = false;
  bool _preStreamValidated = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeAgora();
    _loadUserProfile();
  }

  Future<void> _initializeCamera() async {
    try {
      if (!kIsWeb) {
        final status = await Permission.camera.request();
        if (!status.isGranted) return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();

      // Apply platform-specific settings
      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (e) {}

      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {}
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        _validatePreStream();
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  Future<void> _initializeAgora() async {
    try {
      _agoraEngine = createAgoraRtcEngine();
      await _agoraEngine!.initialize(const RtcEngineContext(
        appId: "YOUR_AGORA_APP_ID", // Replace with actual Agora App ID
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));

      await _agoraEngine!.enableVideo();
      await _agoraEngine!
          .setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      setState(() {
        _isAgoraInitialized = true;
      });
      _validatePreStream();
    } catch (e) {
      print('Agora initialization error: $e');
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final client = SupabaseService.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId != null) {
        final response = await client
            .from('user_profiles')
            .select()
            .eq('id', userId)
            .single();

        setState(() {
          _userProfile = response;
        });

        _calculateUserTier();
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  void _calculateUserTier() {
    if (_userProfile == null) return;

    final creditBalance = _userProfile!['credit_balance'] as int? ?? 0;

    if (creditBalance >= 20000) {
      _userTier = 'platinum';
      _commissionRate = 15.0;
    } else if (creditBalance >= 5000) {
      _userTier = 'gold';
      _commissionRate = 12.0;
    } else if (creditBalance >= 1000) {
      _userTier = 'silver';
      _commissionRate = 10.0;
    } else {
      _userTier = 'bronze';
      _commissionRate = 10.0;
    }

    _updateCommissionCalculation();
  }

  void _updateCommissionCalculation() {
    if (_selectedProduct != null) {
      final retailValue = _selectedProduct!['retail_value'] as int? ?? 0;
      setState(() {
        _potentialCommission = (retailValue * _commissionRate / 100).round();
      });
    }
  }

  Future<void> _selectProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductSelectionScreen(
          userTier: _userTier,
          creditBalance: _userProfile?['credit_balance'] ?? 0,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedProduct = result;
        _selectedProductId = result['id'];
        _titleController.text = 'Live Auction: ${result['title']}';
        _customStartingPrice = result['starting_price'] ?? 0;
      });
      _updateCommissionCalculation();
      _validatePreStream();
    }
  }

  void _validatePreStream() {
    final validated = _selectedProduct != null &&
        _titleController.text.isNotEmpty &&
        _isCameraInitialized &&
        _isAgoraInitialized &&
        _acceptCommissionTerms;

    setState(() {
      _preStreamValidated = validated;
    });
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    try {
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      final newCamera = _cameras[_currentCameraIndex];

      await _cameraController!.dispose();
      _cameraController = CameraController(
        newCamera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      setState(() {});
    } catch (e) {
      print('Camera switch error: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (kIsWeb || _cameraController == null) return;

    try {
      _isFlashOn = !_isFlashOn;
      await _cameraController!
          .setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    } catch (e) {
      print('Flash toggle error: $e');
    }
  }

  Future<void> _goLive() async {
    if (!_preStreamValidated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all requirements')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final client = SupabaseService.instance.client;

      // Create auction item from selected product
      final auctionData = await client
          .from('auction_items')
          .insert({
            'title': _selectedProduct!['title'],
            'description': _selectedProduct!['description'],
            'starting_price': _startingPriceMode == 'auto'
                ? _selectedProduct!['starting_price']
                : _customStartingPrice,
            'reserve_price': _selectedProduct!['reserve_price'],
            'bid_increment': _bidIncrement,
            'category_id': _selectedProduct!['category_id'],
            'images': _selectedProduct!['images'],
            'specifications': _selectedProduct!['specifications'],
            'brand': _selectedProduct!['brand'],
            'model': _selectedProduct!['model'],
            'condition': _selectedProduct!['condition'],
            'seller_id': client.auth.currentUser?.id,
            'start_time': DateTime.now().toIso8601String(),
            'end_time': DateTime.now()
                .add(_getDurationFromString(_selectedDuration))
                .toIso8601String(),
            'status': 'upcoming',
          })
          .select()
          .single();

      // Create commission record
      await client.from('creator_commissions').insert({
        'creator_id': client.auth.currentUser?.id,
        'auction_item_id': auctionData['id'],
        'system_product_id': _selectedProductId,
        'commission_rate': _commissionRate,
        'status': 'pending',
      });

      // Create live stream record
      final streamData = await LiveStreamService.createLiveStream(
        auctionItemId: auctionData['id'],
        title: _titleController.text,
        description: _descriptionController.text,
        scheduledStart: DateTime.now(),
        streamSettings: {
          'duration': _selectedDuration,
          'starting_price_mode': _startingPriceMode,
          'bid_increment': _bidIncrement,
          'commission_rate': _commissionRate,
          'product_tier': _userTier,
        },
      );

      if (streamData != null && _agoraEngine != null) {
        // Record product selection
        await client.from('stream_product_selections').insert({
          'stream_id': streamData['id'],
          'system_product_id': _selectedProductId,
          'creator_id': client.auth.currentUser?.id,
        });

        // Join Agora channel
        await _agoraEngine!.joinChannel(
          token: '', // Use Agora token in production
          channelId: streamData['agora_channel_id'],
          uid: 0,
          options: const ChannelMediaOptions(
            publishCameraTrack: true,
            publishMicrophoneTrack: true,
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
          ),
        );

        // Start the live stream
        await LiveStreamService.startLiveStream(streamData['id']);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LiveAuctionStreamScreen(
                streamId: streamData['id'],
                isStreamer: true,
                agoraEngine: _agoraEngine,
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to go live: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Duration _getDurationFromString(String duration) {
    switch (duration) {
      case '15min':
        return const Duration(minutes: 15);
      case '30min':
        return const Duration(minutes: 30);
      case '1hour':
        return const Duration(hours: 1);
      case '2hours':
        return const Duration(hours: 2);
      default:
        return const Duration(minutes: 30);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _agoraEngine?.leaveChannel();
    _agoraEngine?.release();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Create Live Auction',
          style: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isCameraInitialized && _cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
              onPressed: _switchCamera,
            ),
          if (!kIsWeb && _isCameraInitialized)
            IconButton(
              icon: Icon(
                _isFlashOn ? Icons.flash_on : Icons.flash_off,
                color: Colors.white,
              ),
              onPressed: _toggleFlash,
            ),
        ],
      ),
      body: Column(
        children: [
          // Camera Preview Section (Top Half)
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: _isCameraInitialized && _cameraController != null
                  ? EnhancedCameraPreviewWidget(
                      controller: _cameraController!,
                      selectedProduct: _selectedProduct,
                      potentialCommission: _potentialCommission,
                      commissionRate: _commissionRate,
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),
          ),

          // Configuration Section (Bottom Half)
          Expanded(
            flex: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Selection Section
                    Text(
                      'Select Product',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _selectedProduct == null
                        ? _buildSelectProductButton()
                        : ProductDisplayWidget(
                            product: _selectedProduct!,
                            onEdit: _selectProduct,
                          ),

                    const SizedBox(height: 20),

                    // Commission Preview
                    if (_selectedProduct != null)
                      CommissionPreviewWidget(
                        retailValue: _selectedProduct!['retail_value'] ?? 0,
                        commissionRate: _commissionRate,
                        potentialCommission: _potentialCommission,
                        userTier: _userTier,
                      ),

                    const SizedBox(height: 20),

                    // Stream Configuration
                    if (_selectedProduct != null)
                      StreamConfigWidget(
                        titleController: _titleController,
                        descriptionController: _descriptionController,
                        selectedDuration: _selectedDuration,
                        startingPriceMode: _startingPriceMode,
                        customStartingPrice: _customStartingPrice,
                        bidIncrement: _bidIncrement,
                        acceptCommissionTerms: _acceptCommissionTerms,
                        onDurationChanged: (duration) {
                          setState(() {
                            _selectedDuration = duration;
                          });
                          _validatePreStream();
                        },
                        onStartingPriceModeChanged: (mode) {
                          setState(() {
                            _startingPriceMode = mode;
                          });
                        },
                        onCustomStartingPriceChanged: (price) {
                          setState(() {
                            _customStartingPrice = price;
                          });
                        },
                        onBidIncrementChanged: (increment) {
                          setState(() {
                            _bidIncrement = increment;
                          });
                        },
                        onCommissionTermsChanged: (accepted) {
                          setState(() {
                            _acceptCommissionTerms = accepted;
                          });
                          _validatePreStream();
                        },
                      ),

                    const SizedBox(height: 30),

                    // Go Live Button
                    EnhancedGoLiveButtonWidget(
                      isLoading: _isLoading,
                      isEnabled: _preStreamValidated,
                      selectedProduct: _selectedProduct,
                      cameraReady: _isCameraInitialized,
                      agoraReady: _isAgoraInitialized,
                      commissionTermsAccepted: _acceptCommissionTerms,
                      onPressed: _goLive,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectProductButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade50,
      ),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'Select Product to Stream',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose from system inventory based on your tier',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _selectProduct,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Browse Products',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
