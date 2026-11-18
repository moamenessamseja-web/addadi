/// All user-visible text, Arabic and English side by side (one table, one getter per key).
/// The active language is `AppLanguage.code`; getters are not const, so widgets that use them are not const either.
import '../domain/language.dart';

class S {
  const S._();

  static String _t(String key) => table[key]![AppLanguage.isArabic ? 0 : 1];

  static String get appName => _t('appName');
  static String get promise => _t('promise');
  static String get tabMeters => _t('tabMeters');
  static String get tabAddReading => _t('tabAddReading');
  static String get tabAnalytics => _t('tabAnalytics');
  static String get myMeters => _t('myMeters');
  static String get addMeter => _t('addMeter');
  static String get noMetersTitle => _t('noMetersTitle');
  static String get noMetersBody => _t('noMetersBody');
  static String get overview => _t('overview');
  static String get metersCount => _t('metersCount');
  static String get needAttention => _t('needAttention');
  static String get noReadingYet => _t('noReadingYet');
  static String get due => _t('due');
  static String get stable => _t('stable');
  static String get spike => _t('spike');
  static String get insufficientHistory => _t('insufficientHistory');
  static String get resetMarker => _t('resetMarker');
  static String get latestReading => _t('latestReading');
  static String get periodConsumption => _t('periodConsumption');
  static String get comparedWithPrevious => _t('comparedWithPrevious');
  static String get addReadingAction => _t('addReadingAction');
  static String get analyticsAction => _t('analyticsAction');
  static String get bellTooltip => _t('bellTooltip');
  static String get noAlerts => _t('noAlerts');
  static String get alertsTitle => _t('alertsTitle');
  static String get chooseMeter => _t('chooseMeter');
  static String get previousReading => _t('previousReading');
  static String get noPreviousReading => _t('noPreviousReading');
  static String get newReading => _t('newReading');
  static String get readingDateTime => _t('readingDateTime');
  static String get resetToggle => _t('resetToggle');
  static String get resetHelper => _t('resetHelper');
  static String get resetConfirmTitle => _t('resetConfirmTitle');
  static String get resetConfirmBody => _t('resetConfirmBody');
  static String get calculation => _t('calculation');
  static String get noCalculation => _t('noCalculation');
  static String get save => _t('save');
  static String get savedOnDevice => _t('savedOnDevice');
  static String get saveFailed => _t('saveFailed');
  static String get cancel => _t('cancel');
  static String get confirm => _t('confirm');
  static String get addMeterFirst => _t('addMeterFirst');
  static String get spikeDetected => _t('spikeDetected');
  static String get problemInvalid => _t('problemInvalid');
  static String get problemOlder => _t('problemOlder');
  static String get problemLower => _t('problemLower');
  static String get meterType => _t('meterType');
  static String get place => _t('place');
  static String get unit => _t('unit');
  static String get addMeterTitle => _t('addMeterTitle');
  static String get selectMeter => _t('selectMeter');
  static String get currentComparison => _t('currentComparison');
  static String get currentPeriod => _t('currentPeriod');
  static String get previousPeriod => _t('previousPeriod');
  static String get absoluteVariance => _t('absoluteVariance');
  static String get monthlyChart => _t('monthlyChart');
  static String get chartNote => _t('chartNote');
  static String get burnRate => _t('burnRate');
  static String get perDay => _t('perDay');
  static String get notEnoughHistory => _t('notEnoughHistory');
  static String get noMeterSelected => _t('noMeterSelected');
  static String get manageMeters => _t('manageMeters');
  static String get alertThreshold => _t('alertThreshold');
  static String get theme => _t('theme');
  static String get themeSystem => _t('themeSystem');
  static String get themeLight => _t('themeLight');
  static String get themeDark => _t('themeDark');
  static String get deleteMeter => _t('deleteMeter');
  static String get deleteConfirmTitle => _t('deleteConfirmTitle');
  static String get deleteConfirmBody => _t('deleteConfirmBody');
  static String get delete => _t('delete');
  static String get thresholdHelper => _t('thresholdHelper');
  static String get close => _t('close');
  static String get saveSetting => _t('saveSetting');
  static String get meterReadingsCount => _t('meterReadingsCount');
  static String get noMetersToManage => _t('noMetersToManage');
  static String get editMeter => _t('editMeter');
  static String get saveMeter => _t('saveMeter');
  static String get tariffSection => _t('tariffSection');
  static String get tariffEnable => _t('tariffEnable');
  static String get tariffHelper => _t('tariffHelper');
  static String get currency => _t('currency');
  static String get fixedFee => _t('fixedFee');
  static String get tierUpTo => _t('tierUpTo');
  static String get tierPrice => _t('tierPrice');
  static String get tierRest => _t('tierRest');
  static String get addTier => _t('addTier');
  static String get removeTier => _t('removeTier');
  static String get tariffSet => _t('tariffSet');
  static String get tariffNeedsNumbers => _t('tariffNeedsNumbers');
  static String get tariffNoTiers => _t('tariffNoTiers');
  static String get tariffBadPrice => _t('tariffBadPrice');
  static String get tariffBadFee => _t('tariffBadFee');
  static String get tariffBadLimit => _t('tariffBadLimit');
  static String get tariffLimitsOrder => _t('tariffLimitsOrder');
  static String get tariffLastOpen => _t('tariffLastOpen');
  static String get costEstimate => _t('costEstimate');
  static String get costNote => _t('costNote');
  static String get costBasis => _t('costBasis');
  static String get tiersWord => _t('tiersWord');
  static String get notificationsTitle => _t('notificationsTitle');
  static String get notificationsOn => _t('notificationsOn');
  static String get notificationsOff => _t('notificationsOff');
  static String get notificationsBlocked => _t('notificationsBlocked');
  static String get notificationsError => _t('notificationsError');
  static String get notifDueTitle => _t('notifDueTitle');
  static String get notifSpikeTitle => _t('notifSpikeTitle');
  static String get languageTitle => _t('languageTitle');
  static String get languageArabic => _t('languageArabic');
  static String get languageEnglish => _t('languageEnglish');
  static String get defaultCurrency => _t('defaultCurrency');
  static String get exportTitle => _t('exportTitle');
  static String get exportSubtitle => _t('exportSubtitle');
  static String get exportNothing => _t('exportNothing');
  static String get exportFailed => _t('exportFailed');
  static String get csvMeter => _t('csvMeter');
  static String get csvUnit => _t('csvUnit');
  static String get csvDate => _t('csvDate');
  static String get csvTime => _t('csvTime');
  static String get csvReading => _t('csvReading');
  static String get csvReset => _t('csvReset');
  static String get csvConsumption => _t('csvConsumption');

  // Texts with a number in them.
  static String chartSemantics(int periods) =>
      AppLanguage.isArabic ? 'رسم بياني للاستهلاك، $periods فترات' : 'Consumption chart, $periods periods';

  /// key -> [Arabic, English]. Tested: every key has both, Arabic keys contain Arabic letters, English ones do not.
  static const Map<String, List<String>> table = {
    'appName': ['عَدّادي', 'Ɛaddady'],
    'promise': ['اعرف استهلاكك قبل وصول الفاتورة.', 'Know your usage before the bill arrives.'],
    'tabMeters': ['العدادات', 'Meters'],
    'tabAddReading': ['إضافة قراءة', 'Add reading'],
    'tabAnalytics': ['التحليل', 'Analytics'],
    'myMeters': ['عداداتي', 'My meters'],
    'addMeter': ['إضافة عداد', 'Add meter'],
    'noMetersTitle': ['لم تضف أي عداد بعد', 'You haven\'t added a meter yet'],
    'noMetersBody': ['أضف عدادك الأول (كهرباء أو مياه أو غاز) ثم سجّل قراءاته. كل بياناتك تبقى على هذا الجهاز.', 'Add your first meter (electricity, water or gas), then record its readings. All your data stays on this device.'],
    'overview': ['نظرة عامة', 'Overview'],
    'metersCount': ['عدادات', 'meters'],
    'needAttention': ['تحتاج انتباهًا', 'need attention'],
    'noReadingYet': ['لم تُسجل قراءة', 'No reading yet'],
    'due': ['تحتاج قراءة', 'Reading due'],
    'stable': ['مستقر', 'Stable'],
    'spike': ['زيادة ملحوظة', 'Notable increase'],
    'insufficientHistory': ['يلزم تسجيل قراءة أخرى للمقارنة', 'One more reading is needed to compare'],
    'resetMarker': ['تم تسجيل إعادة ضبط أو استبدال — لا تتم المقارنة عبر هذا الحد', 'A reset or replacement was recorded — nothing is compared across this point'],
    'latestReading': ['آخر قراءة', 'Latest reading'],
    'periodConsumption': ['استهلاك الفترة', 'Period consumption'],
    'comparedWithPrevious': ['مقارنة بالفترة السابقة', 'Compared with the previous period'],
    'addReadingAction': ['إضافة قراءة', 'Add reading'],
    'analyticsAction': ['التحليل', 'Analytics'],
    'bellTooltip': ['التنبيهات', 'Alerts'],
    'noAlerts': ['لا توجد تنبيهات حاليًا', 'No alerts right now'],
    'alertsTitle': ['التنبيهات', 'Alerts'],
    'chooseMeter': ['اختر العداد', 'Choose the meter'],
    'previousReading': ['القراءة السابقة', 'Previous reading'],
    'noPreviousReading': ['لا توجد قراءة سابقة لهذا العداد', 'This meter has no previous reading'],
    'newReading': ['القراءة الجديدة', 'New reading'],
    'readingDateTime': ['تاريخ ووقت القراءة', 'Reading date and time'],
    'resetToggle': ['إعادة ضبط أو استبدال العداد', 'Meter reset or replaced'],
    'resetHelper': ['فعّلها إذا تم تغيير العداد أو إعادة تصفيره أو تجاوز سعته. تُحفظ القراءات القديمة ولا تُحسب فترة استهلاك عبر هذا الحد.', 'Turn this on if the meter was replaced, reset to zero, or rolled over its capacity. Old readings are kept and no consumption is calculated across this point.'],
    'resetConfirmTitle': ['تأكيد إعادة الضبط', 'Confirm reset'],
    'resetConfirmBody': ['ستبدأ هذه القراءة سجلًا جديدًا للمقارنة، ولن يُحسب استهلاك بينها وبين القراءة السابقة. هل تريد المتابعة؟', 'This reading starts a new comparison history, and no consumption is calculated between it and the previous reading. Continue?'],
    'calculation': ['الاستهلاك المحسوب', 'Calculated consumption'],
    'noCalculation': ['لا يوجد استهلاك محسوب بعد', 'No consumption calculated yet'],
    'save': ['حفظ القراءة', 'Save reading'],
    'savedOnDevice': ['تم حفظ القراءة على هذا الجهاز', 'Reading saved on this device'],
    'saveFailed': ['تعذّر الحفظ على هذا الجهاز. لم تُحفظ القراءة.', 'Could not save on this device. The reading was not saved.'],
    'cancel': ['إلغاء', 'Cancel'],
    'confirm': ['متابعة', 'Continue'],
    'addMeterFirst': ['أضف عدادًا أولًا من تبويب العدادات.', 'Add a meter first from the Meters tab.'],
    'spikeDetected': ['زيادة ملحوظة مقارنة بالفترة السابقة. هذا تنبيه للمراجعة وليس تشخيصًا للسبب.', 'Notable increase compared with the previous period. This is a prompt to review, not a diagnosis of the cause.'],
    'problemInvalid': ['أدخل قراءة صحيحة (أرقام فقط، بدون سالب).', 'Enter a valid reading (digits only, no negatives).'],
    'problemOlder': ['تاريخ القراءة أقدم من آخر قراءة مسجلة لهذا العداد.', 'The reading date is earlier than this meter\'s latest reading.'],
    'problemLower': ['القراءة أقل من القراءة السابقة. إن تم تغيير العداد أو تجاوز سعته فعّل «إعادة ضبط أو استبدال العداد».', 'The reading is lower than the previous one. If the meter was replaced or rolled over, turn on "Meter reset or replaced".'],
    'meterType': ['نوع العداد', 'Meter type'],
    'place': ['المكان (مثل: الشقة، المحل)', 'Place (e.g. apartment, shop)'],
    'unit': ['وحدة القياس', 'Unit of measure'],
    'addMeterTitle': ['عداد جديد', 'New meter'],
    'selectMeter': ['اختر عدادًا', 'Choose a meter'],
    'currentComparison': ['مقارنة الفترة الحالية', 'Current period comparison'],
    'currentPeriod': ['الفترة الحالية', 'Current period'],
    'previousPeriod': ['الفترة السابقة', 'Previous period'],
    'absoluteVariance': ['الفرق', 'Difference'],
    'monthlyChart': ['الاستهلاك لكل فترة قراءة', 'Consumption per reading period'],
    'chartNote': ['نقاط مقاسة فقط، دون تقدير للقراءات الناقصة.', 'Measured points only, no estimates for missing readings.'],
    'burnRate': ['متوسط الاستهلاك اليومي', 'Average daily consumption'],
    'perDay': ['في اليوم', 'per day'],
    'notEnoughHistory': ['لا توجد بيانات كافية للرسم بعد. سجّل قراءتين على الأقل بعد آخر إعادة ضبط.', 'Not enough data to draw yet. Record at least two readings after the last reset.'],
    'noMeterSelected': ['أضف عدادًا لعرض التحليل.', 'Add a meter to see analytics.'],
    'manageMeters': ['إدارة العدادات والأماكن', 'Manage meters and places'],
    'alertThreshold': ['حد تنبيه الزيادة', 'Increase alert threshold'],
    'theme': ['المظهر', 'Appearance'],
    'themeSystem': ['النظام', 'System'],
    'themeLight': ['فاتح', 'Light'],
    'themeDark': ['داكن', 'Dark'],
    'deleteMeter': ['حذف العداد', 'Delete meter'],
    'deleteConfirmTitle': ['حذف العداد؟', 'Delete this meter?'],
    'deleteConfirmBody': ['سيُحذف العداد وكل قراءاته من هذا الجهاز نهائيًا، ولا يمكن التراجع.', 'The meter and all its readings will be permanently deleted from this device. This cannot be undone.'],
    'delete': ['حذف', 'Delete'],
    'thresholdHelper': ['يُنبَّه عند زيادة استهلاك الفترة الحالية عن السابقة بهذه النسبة أو أكثر.', 'You are alerted when consumption in the current period is higher than in the previous period by this percentage or more.'],
    'close': ['إغلاق', 'Close'],
    'saveSetting': ['حفظ', 'Save'],
    'meterReadingsCount': ['قراءات', 'readings'],
    'noMetersToManage': ['لا توجد عدادات.', 'No meters.'],
    'editMeter': ['تعديل العداد', 'Edit meter'],
    'saveMeter': ['حفظ التعديلات', 'Save changes'],
    'tariffSection': ['التعرفة المحلية (اختياري)', 'Local tariff (optional)'],
    'tariffEnable': ['تقدير التكلفة بتعرفة أدخلها بنفسي', 'Estimate cost using a tariff I enter'],
    'tariffHelper': ['الأرقام تُدخلها أنت وتبقى على هذا الجهاز. النتيجة تقدير وليست فاتورة رسمية.', 'You enter the numbers and they stay on this device. The result is an estimate, not an official bill.'],
    'currency': ['العملة (مثل: ج.م)', 'Currency (e.g. EGP)'],
    'fixedFee': ['رسم ثابت لكل فترة', 'Fixed fee per period'],
    'tierUpTo': ['حتى (وحدة)', 'Up to (units)'],
    'tierPrice': ['السعر لكل وحدة', 'Price per unit'],
    'tierRest': ['الباقي', 'The rest'],
    'addTier': ['إضافة شريحة', 'Add tier'],
    'removeTier': ['حذف الشريحة', 'Remove tier'],
    'tariffSet': ['تعرفة محلية', 'Local tariff'],
    'tariffNeedsNumbers': ['أكمل أرقام الشرائح (حدّ كل شريحة وسعرها).', 'Complete the tier numbers (limit and price of each tier).'],
    'tariffNoTiers': ['أضف شريحة واحدة على الأقل.', 'Add at least one tier.'],
    'tariffBadPrice': ['السعر لا يمكن أن يكون سالبًا.', 'A price cannot be negative.'],
    'tariffBadFee': ['الرسم الثابت لا يمكن أن يكون سالبًا.', 'The fixed fee cannot be negative.'],
    'tariffBadLimit': ['حدّ الشريحة يجب أن يكون رقمًا أكبر من صفر.', 'A tier limit must be a number greater than zero.'],
    'tariffLimitsOrder': ['حدود الشرائح يجب أن تزيد من شريحة إلى التي بعدها.', 'Tier limits must increase from one tier to the next.'],
    'tariffLastOpen': ['الشريحة الأخيرة تكون «الباقي» بلا حد.', 'The last tier is "The rest", with no limit.'],
    'costEstimate': ['التكلفة التقديرية', 'Estimated cost'],
    'costNote': ['تقدير حسب التعرفة التي أدخلتها، وليس فاتورة رسمية.', 'An estimate from the tariff you entered, not an official bill.'],
    'costBasis': ['أساس الحساب', 'Basis'],
    'tiersWord': ['شرائح', 'tiers'],
    'notificationsTitle': ['التنبيهات المحلية', 'Local notifications'],
    'notificationsOn': ['مفعّلة: تنبيه عند الزيادة الملحوظة وتذكير بالقراءة', 'On: alert on a notable increase and a reading reminder'],
    'notificationsOff': ['متوقفة. يبقى جرس التطبيق يعمل داخل التطبيق.', 'Off. The in-app bell still works.'],
    'notificationsBlocked': ['غير مسموحة من النظام. فعّلها من إعدادات التطبيق في الهاتف.', 'Blocked by the system. Allow them in the phone settings for this app.'],
    'notificationsError': ['تعذّرت جدولة بعض التنبيهات. جرّب مرة أخرى لاحقًا.', 'Some notifications could not be scheduled. Try again later.'],
    'notifDueTitle': ['تحتاج قراءة', 'Reading due'],
    'notifSpikeTitle': ['زيادة ملحوظة في الاستهلاك', 'Notable increase in consumption'],
    'languageTitle': ['اللغة', 'Language'],
    'languageArabic': ['العربية', 'العربية'],
    'languageEnglish': ['English', 'English'],
    'defaultCurrency': ['ج.م', 'EGP'],
    'exportTitle': ['تصدير القراءات (CSV)', 'Export readings (CSV)'],
    'exportSubtitle': ['ملف يُشارَك أو يُفتح في جداول البيانات', 'A file you can share or open in a spreadsheet'],
    'exportNothing': ['لا توجد قراءات لتصديرها بعد.', 'There are no readings to export yet.'],
    'exportFailed': ['تعذّر إنشاء الملف أو مشاركته.', 'Could not create or share the file.'],
    'csvMeter': ['العداد', 'meter'],
    'csvUnit': ['الوحدة', 'unit'],
    'csvDate': ['التاريخ', 'date'],
    'csvTime': ['الوقت', 'time'],
    'csvReading': ['القراءة', 'reading'],
    'csvReset': ['إعادة ضبط (1 = نعم)', 'reset (1 = yes)'],
    'csvConsumption': ['استهلاك الفترة', 'period consumption'],
  };
}
