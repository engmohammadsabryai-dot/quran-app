import '../../domain/models/user_profile.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/local/database.dart';
import '../datasources/secure/secure_storage_service.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final AppDatabase _db;
  final SecureStorageService _secureStorage;

  ProfileRepositoryImpl({
    AppDatabase? db,
    SecureStorageService? secureStorage,
  })  : _db = db ?? AppDatabase.instance,
        _secureStorage = secureStorage ?? SecureStorageService();

  @override
  Stream<List<UserProfile>> watchProfiles() => _db.watchProfiles();

  @override
  Stream<UserProfile?> watchActiveProfile() => _db.watchActiveProfile();

  @override
  Future<void> switchProfile(String userId) async {
    await _db.switchActiveProfile(userId);
    await _secureStorage.saveActiveUserId(userId);
  }

  @override
  Future<void> createProfile(UserProfile profile) async {
    await _db.upsertProfile(profile);
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    await _db.upsertProfile(profile);
  }
}
