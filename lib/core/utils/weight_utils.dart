class WeightUtils {
  static const double kgToLbs = 2.20462;
  static const double lbsToKg = 0.453592;

  /// تحويل من الوحدة المُختارة إلى كيلو (للتخزين دائمًا)
  static double toKg(double value, String unit) {
    if (unit == 'lbs') return value * lbsToKg;
    return value;
  }

  /// تحويل من كيلو (المخزون) إلى الوحدة المُختارة (للعرض)
  static double fromKg(double kg, String unit) {
    if (unit == 'lbs') return kg * kgToLbs;
    return kg;
  }

  /// تنسيق للعرض: يُظهر عدد صحيح إذا لم يوجد كسر
  static String format(double value, String unit) {
    final converted = fromKg(value, unit);
    final formatted = converted == converted.truncateToDouble()
        ? converted.toStringAsFixed(0)
        : converted.toStringAsFixed(1);
    return '$formatted $unit';
  }
}
