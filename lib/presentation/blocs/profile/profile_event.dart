import 'package:equatable/equatable.dart';
import '../../../domain/models/user_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfilesEvent extends ProfileEvent {
  const LoadProfilesEvent();
}

class SwitchProfileEvent extends ProfileEvent {
  final String userId;
  const SwitchProfileEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateProfileEvent extends ProfileEvent {
  final UserProfile profile;
  const CreateProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}
