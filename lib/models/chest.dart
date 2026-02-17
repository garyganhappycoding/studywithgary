import 'reward.dart';

class Chest {
  String id;
  String reward;
  RewardType rewardType;
  bool opened;
  DateTime createdAt;
  DateTime? openedAt;

  Chest({
    required this.id,
    required this.reward,
    required this.rewardType,
    required this.opened,
    DateTime? createdAt,
    this.openedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ✅ ADD THIS copyWith METHOD
  Chest copyWith({
    String? id,
    String? reward,
    RewardType? rewardType,
    bool? opened,
    DateTime? createdAt,
    DateTime? openedAt,
  }) {
    return Chest(
      id: id ?? this.id,
      reward: reward ?? this.reward,
      rewardType: rewardType ?? this.rewardType,
      opened: opened ?? this.opened,
      createdAt: createdAt ?? this.createdAt,
      openedAt: openedAt ?? this.openedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reward': reward,
      'rewardType': rewardType.toString().split('.').last,
      'opened': opened,
      'createdAt': createdAt.toIso8601String(),
      'openedAt': openedAt?.toIso8601String(),
    };
  }

  factory Chest.fromJson(Map<String, dynamic> json) {
    return Chest(
      id: json['id'] ?? '',
      reward: json['reward'] ?? '',
      rewardType: _parseRewardType(json['rewardType'] ?? 'common'),
      opened: json['opened'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      openedAt: json['openedAt'] != null ? DateTime.parse(json['openedAt']) : null,
    );
  }

  static RewardType _parseRewardType(String typeString) {
    switch (typeString) {
      case 'common':
        return RewardType.common;
      case 'rare':
        return RewardType.rare;
      case 'epic':
        return RewardType.epic;
      case 'legendary':
        return RewardType.legendary;
      default:
        return RewardType.common;
    }
  }
}
