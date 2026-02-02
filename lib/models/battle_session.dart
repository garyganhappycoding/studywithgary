class BattleSession {
  String id;
  String opponentId;
  String opponentName;
  int pointsAwarded;
  bool isVictory;
  DateTime battleTime;
  int questionsAnswered;
  int questionsCorrect;
  DateTime createdAt;
  DateTime? endTime;
  int tower1Won;
  int tower2Won;
  int tower3Won;
  String tower1Goal;
  String tower2Goal;
  String tower3Goal;
  int focusCount;
  bool completedAt;

  BattleSession({
    required this.id,
    required this.opponentId,
    required this.opponentName,
    required this.pointsAwarded,
    required this.isVictory,
    required this.battleTime,
    required this.questionsAnswered,
    required this.questionsCorrect,
    DateTime? createdAt,
    this.endTime,
    this.tower1Won = 0,
    this.tower2Won = 0,
    this.tower3Won = 0,
    this.tower1Goal = "",
    this.tower2Goal = "",
    this.tower3Goal = "",
    this.focusCount = 0,
    this.completedAt = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'opponentId': opponentId,
      'opponentName': opponentName,
      'pointsAwarded': pointsAwarded,
      'isVictory': isVictory,
      'battleTime': battleTime.toIso8601String(),
      'questionsAnswered': questionsAnswered,
      'questionsCorrect': questionsCorrect,
      'createdAt': createdAt.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'tower1Won': tower1Won,
      'tower2Won': tower2Won,
      'tower3Won': tower3Won,
      'tower1Goal': tower1Goal,
      'tower2Goal': tower2Goal,
      'tower3Goal': tower3Goal,
      'focusCount': focusCount,
      'completedAt': completedAt,
    };
  }

  factory BattleSession.fromJson(Map<String, dynamic> json) {
    return BattleSession(
      id: json['id'] ?? '',
      opponentId: json['opponentId'] ?? '',
      opponentName: json['opponentName'] ?? '',
      pointsAwarded: json['pointsAwarded'] ?? 0,
      isVictory: json['isVictory'] ?? false,
      battleTime: DateTime.parse(json['battleTime'] ?? DateTime.now().toIso8601String()),
      questionsAnswered: json['questionsAnswered'] ?? 0,
      questionsCorrect: json['questionsCorrect'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      tower1Won: json['tower1Won'] ?? 0,
      tower2Won: json['tower2Won'] ?? 0,
      tower3Won: json['tower3Won'] ?? 0,
      tower1Goal: json['tower1Goal'] ?? 0,
      tower2Goal: json['tower2Goal'] ?? 0,
      tower3Goal: json['tower3Goal'] ?? 0,
      focusCount: json['focusCount'] ?? 0,
      completedAt: json['completedAt'] ?? false,
    );
  }
}
