// providers/stats_provider.dart — v10 XP, achievements, career stats
import 'package:flutter/material.dart';
import '../data/datasources/remote/api_service.dart';
import '../data/datasources/local/token_store.dart';

class Achievement {
  final String keyName, title, description, icon, category;
  final int xpReward;
  final DateTime earnedAt;
  const Achievement({
    required this.keyName, required this.title,
    required this.description, required this.icon,
    required this.category, required this.xpReward,
    required this.earnedAt,
  });
  factory Achievement.fromJson(Map<String,dynamic> j) => Achievement(
    keyName:     j['key_name'] as String? ?? '',
    title:       j['title'] as String? ?? '',
    description: j['description'] as String? ?? '',
    icon:        j['icon'] as String? ?? '🏆',
    category:    j['category'] as String? ?? 'general',
    xpReward:    (j['xp_reward'] as num?)?.toInt() ?? 0,
    earnedAt:    DateTime.tryParse(j['earned_at'] as String? ?? '') ?? DateTime.now(),
  );
}

class CareerStats {
  final int applicationsSent, hiredCount, shortlistedCount;
  final int savedJobs, totalConnections, achievementsEarned;
  final int totalXp, aiSessions, messagesSent;
  const CareerStats({
    this.applicationsSent = 0, this.hiredCount = 0,
    this.shortlistedCount = 0, this.savedJobs = 0,
    this.totalConnections = 0, this.achievementsEarned = 0,
    this.totalXp = 0, this.aiSessions = 0, this.messagesSent = 0,
  });
  factory CareerStats.fromJson(Map<String,dynamic> j) => CareerStats(
    applicationsSent:  (j['applications_sent']  as num?)?.toInt() ?? 0,
    hiredCount:        (j['hired_count']         as num?)?.toInt() ?? 0,
    shortlistedCount:  (j['shortlisted_count']   as num?)?.toInt() ?? 0,
    savedJobs:         (j['saved_jobs']          as num?)?.toInt() ?? 0,
    totalConnections:  (j['total_connections']   as num?)?.toInt() ?? 0,
    achievementsEarned:(j['achievements_earned'] as num?)?.toInt() ?? 0,
    totalXp:           (j['total_xp']           as num?)?.toInt() ?? 0,
    aiSessions:        (j['ai_sessions']         as num?)?.toInt() ?? 0,
    messagesSent:      (j['messages_sent']       as num?)?.toInt() ?? 0,
  );

  // XP level system
  int get level => (totalXp / 500).floor() + 1;
  int get xpInLevel => totalXp % 500;
  int get xpForNextLevel => 500;
  double get levelProgress => xpInLevel / xpForNextLevel;
  String get levelTitle {
    if (level <= 2)  return 'Career Starter';
    if (level <= 5)  return 'Rising Professional';
    if (level <= 10) return 'Skilled Navigator';
    if (level <= 20) return 'Career Expert';
    return 'Elite Professional';
  }
}

class StatsProvider extends ChangeNotifier {
  final _api   = ApiService();
  final _store = TokenStore();

  CareerStats? _stats;
  List<Achievement> _achievements = [];
  bool _loading = false;

  CareerStats? get stats         => _stats;
  List<Achievement> get achievements => _achievements;
  bool get isLoading             => _loading;

  Future<void> load() async {
    _loading = true; notifyListeners();
    try {
      final token = await _store.getAccess() ?? '';
      final sRes  = await _api.getUserStats(token: token);
      final aRes  = await _api.getAchievements(token: token);
      if (sRes['success'] == true) {
        _stats = CareerStats.fromJson(sRes['data'] as Map<String,dynamic>);
      }
      if (aRes['success'] == true) {
        final list = aRes['data'] as List<dynamic>? ?? [];
        _achievements = list.map((e) => Achievement.fromJson(e as Map<String,dynamic>)).toList();
      }
    } catch (_) {} finally {
      _loading = false; notifyListeners();
    }
  }
}
