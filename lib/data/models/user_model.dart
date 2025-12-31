/// UserModel - Data model for user in Firestore
class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? username;
  final DateTime? birthday;
  final String? partnerId;
  final String? coupleId;
  final String? avatar; // NEW: 'DEFAULT', 'assets/...', or 'base64:...'
  final DateTime? lastActive; // NEW: For online/offline status
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.username,
    this.birthday,
    this.partnerId,
    this.coupleId,
    this.avatar,
    this.lastActive,
    required this.createdAt,
  });

  /// Check if profile is complete (has name)
  bool get hasCompletedProfile => name != null && name!.isNotEmpty;

  /// Check if user is paired with partner
  bool get isPaired => partnerId != null && partnerId!.isNotEmpty;

  /// Check if user is online (active within last 5 minutes)
  bool get isOnline {
    if (lastActive == null) return false;
    return DateTime.now().difference(lastActive!).inMinutes < 5;
  }

  /// Create from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      uid: docId,
      email: map['email'] ?? '',
      name: map['name'],
      username: map['username'],
      birthday: map['birthday'] != null
          ? DateTime.tryParse(map['birthday'])
          : null,
      partnerId: map['partnerId'],
      coupleId: map['coupleId'],
      avatar: map['avatar'],
      lastActive: map['lastActive'] != null
          ? DateTime.tryParse(map['lastActive'])
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'username': username,
      'birthday': birthday?.toIso8601String(),
      'partnerId': partnerId,
      'coupleId': coupleId,
      'avatar': avatar,
      'lastActive': lastActive?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create copy with updated fields
  UserModel copyWith({
    String? name,
    String? username,
    DateTime? birthday,
    String? partnerId,
    String? coupleId,
    String? avatar,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      username: username ?? this.username,
      birthday: birthday ?? this.birthday,
      partnerId: partnerId ?? this.partnerId,
      coupleId: coupleId ?? this.coupleId,
      avatar: avatar ?? this.avatar,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt,
    );
  }
}
