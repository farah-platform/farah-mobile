/// Formats dates the way the designs show them, e.g. "السبت، 15 أكتوبر 2026",
/// keeping Western digits.
String formatArabicDate(DateTime date) {
  const days = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];
  const months = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  return '${days[date.weekday - 1]}، ${date.day} ${months[date.month - 1]} ${date.year}';
}
