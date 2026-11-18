import 'package:addady/domain/app_data.dart';
import 'package:addady/domain/language.dart';
import 'package:addady/domain/models.dart';
import 'package:addady/ui/notification_texts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('language is stored and restored; unknown values fall back to Arabic', () {
    expect(AppData.decode(const AppData(language: 'en').encode()).language, equals('en'));
    expect(AppData.decode(const AppData().encode()).language, equals('ar'));
    expect(AppData.decode('{"language":"fr"}').language, equals('ar'));
  });

  test('utility labels and meter titles follow the language', () {
    const meter = Meter(id: '1', type: UtilityType.water, place: 'Flat', unit: 'm³');
    AppLanguage.code = 'en';
    expect(meter.title, equals('Water — Flat'));
    AppLanguage.code = 'ar';
    expect(meter.title, equals('مياه — Flat'));
  });

  test('notification texts follow the language at the moment they are produced', () {
    final texts = notificationTexts();
    AppLanguage.code = 'en';
    expect(texts.dueBody('Water', '2026/01/01').startsWith('Time to read Water'), isTrue);
    expect(texts.spikeBody('Water', '+40%').contains('+40%'), isTrue);
    AppLanguage.code = 'ar';
    expect(texts.dueBody('مياه', '2026/01/01').startsWith('حان موعد'), isTrue);
  });
}
