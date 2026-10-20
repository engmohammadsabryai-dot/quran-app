import '../models/user_profile.dart';

abstract class IProfileRepository {
  Stream<List<UserProfile>> watchProfiles();
  Stream<UserProfile?> watchActiveProfile();
  Future<void> switchProfile(String userId);
  Future<void> createProfile(UserProfile profile);
  Future<void> updateProfile(UserProfile profile);
}
