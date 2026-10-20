import '../../domain/models/mutashabiha_item.dart';
import '../../domain/repositories/i_mutashabihat_repository.dart';
import '../datasources/local/database.dart';

class MutashabihatRepositoryImpl implements IMutashabihatRepository {
  final AppDatabase _db;

  MutashabihatRepositoryImpl({AppDatabase? db}) : _db = db ?? AppDatabase.instance;

  @override
  Stream<List<MutashabihaItem>> watchMutashabihat() => _db.watchMutashabihat();

  @override
  List<MutashabihaItem> getMutashabihatForAyahRange(int surah, int fromAyah, int toAyah) {
    return _db.getMutashabihatForAyahRange(surah, fromAyah, toAyah);
  }
}
