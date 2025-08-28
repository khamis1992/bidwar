import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class VideoViewWidget extends StatelessWidget {
  final RtcEngine? agoraEngine;
  final int remoteUid;
  final bool isJoined;
  final bool isStreamer;

  const VideoViewWidget({
    Key? key,
    required this.agoraEngine,
    required this.remoteUid,
    required this.isJoined,
    required this.isStreamer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: _buildVideoView(),
    );
  }

  Widget _buildVideoView() {
    if (agoraEngine == null || !isJoined) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Connecting to stream...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (isStreamer) {
      // Show local camera preview for streamer
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: agoraEngine!,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      // Show remote stream for viewers
      if (remoteUid != 0) {
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: agoraEngine!,
            canvas: VideoCanvas(uid: remoteUid),
            connection: const RtcConnection(),
          ),
        );
      } else {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off,
                color: Colors.white54,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Waiting for streamer...',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }
    }
  }
}
