import 'package:equatable/equatable.dart';
import '../../../domain/models/user_profile.dart';

class ProfileState extends Equatable {
  final List<UserProfile> profiles;
  final UserProfile? activeProfile;
  final bool isLoading;
  final String? errorMessage;

  const ProfileState({
    this.profiles = const [],
    this.activeProfile,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Dynamic Dual-UI routing indicator
  bool get isKidsMode => activeProfile?.isChild ?? false;

  ProfileState copyWith({
    List<UserProfile>? profiles,
    UserProfile? activeProfile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ProfileState(
      profiles: profiles ?? this.profiles,
      activeProfile: activeProfile ?? this.activeProfile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [profiles, activeProfile, isLoading, errorMessage];
}
