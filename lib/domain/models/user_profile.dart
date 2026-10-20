import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String userId;
  final String name;
  final int age;
  final String gender; // 'male' or 'female'
  final String avatarId;
  final bool isActive;
  final DateTime createdAt;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.avatarId,
    this.isActive = false,
    required this.createdAt,
  });

  /// Dynamic Dual-UI Experience Routing:
  /// If age < 15, activate Child Mode (KidsFunTheme); otherwise Adult Mode.
  bool get isChild => age < 15;

  UserProfile copyWith({
    String? userId,
    String? name,
    int? age,
    String? gender,
    String? avatarId,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      avatarId: avatarId ?? this.avatarId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [userId, name, age, gender, avatarId, isActive, createdAt];
}
