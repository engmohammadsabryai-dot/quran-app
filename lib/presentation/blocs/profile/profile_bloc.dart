import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/i_profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IProfileRepository _profileRepository;
  StreamSubscription? _profilesSubscription;
  StreamSubscription? _activeProfileSubscription;

  ProfileBloc({required IProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(const ProfileState(isLoading: true)) {
    on<LoadProfilesEvent>(_onLoadProfiles);
    on<SwitchProfileEvent>(_onSwitchProfile);
    on<CreateProfileEvent>(_onCreateProfile);

    on<_ProfilesUpdatedEvent>((event, emit) {
      final active = event.profiles.cast<dynamic>().firstWhere(
            (p) => p.isActive == true,
            orElse: () => event.profiles.isNotEmpty ? event.profiles.first : null,
          );
      emit(state.copyWith(
        profiles: event.profiles.cast(),
        activeProfile: active,
        isLoading: false,
      ));
    });

    _initStreams();
  }

  void _initStreams() {
    _profilesSubscription = _profileRepository.watchProfiles().listen((profiles) {
      add(_ProfilesUpdatedEvent(profiles));
    });
  }

  Future<void> _onLoadProfiles(LoadProfilesEvent event, Emitter<ProfileState> emit) async {
    // Handled reactively by stream
  }

  Future<void> _onSwitchProfile(SwitchProfileEvent event, Emitter<ProfileState> emit) async {
    try {
      await _profileRepository.switchProfile(event.userId);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'فشل في تبديل الملف الشخصي: $e'));
    }
  }

  Future<void> _onCreateProfile(CreateProfileEvent event, Emitter<ProfileState> emit) async {
    try {
      await _profileRepository.createProfile(event.profile);
    } catch (e) {
      emit(state.copyWith(errorMessage: 'فشل في إضافة الملف الشخصي: $e'));
    }
  }

  @override
  Future<void> close() {
    _profilesSubscription?.cancel();
    _activeProfileSubscription?.cancel();
    return super.close();
  }
}

class _ProfilesUpdatedEvent extends ProfileEvent {
  final List<dynamic> profiles;
  const _ProfilesUpdatedEvent(this.profiles);

  @override
  List<Object?> get props => [profiles];
}
