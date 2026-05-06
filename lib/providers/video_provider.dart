import 'package:flutter/material.dart';
import '../data/models/video_session_model.dart';
import '../data/repositories/video_repository.dart';

class VideoProvider extends ChangeNotifier {
  final VideoRepository _videoRepository = VideoRepository();

  List<VideoSession> _sessions = [];
  bool _isLoading = false;
  String? _error;
  bool _isInCall = false;
  String? _currentChannel;
  int _callStartTime = 0;

  List<VideoSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInCall => _isInCall;
  String? get currentChannel => _currentChannel;

  Future<Map<String, dynamic>> startCall({
    required int mentorId,
    required int seekerId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _videoRepository.startSession(
        mentorId: mentorId,
        seekerId: seekerId,
      );
      _setLoading(false);
      _isInCall = true;
      _currentChannel = result['channel_name'];
      _callStartTime = DateTime.now().millisecondsSinceEpoch;
      return result;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> joinCall(String channelName) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _videoRepository.joinSession(channelName);
      _setLoading(false);
      _isInCall = true;
      _currentChannel = channelName;
      _callStartTime = DateTime.now().millisecondsSinceEpoch;
      return result;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> endCall() async {
    if (_currentChannel == null) return;

    final duration =
        (DateTime.now().millisecondsSinceEpoch - _callStartTime) ~/ 1000;

    try {
      await _videoRepository.endSession(_currentChannel!, duration);
      _isInCall = false;
      _currentChannel = null;
      await loadSessions();
      notifyListeners();
    } catch (e) {
      debugPrint('Error ending call: $e');
    }
  }

  Future<void> loadSessions() async {
    _setLoading(true);
    _clearError();

    try {
      _sessions = await _videoRepository.getSessions();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
