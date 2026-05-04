class UserPhoto {
  final int id;
  final String photoUrl;
  final int photoOrder;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPhoto({
    required this.id,
    required this.photoUrl,
    required this.photoOrder,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserPhoto.fromJson(Map<String, dynamic> json) {
    return UserPhoto(
      id: json['id'] as int,
      photoUrl: json['photoUrl'] as String,
      photoOrder: json['photoOrder'] as int,
      isPrimary: json['isPrimary'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'photoUrl': photoUrl,
      'photoOrder': photoOrder,
      'isPrimary': isPrimary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}