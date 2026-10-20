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

    _initStreams();
  }

  void _initStreams() {
    _profilesSubscription = _profileRepository.watchProfiles().listen((profiles) {
      final active = profiles.cast<dynamic>().firstWhere(
            (p) => p.isActive == true,
            orElse: () => profiles.isNotEmpty ? profiles.first : null,
          );
      emit(state.copyWith(
        profiles: profiles,
        activeProfile: active,
        isLoading: false,
      ));
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
