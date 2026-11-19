/// Pure Dart: the app language, shared by the UI strings, the domain labels and the notification texts.
/// A single global is enough for a one-user, one-screen-at-a-time app; the store sets it on load and on change.
library;

class AppLanguage {
  const AppLanguage._();

  /// 'ar' or 'en'.
  static String code = 'ar';

  static bool get isArabic => code != 'en';
}
