import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../providers/video_provider.dart';

class VideoCallPage extends StatefulWidget {
  final String channelName;
  final String token;
  final String appId;
  final String peerName;
  final bool isMentor;

  const VideoCallPage({
    super.key,
    required this.channelName,
    required this.token,
    required this.appId,
    required this.peerName,
    required this.isMentor,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late RtcEngine _engine;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isCameraOff = false;
  int? _remoteUid;
  Timer? _durationTimer;
  int _callDuration = 0;

  // Video view controllers - using the correct type
  int _localUid = 0;
  int? _remoteVideoUid;

  @override
  void initState() {
    super.initState();
    _initAgora();
    _startDurationTimer();
  }

  void _startDurationTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _callDuration++);
      }
    });
  }

  Future<void> _initAgora() async {
    // Request permissions
    await [Permission.camera, Permission.microphone].request();

    // Create engine
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: widget.appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    // Set event handlers
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint('onJoinChannelSuccess');
          setState(() => _isJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('onUserJoined: $remoteUid');
          setState(() => _remoteUid = remoteUid);
          _remoteVideoUid = remoteUid;
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint('onUserOffline: $remoteUid');
              setState(() => _remoteUid = null);
              _remoteVideoUid = null;
            },
        onError: (err, msg) {
          debugPrint('Agora error: $err - $msg');
        },
      ),
    );

    // Set client role
    await _engine.setClientRole(
      role: widget.isMentor
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
    );

    // Enable video
    await _engine.enableVideo();

    // Setup local video
    await _setupLocalVideo();

    // Join channel
    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: 0,
      options: ChannelMediaOptions(),
    );
  }

  Future<void> _setupLocalVideo() async {
    // Enable local video
    await _engine.enableLocalVideo(true);

    // Start preview
    await _engine.startPreview();

    // Setup local video render view
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video (full screen)
          if (_remoteUid != null)
            _buildRemoteVideo()
          else
            _buildWaitingScreen(),

          // Local video (small overlay)
          _buildLocalVideoOverlay(),

          // Top bar with duration
          _buildTopBar(),

          // Bottom controls
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildRemoteVideo() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid!),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      ),
    );
  }

  Widget _buildWaitingScreen() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
              child: Text(
                widget.peerName.isNotEmpty
                    ? widget.peerName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 40,
                  color: AppColors.primaryCyan,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Waiting for ${widget.peerName} to join...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalVideoOverlay() {
    return Positioned(
      top: 60,
      right: 16,
      child: Container(
        width: 100,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AgoraVideoView(
            controller: VideoViewController.local(
              rtcEngine: _engine,
              canvas: const VideoCanvas(uid: 0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 20,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => _leaveCall(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatDuration(_callDuration),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              label: _isMuted ? 'Unmute' : 'Mute',
              onPressed: _toggleMute,
              color: _isMuted ? Colors.red : Colors.white,
            ),
            _buildControlButton(
              icon: Icons.call_end,
              label: 'End',
              onPressed: _leaveCall,
              color: Colors.red,
            ),
            _buildControlButton(
              icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
              label: _isCameraOff ? 'Camera On' : 'Camera Off',
              onPressed: _toggleCamera,
              color: _isCameraOff ? Colors.red : Colors.white,
            ),
            _buildControlButton(
              icon: Icons.switch_camera,
              label: 'Switch',
              onPressed: _switchCamera,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withOpacity(0.2),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }

  Future<void> _leaveCall() async {
    _durationTimer?.cancel();
    await _engine.stopPreview();
    await _engine.leaveChannel();
    await _engine.release();

    // End call in provider
    final videoProvider = context.read<VideoProvider>();
    await videoProvider.endCall();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _engine.muteLocalAudioStream(_isMuted);
  }

  void _toggleCamera() {
    setState(() => _isCameraOff = !_isCameraOff);
    _engine.muteLocalVideoStream(_isCameraOff);
  }

  void _switchCamera() {
    _engine.switchCamera();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }
}
