enum UserRole {
  user,
  moderator,
  admin;

  static UserRole fromString(String val) {
    return UserRole.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => UserRole.user,
    );
  }
}

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final UserRole role;
  final String? campusRegistrationNumber;
  final int reputationScore;
  final bool isBanned;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.role = UserRole.user,
    this.campusRegistrationNumber,
    this.reputationScore = 100,
    this.isBanned = false,
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin || role == UserRole.moderator;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name,
      'campusRegistrationNumber': campusRegistrationNumber,
      'reputationScore': reputationScore,
      'isBanned': isBanned,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      uid: id,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Campus Student',
      photoUrl: map['photoUrl'] as String?,
      role: UserRole.fromString(map['role'] as String? ?? 'user'),
      campusRegistrationNumber: map['campusRegistrationNumber'] as String?,
      reputationScore: (map['reputationScore'] as num?)?.toInt() ?? 100,
      isBanned: map['isBanned'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    String? campusRegistrationNumber,
    int? reputationScore,
    bool? isBanned,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      campusRegistrationNumber:
          campusRegistrationNumber ?? this.campusRegistrationNumber,
      reputationScore: reputationScore ?? this.reputationScore,
      isBanned: isBanned ?? this.isBanned,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
