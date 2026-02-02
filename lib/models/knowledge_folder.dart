class KnowledgeFolder {
  String id;
  String name;
  String description;
  bool isExpanded;

  KnowledgeFolder({
    required this.id,
    required this.name,
    required this.description,
    this.isExpanded = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isExpanded': isExpanded,
    };
  }

  factory KnowledgeFolder.fromJson(Map<String, dynamic> json) {
    return KnowledgeFolder(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isExpanded: json['isExpanded'] ?? false,
    );
  }
}
