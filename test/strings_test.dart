import 'package:addady/domain/language.dart';
import 'package:addady/ui/strings.dart';
import 'package:flutter_test/flutter_test.dart';

final _arabicLetter = RegExp(r'[\u0600-\u06FF]');

void main() {
  test('every key has a non-empty Arabic and English text', () {
    for (final e in S.table.entries) {
      expect(e.value.length, equals(2));
      expect(e.value[0].trim().isNotEmpty, isTrue);
      expect(e.value[1].trim().isNotEmpty, isTrue);
    }
  });

  test('Arabic texts contain Arabic letters; English texts contain none (except the shared language names)', () {
    const shared = {'languageArabic', 'languageEnglish'};
    for (final e in S.table.entries) {
      if (shared.contains(e.key)) continue;
      if (e.key == 'appName') {
        expect(_arabicLetter.hasMatch(e.value[0]), isTrue);
        continue;
      }
      expect(_arabicLetter.hasMatch(e.value[0]), isTrue);
      expect(_arabicLetter.hasMatch(e.value[1]), isFalse);
    }
  });

  test('the getters follow the active language', () {
    AppLanguage.code = 'en';
    expect(S.myMeters, equals('My meters'));
    expect(S.chartSemantics(3), equals('Consumption chart, 3 periods'));
    AppLanguage.code = 'ar';
    expect(S.myMeters, equals('عداداتي'));
    expect(S.chartSemantics(3).contains('3'), isTrue);
  });
}
