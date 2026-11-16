import '../domain/notifications.dart';
import 'strings.dart';

/// Numeric runs are wrapped in left-to-right isolates so dates and percentages keep their order inside Arabic text.
String _ltr(String s) => '\u2066$s\u2069';

final NotificationTexts arabicNotificationTexts = NotificationTexts(
  dueTitle: S.notifDueTitle,
  dueBody: (meterTitle, lastDate) => 'حان موعد قراءة $meterTitle. آخر قراءة بتاريخ ${_ltr(lastDate)}.',
  spikeTitle: S.notifSpikeTitle,
  spikeBody: (meterTitle, percent) =>
      '$meterTitle: ${_ltr(percent)} مقارنة بالفترة السابقة. تنبيه للمراجعة وليس تشخيصًا للسبب.',
);
