enum RewardType { common, rare, epic, legendary }

class Reward {
  String id;
  String title;
  String description;
  RewardType type;
  bool claimed;
  DateTime createdAt;

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.claimed = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'claimed': claimed,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: _parseRewardType(json['type'] ?? 'common'),
      claimed: json['claimed'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
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
