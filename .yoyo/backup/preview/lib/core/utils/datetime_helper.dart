import 'package:easy_localization/easy_localization.dart';

class DateTimeHelper {
  static String formatTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('h:mm a').format(dateTime);
  }

  static String formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('M/d/yy').format(dateTime);
  }
}
