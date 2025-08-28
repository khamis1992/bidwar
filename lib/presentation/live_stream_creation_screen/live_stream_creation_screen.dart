import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/auction_service.dart';
import '../../services/live_stream_service.dart';
import '../live_auction_stream_screen/live_auction_stream_screen.dart';
import './widgets/auction_config_widget.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/go_live_button_widget.dart';
import './widgets/stream_settings_widget.dart';

class LiveStreamCreationScreen extends StatefulWidget {
  const LiveStreamCreationScreen({Key? key}) : super(key: key);

  @override
  State<LiveStreamCreationScreen> createState() =>
      _LiveStreamCreationScreenState();
}

class _LiveStreamCreationScreenState extends State<LiveStreamCreationScreen> {
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
  String? _selectedAuctionId;
  Map<String, dynamic>? _selectedAuction;
  List<dynamic> _userAuctions = [];
  String _selectedDuration = '30min';
  bool _isPublic = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeAgora();
    _loadUserAuctions();
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
    } catch (e) {
      print('Agora initialization error: $e');
    }
  }

  Future<void> _loadUserAuctions() async {
    try {
      final auctions = await AuctionService.instance.getAuctionItems();
      setState(() {
        _userAuctions = auctions
            .where((auction) =>
                auction['status'] == 'upcoming' || auction['status'] == 'live')
            .toList();
      });
    } catch (e) {
      print('Error loading auctions: $e');
    }
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
    if (_selectedAuctionId == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create live stream record
      final streamData = await LiveStreamService.createLiveStream(
        auctionItemId: _selectedAuctionId!,
        title: _titleController.text,
        description: _descriptionController.text,
        scheduledStart: DateTime.now(),
        streamSettings: {
          'duration': _selectedDuration,
          'is_public': _isPublic,
          'camera_position': _currentCameraIndex,
        },
      );

      if (streamData != null && _agoraEngine != null) {
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
        title: const Text('Create Live Stream'),
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
                  ? CameraPreviewWidget(controller: _cameraController!)
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
                    // Auction Configuration
                    AuctionConfigWidget(
                      userAuctions: _userAuctions,
                      selectedAuctionId: _selectedAuctionId,
                      onAuctionSelected: (auctionId, auction) {
                        setState(() {
                          _selectedAuctionId = auctionId;
                          _selectedAuction = auction;
                          _titleController.text = auction?['title'] ?? '';
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Stream Settings
                    StreamSettingsWidget(
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                      selectedDuration: _selectedDuration,
                      isPublic: _isPublic,
                      onDurationChanged: (duration) {
                        setState(() {
                          _selectedDuration = duration;
                        });
                      },
                      onVisibilityChanged: (isPublic) {
                        setState(() {
                          _isPublic = isPublic;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    // Go Live Button
                    GoLiveButtonWidget(
                      isLoading: _isLoading,
                      isEnabled: _selectedAuctionId != null &&
                          _titleController.text.isNotEmpty &&
                          _isCameraInitialized &&
                          _isAgoraInitialized,
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
}
