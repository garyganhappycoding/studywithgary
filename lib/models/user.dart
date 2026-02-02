import 'knowledge_card.dart';
import 'knowledge_folder.dart';
import 'study_session.dart';
import 'battle_session.dart';
import 'reward.dart';
import 'chest.dart';

class User {
  int arenaPoints;
  List<KnowledgeCard> cards;
  List<KnowledgeFolder> folders;
  List<StudySession> sessions;
  List<BattleSession> battleSessions;
  List<Chest> chests;
  List<Reward> rewards;

  User({
    required this.arenaPoints,
    required this.cards,
    required this.folders,
    required this.sessions,
    required this.battleSessions,
    required this.chests,
    required this.rewards,
  });

  Map<String, dynamic> toJson() {
    return {
      'arenaPoints': arenaPoints,
      'cards': cards.map((c) => c.toJson()).toList(),
      'folders': folders.map((f) => f.toJson()).toList(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'battleSessions': battleSessions.map((b) => b.toJson()).toList(),
      'chests': chests.map((c) => c.toJson()).toList(),
      'rewards': rewards.map((r) => r.toJson()).toList(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      arenaPoints: json['arenaPoints'] ?? 0,
      cards: (json['cards'] as List?)
          ?.map((c) => KnowledgeCard.fromJson(c))
          .toList() ??
          [],
      folders: (json['folders'] as List?)
          ?.map((f) => KnowledgeFolder.fromJson(f))
          .toList() ??
          [],
      sessions: (json['sessions'] as List?)
          ?.map((s) => StudySession.fromJson(s))
          .toList() ??
          [],
      battleSessions: (json['battleSessions'] as List?)
          ?.map((b) => BattleSession.fromJson(b))
          .toList() ??
          [],
      chests: (json['chests'] as List?)
          ?.map((c) => Chest.fromJson(c))
          .toList() ??
          [],
      rewards: (json['rewards'] as List?)
          ?.map((r) => Reward.fromJson(r))
          .toList() ??
          [],
    );
  }
}
