import '../models/mutashabiha_item.dart';

abstract class IMutashabihatRepository {
  Stream<List<MutashabihaItem>> watchMutashabihat();
  List<MutashabihaItem> getMutashabihatForAyahRange(int surah, int fromAyah, int toAyah);
}
