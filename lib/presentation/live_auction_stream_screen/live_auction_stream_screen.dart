import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auction_service.dart';
import '../../services/live_stream_service.dart';
import './widgets/auction_overlay_widget.dart';
import './widgets/bidding_panel_widget.dart';
import './widgets/chat_interface_widget.dart';
import './widgets/stream_controls_widget.dart';
import './widgets/video_view_widget.dart';

class LiveAuctionStreamScreen extends StatefulWidget {
  final String streamId;
  final bool isStreamer;
  final RtcEngine? agoraEngine;

  const LiveAuctionStreamScreen({
    Key? key,
    required this.streamId,
    this.isStreamer = false,
    this.agoraEngine,
  }) : super(key: key);

  @override
  State<LiveAuctionStreamScreen> createState() =>
      _LiveAuctionStreamScreenState();
}

class _LiveAuctionStreamScreenState extends State<LiveAuctionStreamScreen>
    with WidgetsBindingObserver {
  // Agora variables
  RtcEngine? _agoraEngine;
  int _remoteUid = 0;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;

  // Stream data
  Map<String, dynamic>? _streamData;
  Map<String, dynamic>? _auctionData;
  List<dynamic> _chatMessages = [];
  int _viewerCount = 0;
  int _currentBid = 0;
  Timer? _streamTimer;
  Duration _streamDuration = Duration.zero;

  // UI state
  bool _showChat = true;
  bool _showBiddingPanel = false;
  final _chatController = TextEditingController();
  final _bidController = TextEditingController();

  // Real-time subscriptions
  RealtimeChannel? _streamSubscription;
  RealtimeChannel? _chatSubscription;
  RealtimeChannel? _viewerSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await _setupAgoraEngine();
    await _loadStreamData();
    await _joinStream();
    _setupRealtimeSubscriptions();
    _startStreamTimer();
  }

  Future<void> _setupAgoraEngine() async {
    try {
      if (widget.agoraEngine != null) {
        _agoraEngine = widget.agoraEngine;
      } else {
        _agoraEngine = createAgoraRtcEngine();
        await _agoraEngine!.initialize(const RtcEngineContext(
          appId: "YOUR_AGORA_APP_ID", // Replace with actual App ID
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ));
      }

      _setupEventHandlers();

      if (!widget.isStreamer) {
        await _agoraEngine!
            .setClientRole(role: ClientRoleType.clientRoleAudience);
        await _agoraEngine!.enableVideo();
      }
    } catch (e) {
      print('Agora setup error: $e');
    }
  }

  void _setupEventHandlers() {
    _agoraEngine!.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            _isJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          setState(() {
            _remoteUid = 0;
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          setState(() {
            _isJoined = false;
            _remoteUid = 0;
          });
        },
      ),
    );
  }

  Future<void> _loadStreamData() async {
    try {
      final streamData =
          await LiveStreamService.getStreamDetails(widget.streamId);
      final chatMessages =
          await LiveStreamService.getChatMessages(widget.streamId);

      setState(() {
        _streamData = streamData;
        _auctionData = streamData?['auction_item'];
        _chatMessages = chatMessages;
        _currentBid = _auctionData?['current_highest_bid'] ?? 0;
        _viewerCount = streamData?['viewer_count'] ?? 0;
      });
    } catch (e) {
      print('Error loading stream data: $e');
    }
  }

  Future<void> _joinStream() async {
    try {
      if (_streamData?['agora_channel_id'] != null) {
        await _agoraEngine!.joinChannel(
          token: "", // Use Agora token in production
          channelId: _streamData!['agora_channel_id'],
          uid: 0,
          options: ChannelMediaOptions(
            publishCameraTrack: widget.isStreamer,
            publishMicrophoneTrack: widget.isStreamer,
            clientRoleType: widget.isStreamer
                ? ClientRoleType.clientRoleBroadcaster
                : ClientRoleType.clientRoleAudience,
          ),
        );

        if (!widget.isStreamer) {
          await LiveStreamService.joinStream(widget.streamId);
        }
      }
    } catch (e) {
      print('Join stream error: $e');
    }
  }

  void _setupRealtimeSubscriptions() {
    // Subscribe to stream updates
    _streamSubscription = LiveStreamService.subscribeToStreamUpdates(
      widget.streamId,
      (payload) {
        if (mounted) {
          setState(() {
            _streamData = {..._streamData!, ...payload.newRecord};
            if (payload.newRecord['status'] == 'ended') {
              _handleStreamEnded();
            }
          });
        }
      },
    );

    // Subscribe to chat messages
    _chatSubscription = LiveStreamService.subscribeToChatMessages(
      widget.streamId,
      (payload) {
        if (mounted) {
          setState(() {
            _chatMessages.add(payload.newRecord);
          });
        }
      },
    );

    // Subscribe to viewer updates
    _viewerSubscription = LiveStreamService.subscribeToViewerUpdates(
      widget.streamId,
      (payload) {
        _updateViewerCount();
      },
    );
  }

  void _startStreamTimer() {
    _streamTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _streamData?['actual_start'] != null) {
        final startTime = DateTime.parse(_streamData!['actual_start']);
        setState(() {
          _streamDuration = DateTime.now().difference(startTime);
        });
      }
    });
  }

  Future<void> _updateViewerCount() async {
    try {
      final streamData =
          await LiveStreamService.getStreamDetails(widget.streamId);
      if (mounted) {
        setState(() {
          _viewerCount = streamData?['viewer_count'] ?? 0;
        });
      }
    } catch (e) {
      print('Error updating viewer count: $e');
    }
  }

  Future<void> _sendChatMessage() async {
    if (_chatController.text.trim().isEmpty) return;

    try {
      await LiveStreamService.sendChatMessage(
        streamId: widget.streamId,
        content: _chatController.text.trim(),
      );
      _chatController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  Future<void> _placeBid() async {
    final bidAmount = int.tryParse(_bidController.text);
    if (bidAmount == null || bidAmount <= _currentBid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid bid amount')),
      );
      return;
    }

    try {
      await AuctionService.instance.placeBid(
        auctionItemId: _auctionData!['id'],
        bidAmount: bidAmount,
      );

      _bidController.clear();
      setState(() {
        _showBiddingPanel = false;
      });

      // Provide haptic feedback
      HapticFeedback.mediumImpact();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place bid: $e')),
      );
    }
  }

  Future<void> _toggleMute() async {
    if (!widget.isStreamer) return;

    try {
      _isMuted = !_isMuted;
      await _agoraEngine!.muteLocalAudioStream(_isMuted);
      setState(() {});
    } catch (e) {
      print('Toggle mute error: $e');
    }
  }

  Future<void> _toggleVideo() async {
    if (!widget.isStreamer) return;

    try {
      _isVideoEnabled = !_isVideoEnabled;
      await _agoraEngine!.muteLocalVideoStream(!_isVideoEnabled);
      setState(() {});
    } catch (e) {
      print('Toggle video error: $e');
    }
  }

  Future<void> _endStream() async {
    if (!widget.isStreamer) return;

    try {
      await LiveStreamService.endLiveStream(widget.streamId);
      _handleStreamEnded();
    } catch (e) {
      print('End stream error: $e');
    }
  }

  void _handleStreamEnded() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Stream Ended'),
        content: Text(
          widget.isStreamer
              ? 'Your live stream has ended successfully.'
              : 'The live stream has ended.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused && !widget.isStreamer) {
      LiveStreamService.leaveStream(widget.streamId);
    } else if (state == AppLifecycleState.resumed && !widget.isStreamer) {
      LiveStreamService.joinStream(widget.streamId);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _streamTimer?.cancel();

    _streamSubscription?.unsubscribe();
    _chatSubscription?.unsubscribe();
    _viewerSubscription?.unsubscribe();

    if (!widget.isStreamer) {
      LiveStreamService.leaveStream(widget.streamId);
    }

    _agoraEngine?.leaveChannel();
    if (widget.agoraEngine == null) {
      _agoraEngine?.release();
    }

    _chatController.dispose();
    _bidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_streamData == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video View (Full Screen)
            VideoViewWidget(
              agoraEngine: _agoraEngine,
              remoteUid: _remoteUid,
              isJoined: _isJoined,
              isStreamer: widget.isStreamer,
            ),

            // Auction Overlay (Top)
            AuctionOverlayWidget(
              auctionData: _auctionData,
              currentBid: _currentBid,
              viewerCount: _viewerCount,
              streamDuration: _streamDuration,
              onBack: () => Navigator.pop(context),
            ),

            // Chat Interface (Bottom)
            if (_showChat)
              ChatInterfaceWidget(
                messages: _chatMessages,
                chatController: _chatController,
                onSendMessage: _sendChatMessage,
                onToggleChat: () => setState(() => _showChat = false),
              ),

            // Bidding Panel (Floating)
            if (_showBiddingPanel && !widget.isStreamer)
              BiddingPanelWidget(
                currentBid: _currentBid,
                bidController: _bidController,
                onPlaceBid: _placeBid,
                onClose: () => setState(() => _showBiddingPanel = false),
              ),

            // Floating Bid Button
            if (!widget.isStreamer && !_showBiddingPanel)
              Positioned(
                right: 20,
                bottom: _showChat ? 180 : 100,
                child: FloatingActionButton.extended(
                  onPressed: () => setState(() => _showBiddingPanel = true),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.gavel),
                  label: Text('\$${_currentBid + 50}'),
                ),
              ),

            // Show Chat Button (when hidden)
            if (!_showChat)
              Positioned(
                right: 20,
                bottom: 20,
                child: FloatingActionButton(
                  onPressed: () => setState(() => _showChat = true),
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                  mini: true,
                  child: const Icon(Icons.chat),
                ),
              ),

            // Stream Controls (for streamers)
            if (widget.isStreamer)
              StreamControlsWidget(
                isMuted: _isMuted,
                isVideoEnabled: _isVideoEnabled,
                onToggleMute: _toggleMute,
                onToggleVideo: _toggleVideo,
                onEndStream: _endStream,
              ),
          ],
        ),
      ),
    );
  }
}
