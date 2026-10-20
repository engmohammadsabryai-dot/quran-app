import 'package:flutter_test/flutter_test.dart';
import 'package:quran_memorization_engine/data/datasources/local/seed_data.dart';
import 'package:quran_memorization_engine/domain/models/user_profile.dart';

void main() {
  group('UserProfile Dynamic Dual-UI Routing Tests', () {
    test('User with age < 15 is identified as child (Kids Mode)', () {
      final childProfile = UserProfile(
        userId: 'child-1',
        name: 'سالم',
        age: 9,
        gender: 'male',
        avatarId: 'kid_salem',
        createdAt: DateTime.now(),
      );

      expect(childProfile.isChild, isTrue);
    });

    test('User with age >= 15 is identified as adult (Adult Mode)', () {
      final adultProfile = UserProfile(
        userId: 'adult-1',
        name: 'عبد الرحمن',
        age: 28,
        gender: 'male',
        avatarId: 'adult_1',
        createdAt: DateTime.now(),
      );

      expect(adultProfile.isChild, isFalse);
    });
  });

  group('Mutashabihat Engine Tests', () {
    test('Matches verbal similarities by Surah and Ayah range', () {
      final catalog = AppSeedData.mutashabihatCatalog;

      // Item 1 is Al-Baqarah 48 vs 123
      final item1 = catalog.first;
      expect(item1.matchesAyah(2, 48), isTrue);
      expect(item1.matchesAyah(2, 123), isTrue);
      expect(item1.matchesAyah(2, 50), isFalse);

      // Check range query (Quarter 4 contains ayah 48)
      expect(item1.isInRange(2, 44, 59), isTrue);
      expect(item1.isInRange(2, 1, 25), isFalse);

      // Mnemonic rule must be populated
      expect(item1.ruleMnemonic, isNotEmpty);
      expect(item1.differenceHighlight, isNotEmpty);
    });
  });
}
