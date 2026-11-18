import '../domain/language.dart';
import '../domain/notifications.dart';
import 'strings.dart';

/// Numeric runs are wrapped in left-to-right isolates so dates and percentages keep their order inside Arabic text.
String _ltr(String s) => '\u2066$s\u2069';

/// Built again whenever the language changes, so scheduled reminders are re-armed with the new texts.
NotificationTexts notificationTexts() => NotificationTexts(
      dueTitle: S.notifDueTitle,
      dueBody: (meterTitle, lastDate) => AppLanguage.isArabic
          ? 'حان موعد قراءة $meterTitle. آخر قراءة بتاريخ ${_ltr(lastDate)}.'
          : 'Time to read $meterTitle. Last reading on ${_ltr(lastDate)}.',
      spikeTitle: S.notifSpikeTitle,
      spikeBody: (meterTitle, percent) => AppLanguage.isArabic
          ? '$meterTitle: ${_ltr(percent)} مقارنة بالفترة السابقة. تنبيه للمراجعة وليس تشخيصًا للسبب.'
          : '$meterTitle: ${_ltr(percent)} compared with the previous period. A prompt to review, not a diagnosis of the cause.',
    );
