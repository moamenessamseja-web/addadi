/// All user-visible Arabic text in one place (README + design foundation wording).
class S {
  const S._();

  static const appName = 'عَدّادي';
  static const promise = 'اعرف استهلاكك قبل وصول الفاتورة.';

  static const tabMeters = 'العدادات';
  static const tabAddReading = 'إضافة قراءة';
  static const tabAnalytics = 'التحليل';

  static const myMeters = 'عداداتي';
  static const addMeter = 'إضافة عداد';
  static const noMetersTitle = 'لم تضف أي عداد بعد';
  static const noMetersBody = 'أضف عدادك الأول (كهرباء أو مياه أو غاز) ثم سجّل قراءاته. كل بياناتك تبقى على هذا الجهاز.';

  static const overview = 'نظرة عامة';
  static const metersCount = 'عدادات';
  static const needAttention = 'تحتاج انتباهًا';

  static const noReadingYet = 'لم تُسجل قراءة';
  static const due = 'تحتاج قراءة';
  static const stable = 'مستقر';
  static const spike = 'زيادة ملحوظة';
  static const insufficientHistory = 'يلزم تسجيل قراءة أخرى للمقارنة';
  static const resetMarker = 'تم تسجيل إعادة ضبط أو استبدال — لا تتم المقارنة عبر هذا الحد';

  static const latestReading = 'آخر قراءة';
  static const periodConsumption = 'استهلاك الفترة';
  static const comparedWithPrevious = 'مقارنة بالفترة السابقة';
  static const addReadingAction = 'إضافة قراءة';
  static const analyticsAction = 'التحليل';

  static const bellTooltip = 'التنبيهات';
  static const noAlerts = 'لا توجد تنبيهات حاليًا';
  static const alertsTitle = 'التنبيهات';

  // Add reading
  static const chooseMeter = 'اختر العداد';
  static const previousReading = 'القراءة السابقة';
  static const noPreviousReading = 'لا توجد قراءة سابقة لهذا العداد';
  static const newReading = 'القراءة الجديدة';
  static const readingDateTime = 'تاريخ ووقت القراءة';
  static const resetToggle = 'إعادة ضبط أو استبدال العداد';
  static const resetHelper = 'فعّلها إذا تم تغيير العداد أو إعادة تصفيره أو تجاوز سعته. تُحفظ القراءات القديمة ولا تُحسب فترة استهلاك عبر هذا الحد.';
  static const resetConfirmTitle = 'تأكيد إعادة الضبط';
  static const resetConfirmBody = 'ستبدأ هذه القراءة سجلًا جديدًا للمقارنة، ولن يُحسب استهلاك بينها وبين القراءة السابقة. هل تريد المتابعة؟';
  static const calculation = 'الاستهلاك المحسوب';
  static const noCalculation = 'لا يوجد استهلاك محسوب بعد';
  static const save = 'حفظ القراءة';
  static const savedOnDevice = 'تم حفظ القراءة على هذا الجهاز';
  static const saveFailed = 'تعذّر الحفظ على هذا الجهاز. لم تُحفظ القراءة.';
  static const cancel = 'إلغاء';
  static const confirm = 'متابعة';
  static const addMeterFirst = 'أضف عدادًا أولًا من تبويب العدادات.';
  static const spikeDetected = 'زيادة ملحوظة مقارنة بالفترة السابقة. هذا تنبيه للمراجعة وليس تشخيصًا للسبب.';

  static const problemInvalid = 'أدخل قراءة صحيحة (أرقام فقط، بدون سالب).';
  static const problemOlder = 'تاريخ القراءة أقدم من آخر قراءة مسجلة لهذا العداد.';
  static const problemLower = 'القراءة أقل من القراءة السابقة. إن تم تغيير العداد أو تجاوز سعته فعّل «إعادة ضبط أو استبدال العداد».';

  // Add meter
  static const meterType = 'نوع العداد';
  static const place = 'المكان (مثل: الشقة، المحل)';
  static const unit = 'وحدة القياس';
  static const addMeterTitle = 'عداد جديد';

  // Analytics
  static const selectMeter = 'اختر عدادًا';
  static const currentComparison = 'مقارنة الفترة الحالية';
  static const currentPeriod = 'الفترة الحالية';
  static const previousPeriod = 'الفترة السابقة';
  static const absoluteVariance = 'الفرق';
  static const monthlyChart = 'الاستهلاك لكل فترة قراءة';
  static const chartNote = 'نقاط مقاسة فقط، دون تقدير للقراءات الناقصة.';
  static const burnRate = 'متوسط الاستهلاك اليومي';
  static const perDay = 'في اليوم';
  static const notEnoughHistory = 'لا توجد بيانات كافية للرسم بعد. سجّل قراءتين على الأقل بعد آخر إعادة ضبط.';
  static const noMeterSelected = 'أضف عدادًا لعرض التحليل.';

  // Drawer
  static const manageMeters = 'إدارة العدادات والأماكن';
  static const alertThreshold = 'حد تنبيه الزيادة';
  static const theme = 'المظهر';
  static const themeSystem = 'النظام';
  static const themeLight = 'فاتح';
  static const themeDark = 'داكن';
  static const deleteMeter = 'حذف العداد';
  static const deleteConfirmTitle = 'حذف العداد؟';
  static const deleteConfirmBody = 'سيُحذف العداد وكل قراءاته من هذا الجهاز نهائيًا، ولا يمكن التراجع.';
  static const delete = 'حذف';
  static const thresholdHelper = 'يُنبَّه عند زيادة استهلاك الفترة الحالية عن السابقة بهذه النسبة أو أكثر.';
  static const close = 'إغلاق';
  static const saveSetting = 'حفظ';
  static const meterReadingsCount = 'قراءات';
  static const noMetersToManage = 'لا توجد عدادات.';

  // Notifications
  static const notificationsTitle = 'التنبيهات المحلية';
  static const notificationsOn = 'مفعّلة: تنبيه عند الزيادة الملحوظة وتذكير بالقراءة';
  static const notificationsOff = 'متوقفة. يبقى جرس التطبيق يعمل داخل التطبيق.';
  static const notificationsBlocked = 'غير مسموحة من النظام. فعّلها من إعدادات التطبيق في الهاتف.';
  static const notificationsError = 'تعذّرت جدولة بعض التنبيهات. جرّب مرة أخرى لاحقًا.';
  static const notifDueTitle = 'تحتاج قراءة';
  static const notifSpikeTitle = 'زيادة ملحوظة في الاستهلاك';
}
