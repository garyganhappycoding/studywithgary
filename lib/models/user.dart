// lib/models/user_model.dart (rename from user.dart if needed)

class UserModel {
   int arenaPoints;
  // NO lists of cards, folders, sessions here. They are in separate subcollections.
  // Add other top-level user properties like email, username, etc. if you load them with the user doc.

  UserModel({
    required this.arenaPoints,
    // Add other properties as needed
  });

  // Factory constructor for creating a new User instance from a map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      arenaPoints: json['arenaPoints'] as int? ?? 0,
      // Map other properties if they exist in your user document
    );
  }

  // Method to convert a User instance into a map
  Map<String, dynamic> toJson() {
    return {
      'arenaPoints': arenaPoints,
      // Map other properties if they exist
    };
  }

  // Optional: copyWith method for immutability
  UserModel copyWith({
    int? arenaPoints,
  }) {
    return UserModel(
      arenaPoints: arenaPoints ?? this.arenaPoints,
    );
  }
}
